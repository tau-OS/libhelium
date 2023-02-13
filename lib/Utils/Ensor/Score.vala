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

    public async List<int> score (HashTable<int, int?> colors_to_population) {
      double population_sum = 0.0;

      foreach (var entry in colors_to_population.get_values ()) {
        population_sum += entry;
      }

      var colors_to_cam16 = new HashTable<int, He.Color.CAM16Color?> (null, null);
      double[] hue_proportions = new double[361];

      foreach (var color in colors_to_population.get_keys ()) {
        double population = colors_to_population.get (color);
        double proportion = population / population_sum;

        He.Color.CAM16Color cam = He.Color.cam16_from_int (color);
        colors_to_cam16.insert (color, cam);

        int hue = (int) Math.round (cam.h);
        hue_proportions[hue] += proportion;
      }

      var colors_to_excited_proportion = new HashTable<int, double?> (null, null);

      foreach (var color in colors_to_cam16.get_keys ()) {
        He.Color.CAM16Color cam = colors_to_cam16.get (color);
        int hue = (int) Math.round (cam.h);
        double excited_proportion = 0.0;

        for (int j = (hue - 15); j < (hue + 15); j++) {
          int neighbor_hue = He.MathUtils.sanitize_degrees_int (j);
          excited_proportion += hue_proportions[neighbor_hue];
        }

        colors_to_excited_proportion.insert (color, excited_proportion);
      }

      var colors_to_score = new HashTable<int, double?> (null, null);

      foreach (var color in colors_to_cam16.get_keys ()) {
        He.Color.CAM16Color cam = colors_to_cam16.get (color);

        foreach (var proportion in colors_to_excited_proportion.get_values ()) {
          double proportion_score = proportion * 70.0;

          double chroma_weight = cam.C < TARGET_CHROMA ? WEIGHT_CHROMA_BELOW : WEIGHT_CHROMA_ABOVE;
          double chroma_score = (cam.C - TARGET_CHROMA) * chroma_weight;

          double score = proportion_score + chroma_score;
          colors_to_score.insert (color, score);
        }
      }

      List<int> filtered_colors = filter (colors_to_excited_proportion, colors_to_cam16);
      var filtered_colors_to_score = new HashTable<int, double?> (null, null);

      foreach (var color in filtered_colors) {
        filtered_colors_to_score.insert (color, colors_to_score.get (color));
      }

      filtered_colors_to_score.get_keys ().sort ((GLib.CompareFunc<int>) compare_filtered_colors_to_score);
      var colors_by_score_descending = new List<int> ();

      foreach (var k in filtered_colors_to_score.get_keys ()) {
        foreach (var color in colors_to_cam16.get_keys ()) {
          He.Color.CAM16Color cam = colors_to_cam16.get (color);
          var duplicate_hue = false;

          foreach (var already_chosen_color in colors_by_score_descending) {
            He.Color.CAM16Color already_chosen_cam = colors_to_cam16.get (color);

            if (He.MathUtils.difference_degrees (cam.h, already_chosen_cam.h) < 15) {
              duplicate_hue = true;
              continue;
            }
          }

          if (duplicate_hue) {
            continue;
          }

          print ("Filtered CAM16 Color: C: %f / h: %f\n", cam.C, cam.h);

          colors_by_score_descending.prepend (k);
        }
      }

      if (colors_by_score_descending.is_empty ()) {
        colors_by_score_descending.prepend ((int) 0xFF8C56BF); // Tau Purple to not leave it empty
      }

      yield colors_by_score_descending;
    }

    private static List<int> filter (HashTable<int, double?> colors_to_excited_proportion,
                                     HashTable<int, He.Color.CAM16Color?> colors_to_cam16) {
      var filtered = new List<int?> ();

      foreach (var entry in colors_to_cam16.get_keys ()) {
        foreach (var cam in colors_to_cam16.get_values ()) {
          double proportion = colors_to_excited_proportion.get (entry);

          if (
              cam.C >= CUTOFF_CHROMA &&
              He.MathUtils.lstar_from_argb (entry) >= CUTOFF_TONE &&
              proportion >= CUTOFF_EXCITED_PROPORTION
          ) {
            filtered.append (entry);
          }
        }
      }

      return filtered;
    }

    public static int compare_filtered_colors_to_score (int a, int b) {
      return He.Misc.Comparable.compare_to (a, b);
    }
  }
}
