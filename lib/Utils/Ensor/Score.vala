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

    public class AnnotatedColor {
      public int argb;
      public double cam_hue;
      public double cam_chroma;
      public double excited_proportion;
      public double score;

      public int compare_to (AnnotatedColor other) {
        return this.score > other.score ? -1 : this.score < other.score ? 1 : 0;
      }
    }

    public GLib.Array<int> score (HashTable<int?, int?> colors_to_population) {
      double population_sum = 0.0;
      uint input_size = colors_to_population.size ();

      int[] argbs = {};
      int[] populations = {};

      foreach (var key in colors_to_population.get_keys ()) {
        var val = colors_to_population.lookup (key);

        argbs += key;
        populations += val;
      }

      for (int i = 0; i < input_size; i++) {
        population_sum += populations[i];
      }

      double[] hue_proportions = new double[361];
      GLib.Array<AnnotatedColor> colors = new GLib.Array<AnnotatedColor> ();

      for (int i = 0; i < input_size; i++) {
        double proportion = populations[i] / population_sum;

        He.Color.CAM16Color cam = He.Color.cam16_from_int (argbs[i]);

        int hue = (int)He.MathUtils.sanitize_degrees (Math.round (cam.h));
        hue_proportions[hue] += proportion;

        colors.append_val (new AnnotatedColor () {
          argb = argbs[i],
          cam_hue = cam.h,
          cam_chroma = cam.C,
          excited_proportion = 0,
          score = -1
        });
      }

      for (int i = 0; i < input_size; i++) {
        int hue = (int)Math.round (colors.index (i).cam_hue);
        for (int j = (hue - 15); j < (hue + 15); j++) {
          int sanitized_hue = (int)He.MathUtils.sanitize_degrees (j);
          colors.index (i).excited_proportion += hue_proportions[sanitized_hue];
        }
      }

      for (int i = 0; i < input_size; i++) {
        double proportion_score = colors.index (i).excited_proportion * 100.0 * WEIGHT_PROPORTION;
        double chroma = colors.index (i).cam_chroma;
        double chroma_weight = (chroma > TARGET_CHROMA ? WEIGHT_CHROMA_ABOVE : WEIGHT_CHROMA_BELOW);
        double chroma_score = (chroma - TARGET_CHROMA) * chroma_weight;

        colors.index (i).score = chroma_score + proportion_score;
      }

      colors.sort ((a, b) => a.compare_to (b));

      GLib.Array<AnnotatedColor> selected_colors = new GLib.Array<AnnotatedColor> ();
      for (int i = 0; i < input_size; i++) {
        if (!good_color_finder (colors.index (i))) {
          continue;
        }

        bool is_duplicate_color = false;
        for (int j = 0; j < selected_colors.length; j++) {
          if (colors_are_too_close (selected_colors.index (j), colors.index (i))) {
            is_duplicate_color = true;
            break;
          }
        }

        if (is_duplicate_color) {
          continue;
        }

        selected_colors.append_val (colors.index (i));
      }

      if (selected_colors.length == 0) {
        selected_colors.append_val (new AnnotatedColor () {
          argb = int.parse ("#FF8C56BF"),
          cam_hue = 311.12,
          cam_chroma = 57.36,
          excited_proportion = 0,
          score = 0
        });
      }

      GLib.Array<int> return_value = new GLib.Array<int> ();

      for (int j = 0; j < selected_colors.length; j++) {
        return_value.append_val (selected_colors.index (j).argb);
      }

      print ("FIRST RESULT: %s\n", Color.hexcode_argb (return_value.index (0)));

      return return_value;
    }

    bool good_color_finder (AnnotatedColor color) {
      return color.cam_chroma >= CUTOFF_CHROMA &&
             He.MathUtils.lstar_from_argb (color.argb) >= CUTOFF_TONE &&
             color.excited_proportion >= CUTOFF_EXCITED_PROPORTION;
    }

    bool colors_are_too_close (AnnotatedColor color_one, AnnotatedColor color_two) {
      return MathUtils.difference_degrees (color_one.cam_hue, color_two.cam_hue) < 15;
    }
  }
}
