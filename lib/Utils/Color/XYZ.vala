namespace He {
    public struct XYZColor {
        public double x;
        public double y;
        public double z;
    }

    private const double[,] CAM16RGB_TO_XYZ = {
        { 1.8620678, -1.0112547, 0.14918678 },
        { 0.38752654, 0.62144744, -0.00897398 },
        { -0.01584150, -0.03412294, 1.0499644 }
    };

    // RGB to XYZ matrix: input is 0-1 (standard linearized), output is 0-100 (XYZ D65)
    private const double[,] RGB_TO_XYZ = {
        { 41.24564, 35.75761, 18.04375 },
        { 21.26729, 71.51522, 7.21750 },
        { 1.93339, 11.91920, 95.03041 }
    };

    public XYZColor argb_to_xyz (int argb) {
        double r = MathUtils.linearized (red_from_rgba_int (argb));
        double g = MathUtils.linearized (green_from_rgba_int (argb));
        double b = MathUtils.linearized (blue_from_rgba_int (argb));
        double[] xyz = MathUtils.elem_mul ({ r, g, b }, SRGB_TO_XYZ);
        return { xyz[0], xyz[1], xyz[2] };
    }

    public double rgb_value_to_xyz (double v) {
        v = Math.fmax (0.0, v);
        if ((v /= 255.0) <= 0.04045)return v / 12.92;
        return Math.pow (Math.fmax (0.0, (v + 0.055) / 1.055), 2.4);
    }

    public XYZColor rgb_to_xyz (RGBColor color) {
        var r = rgb_value_to_xyz (color.r);
        var g = rgb_value_to_xyz (color.g);
        var b = rgb_value_to_xyz (color.b);

        double[] xyz = MathUtils.elem_mul ({ r, g, b }, RGB_TO_XYZ);

        XYZColor result = {
            xyz[0],
            xyz[1],
            xyz[2]
        };

        return result;
    }

    public XYZColor cam16_to_xyz (CAM16Color color) {
        ViewingConditions vc = ViewingConditions.with_lstar (50.0);
        double j_safe = Math.fmax (0.0, color.j);
        double alpha = (color.c == 0.0 || color.j == 0.0) ? 0.0 : color.c / Math.sqrt (j_safe / 100.0);

        double base_t = Math.fmax (0.0, 1.64 - Math.pow (0.29, vc.n));
        double t = Math.pow (Math.fmax (0.0, alpha / Math.pow (base_t, 0.73)), 1.0 / 0.9);
        double h_in_radians = color.h * Math.PI / 180.0;

        double e_hue = 0.25 * (Math.cos (h_in_radians + 2.0) + 3.8);
        double ac = vc.aw * Math.pow (Math.fmax (0.0, j_safe / 100.0), 1.0 / vc.c / vc.z);
        double p1 = e_hue * (50000.0 / 13.0) * vc.nc * vc.ncb;
        double p2 = (ac / Math.fmax (1e-10, vc.nbb));

        double h_sine = Math.sin (h_in_radians);
        double h_cosine = Math.cos (h_in_radians);

        double gamma = 23.0 * (p2 + 0.305) * t / (23.0 * p1 + 11.0 * t * h_cosine + 108.0 * t * h_sine);
        double a = gamma * h_cosine;
        double b = gamma * h_sine;
        double r_a = (460.0 * p2 + 451.0 * a + 288.0 * b) / 1403.0;
        double g_a = (460.0 * p2 - 891.0 * a - 261.0 * b) / 1403.0;
        double b_a = (460.0 * p2 - 220.0 * a - 6300.0 * b) / 1403.0;

        double r_a_abs = Math.fabs (r_a);
        double r_c_base = Math.fmax (0.0, (27.13 * r_a_abs) / Math.fmax (1e-10, 400.0 - r_a_abs));
        double r_c = MathUtils.signum (r_a) * (100.0 / Math.fmax (1e-10, vc.fl)) * Math.pow (r_c_base, 1.0 / 0.42);
        double g_a_abs = Math.fabs (g_a);
        double g_c_base = Math.fmax (0.0, (27.13 * g_a_abs) / Math.fmax (1e-10, 400.0 - g_a_abs));
        double g_c = MathUtils.signum (g_a) * (100.0 / Math.fmax (1e-10, vc.fl)) * Math.pow (g_c_base, 1.0 / 0.42);
        double b_a_abs = Math.fabs (b_a);
        double b_c_base = Math.fmax (0.0, (27.13 * b_a_abs) / Math.fmax (1e-10, 400.0 - b_a_abs));
        double b_c = MathUtils.signum (b_a) * (100.0 / Math.fmax (1e-10, vc.fl)) * Math.pow (b_c_base, 1.0 / 0.42);
        double r_f = r_c / Math.fmax (1e-10, vc.rgb_d[0]);
        double g_f = g_c / Math.fmax (1e-10, vc.rgb_d[1]);
        double b_f = b_c / Math.fmax (1e-10, vc.rgb_d[2]);

        double[,] matrix = CAM16RGB_TO_XYZ;
        double x = (r_f * matrix[0, 0]) + (g_f * matrix[0, 1]) + (b_f * matrix[0, 2]);
        double y = (r_f * matrix[1, 0]) + (g_f * matrix[1, 1]) + (b_f * matrix[1, 2]);
        double z = (r_f * matrix[2, 0]) + (g_f * matrix[2, 1]) + (b_f * matrix[2, 2]);

        XYZColor xyz = { x, y, z };

        return xyz;
    }

    // Adapted from https://cs.github.com/Ogeon/palette/blob/d4cae1e2510205f7626e880389e5e18b45913bd4/palette/src/xyz.rs#L259
    public XYZColor lab_to_xyz (LABColor color) {
        // Recip call shows performance benefits in benchmarks for this function
        var y = (color.l + 16.0) * (1.0 / 116.0);
        var x = y + (color.a * 1.0 / 500.0);
        var z = y - (color.b * 1.0 / 200.0);

        // D65 white point
        XYZColor result = {
            MathUtils.convert (x) * 0.95047,
            MathUtils.convert (y) * 1.00000,
            MathUtils.convert (z) * 1.08883
        };

        return result;
    }
}