namespace He {
    public struct CAM16Color {
        public double j;
        public double a;
        public double b;
        public double c;
        public double h;
        public double m;
        public double s;
    }

    private const double[,] XYZ_TO_CAM16RGB = {
        { 0.401288, 0.650173, -0.051461 },
        { -0.250268, 1.204414, 0.045854 },
        { -0.002079, 0.048952, 0.953127 }
    };

    public CAM16Color xyz_to_cam16 (XYZColor color) {
        ViewingConditions vc = ViewingConditions.with_lstar (lab_to_xyz ({ 50.0, 0.0, 0.0 }).y* 100.0);

        double[,] matrix = XYZ_TO_CAM16RGB;
        double r_t = (color.x * matrix[0, 0]) + (color.y * matrix[0, 1]) + (color.z * matrix[0, 2]);
        double g_t = (color.x * matrix[1, 0]) + (color.y * matrix[1, 1]) + (color.z * matrix[1, 2]);
        double b_t = (color.x * matrix[2, 0]) + (color.y * matrix[2, 1]) + (color.z * matrix[2, 2]);

        double r_d = vc.rgb_d[0] * r_t;
        double g_d = vc.rgb_d[1] * g_t;
        double b_d = vc.rgb_d[2] * b_t;

        // Ensure non-negative values for power operation
        double r_af = MathUtils.pow (MathUtils.max (0.0, vc.fl * MathUtils.abs (r_d) / 100.0), 0.42);
        double g_af = MathUtils.pow (MathUtils.max (0.0, vc.fl * MathUtils.abs (g_d) / 100.0), 0.42);
        double b_af = MathUtils.pow (MathUtils.max (0.0, vc.fl * MathUtils.abs (b_d) / 100.0), 0.42);
        double r_a = MathUtils.signum (r_d) * 400.0 * r_af / (r_af + 27.13);
        double g_a = MathUtils.signum (g_d) * 400.0 * g_af / (g_af + 27.13);
        double b_a = MathUtils.signum (b_d) * 400.0 * b_af / (b_af + 27.13);

        // redness-greenness
        double a = (11.0 * r_a + -12.0 * g_a + b_a) / 11.0;
        // yellowness-blueness
        double b = (r_a + g_a - 2.0 * b_a) / 9.0;

        double u = (20.0 * r_a + 20.0 * g_a + 21.0 * b_a) / 20.0;
        double p2 = (40.0 * r_a + 20.0 * g_a + b_a) / 20.0;

        double hr = Math.atan2 (b, a);
        double atan_degrees = hr * 180.0 / Math.PI;
        double h =
            atan_degrees < 0.0
            ? atan_degrees + 360.0
            : atan_degrees >= 360.0
            ? atan_degrees - 360.0
            : atan_degrees;

        double ac = p2 * vc.nbb;

        // Protect against division by zero and negative power base
        double aw_safe = MathUtils.max (1e-10, vc.aw);
        double ac_ratio = MathUtils.max (0.0, ac / aw_safe);
        var j = 100.0 * Math.pow (ac_ratio, vc.c * vc.z);

        double hue_prime = (h < 20.14) ? h + 360.0 : h;
        double e_hue = 0.25 * (Math.cos ((hue_prime * (Math.PI / 180.0)) + 2.0) + 3.8);
        double p1 = 50000.0 / 13.0 * e_hue * vc.nc * vc.ncb;
        double t = p1 * Math.hypot (a, b) / (u + 0.305);

        // Ensure base for power operations is non-negative
        double base_1 = MathUtils.max (0.0, 1.64 - MathUtils.pow (0.29, vc.n));
        double base_t = MathUtils.max (0.0, t);
        double alpha = MathUtils.pow (base_1, 0.73) * MathUtils.pow (base_t, 0.9);

        // CAM16 chroma, colorfulness, saturation
        double j_safe = MathUtils.max (0.0, j);
        double c = alpha * Math.sqrt (j_safe / 100.0);
        double m = c * vc.fl_root;

        // Protect sqrt argument
        double s_arg = MathUtils.max (0.0, (alpha * vc.c) / (vc.aw + 4.0));
        double s = 50.0 * Math.sqrt (s_arg);

        CAM16Color result = {
            j,
            a,
            b,
            c,
            h,
            m,
            s
        };
        return result;
    }

    public CAM16Color cam16_from_int (int argb) {
        // Transform ARGB int to XYZ
        int red = (argb & 0x00ff0000) >> 16;
        int green = (argb & 0x0000ff00) >> 8;
        int blue = (argb & 0x000000ff);
        double red_l = MathUtils.linearized (red);
        double green_l = MathUtils.linearized (green);
        double blue_l = MathUtils.linearized (blue);
        double x = 0.41233895 * red_l + 0.35762064 * green_l + 0.18051042 * blue_l;
        double y = 0.2126 * red_l + 0.7152 * green_l + 0.0722 * blue_l;
        double z = 0.01932141 * red_l + 0.11916382 * green_l + 0.95034478 * blue_l;

        XYZColor result = {
            x,
            y,
            z
        };

        return xyz_to_cam16 (result);
    }
}