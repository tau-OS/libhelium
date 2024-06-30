namespace He.Color {
    public struct HCTColor {
        public double h;
        public double c;
        public double t;
        public int a; // Keep hexcode rep as string on the struct for easy lookup
    }

    public HCTColor from_params (double hue, double chroma, double tone) {
      HCTColor result = {hue, chroma, tone};
      return result;
    }

    // Disliked means a yellow-green that's not neutral
    public static bool disliked (He.Color.HCTColor hct) {
      bool hue_passes = Math.round (hct.h) >= 90.0 && Math.round (hct.h) <= 111.0;
      bool chroma_passes = Math.round (hct.c) > 16.0;
      bool tone_passes = Math.round (hct.t) < 65.0;

      return hue_passes && chroma_passes && tone_passes;
    }

    // If color is disliked, lighten it to make it likable.
    public static He.Color.HCTColor fix_disliked (He.Color.HCTColor hct) {
      if (disliked (hct)) {
        return He.Color.from_params (hct.h, hct.c, 70.0);
      }

      return hct;
    }

    public string hct_to_hex (double hue, double chroma, double lstar) {
        He.Color.HCTColor hct = {hue, chroma, lstar};

        // If color is mono…
        if (hct.c < 1.0001 || hct.t < 0.0001 || hct.t > 99.9999) {
            return hexcode_argb (He.MathUtils.argb_from_lstar (hct.t));
        // Else…
        } else {
          hue = He.MathUtils.sanitize_degrees (hct.h);
          double hr = hue / 180 * Math.PI;
          double y = He.MathUtils.y_from_lstar (hct.t);
          int exact_answer = find_result_by_j (hr, hct.c, y);

          if (exact_answer != 0) {
            return hexcode_argb (exact_answer);
          }

          double[] linrgb = He.MathUtils.bisect_to_limit (y, hr);
          return hexcode_argb (argb_from_linrgb (linrgb));
        }
    }

    public int hct_to_argb (double hue, double chroma, double lstar) {
        // If color is mono…
        if (chroma < 1.0001 || lstar < 0.0001 || lstar > 99.9999) {
          return He.MathUtils.argb_from_lstar (lstar);
        // Else…
        } else {
          double hues = He.MathUtils.sanitize_degrees (hue);
          double hr = hues / 180 * Math.PI;
          double y = He.MathUtils.y_from_lstar (lstar);
          int exact_answer = find_result_by_j (hr, chroma, y);

          if (exact_answer != 0) {
            return exact_answer;
          }

          double[] linrgb = He.MathUtils.bisect_to_limit (y, hr);

          return argb_from_linrgb (linrgb);
        }
    }

    public HCTColor hct_blend (HCTColor a, HCTColor b) {
        var difference_degrees = He.MathUtils.difference_degrees (a.h, b.h);
        var rot_deg = MathUtils.min (difference_degrees * 0.5, 15.0);
        var output =
          He.MathUtils.sanitize_degrees (
            a.h
            + rot_deg * He.MathUtils.rotate_direction (a.h, b.h));

        return fix_disliked ({output, a.c, a.t});
    }

    public static double get_rotated_hue (double hue, double[] hues, double[] rotations) {
      double source_hue = hue;
      if (rotations.length == 1) {
        return MathUtils.sanitize_degrees (source_hue + rotations[0]);
      }
      int size = hues.length;
      for (int i = 0; i <= (size - 2); i++) {
        double hue_a = hues[i];
        double hue_b = hues[i + 1];
        if (hue_a < source_hue && source_hue < hue_b) {
          return MathUtils.sanitize_degrees (source_hue + rotations[i]);
        }
      }
      return source_hue;
    }
}
