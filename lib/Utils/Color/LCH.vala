namespace He.Color {
    public struct LCHColor {
        public double l;
        public double c;
        public double h;
    }

    public LCHColor rgb_to_lch (RGBColor color) {
        var lab_color = rgb_to_lab (color);
        var result = lab_to_lch (lab_color);

        return result;
    }

    public LCHColor lab_to_lch (LABColor color) {
        LCHColor result = {
            color.l,
            Math.hypot (color.a, color.b),
            Math.atan2 (color.b, color.a) * 360.0 / 6.283185307179586
        };

        return result;
    }

    public LCHColor hct_to_lch (HCTColor color) {
        LCHColor lch_color_derived = {
            color.t,
            color.c,
            color.h
        };

        return lch_color_derived;
    }
}