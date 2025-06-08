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

    public class AnnotatedColor {
      public int argb;
      public double cam_hue;
      public double cam_chroma;
      public double excited_proportion;
      public double score;


      public static CompareFunc<weak AnnotatedColor> cmp = (a, b) => {
        return (int) (a.score < b.score) - (int) (a.score > b.score);
      };
    }

    public GLib.Array<int> score (HashTable<int?, int?> colors_to_population, int? desired) {
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
      GLib.GenericArray<AnnotatedColor> colors = new GLib.GenericArray<AnnotatedColor> ();

      for (int i = 0; i < input_size; i++) {
        double proportion = populations[i] / population_sum;

        CAM16Color cam = cam16_from_int (argbs[i]);

        int hue = (int) Math.floor (MathUtils.sanitize_degrees (cam.h));
        hue_proportions[hue] += proportion;

        colors.add (new AnnotatedColor () {
          argb = argbs[i],
          cam_hue = cam.h,
          cam_chroma = cam.c,
          excited_proportion = 0.0,
          score = -1.0
        });
      }

      for (int i = 0; i < input_size; i++) {
        int hue = (int) Math.floor (colors.get (i).cam_hue);
        for (int j = (hue - 14); j < (hue + 16); j++) {
          int sanitized_hue = (int) Math.floor (MathUtils.sanitize_degrees (j));
          colors.get (i).excited_proportion += hue_proportions[sanitized_hue];
        }
      }

      for (int i = 0; i < input_size; i++) {
        double proportion_score = colors.get (i).excited_proportion* 100.0 * WEIGHT_PROPORTION;
        double chroma = colors.get (i).cam_chroma;
        double chroma_weight = (chroma > TARGET_CHROMA ? WEIGHT_CHROMA_ABOVE : WEIGHT_CHROMA_BELOW);
        double chroma_score = (chroma - TARGET_CHROMA) * chroma_weight;

        colors.get (i).score = chroma_score + proportion_score;
      }

      colors.sort (AnnotatedColor.cmp);

      GLib.GenericArray<AnnotatedColor> selected_colors = new GLib.GenericArray<AnnotatedColor> ();
      for (int i = 0; i < input_size; i++) {
        if (!good_color_finder (colors.get (i))) {
          continue;
        }

        bool is_duplicate_color = false;
        for (int j = 0; j < selected_colors.length; j++) {
          if (colors_are_too_close (selected_colors.get (j), colors.get (i))) {
            is_duplicate_color = true;
            break;
          }
        }

        if (is_duplicate_color) {
          continue;
        }

        if (selected_colors.length > 4) {
          break;
        }

        selected_colors.add (colors.get (i));
      }

      if (selected_colors.length == 0) {
        selected_colors.add (new AnnotatedColor () {
          argb = TAU_PURPLE,
          cam_hue = 311.12,
          cam_chroma = 57.36,
          excited_proportion = 0.0,
          score = 0.0
        });
      }

      GLib.Array<int> return_value = new GLib.Array<int> ();

      for (int j = 0; j < selected_colors.length; j++) {
        return_value.append_val (selected_colors.get (j).argb);
        print ("#%d ENSOR ARGB RESULT: %d\n#%d ENSOR HEX RESULT: #%X\n", j, (int) return_value.index ((int) j), j, (int) return_value.index ((int) j));
      }
      return return_value;
    }

    bool good_color_finder (AnnotatedColor color) {
      return color.cam_chroma >= CUTOFF_CHROMA &&
             color.excited_proportion >= CUTOFF_EXCITED_PROPORTION;
    }

    bool colors_are_too_close (AnnotatedColor color_one, AnnotatedColor color_two) {
      return MathUtils.difference_degrees (color_one.cam_hue, color_two.cam_hue) < 15.0;
    }
  }
}