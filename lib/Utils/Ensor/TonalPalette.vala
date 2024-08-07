public class He.TonalPalette : GLib.Object {
    private GLib.HashTable<int, int> cache;
    public double hue { get; private set; }
    public double chroma { get; private set; }
    public HCTColor key_color { get; private set; }

    public TonalPalette(double hue, double chroma, HCTColor key_color) {
        this.hue = hue;
        this.chroma = chroma;
        this.key_color = key_color;
        this.cache = new GLib.HashTable<int, int> (null, null);
    }

    public static TonalPalette tonal_palette_from_int(int argb) {
        HCTColor hct = from_int(argb);
        return TonalPalette.from_hct(hct);
    }

    public static TonalPalette from_hct(HCTColor hct) {
        return new TonalPalette(hct.h, hct.c, hct);
    }

    public static TonalPalette from_hue_and_chroma(double hue, double chroma) {
        KeyColor key_color = new KeyColor(hue, chroma);
        return new TonalPalette(hue, chroma, key_color.create());
    }

    public int tone(double tone) {
        int? argb = this.cache.lookup((int) tone);
        if (argb == null) {
            argb = hct_to_argb(this.hue, this.chroma, tone);
            this.cache.insert((int) tone, argb);
        }
        return argb;
    }

    public HCTColor get_hct(double tone) {
        return from_int(this.tone(tone));
    }
}