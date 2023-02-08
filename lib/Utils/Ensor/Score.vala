using He.Color;
public class He.Ensor.Score {

  const double CUTOFF_CHROMA = 15.0;
  const double CUTOFF_EXCITED_PROPORTION = 0.01;
  const double CUTOFF_TONE = 10.0;
  const double TARGET_CHROMA = 48.0;
  const double WEIGHT_PROPORTION = 0.7;
  const double WEIGHT_CHROMA_ABOVE = 0.3;
  const double WEIGHT_CHROMA_BELOW = 0.1;

  public static List<int> score (HashTable<int, int> colors_to_population) {
    double population_sum = 0.0;

    foreach (var entry in colors_to_population.get_values ()) {
      population_sum += entry;
    }

    var colors_to_cam16 = new HashTable<int, CAM16Color?> (null, null);
    double[] hue_proportions = new double[361];

    foreach (var color in colors_to_population.get_keys ()) {
      double population = colors_to_population.get (color);
      double proportion = population / population_sum;

      CAM16Color cam = cam16_from_int (color);
      colors_to_cam16.set (color, cam);

      int hue = (int) Math.round (cam.h);
      hue_proportions[hue] += proportion;
    }

    var colors_to_excited_proportion = new HashTable<int?, double?> (null, null);

    foreach (var color in colors_to_cam16.get_keys ()) {
      CAM16Color cam = colors_to_cam16.get (color);
      int hue = (int) Math.round (cam.h);
      double excited_proportion = 0.0;

      for (int j = (hue - 15); j < (hue + 15); j++) {
        int neighbor_hue = sanitize_degrees_int (j);
        excited_proportion += hue_proportions[neighbor_hue];
      }

      colors_to_excited_proportion.set (color, excited_proportion);
    }

    var colors_to_score = new HashTable<int?, double?> (null, null);

    foreach (var color in colors_to_cam16.get_keys ()) {
      CAM16Color cam = colors_to_cam16.get (color);

      double proportion = colors_to_excited_proportion.get (color);
      double proportion_score = proportion * 100.0 * WEIGHT_PROPORTION;

      double chroma_weight = cam.C < TARGET_CHROMA ? WEIGHT_CHROMA_BELOW : WEIGHT_CHROMA_ABOVE;
      double chroma_score = (cam.C - TARGET_CHROMA) * chroma_weight;

      double score = proportion_score + chroma_score;
      colors_to_score.set (color, score);
    }

    List<int> filtered_colors = filter (colors_to_excited_proportion, colors_to_cam16);
    var filtered_colors_to_score = new HashTable<int, double?> (null, null);

    foreach (var color in filtered_colors) {
      filtered_colors_to_score.set (color, colors_to_score.get (color));
    }

    var entry_list = He.Misc.hash_table_to_pair_list(filtered_colors_to_score);
    entry_list.sort ((CompareFunc<He.Misc.Pair<int, double?>>) compare_filtered_colors_to_score);
    var colors_by_score_descending = new List<int>();

    foreach (var entry in entry_list) {
      int color = entry.first;
      CAM16Color cam = colors_to_cam16.get (color);
      var duplicate_hue = false;

      foreach (var already_chosen_color in colors_by_score_descending) {
        CAM16Color already_chosen_cam = colors_to_cam16.get (already_chosen_color);

        if (difference_degrees (cam.h, already_chosen_cam.h) < 15) {
          duplicate_hue = true;
          break;
        }
      }

      if (duplicate_hue) {
        continue;
      }

      colors_by_score_descending.append (entry.first);
    }

    if (colors_by_score_descending.is_empty ()) {
      colors_by_score_descending.append ((int) 0xFF8C56BF); // Tau Purple to not leave it empty
    }

    return colors_by_score_descending;
  }

  private static List<int> filter (HashTable<int, double?> colors_to_excited_proportion, HashTable<int, CAM16Color?> colors_to_cam16) {
    var filtered = new List<int> ();

    foreach (var color in colors_to_cam16.get_keys ()) {
      CAM16Color cam = colors_to_cam16.get (color);
      double proportion = colors_to_excited_proportion.get (color);

      var y = rgb_to_xyz (from_argb_int (color)).y;
      var lstar = 116.0 * lab_f(y / 100.0) - 16.0;

      if (
          cam.C >= CUTOFF_CHROMA &&
          lstar >= CUTOFF_TONE &&
          proportion >= CUTOFF_EXCITED_PROPORTION
      ) {
        filtered.append (color);
      }
    }

    return filtered;
  }

  public int compare_filtered_colors_to_score (He.Misc.Pair<int, double?> entry1, He.Misc.Pair<int, double?> entry2) {
    return -(entry1.second > entry2.second ? 1 : entry1.second < entry2.second ? -1 : 0);
  }
}
