namespace He.Color {
    public struct CAM16Color {
        public double J;
        public double a;
        public double b;
        public double C;
        public double h;
    }

    public const double[,] XYZ_TO_CAM16RGB = {
        {0.401288, 0.650173, -0.051461},
        {-0.250268, 1.204414, 0.045854},
        {-0.002079, 0.048952, 0.953127}
    };
    public const double[,] CAM16RGB_TO_XYZ = {
        {1.8620678, -1.0112547, 0.14918678},
        {0.38752654, 0.62144744, -0.00897398},
        {-0.01584150, -0.03412294, 1.0499644}
    };

    public CAM16Color xyz_to_cam16 (XYZColor color) {
        ViewingConditions vc = ViewingConditions.with_lstar (LSTAR);

        double[,] matrix = XYZ_TO_CAM16RGB;
        double r_t = (color.x * matrix[0,0]) + (color.y * matrix[0,1]) + (color.z * matrix[0,2]);
        double g_t = (color.x * matrix[1,0]) + (color.y * matrix[1,1]) + (color.z * matrix[1,2]);
        double b_t = (color.x * matrix[2,0]) + (color.y * matrix[2,1]) + (color.z * matrix[2,2]);

        double r_d = vc.rgb_d[0] * r_t;
        double g_d = vc.rgb_d[1] * g_t;
        double b_d = vc.rgb_d[2] * b_t;

        double r_af = Math.pow(vc.fl * Math.fabs(r_d) / 100.0, 0.42);
        double g_af = Math.pow(vc.fl * Math.fabs(g_d) / 100.0, 0.42);
        double b_af = Math.pow(vc.fl * Math.fabs(b_d) / 100.0, 0.42);
        double r_a = MathUtils.signum(r_d) * 400.0 * r_af / (r_af + 27.13);
        double g_a = MathUtils.signum(g_d) * 400.0 * g_af / (g_af + 27.13);
        double b_a = MathUtils.signum(b_d) * 400.0 * b_af / (b_af + 27.13);

        var a = r_a + (-12 * g_a + b_a) / 11;
        var b = (r_a + g_a - 2 * b_a) / 9;

        double u = (20.0 * r_a + 20.0 * g_a + 21.0 * b_a) / 20.0;
        double p2 = (40.0 * r_a + 20.0 * g_a + b_a) / 20.0;

        double hr = Math.atan2 (b, a);
        double atanDegrees = hr * 180/Math.PI;
        double h =
            atanDegrees < 0
                ? atanDegrees + 360.0
                : atanDegrees >= 360 ? atanDegrees - 360.0 : atanDegrees;

        double ac = p2 * vc.nbb;

        double hue_p = (h < 20.14) ? h + 360 : h;
        double e_hue = 0.25 * (Math.cos (hue_p * Math.PI/180 + 2.0) + 3.8);
        double p1 = 5e4 / 13.0 * e_hue * vc.nc * vc.ncb;
        double t = p1 * Math.hypot (a, b) / (u + 0.305);
        var J  = 100.0 * Math.pow (ac / vc.aw, vc.c * vc.z);

        var alpha = Math.pow(1.64 - Math.pow (0.29, vc.n), 0.73) * Math.pow(t, 0.9);
        var C = alpha * Math.sqrt(J / 100.0);

        CAM16Color result = {
            J,
            a,
            b,
            C,
            h
        };
        return result;
    }

    public CAM16Color cam16_from_int (int argb) {
        // Transform ARGB int to XYZ
        int red = (argb & 0x00ff0000) >> 16;
        int green = (argb & 0x0000ff00) >> 8;
        int blue = (argb & 0x000000ff);
        double redL = He.MathUtils.linearized(red);
        double greenL = He.MathUtils.linearized(green);
        double blueL = He.MathUtils.linearized(blue);
        double x = 0.41233895 * redL + 0.35762064 * greenL + 0.18051042 * blueL;
        double y = 0.2126 * redL + 0.7152 * greenL + 0.0722 * blueL;
        double z = 0.01932141 * redL + 0.11916382 * greenL + 0.95034478 * blueL;

        XYZColor result = {
            x,
            y,
            z
        };

        return xyz_to_cam16 (result);
    }
}