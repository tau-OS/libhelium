// Adapted from the Java implementation of material-color-utilities licensed under the Apache License, Version 2.0
// Copyright (c) 2021 Google LLC

namespace He {
  public class Score {

    const double TARGET_CHROMA = 48.0;
    const double WEIGHT_PROPORTION = 0.7;
    const double WEIGHT_CHROMA_ABOVE = 0.3;
    const double WEIGHT_CHROMA_BELOW = 0.1;
    const double CUTOFF_CHROMA = 5.0;
    const double CUTOFF_EXCITED_PROPORTION = 0.01;
    const int TAU_PURPLE = 0x8C56BF;

    // Pre-computed tau purple CAM16 values
    const double TAU_PURPLE_HUE = 311.12;
    const double TAU_PURPLE_CHROMA = 57.36;

    public GLib.Array<int> score (HashTable<int?, int?> colors_to_population, int? desired) {
      uint input_size = colors_to_population.size ();

      // Handle nullable desired parameter
      int desired_count = (desired != null) ? desired : 4;

      // Early exit for empty input
      if (input_size == 0) {
        var return_value = new GLib.Array<int> ();
        int fallback = TAU_PURPLE;
        return_value.append_val (fallback);
        return return_value;
      }

      // Use primitive arrays for better performance
      int[] argbs = new int[input_size];
      int[] populations = new int[input_size];
      double[] cam_hues = new double[input_size];
      double[] cam_chromas = new double[input_size];
      double[] excited_proportions = new double[input_size];
      double[] scores = new double[input_size];

      // Calculate total population
      double population_sum = 0.0;
      uint idx = 0;

      foreach (var key in colors_to_population.get_keys ()) {
        var val = colors_to_population.lookup (key);
        argbs[idx] = key;
        populations[idx] = val;
        population_sum += val;
        idx++;
      }

      // Protect against division by zero
      if (population_sum < 1e-10) {
        population_sum = 1.0;
      }

      // Pre-compute hue proportions array
      double[] hue_proportions = new double[361];

      // Convert colors to CAM16 and calculate hue proportions
      for (uint i = 0; i < input_size; i++) {
        double proportion = populations[i] / population_sum;

        // CAM16 conversion - this is the expensive operation, only done once per color
        CAM16Color cam = cam16_from_int (argbs[i]);

        cam_hues[i] = cam.h;
        cam_chromas[i] = cam.c;
        excited_proportions[i] = 0.0;
        scores[i] = -1.0;

        int hue = (int) Math.floor (MathUtils.sanitize_degrees (cam.h));
        if (hue >= 0 && hue < 361) {
          hue_proportions[hue] += proportion;
        }
      }

      // Calculate excited proportions for each color
      for (uint i = 0; i < input_size; i++) {
        int hue = (int) Math.floor (cam_hues[i]);

        // Sum proportions in hue range [hue-14, hue+15]
        for (int j = hue - 14; j < hue + 16; j++) {
          int sanitized_hue = (int) Math.floor (MathUtils.sanitize_degrees (j));
          if (sanitized_hue >= 0 && sanitized_hue < 361) {
            excited_proportions[i] += hue_proportions[sanitized_hue];
          }
        }
      }

      // Calculate scores
      for (uint i = 0; i < input_size; i++) {
        double proportion_score = excited_proportions[i] * 100.0 * WEIGHT_PROPORTION;
        double chroma = cam_chromas[i];
        double chroma_weight = (chroma > TARGET_CHROMA) ? WEIGHT_CHROMA_ABOVE : WEIGHT_CHROMA_BELOW;
        double chroma_score = (chroma - TARGET_CHROMA) * chroma_weight;
        scores[i] = chroma_score + proportion_score;
      }

      // Sort indices by score (descending) using simple selection for small arrays
      // Create index array for indirect sorting
      int[] sorted_indices = new int[input_size];
      for (uint i = 0; i < input_size; i++) {
        sorted_indices[i] = (int) i;
      }

      // Simple insertion sort - efficient for small arrays (typically < 128 colors)
      for (uint i = 1; i < input_size; i++) {
        int key_idx = sorted_indices[i];
        double key_score = scores[key_idx];
        int j = (int) i - 1;

        // Sort descending (higher scores first)
        while (j >= 0 && scores[sorted_indices[j]] < key_score) {
          sorted_indices[j + 1] = sorted_indices[j];
          j--;
        }
        sorted_indices[j + 1] = key_idx;
      }

      // Select colors that pass quality thresholds and aren't too similar
      int[] selected_argbs = new int[desired_count];
      double[] selected_hues = new double[desired_count];
      int selected_count = 0;

      for (uint i = 0; i < input_size && selected_count < desired_count; i++) {
        int idx_i = sorted_indices[i];

        // Check if color passes quality thresholds
        if (cam_chromas[idx_i] < CUTOFF_CHROMA) {
          continue;
        }
        if (excited_proportions[idx_i] < CUTOFF_EXCITED_PROPORTION) {
          continue;
        }

        // Check if color is too close to already selected colors
        bool is_duplicate = false;
        double candidate_hue = cam_hues[idx_i];

        for (int j = 0; j < selected_count; j++) {
          double hue_diff = MathUtils.difference_degrees (selected_hues[j], candidate_hue);
          if (hue_diff < 15.0) {
            is_duplicate = true;
            break;
          }
        }

        if (is_duplicate) {
          continue;
        }

        // Add to selected colors
        selected_argbs[selected_count] = argbs[idx_i];
        selected_hues[selected_count] = candidate_hue;
        selected_count++;
      }

      // If no colors were selected, use fallback
      if (selected_count == 0) {
        int fallback = TAU_PURPLE;
        selected_argbs[0] = fallback;
        selected_count = 1;
      }

      // Build return array
      GLib.Array<int> return_value = new GLib.Array<int> ();
      for (int i = 0; i < selected_count; i++) {
        return_value.append_val (selected_argbs[i]);
      }

      return return_value;
    }
  }
}
