namespace He.Color {
    public struct HCTColor {
        public double h;
        public double c;
        public double t;
        public int a; // Keep hexcode rep as string on the struct for easy lookup
    }

    public static HCTColor from_params (double hue, double chroma, double tone) {
      HCTColor result = {
        hue,
        chroma,
        tone
      };

      int argb = hct_to_argb (result);
      return hct_from_argb (argb);
    }

    private HCTColor hct_from_argb (int argb) {
      CAM16Color cam = cam16_from_int (argb);
      var hue = cam.h;
      var chroma = cam.C;
      var tone = He.MathUtils.lstar_from_argb (argb);

      HCTColor result = {
        hue,
        chroma,
        tone,
        argb
      };

      return result;
    }

    public HCTColor cam16_and_lch_to_hct (CAM16Color color, LCHColor tone) {
        HCTColor result = from_params (color.h, color.C, tone.l);
    
        // Now, we're not just gonna accept what comes to us via CAM16 and LCH,
        // because it generates bad HCT colors. So we're gonna test the color and
        // fix it for UI usage.
        bool hue_not_pass = result.h >= 90.0 && result.h <= 111.0;
        bool tone_not_pass = result.t < 70.0;
    
        if (hue_not_pass || tone_not_pass) {
          return {result.h, result.c, 70.0, result.a}; // Fix color for UI, based on Psychology
        } else {
          return {result.h, result.c, result.t, result.a};
        }
    }

    public string hct_to_hex (HCTColor color) {
        // If color is mono
        if (color.c < 1.0001 || color.t < 0.0001 || color.t > 99.9999) {
          return hexcode_argb (He.MathUtils.argb_from_lstar (color.t));
        }
    
        // Else...
        color.h = He.MathUtils.sanitize_degrees (color.h);
        double hr = color.h / 180 * Math.PI;
        double y = 100.0 * He.MathUtils.lab_inverse_fovea ((color.t + 16.0) / 116.0);
        int exact_answer = find_result_by_j (hr, color.c, y);

        if (exact_answer != 0) {
          return hexcode_argb (exact_answer);
        }

        double[] linrgb = He.MathUtils.bisect_to_limit (y, hr);

        return hexcode_argb (argb_from_linrgb (linrgb));
    }

    public int hct_to_argb (HCTColor color) {
        // If color is mono
        if (color.c < 1.0001 || color.t < 0.0001 || color.t > 99.9999) {
          return He.MathUtils.argb_from_lstar (color.t);
        }
    
        // Else...
        color.h = He.MathUtils.sanitize_degrees (color.h);
        double hr = color.h / 180 * Math.PI;
        double y = 100.0 * He.MathUtils.lab_inverse_fovea ((color.t + 16.0) / 116.0);
        int exact_answer = find_result_by_j (hr, color.c, y);

        if (exact_answer != 0) {
          return exact_answer;
        }

        double[] linrgb = He.MathUtils.bisect_to_limit (y, hr);

        return argb_from_linrgb (linrgb);
    }

    public HCTColor hct_blend (HCTColor a, HCTColor b) {
        var difference_degrees = He.MathUtils.difference_degrees (a.h, b.h);
        var rot_deg = Math.fmin (difference_degrees * 0.5, 15.0);
        var output = He.MathUtils.sanitize_degrees (a.h + rot_deg * He.MathUtils.rotate_direction (a.h, b.h));

        return {output, a.c, a.t};
    }
}