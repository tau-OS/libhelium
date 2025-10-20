namespace He {
    public Gdk.RGBA to_gdk_rgba (RGBColor color) {
        // Clamp and normalize RGB values to 0.0-1.0 range
        float r = (float) MathUtils.clamp_double (0.0, 255.0, color.r) / 255.0f;
        float g = (float) MathUtils.clamp_double (0.0, 255.0, color.g) / 255.0f;
        float b = (float) MathUtils.clamp_double (0.0, 255.0, color.b) / 255.0f;

        Gdk.RGBA result = {
            r,
            g,
            b,
            1.0f
        };

        return result;
    }
}