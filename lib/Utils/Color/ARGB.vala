namespace He.Color {
    public const double[,] SRGB_TO_XYZ = {
        {0.41233895, 0.35762064, 0.18051042},
        {0.2126, 0.7152, 0.0722},
        {0.01932141, 0.11916382, 0.95034478}
    };

    public int rgb_to_argb_int (RGBColor color) {
        int result = (int) color.r << 16 | (int) color.g << 8 | (int) color.b;
        return result;
    }

    public static int argb_from_rgb_int (int red, int green, int blue) {
        return (255 << 24) | ((red & 255) << 16) | ((green & 255) << 8) | (blue & 255);
    }

    public static double[] xyz_to_argb (int argb) {
        double r = MathUtils.linearized (red_from_rgba_int(argb));
        double g = MathUtils.linearized (green_from_rgba_int(argb));
        double b = MathUtils.linearized (blue_from_rgba_int(argb));
        return MathUtils.elem_mul (new double[] {r, g, b}, SRGB_TO_XYZ);
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