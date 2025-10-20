public class He.TonalPalette : GLib.Object {
    private Gee.HashMap<int, int> cache = new Gee.HashMap<int, int> (null, null);
    public double hue { get; set; }
    public double chroma { get; set; }
    public HCTColor key_color { get; set; }

    public TonalPalette(double hue, double chroma, HCTColor key_color) {
        this.hue = MathUtils.sanitize_degrees(hue);
        this.chroma = Math.fmax(0.0, chroma);
        this.key_color = key_color;
    }

    public static TonalPalette from_int(int argb) {
        HCTColor hct = hct_from_int(argb);
        return TonalPalette.from_hct(hct);
    }

    public static TonalPalette from_hct(HCTColor hct) {
        return new TonalPalette(hct.h, hct.c, hct);
    }

    public static TonalPalette from_hue_and_chroma(double hue, double chroma) {
        HCTColor key_color = new KeyColor(hue, chroma).create();
        return new TonalPalette(hue, chroma, key_color);
    }

    public int get_tone(int tone) {
        tone = (int) MathUtils.clamp_double((double) tone, 0.0, 100.0);
        int? color = cache.get(tone);
        if (color == null) {
            if (tone == 99 && HCTColor.hue_is_yellow(hue)) {
                int tone98 = hct_to_argb(this.hue, this.chroma, 98.0);
                int tone100 = hct_to_argb(this.hue, this.chroma, 100.0);
                color = average_argb(tone98, tone100);
            } else {
                color = hct_to_argb(this.hue, this.chroma, (double) tone);
            }
            cache.set(tone, color);
        }
        return color;
    }

    private int average_argb(int argb1, int argb2) {
        int r1 = (argb1 >> 16) & 0xFF;
        int g1 = (argb1 >> 8) & 0xFF;
        int b1 = argb1 & 0xFF;

        int r2 = (argb2 >> 16) & 0xFF;
        int g2 = (argb2 >> 8) & 0xFF;
        int b2 = argb2 & 0xFF;

        int r = MathUtils.round((r1 + r2) / 2.0);
        int g = MathUtils.round((g1 + g2) / 2.0);
        int b = MathUtils.round((b1 + b2) / 2.0);

        return (255 << 24 | (r & 255) << 16 | (g & 255) << 8 | b & 255);
    }

    public HCTColor get_hct(double tone) {
        tone = MathUtils.clamp_double(tone, 0.0, 100.0);
        return from_params(this.hue, this.chroma, tone);
    }
}