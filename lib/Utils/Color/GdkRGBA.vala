namespace He {
    public Gdk.RGBA to_gdk_rgba (RGBColor color) {
        Gdk.RGBA result = {
            (float) color.r / 255.0f,
            (float) color.g / 255.0f,
            (float) color.b / 255.0f,
            1.0f
        };

        return result;
    }
}