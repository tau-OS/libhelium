namespace He.Color {
    public int to_argb_int (RGBColor color) {
        int result = (int) color.r << 16 | (int) color.g << 8 | (int) color.b;
        
        return result;
    }
    
    public int red_from_rgba_int (int color) {
        return (color & 0x00ff0000) >> 16;
    }
    
    public int green_from_rgba_int (int color) {
        return (color & 0x0000ff00) >> 8;
    }
    
    public int blue_from_rgba_int (int color) {
        return (color & 0x000000ff);
    }
}