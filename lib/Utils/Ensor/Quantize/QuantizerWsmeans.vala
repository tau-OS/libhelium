// Adapted from the Java implementation of material-color-utilities licensed under the Apache License, Version 2.0
// Copyright (c) 2021 Google LLC

public class He.QuantizerWsmeans : Object {
  private QuantizerWsmeans () {}

  private class Distance : Object {
    public int index;
    public double distance;

    public Distance() {
      this.index = -1;
      this.distance = -1;
    }

    public int compare_to(Distance other) {
      return this.distance > other.distance ? 1 : this.distance < other.distance ? -1 : 0;
    }
  }

  private const int MAX_ITERATIONS = 10;
  private const double MIN_MOVEMENT_DISTANCE = 3.0;

  public static GLib.HashTable<int,int> quantize (int[] input_pixels, int[] starting_clusters, int max_colors) {
    // Uses a seeded random number generator to ensure consistent results.
    var random = new Rand.with_seed(0x42688);

    var pixel_to_count = new HashTable<int?, int?> (int_hash, int_equal);
    var points = new List<double?>[input_pixels.length];
    int[] pixels = new int[input_pixels.length];
    PointProviderLab point_provider = new PointProviderLab ();

    int point_count = 0;
    for (int i = 0; i < input_pixels.length; i++) {
      int input_pixel = input_pixels[i];
      var pixel_count = pixel_to_count.get (input_pixel);
      if (pixel_count == null) {
        var point = new List<double?> ();
        foreach (var value in point_provider.from_int (input_pixel)) {
          point.append (value);
        }

        points[point_count] = point.copy_deep ((a) => a);
        pixels[point_count] = input_pixel;
        point_count++;

        pixel_to_count.set (input_pixel, 1);
      } else {
        pixel_to_count.set (input_pixel, pixel_count + 1);
      }
    }

    int[] counts = new int[point_count];
    for (int i = 0; i < point_count; i++) {
      int pixel = pixels[i];
      int count = pixel_to_count.get (pixel);
      counts[i] = count;
    }

    int cluster_count = (int) Math.fmin (max_colors, point_count);
    if (starting_clusters.length != 0) {
      cluster_count = (int) Math.fmin (cluster_count, starting_clusters.length);
    }

    var clusters = new List<double?>[cluster_count];
    int clusters_created = 0;
    for (int i = 0; i < starting_clusters.length; i++) {
      var cluster = new List<double?> ();
      foreach (var value in point_provider.from_int (starting_clusters[i])) {
        cluster.append (value);
      }

      clusters[i] = cluster.copy_deep ((a) => a);
      clusters_created++;
    }

    int additional_clusters_needed = cluster_count - clusters_created;
    if (additional_clusters_needed > 0) {
      for (int i = 0; i < additional_clusters_needed; i++) {}
    }

    int[] cluster_indices = new int[point_count];
    for (int i = 0; i < point_count; i++) {
      cluster_indices[i] = random.int_range (0, cluster_count);
    }

    int[,] index_matrix = new int[cluster_count,cluster_count];

    List<Distance?>[] distance_to_index_matrix = new List<Distance?>[cluster_count];
    for (int i = 0; i < cluster_count; i++) {
      distance_to_index_matrix[i] = new List<Distance?> ();

      for (int j = 0; j < cluster_count; j++) {
        distance_to_index_matrix[i].append (new Distance ());
      }
    }

    int[] pixel_count_sums = new int[cluster_count];
    for (int iteration = 0; iteration < MAX_ITERATIONS; iteration++) {
      for (int i = 0; i < cluster_count; i++) {
        for (int j = i + 1; j < cluster_count; j++) {
          var a = new double[clusters[i].length ()];
          var b = new double[clusters[j].length ()];

          for (int k = 0; k < clusters[i].length (); k++) {
            a[k] = clusters[i].nth_data (k);
          }

          for (int k = 0; k < clusters[j].length (); k++) {
            b[k] = clusters[j].nth_data (k);
          }

          double distance = point_provider.distance (a, b);
          distance_to_index_matrix[j].nth_data (i).distance = distance;
          distance_to_index_matrix[j].nth_data (i).index = i;
          distance_to_index_matrix[i].nth_data (j).distance = distance;
          distance_to_index_matrix[i].nth_data (j).index = j;
        }

        distance_to_index_matrix[i].sort((a, b) => a.compare_to (b));
        for (int j = 0; j < cluster_count; j++) {
          index_matrix[i,j] = distance_to_index_matrix[i].nth_data (j).index;
        }
      }

      int points_moved = 0;
      for (int i = 0; i < point_count; i++) {
        double[] point = new double[points[i].length ()];

        for (int j = 0; j < points[i].length (); j++) {
          point[j] = points[i].nth (j).data;
        }

        int previous_cluster_index = cluster_indices[i];
        double[] previous_cluster = new double[clusters[previous_cluster_index].length ()];
        for (int j = 0; j < clusters[previous_cluster_index].length (); j++) {
          previous_cluster[j] = clusters[previous_cluster_index].nth (j).data;
        }
        double previous_distance = point_provider.distance (point, previous_cluster);

        double minimum_distance = previous_distance;
        int new_cluster_index = -1;
        for (int j = 0; j < cluster_count; j++) {
          if (distance_to_index_matrix[previous_cluster_index].nth_data (j).distance >= 4 * previous_distance) {
            continue;
          }

          double[] cluster = new double[clusters[j].length ()];
          for (int k = 0; k < clusters[j].length (); k++) {
            cluster[k] = clusters[j].nth (k).data;
          }

          double distance = point_provider.distance (point, cluster);
          if (distance < minimum_distance) {
            minimum_distance = distance;
            new_cluster_index = j;
          }
        }
        if (new_cluster_index != -1) {
          double distance_change = Math.fabs (Math.sqrt (minimum_distance) - Math.sqrt (previous_distance));
          if (distance_change > MIN_MOVEMENT_DISTANCE) {
            points_moved++;
            cluster_indices[i] = new_cluster_index;
          }
        }
      }

      if (points_moved == 0 && iteration != 0) {
        break;
      }

      double[] component_a_sums = new double[cluster_count];
      double[] component_b_sums = new double[cluster_count];
      double[] component_c_sums = new double[cluster_count];

      for (int i = 0; i < cluster_count; i++) {
        pixel_count_sums[i] = 0;
      }

      for (int i = 0; i < point_count; i++) {
        int cluster_index = cluster_indices[i];
        double[] point = new double[points[i].length ()];
        for (int j = 0; j < points[i].length (); j++) {
          point[j] = points[i].nth (j).data;
        }
        int count = counts[i];
        pixel_count_sums[cluster_index] += count;
        component_a_sums[cluster_index] += (point[0] * count);
        component_b_sums[cluster_index] += (point[1] * count);
        component_c_sums[cluster_index] += (point[2] * count);
      }

      for (int i = 0; i < cluster_count; i++) {
        int count = pixel_count_sums[i];
        if (count == 0) {
          var cluster = new List<double?> ();
          cluster.append (0.0);
          cluster.append (0.0);
          cluster.append (0.0);

          clusters[i] = cluster.copy_deep ((a) => a);
          continue;
        }
        double a = component_a_sums[i] / count;
        double b = component_b_sums[i] / count;
        double c = component_c_sums[i] / count;
        clusters[i].insert (a, 0);
        clusters[i].insert (b, 1);
        clusters[i].insert (c, 2);
      }
    }

    var argb_to_population = new HashTable<int?, int?>(int_hash, int_equal);
    for (int i = 0; i < cluster_count; i++) {
      int count = pixel_count_sums[i];
      if (count == 0) {
        continue;
      }

      double[] cluster = new double[clusters[i].length ()];

      for (int j = 0; j < clusters[i].length (); j++) {
        cluster[j] = clusters[i].nth (j).data;
      }

      int possible_new_cluster = point_provider.to_int (cluster);
      if (argb_to_population.contains (possible_new_cluster)) {
        continue;
      }

      argb_to_population.set (possible_new_cluster, count);
    }

    return argb_to_population;
  }
}
