// Adapted from the C++ implementation of material-color-utilities licensed under the Apache License, Version 2.0
// Copyright (c) 2021 Google LLC

public class He.QuantizerWsmeans : Object {
  private QuantizerWsmeans () {}

  private const int RAND_MAX = 32767;
  private const int MAX_ITERATIONS = 1;
  private const double MIN_MOVEMENT_DISTANCE = 3.0;

  public static GLib.HashTable<int?, int?> quantize (int[] input_pixels, int[] starting_clusters, int max_colors) {
    // Early exit for empty input
    if (input_pixels.length == 0) {
      return new GLib.HashTable<int?, int?> (int_hash, int_equal);
    }

    // Build pixel count map and unique pixel list using primitive arrays
    // Use a simple hash-based deduplication
    var pixel_to_count = new GLib.HashTable<int?, int?> (int_hash, int_equal);

    // First pass: count pixels
    foreach (var pixel in input_pixels) {
      var count = pixel_to_count.lookup (pixel);
      if (count != null) {
        pixel_to_count.insert (pixel, count + 1);
      } else {
        pixel_to_count.insert (pixel, 1);
      }
    }

    // Extract unique pixels into arrays
    uint unique_count = pixel_to_count.size ();
    if (unique_count == 0) {
      return new GLib.HashTable<int?, int?> (int_hash, int_equal);
    }

    int[] pixels = new int[unique_count];
    int[] pixel_counts = new int[unique_count];
    LABColor[] points = new LABColor[unique_count];

    uint idx = 0;
    foreach (var key in pixel_to_count.get_keys ()) {
      pixels[idx] = key;
      pixel_counts[idx] = pixel_to_count.lookup (key);
      points[idx] = lab_from_argb (key);
      idx++;
    }

    int point_count = (int) unique_count;
    int cluster_count = (int) MathUtils.min (max_colors, point_count);

    if (starting_clusters.length != 0) {
      cluster_count = (int) MathUtils.min (cluster_count, starting_clusters.length);
    }

    // Pre-allocate cluster arrays
    LABColor[] clusters = new LABColor[cluster_count];
    int[] cluster_indices = new int[point_count];
    int[] pixel_count_sums = new int[cluster_count];

    // Initialize clusters from starting clusters
    int clusters_from_starting = int.min (cluster_count, starting_clusters.length);
    for (int i = 0; i < clusters_from_starting; i++) {
      clusters[i] = lab_from_argb (starting_clusters[i]);
    }

    // Add random clusters if needed
    var random = new Rand.with_seed (42688);
    int additional_clusters_needed = cluster_count - clusters_from_starting;
    for (int i = 0; i < additional_clusters_needed; i++) {
      double l = random.next_int () / (double) RAND_MAX * 100.0;
      double a = random.next_int () / (double) RAND_MAX * 200.0 - 100.0;
      double b = random.next_int () / (double) RAND_MAX * 200.0 - 100.0;
      clusters[clusters_from_starting + i] = { l, a, b };
    }

    // Initialize cluster indices randomly
    random = new Rand.with_seed (42688);
    for (int i = 0; i < point_count; i++) {
      cluster_indices[i] = random.int_range (0, cluster_count);
    }

    // Pre-allocate distance matrix (flattened 2D array for cache efficiency)
    double[] cluster_distances = new double[cluster_count * cluster_count];

    for (int iteration = 0; iteration < MAX_ITERATIONS; iteration++) {
      // Calculate cluster-to-cluster distances (symmetric, so only compute upper triangle)
      for (int i = 0; i < cluster_count; i++) {
        cluster_distances[i * cluster_count + i] = 0.0;
        for (int j = i + 1; j < cluster_count; j++) {
          double dist = clusters[i].distance (clusters[j]);
          cluster_distances[i * cluster_count + j] = dist;
          cluster_distances[j * cluster_count + i] = dist;
        }
      }

      bool color_moved = false;

      // Assign points to nearest cluster
      for (int i = 0; i < point_count; i++) {
        var point = points[i];
        int previous_cluster_index = cluster_indices[i];
        double previous_distance = point.distance (clusters[previous_cluster_index]);
        double minimum_distance = previous_distance;
        int new_cluster_index = -1;

        // Check all clusters for a closer one
        // Use triangle inequality optimization: skip clusters that are too far
        for (int j = 0; j < cluster_count; j++) {
          if (j == previous_cluster_index) continue;

          // Triangle inequality pruning
          double cluster_dist = cluster_distances[previous_cluster_index * cluster_count + j];
          if (cluster_dist >= 4.0 * previous_distance) {
            continue;
          }

          double distance = point.distance (clusters[j]);
          if (distance < minimum_distance) {
            minimum_distance = distance;
            new_cluster_index = j;
          }
        }

        if (new_cluster_index != -1) {
          double distance_change = Math.fabs (
            Math.sqrt (Math.fmax (0.0, minimum_distance)) -
            Math.sqrt (Math.fmax (0.0, previous_distance))
          );
          if (distance_change > MIN_MOVEMENT_DISTANCE) {
            color_moved = true;
            cluster_indices[i] = new_cluster_index;
          }
        }
      }

      if (!color_moved && iteration != 0) {
        break;
      }

      // Update cluster centers
      double[] component_l_sums = new double[cluster_count];
      double[] component_a_sums = new double[cluster_count];
      double[] component_b_sums = new double[cluster_count];

      for (int i = 0; i < cluster_count; i++) {
        pixel_count_sums[i] = 0;
        component_l_sums[i] = 0.0;
        component_a_sums[i] = 0.0;
        component_b_sums[i] = 0.0;
      }

      for (int i = 0; i < point_count; i++) {
        int cluster_index = cluster_indices[i];
        var point = points[i];
        int count = pixel_counts[i];

        pixel_count_sums[cluster_index] += count;
        component_l_sums[cluster_index] += point.l * count;
        component_a_sums[cluster_index] += point.a * count;
        component_b_sums[cluster_index] += point.b * count;
      }

      for (int i = 0; i < cluster_count; i++) {
        int count = pixel_count_sums[i];
        if (count == 0) {
          clusters[i] = { 0, 0, 0 };
        } else {
          clusters[i] = {
            component_l_sums[i] / count,
            component_a_sums[i] / count,
            component_b_sums[i] / count
          };
        }
      }
    }

    // Build result: convert cluster centers to ARGB and count populations
    var color_to_count = new GLib.HashTable<int?, int?> (int_hash, int_equal);

    // Track which ARGB values we've already seen to merge duplicates
    int[] cluster_argbs = new int[cluster_count];
    for (int i = 0; i < cluster_count; i++) {
      cluster_argbs[i] = -1; // Invalid marker
    }

    for (int i = 0; i < cluster_count; i++) {
      int count = pixel_count_sums[i];
      if (count == 0) continue;

      int argb = lab_to_argb_int (clusters[i]);

      // Check for duplicate ARGB values
      bool found_duplicate = false;
      for (int j = 0; j < i; j++) {
        if (cluster_argbs[j] == argb) {
          // Merge with existing
          var existing = color_to_count.lookup (argb);
          if (existing != null) {
            color_to_count.insert (argb, existing + count);
          }
          found_duplicate = true;
          break;
        }
      }

      if (!found_duplicate) {
        cluster_argbs[i] = argb;
        var existing = color_to_count.lookup (argb);
        if (existing != null) {
          color_to_count.insert (argb, existing + count);
        } else {
          color_to_count.insert (argb, count);
        }
      }
    }

    return color_to_count;
  }
}
