public class He.KeyColor : GLib.Object {
    private GLib.HashTable<int, double?> chroma_cache;
    private const double max_chroma_value = 200.0;

    public double hue { get; set; }
    public double requested_chroma { get; set; }

    public KeyColor(double hue, double requested_chroma) {
        this.hue = MathUtils.sanitize_degrees(hue);
        this.requested_chroma = Math.fmax(0.0, requested_chroma);
        this.chroma_cache = new GLib.HashTable<int, double?> (null, null);
    }

    public HCTColor create() {
        int pivot_tone = 50;
        int tone_step_size = 1;
        double epsilon = 0.01;

        // First, find the best achievable chroma across all tones
        double best_chroma = 0.0;
        int best_tone = pivot_tone;

        // Quick scan to find the tone with maximum chroma
        for (int tone = 0; tone <= 100; tone += 5) {
            double chroma_at_tone = this.max_chroma(tone);
            if (chroma_at_tone > best_chroma) {
                best_chroma = chroma_at_tone;
                best_tone = tone;
            }
        }

        // If the requested chroma is higher than what's achievable, use the best we can get
        if (this.requested_chroma > best_chroma + epsilon) {
            return from_params(this.hue, best_chroma, best_tone);
        }

        // Find all tones that can achieve the requested chroma, pick closest to pivot (50)
        int closest_tone = pivot_tone;
        int closest_distance = 100;
        
        for (int tone = 0; tone <= 100; tone += tone_step_size) {
            double chroma_at_tone = this.max_chroma(tone);
            if (chroma_at_tone >= this.requested_chroma - epsilon) {
                int distance = (int)Math.fabs(tone - pivot_tone);
                if (distance < closest_distance) {
                    closest_distance = distance;
                    closest_tone = tone;
                }
            }
        }

        // Final validation and selection
        int final_tone = closest_tone;
        double final_chroma = this.max_chroma(final_tone);

        // If we can't achieve the requested chroma, clamp it to what's achievable
        double actual_chroma = MathUtils.min(this.requested_chroma, final_chroma);
        actual_chroma = Math.fmax(0.0, actual_chroma);

        return from_params(this.hue, actual_chroma, final_tone);
    }

    private double max_chroma(int tone) {
        double? chroma = this.chroma_cache.lookup(tone);
        if (chroma == null) {
            // Create HCT with maximum possible chroma and see what we actually get
            HCTColor test_color = from_params(this.hue, max_chroma_value, tone);
            chroma = test_color.c;
            this.chroma_cache.insert(tone, chroma);
        }
        return chroma;
    }
}