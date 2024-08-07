public class He.KeyColor : GLib.Object {
    private GLib.HashTable<int, double?> chroma_cache;
    private const double max_chroma_value = 200.0;

    public double hue { get; private set; }
    public double requested_chroma { get; private set; }

    public KeyColor(double hue, double requested_chroma) {
        this.hue = hue;
        this.requested_chroma = requested_chroma;
        this.chroma_cache = new GLib.HashTable<int, double?> (null, null);
    }

    public HCTColor create() {
        int pivot_tone = 50;
        int tone_step_size = 1;
        double epsilon = 0.01;

        int lower_tone = 0;
        int upper_tone = 100;

        while (lower_tone < upper_tone) {
            int mid_tone = (lower_tone + upper_tone) / 2;
            bool is_ascending = this.max_chroma(mid_tone) < this.max_chroma(mid_tone + tone_step_size);
            bool sufficient_chroma = this.max_chroma(mid_tone) >= this.requested_chroma - epsilon;

            if (sufficient_chroma) {
                if (Math.fabs(lower_tone - pivot_tone) < Math.fabs(upper_tone - pivot_tone)) {
                    upper_tone = mid_tone;
                } else {
                    if (lower_tone == mid_tone) {
                        return from_params(this.hue, this.requested_chroma, lower_tone);
                    }
                    lower_tone = mid_tone;
                }
            } else {
                if (is_ascending) {
                    lower_tone = mid_tone + tone_step_size;
                } else {
                    upper_tone = mid_tone;
                }
            }
        }

        return from_params(this.hue, this.requested_chroma, lower_tone);
    }

    private double max_chroma(int tone) {
        double? chroma = this.chroma_cache.lookup(tone);
        if (chroma == null) {
            chroma = from_params(this.hue, max_chroma_value, tone).c;
            this.chroma_cache.insert(tone, chroma);
        }
        return chroma;
    }
}