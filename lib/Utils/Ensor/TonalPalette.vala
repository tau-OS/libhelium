public class He.TonalPalette : GLib.Object {
    private GLib.HashTable<double?, double?> cache;
    public double hue { get; set; }
    public double chroma { get; set; }
    public HCTColor key_color { get; set; }

    public TonalPalette(double hue, double chroma, HCTColor key_color) {
        this.hue = hue;
        this.chroma = chroma;
        this.key_color = key_color;
        this.cache = new GLib.HashTable<double?, double?> (null, null);
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

    public double get_tone(double tone) {
        double? color = cache.get(tone);
        if (color == null) {
            color = hct_to_argb(this.hue, this.chroma, tone);
            cache.insert(tone, color);
        }
        return color;
    }

    public HCTColor get_hct(double tone) {
        return from_params(this.hue, this.chroma, tone);
    }
}