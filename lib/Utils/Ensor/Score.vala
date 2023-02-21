// Adapted from the Java implementation of material-color-utilities licensed under the Apache License, Version 2.0
// Copyright (c) 2021 Google LLC

namespace He {
  public class Score {

    const double CUTOFF_CHROMA = 15.0;
    const double CUTOFF_EXCITED_PROPORTION = 0.01;
    const double CUTOFF_TONE = 10.0;
    const double TARGET_CHROMA = 48.0;
    const double WEIGHT_CHROMA_ABOVE = 0.3;
    const double WEIGHT_CHROMA_BELOW = 0.1;
    const double WEIGHT_PROPORTION = 0.7;

    public struct AnnotatedColor {
      public int argb;
      public double cam_hue;
      public double cam_chroma;
      public double excited_proportion;
      public double score;
    }

    public GLib.List<AnnotatedColor?> score (HashTable<int, int?> colors_to_population) {
      double population_sum = 0.0;
      int input_size = 127; // The amount of colors previously quantized (index starts at 0)

      int argbs[127] = {0};
      //  var argbs = new int[input_size];
      //  var populations = new int[input_size];
      int populations[127] = {0};

      foreach (var key in colors_to_population.get_keys ()) {
        foreach (var val in colors_to_population.get_values ()) {
          for (int i = 0; i < input_size; i++) {
            argbs[i] = key;
            populations[i] = val;
          }
        }
      }

      for (int i = 0; i < input_size; i++) {
        population_sum += populations[i];
      }

      double[] hue_proportions = new double[361];
      GLib.List<AnnotatedColor?> colors = new GLib.List<AnnotatedColor> ();

      for (int i = 0; i < input_size; i++) {
        double proportion = populations[i] / population_sum;

        He.Color.CAM16Color cam = He.Color.cam16_from_int (argbs[i]);

        int hue = (int)He.MathUtils.sanitize_degrees (Math.round (cam.h));
        hue_proportions[hue] += proportion;

        colors.insert ({argbs[i], cam.h, cam.C, 0, -1}, argbs[i]);
      }

      for (int i = 0; i < input_size; i++) {
        int hue = (int)Math.round (colors.nth_data (i).cam_hue);
        for (int j = (hue - 15); j < (hue + 15); j++) {
          int sanitized_hue = (int)He.MathUtils.sanitize_degrees (j);
          colors.nth_data (i).excited_proportion += hue_proportions[sanitized_hue];
        }
      }

      for (int i = 0; i < input_size; i++) {
        double proportion_score = colors.nth_data (i).excited_proportion * 100.0 * WEIGHT_PROPORTION;
        double chroma = colors.nth_data (i).cam_chroma;
        double chroma_weight = (chroma > TARGET_CHROMA ? WEIGHT_CHROMA_ABOVE : WEIGHT_CHROMA_BELOW);
        double chroma_score = (chroma - TARGET_CHROMA) * chroma_weight;

        colors.nth_data (i).score = chroma_score + proportion_score;
      }

      for (int i = 0; i < input_size; i++) {
        argb_color_sort (colors.nth_data (i + 1), colors.nth_data (input_size - i));
      }

      GLib.List<AnnotatedColor?> selected_colors = new GLib.List<AnnotatedColor> ();
      for (int i = 0; i < input_size; i++) {
        if (!good_color_finder (colors.nth_data (i))) {
          continue;
        }

        selected_colors.insert (colors.nth_data (i), i);

        bool is_duplicate_color = false;
        if (colors_close_finder (selected_colors.nth_data (i).cam_hue, colors.nth_data (i).cam_hue)) {
          is_duplicate_color = true;
          break;
        }

        if (is_duplicate_color) {
          continue;
        }
      }

      if (selected_colors.is_empty ()) {
        selected_colors.insert ({int.parse ("#FF8C56BF"), 311.12, 57.36, 0.0, 0.0}, 0);
      }

      print ("FIRST SCORED RESULT: %s\n", Color.hexcode_argb(selected_colors.nth_data (0).argb));

      return selected_colors;
    }

    bool good_color_finder (AnnotatedColor color) {
      return color.cam_chroma >= CUTOFF_CHROMA &&
             He.MathUtils.lstar_from_argb (color.argb) >= CUTOFF_TONE &&
             color.excited_proportion >= CUTOFF_EXCITED_PROPORTION;
    }

    bool colors_close_finder (double hue_one, double hue_two) {
      return MathUtils.difference_degrees (hue_one, hue_two) < 15;
    }

    bool argb_color_sort (AnnotatedColor a, AnnotatedColor b) {
      return a.score > b.score;
    }
  }
}
