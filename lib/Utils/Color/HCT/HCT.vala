namespace He.Color {
    public struct HCTColor {
        public double h;
        public double c;
        public double t;
        public int a; // Keep hexcode rep as string on the struct for easy lookup
    }

    public string hct_to_hex (double hue, double chroma, double tone) {
        // If color is mono
        if (chroma < 1.0001 || tone < 0.0001 || tone > 99.9999) {
            return hexcode_argb (He.MathUtils.argb_from_lstar (tone));
        }
    
        // Else...
        hue = He.MathUtils.sanitize_degrees (hue);
        double hr = hue / 180 * Math.PI;
        double y = He.MathUtils.y_from_lstar (tone);
        int exact_answer = find_result_by_j (hr, chroma, y);

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
        double y = He.MathUtils.y_from_lstar (tone);
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