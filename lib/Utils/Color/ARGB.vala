namespace He.Color {
    private const double[,] SRGB_TO_XYZ = {
        { 0.41233895, 0.35762064, 0.18051042 },
        { 0.2126, 0.7152, 0.0722 },
        { 0.01932141, 0.11916382, 0.95034478 }
    };

    public int rgb_to_argb_int (RGBColor color) {
        int clr = 0;
        clr |= (int) color.r << 16;
        clr |= (int) color.g << 8;
        clr |= (int) color.b;

        return clr;
    }

    public int lab_to_argb_int (LABColor lab) {
        double[] white_point = { XN, YN, ZN };
        var fy = (lab.l + 16.0) / 116.0;
        var fx = lab.a / 500.0 + fy;
        var fz = fy - lab.b / 200.0;
        var xn = MathUtils.lab_inverse_fovea (fx);
        var yn = MathUtils.lab_inverse_fovea (fy);
        var zn = MathUtils.lab_inverse_fovea (fz);
        XYZColor xyz = { xn * white_point[0], yn * white_point[1], zn * white_point[2] };
        return xyz_to_argb (xyz);
    }

    public static int argb_from_rgb_int (int red, int green, int blue) {
        return (255 << 24) | ((red & 255) << 16) | ((green & 255) << 8) | (blue & 255);
    }

    public static int xyz_to_argb (XYZColor xyz) {
        var matrix = MathUtils.elem_mul (new double[] { xyz.x, xyz.y, xyz.z }, XYZ_TO_SRGB);
        var r = MathUtils.delinearized (matrix[0]);
        var g = MathUtils.delinearized (matrix[1]);
        var b = MathUtils.delinearized (matrix[2]);
        return argb_from_rgb_int (r, g, b);
    }

    public static double[] argb_to_rgb (int argb) {
        double r = MathUtils.linearized (red_from_rgba_int (argb));
        double g = MathUtils.linearized (green_from_rgba_int (argb));
        double b = MathUtils.linearized (blue_from_rgba_int (argb));
        return MathUtils.elem_mul (new double[] { r, g, b }, SRGB_TO_XYZ);
    }

    public int alpha_from_rgba_int (int argb) {
        return (argb >> 24) & 255;
    }

    public int red_from_rgba_int (int argb) {
        return (argb >> 16) & 255;
    }

    public int green_from_rgba_int (int argb) {
        return (argb >> 8) & 255;
    }

    public int blue_from_rgba_int (int argb) {
        return argb & 255;
    }
}