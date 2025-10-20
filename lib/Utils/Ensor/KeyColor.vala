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

        int lower_tone = 0;
        int upper_tone = 100;

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

        // Binary search for the tone closest to pivot that can achieve requested chroma
        int max_iterations = 100;
        int iteration = 0;
        while (lower_tone < upper_tone && iteration < max_iterations) {
            iteration++;
            int mid_tone = (lower_tone + upper_tone) / 2;
            double mid_chroma = this.max_chroma(mid_tone);

            if (mid_chroma >= this.requested_chroma - epsilon) {
                // This tone can achieve the requested chroma
                // Check if we should prefer this tone or keep searching
                if (Math.fabs(mid_tone - pivot_tone) <= Math.fabs(upper_tone - pivot_tone)) {
                    upper_tone = mid_tone;
                } else {
                    if (lower_tone == mid_tone) {
                        break;
                    }
                    lower_tone = mid_tone;
                }
            } else {
                // This tone cannot achieve the requested chroma
                // Determine search direction based on chroma gradient
                bool is_ascending = mid_tone < 100 &&
                    this.max_chroma(mid_tone) < this.max_chroma(mid_tone + tone_step_size);

                if (is_ascending) {
                    lower_tone = mid_tone + tone_step_size;
                } else {
                    upper_tone = mid_tone;
                }
            }
        }

        // Final validation and selection
        int final_tone = MathUtils.clamp_int(0, 100, lower_tone);
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