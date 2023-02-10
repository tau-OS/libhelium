namespace He.Color {
    public string hexcode (double r, double g, double b) {
        return "#" + "%02x%02x%02x".printf (
            (uint)r,
            (uint)g,
            (uint)b
        );
    }

    public string hexcode_argb (int color) {
        string c = "%x".printf (color);
        string result = "#" + c.substring (2, 6);
        return result;
    }
}