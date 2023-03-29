namespace He.Color {
    public string hexcode (double r, double g, double b) {
        return "#%02X%02X%02X".printf ((uint)r, (uint)g, (uint)b);
    }

    public string hexcode_argb (int color) {
        return "#%06X".printf ((0xFFFFFF & color));
    }
}
