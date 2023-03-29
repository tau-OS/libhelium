namespace He.Color {
    /**
    * Miscellaneous constants for the Lab colorspace
    */
    // Corresponds roughly to RGB brighter/darker
    public const double Kn = 16.0;
    // D65 standard referent
    public const double Xn = 0.95047;
    public const double Yn = 1.00000;
    public const double Zn = 1.08883;
    public const double t0 = 0.137931034;  // 4 / 29
    public const double t1 = 0.206896552;  // 6 / 29
    public const double t2 = 0.128418549;  // 3  * t1 * t1
    public const double t3 = 0.008856452;  // t1 * t1 * t1

    public struct LABColor {
        public double l;
        public double a;
        public double b;

        public double distance (LABColor lab) {
            double d_l = l - lab.l;
            double d_a = a - lab.a;
            double d_b = b - lab.b;
            return (d_l * d_l) + (d_a * d_a) + (d_b * d_b);
        }
    }

    public double xyz_value_to_lab (double v) {
        if (v > He.Color.t3) return Math.pow (v, 1d / 3d);
        return v / He.Color.t2 + He.Color.t0;
    }

    public LABColor xyz_to_lab (XYZColor color) {
        var l = xyz_value_to_lab (color.x);
        var a = xyz_value_to_lab (color.y);
        var b = xyz_value_to_lab (color.z);

        LABColor result = {
          l,
          a,
          b
        };

        return result;
    }

    public LABColor lch_to_lab (LCHColor color) {
        var hr = color.h * Math.PI / 180.0;
        LABColor result = {
          color.l,
          color.c * Math.cos (hr),
          color.c * Math.sin (hr)
        };

        return result;
    }

    public LABColor rgb_to_lab (RGBColor color) {
        var xyz_color = rgb_to_xyz (color);
        var l = 116d * xyz_color.y - 16d;

        LABColor result = {
          l < 0 ? 0 : l,
          500d * (xyz_color.x - xyz_color.y),
          200d * (xyz_color.y - xyz_color.z)
        };

        return result;
    }

    public LABColor lab_from_argb (int argb) {
        var linear_r = MathUtils.linearized (red_from_rgba_int (argb));
        var linear_g = MathUtils.linearized (green_from_rgba_int (argb));
        var linear_b = MathUtils.linearized (blue_from_rgba_int (argb));
        var xyz = MathUtils.elem_mul (new double[] {linear_r, linear_g, linear_b}, SRGB_TO_XYZ);
        double[] d65 = {Xn, Yn, Zn};
        var xn = xyz[0] / d65[0];
        var yn = xyz[1] / d65[1];
        var zn = xyz[2] / d65[2];
        var fx = MathUtils.lab_fovea (xn);
        var fy = MathUtils.lab_fovea (yn);
        var fz = MathUtils.lab_fovea (zn);
        var l = 116.0 * fy - 16;
        var a = 500.0 * (fx - fy);
        var b = 200.0 * (fy - fz);
        return {l, a, b};
    }
}
