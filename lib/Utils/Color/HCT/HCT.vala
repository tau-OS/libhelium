namespace He {
    public struct HCTColor {
        public double h;
        public double c;
        public double t;
        public int a; // Keep hexcode rep as string on the struct for easy lookup

        public int to_int () {
            return this.a;
        }
    }

    public int get_argb () {
        return (int) HCTColor.to_int;
    }

    public HCTColor set_internal_state (int argb) {
        var a = argb;
        CAM16Color cam = cam16_from_int (argb);
        var h = cam.h;
        var c = cam.c;
        var t = MathUtils.lstar_from_argb (argb);

        return { h, c, t, a };
    }

    public HCTColor from_params (double hue, double chroma, double tone) {
        return set_internal_state (from_solved (hue, chroma, tone));
    }

    public HCTColor in_vc (ViewingConditions vc) {
        // 1. Use CAM16 to find XYZ coordinates of color in specified VC.
        CAM16Color cam16 = cam16_from_int (get_argb ());
        XYZColor viewed = cam16_to_xyz (cam16);

        // 2. Create CAM16 of those XYZ coordinates in default VC.
        CAM16Color recast = xyz_to_cam16 ({ viewed.x, viewed.y, viewed.z });

        // 3. Create HCT from:
        // - CAM16 using default VC with XYZ coordinates in specified VC.
        // - L* converted from Y in XYZ coordinates in specified VC.
        return from_params (recast.h, recast.c, MathUtils.lstar_from_y (viewed.y));
    }

    // Disliked means a yellow-green that's not neutral
    public static bool disliked (HCTColor hct) {
        bool hue_passes = MathUtils.round_double (hct.h) >= 90.0 && MathUtils.round_double (hct.h) <= 111.0;
        bool chroma_passes = MathUtils.round_double (hct.c) > 16.0;
        bool tone_passes = MathUtils.round_double (hct.t) < 65.0;

        return hue_passes && chroma_passes && tone_passes;
    }

    // If color is disliked, lighten it to make it likable.
    public static HCTColor fix_disliked (HCTColor hct) {
        if (disliked (hct)) {
            return from_params (hct.h, hct.c, 70.0);
        }

        return hct;
    }

    // Find if the hue is yellow. Useful to adjust to avoid disliked colors.
    public bool hue_is_yellow (double hue) {
        return Math.floor (hue) >= 105.0 && Math.floor (hue) < 125.0;
    }

    public bool hue_is_blue (double hue) {
        return Math.floor (hue) >= 250.0 && Math.floor (hue) < 270.0;
    }

    public bool hue_is_cyan (double hue) {
        return Math.floor (hue) >= 170.0 && Math.floor (hue) < 207.0;
    }

    public HCTColor hct_from_int (int argb) {
        var color = cam16_from_int (argb);
        return { color.h, color.c, MathUtils.lstar_from_argb (argb), argb };
    }

    public string hct_to_hex (double hue, double chroma, double lstar) {
        return hexcode_argb (hct_to_argb (hue, chroma, lstar));
    }

    public string hex_from_hct_with_contrast (HCTColor hct, double contrast) {
        return hexcode_argb (hct_to_argb (hct.h, hct.c, contrast));
    }

    public string hex_from_hct (HCTColor hct) {
        return hexcode_argb (hct_to_argb (hct.h, hct.c, hct.t));
    }

    public int hct_to_argb (double hue, double chroma, double lstar) {
        // If color is mono…
        if (chroma < 0.0001 || lstar < 0.0001 || lstar > 99.9999) {
            return MathUtils.argb_from_lstar (lstar);
            // Else…
        } else {
            double hues = MathUtils.sanitize_degrees (hue);
            double hr = hues / 180 * Math.PI;
            double y = MathUtils.y_from_lstar (lstar);
            int exact_answer = find_result_by_j (hr, chroma, y);

            if (exact_answer != 0) {
                return exact_answer;
            }

            double[] linrgb = MathUtils.bisect_to_limit (y, hr);

            return argb_from_linrgb (linrgb);
        }
    }

    public HCTColor hct_blend (HCTColor a, HCTColor b) {
        var difference_degrees = MathUtils.difference_degrees (a.h, b.h);
        var rot_deg = MathUtils.min (difference_degrees * 0.5, 15.0);
        var output =
            MathUtils.sanitize_degrees (
                                        a.h
                                        + rot_deg * MathUtils.rotate_direction (a.h, b.h));

        return fix_disliked ({ output, a.c, a.t });
    }

    public static double get_rotated_hue (HCTColor hct, double[] hues, double[] rotations) {
        return MathUtils.sanitize_degrees (piecewise_val (hct, hues, rotations) + hct.h);
    }

    public static double piecewise_val (HCTColor hct, double[] huebps, double[] hues) {
        int size = (int) MathUtils.min (huebps.length - 1, hues.length);
        double src_h = hct.h;

        for (int i = 0; i < size; i++) {
            if (src_h >= huebps[i] && src_h < huebps[i + 1]) {
                return MathUtils.sanitize_degrees (hues[i]);
            }
        }
        return src_h;
    }
}