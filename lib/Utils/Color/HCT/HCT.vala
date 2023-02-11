namespace He.Color {
    public struct HCTColor {
        public double h;
        public double c;
        public double t;
        public int a; // Keep hexcode rep as string on the struct for easy lookup
    }

    public static HCTColor from_params (double hue, double chroma, double tone) {
      int argb = hct_to_argb (hue, chroma, tone);
      CAM16Color cam = cam16_from_int (argb);
      var nhue = cam.h;
      var nchroma = cam.C;
      var ntone = He.MathUtils.lstar_from_argb (argb);

      HCTColor result = {
        nhue,
        nchroma,
        ntone,
        argb
      };

      return result;
    }

    public HCTColor cam16_and_lch_to_hct (CAM16Color color, LCHColor tone) {
        return from_params (color.h, color.C, tone.l);
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

    public int hct_to_argb (double hue, double chroma, double tone) {
        // If color is mono
        if (chroma < 1.0001 || tone < 0.0001 || tone > 99.9999) {
          return He.MathUtils.argb_from_lstar (tone);
        }
    
        // Else...
        double hues = He.MathUtils.sanitize_degrees (hue);
        double hr = hues / 180 * Math.PI;
        double y = 100.0 * He.MathUtils.lab_inverse_fovea ((tone + 16.0) / 116.0);
        int exact_answer = find_result_by_j (hr, chroma, y);

        if (exact_answer != 0) {
          return exact_answer;
        }

        double[] linrgb = He.MathUtils.bisect_to_limit (y, hr);

        return argb_from_linrgb (linrgb);
    }

    public HCTColor hct_blend (HCTColor a, HCTColor b) {
        var difference_degrees  = He.MathUtils.difference_degrees (a.h, b.h);
        var rot_deg = Math.fmin(difference_degrees * 0.5, 15.0);
        var output = He.MathUtils.sanitize_degrees (a.h + rot_deg * He.MathUtils.rotate_direction (a.h, b.h));

        return {output, a.c, a.t};
    }
}