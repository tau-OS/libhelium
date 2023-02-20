namespace He.Color {
    public string hexcode (double r, double g, double b) {
        return "#%02X%02X%02X".printf ((uint)r, (uint)g, (uint)b);
    }

    public string hexcode_argb (int color) {
        double r = red_from_rgba_int (color);
        double g = green_from_rgba_int (color);
        double b = blue_from_rgba_int (color);

        return "#%02X%02X%02X".printf ((uint)r, (uint)g, (uint)b);
    }
}