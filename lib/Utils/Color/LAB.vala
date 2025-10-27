namespace He {
    /**
     * Miscellaneous constants for the Lab colorspace
     */
    // Corresponds roughly to RGB brighter/darker
    private const double KN = 16.0;
    // D65 standard referent (scaled to the 0-100 XYZ range)
    private const double XN = 95.047;
    private const double YN = 100.000;
    private const double ZN = 108.883;
    private const double T0 = 0.137931034; // 4 / 29
    private const double T1 = 0.206896552; // 6 / 29
    private const double T2 = 0.128418549; // 3  * t1 * t1
    private const double T3 = 0.008856452; // t1 * t1 * t1

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
        // Delegate to the canonical lab fovea implementation to keep
        // behavior consistent across the codebase. `MathUtils.lab_fovea`
        // expects a normalized value (X/Xn), so callers should pass the
        // normalized value. This function preserves the previous name but
        // forwards to the shared implementation.
        return MathUtils.lab_fovea (v);
    }

    public LABColor xyz_to_lab (XYZColor color) {
        // Normalize XYZ by the D65 white point (XN, YN, ZN) before applying
        // the f(t) (lab fovea) curve. The XYZ values used across the codebase
        // are in the 0-100 range, while XN/YN/ZN here are the normalized D65
        // values (0.95047, 1.0, 1.08883). Divide accordingly.
        double xn = color.x / XN;
        double yn = color.y / YN;
        double zn = color.z / ZN;

        double fx = xyz_value_to_lab (xn);
        double fy = xyz_value_to_lab (yn);
        double fz = xyz_value_to_lab (zn);

        double L = 116.0 * fy - 16.0;
        double A = 500.0 * (fx - fy);
        double B = 200.0 * (fy - fz);

        LABColor result = {
            L < 0 ? 0 : L,
            A,
            B
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
        // Convert RGB -> XYZ (XYZ returned in 0-100 range), then XYZ -> Lab
        var xyz_color = rgb_to_xyz (color);
        return xyz_to_lab (xyz_color);
    }

    public LABColor lab_from_argb (int argb) {
        var linear_r = MathUtils.linearized (red_from_rgba_int (argb));
        var linear_g = MathUtils.linearized (green_from_rgba_int (argb));
        var linear_b = MathUtils.linearized (blue_from_rgba_int (argb));
        var xyz = MathUtils.elem_mul (new double[] { linear_r, linear_g, linear_b }, SRGB_TO_XYZ);
        double[] d65 = { XN, YN, ZN };

        // Protect against division by zero
        var xn = xyz[0] / Math.fmax (1e-10, d65[0]);
        var yn = xyz[1] / Math.fmax (1e-10, d65[1]);
        var zn = xyz[2] / Math.fmax (1e-10, d65[2]);
        var fx = MathUtils.lab_fovea (xn);
        var fy = MathUtils.lab_fovea (yn);
        var fz = MathUtils.lab_fovea (zn);
        var l = 116.0 * fy - 16;
        var a = 500.0 * (fx - fy);
        var b = 200.0 * (fy - fz);
        return { l, a, b };
    }
}