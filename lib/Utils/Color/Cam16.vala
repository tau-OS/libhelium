namespace He.Color {
    public struct CAM16Color {
        public double J;
        public double a;
        public double b;
        public double C;
        public double h;
    }

    public const double LSTAR = 49.6;

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
        ViewingConditions vc = ViewingConditions.with_lstar(LSTAR);
        var r_a =  0.401288 * color.x + 0.650173 * color.y - 0.051461 * color.z;
        var g_a = -0.250268 * color.x + 1.204414 * color.y + 0.045854 * color.z;
        var b_a = -0.002079 * color.x + 0.048952 * color.y + 0.953127 * color.z;

        var a = r_a + (-12 * g_a + b_a) / 11;
        var b = (r_a + g_a - 2 * b_a) / 9;

        // auxiliary components
        double u = (20.0 * r_a + 20.0 * g_a + 21.0 * b_a) / 20.0;
        double p2 = (40.0 * r_a + 20.0 * g_a + b_a) / 20.0;

        double hr = Math.atan2(b, a);
        double atanDegrees = hr * 180/Math.PI;
        double h =
            atanDegrees < 0
                ? atanDegrees + 360.0
                : atanDegrees >= 360 ? atanDegrees - 360.0 : atanDegrees;

        double ac = p2 * vc.nbb;

        double hue_p = (h < 20.14) ? h + 360 : h;
        double e_hue = 0.25 * (Math.cos(hue_p * Math.PI/180 + 2.0) + 3.8);
        double p1 = 5e4 / 13.0 * e_hue * vc.nc * vc.ncb;
        double t = p1 * Math.hypot(a, b) / (u + 0.305);
        var J  = 100.0 * Math.pow(ac / vc.aw, vc.c * vc.z);

        var alpha = Math.pow(1.64 - Math.pow(0.29, vc.n), 0.73) * Math.pow(t, 0.9);
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

    // ARGB int (e.g. 0xffffffff) discounting alpha channel → RGBColor → XYZColor → CAM16Color. Yes.
    public CAM16Color cam16_from_int (int argb) {
        return xyz_to_cam16(rgb_to_xyz(from_argb_int(argb)));
    }
}