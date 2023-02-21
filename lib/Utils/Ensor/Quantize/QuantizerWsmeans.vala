// Adapted from the C++ implementation of material-color-utilities licensed under the Apache License, Version 2.0
// Copyright (c) 2021 Google LLC

public class He.QuantizerWsmeans : Object {
  private QuantizerWsmeans () {}
  class Swatch {
    public int argb = 0;
    public int population = 0;

    public Swatch(int argb, int population) {
      this.argb = argb;
      this.population = population;
    }

    public int compare_to(Swatch other) {
      return this.population > other.population ? 1 : this.population < other.population ? -1 : 0;
    }
  }

  class DistanceToIndex {
    public double distance = 0.0;
    public int index = 0;

    public int compare_to(DistanceToIndex other) {
      return this.distance > other.distance ? 1 : this.distance < other.distance ? -1 : 0;
    }
  }

  delegate T fill_list_delegate<T> (int index);

  static void fill_list<T>(List<T> list, int size, fill_list_delegate<T> value_func) {
    for (int i = 0; i < size; i++) {
      list.append (value_func(i));
    }
  }

  static List<List<T>> create_2d_list<T>(int first_size, int second_size, fill_list_delegate<T> value_func) {
    var list = new List<List<T>> ();

    for (int i = 0; i < first_size; i++) {
      var sublist = new List<T> ();
      fill_list (sublist, second_size, value_func);
      list.append ((owned) sublist);
    }

    return list;
  }

  private const int RAND_MAX = 2^32-1;
  private const int MAX_ITERATIONS = 100;
  private const double MIN_MOVEMENT_DISTANCE = 3.0;

  public static GLib.HashTable<int, int?> quantize (int[] input_pixels, int[] starting_clusters, int max_colors) {
    var pixel_to_count = new GLib.HashTable<int, int?> (null, null);

    // Maybe this needs to be uint? See Google's CPP implementation.
    var pixels = new GLib.List<int?> ();
    var points = new GLib.List<Color.LABColor?> ();

    foreach (var pixel in input_pixels) {
      var count = pixel_to_count.lookup (pixel);

      if (count != null) {
        pixel_to_count.insert (pixel, count + 1);
      } else {
          pixels.append(pixel);
          points.append(Color.rgb_to_lab(Color.from_argb_int (pixel)));
          pixel_to_count.insert(pixel, 1);
      }
    }

    int cluster_count = (int) Math.fmin (max_colors, points.length ());

    if (starting_clusters.length == 0) {
      cluster_count = (int) Math.fmin (cluster_count, starting_clusters.length);
    }

    var pixel_count_sums = new int[256];
    var clusters = new GLib.List<Color.LABColor?> ();

    foreach (var argb in starting_clusters) {
      clusters.append(Color.rgb_to_lab(Color.from_argb_int (argb)));
    }

    var random = new Rand.with_seed (42688);
    var additional_clusters_needed = cluster_count - (int) clusters.length ();
    if (starting_clusters.length == 0 && additional_clusters_needed > 0) {
      for (int i = 0; i < additional_clusters_needed; i++) {
        // Adds a random Lab color to clusters.
        double l = random.next_int () / (double) RAND_MAX * (100.0) + 0.0;
        double a = random.next_int () / (double) RAND_MAX * (100.0 - -100.0) - 100.0;
        double b = random.next_int () / (double) RAND_MAX * (100.0 - -100.0) - 100.0;
        clusters.append({l, a, b});
      }
    }

    var cluster_indices = new GLib.List<int> ();

    random = new Rand.with_seed (42688);

    for (var i = 0; i < points.length (); i++) {
      cluster_indices.append((int) random.next_int () % cluster_count);
    }

    var index_matrix = new int[cluster_count, cluster_count];
    var distance_to_index_matrix = create_2d_list<DistanceToIndex>(cluster_count, cluster_count, (i) => new DistanceToIndex ());

    for (int iteration = 0; iteration < MAX_ITERATIONS; iteration++) {
      // Calculate cluster distances
      for (int i = 0; i < cluster_count; i++) {
        distance_to_index_matrix.nth_data(i).nth_data(i).distance = 0;
        distance_to_index_matrix.nth_data(i).nth_data(i).index = i;
        for (int j = i + 1; j < cluster_count; j++) {
          double distance = Color.lab_distance(clusters.nth_data(i), clusters.nth_data(j));

          distance_to_index_matrix.nth_data(j).nth_data(i).distance = distance;
          distance_to_index_matrix.nth_data(j).nth_data(i).index = i;
          distance_to_index_matrix.nth_data(i).nth_data(j).distance = distance;
          distance_to_index_matrix.nth_data(i).nth_data(j).index = j;
        }

        unowned var row = distance_to_index_matrix.nth_data(i);
        row.sort((a, b) => a.compare_to(b));

        for (int j = 0; j < cluster_count; j++) {
          index_matrix[i, j] = row.nth_data(j).index;
        }
      }

      var color_moved = false;
      for (var i = 0; i < points.length(); i++) {
        var point = points.nth_data(i);

        var previous_cluster_index = cluster_indices.nth_data(i);
        var previous_cluster = clusters.nth_data(previous_cluster_index);
        var previous_distance = Color.lab_distance(point, previous_cluster);
        double minimum_distance = previous_distance;
        int new_cluster_index = -1;

        for (int j = 0; j < cluster_count; j++) {
          if (distance_to_index_matrix.nth_data(previous_cluster_index).nth_data(j).distance >=
              4 * previous_distance) {
            continue;
          }
          double distance = Color.lab_distance(point, clusters.nth_data(j));
          if (distance < minimum_distance) {
            minimum_distance = distance;
            new_cluster_index = j;
          }
        }
        if (new_cluster_index != -1) {
          double distanceChange =
            Math.fabs(Math.sqrt(minimum_distance) - Math.sqrt(previous_distance));
          if (distanceChange > MIN_MOVEMENT_DISTANCE) {
            color_moved = true;
            cluster_indices.insert(new_cluster_index, i);
          }
        }
      }

      if (!color_moved && (iteration != 0)) {
        break;
      }

      var component_a_sums = new double[256];
      var component_b_sums = new double[256];
      var component_c_sums = new double[256];
      for (int i = 0; i < cluster_count; i++) {
        pixel_count_sums[i] = 0;
      }

      for (var i = 0; i < points.length(); i++) {
        int clusterIndex = cluster_indices.nth_data(i);
        var point = points.nth_data(i);
        int count = pixel_to_count[pixels.nth_data(i)];

        pixel_count_sums[clusterIndex] += count;
        component_a_sums[clusterIndex] += (point.l * count);
        component_b_sums[clusterIndex] += (point.a * count);
        component_c_sums[clusterIndex] += (point.b * count);
      }

      for (int i = 0; i < cluster_count; i++) {
        int count = pixel_count_sums[i];
        if (count == 0) {
          clusters.insert({0, 0, 0}, i);
          continue;
        }
        double a = component_a_sums[i] / count;
        double b = component_b_sums[i] / count;
        double c = component_c_sums[i] / count;
        clusters.insert({a, b, c}, i);
      }
    }

    var swatches = new GLib.List<Swatch> ();
    var cluster_argbs = new GLib.List<int> ();

    for (int i = 0; i < cluster_count; i++) {
      int count = pixel_count_sums[i];
      if (count == 0) {
        continue;
      }
      var possible_new_cluster = Color.rgb_to_argb_int (Color.lab_to_rgb((clusters.nth_data(i))));
      int use_new_cluster = 1;
      for (var j = 0; j < swatches.length(); j++) {
        if (swatches.nth_data(j).argb == possible_new_cluster) {
          swatches.nth_data(j).population += count;
          use_new_cluster = 0;
          break;
        }
      }

      if (use_new_cluster == 0) {
        continue;
      }
      cluster_argbs.append(possible_new_cluster);
      swatches.append(new Swatch(possible_new_cluster, count));
    }

    swatches.sort((a, b) => a.compare_to(b));

    var color_to_count = new GLib.HashTable<int, int> (null, null);
    for (var i = 0; i < swatches.length(); i++) {
      color_to_count[swatches.nth_data(i).argb] = swatches.nth_data(i).population;
    }

    //  var input_pixel_to_cluster_pixel = new GLib.HashTable<int, int> (null, null);
    //  for (var i = 0; i < points.length(); i++) {
    //    int pixel = pixels.nth_data(i);
    //    int cluster_index = cluster_indices.nth_data(i);
    //    int cluster_argb = cluster_argbs.nth_data(cluster_index);
    //    input_pixel_to_cluster_pixel[pixel] = cluster_argb;
    //  }

    return color_to_count;
  }
}
