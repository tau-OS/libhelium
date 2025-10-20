namespace He {
    public string hexcode (double r, double g, double b) {
        // Clamp values to valid 0-255 range
        uint r_clamped = (uint) MathUtils.clamp_double (0.0, 255.0, r);
        uint g_clamped = (uint) MathUtils.clamp_double (0.0, 255.0, g);
        uint b_clamped = (uint) MathUtils.clamp_double (0.0, 255.0, b);
        return "#%02X%02X%02X".printf (r_clamped, g_clamped, b_clamped);
    }

    public string hexcode_argb (int color) {
        return "#%06X".printf ((0xFFFFFF & color));
    }
}