namespace He.Color {
    public struct HCTColor {
        public double h;
        public double c;
        public double t;
        public string a; // Keep hexcode rep as string on the struct for easy lookup
    }

    public HCTColor cam16_and_lch_to_hct (CAM16Color color, LCHColor tone) {
        HCTColor result = {
          color.h,
          color.C,
          tone.l
        };
    
        // Now, we're not just gonna accept what comes to us via CAM16 and LCH,
        // because it generates bad HCT colors. So we're gonna test the color and
        // fix it for UI usage.
        bool hueNotPass = result.h >= 90.0 && result.h <= 111.0;
        bool toneNotPass = result.t < 70.0;
    
        if (hueNotPass || toneNotPass) {
          return {result.h, result.c, 70.0, result.a}; // Fix color for UI, based on Psychology
        } else {
          return {result.h, result.c, result.t, result.a};
        }
    }

    public string hct_to_hex (HCTColor color) {
        // If color is mono
        if (color.c < 1.0001 || color.t < 0.0001 || color.t > 99.9999) {
            double y = 100.0 * He.MathUtils.lab_inverse_fovea ((color.t + 16.0) / 116.0);
            double normalized = y / 100.0;
            double delinearized = 0.0;

            if (normalized <= 0.0031308) {
                delinearized = normalized * 12.92;
            } else {
                delinearized = 1.055 * Math.pow (normalized, 1.0 / 2.4) - 0.055;
            }

            int component = (int)Math.round (delinearized * 255.0).clamp(0, 255);

            return hexcode (component, component, component);
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

    public HCTColor hct_blend (HCTColor a, HCTColor b) {
        var difference_degrees  = He.MathUtils.difference_degrees (a.h, b.h);
        var rot_deg = Math.fmin(difference_degrees * 0.5, 15.0);
        var output = He.MathUtils.sanitize_degrees (a.h + rot_deg * He.MathUtils.rotate_direction (a.h, b.h));

        return {output, a.c, a.t};
    }
}