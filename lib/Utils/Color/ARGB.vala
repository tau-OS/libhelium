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

    public static int argb_from_rgb_int (int r, int g, int b) {
        return (255 << 24) | ((r & 255) << 16) | ((g & 255) << 8) | (b & 255);
    }

    public static double[] xyz_to_argb (int argb) {
        double r = MathUtils.linearized (red_from_rgba_int(argb));
        double g = MathUtils.linearized (green_from_rgba_int(argb));
        double b = MathUtils.linearized (blue_from_rgba_int(argb));
        return MathUtils.elem_mul (new double[] {r, g, b}, SRGB_TO_XYZ);
    }
    
    public int red_from_rgba_int (int color) {
        return (color & 0x00FF0000) >> 16;
    }
    
    public int green_from_rgba_int (int color) {
        return (color & 0x0000FF00) >> 8;
    }
    
    public int blue_from_rgba_int (int color) {
        return (color & 0x000000FF);
    }
}