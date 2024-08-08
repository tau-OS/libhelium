namespace He {
    public class DynamicColor : Object {
        public string name { get; set; }
        public PaletteFunc palette { get; set; }
        public ToneFunc tonev { get; set; }
        public bool is_background { get; set; }
        public BackgroundFunc background { get; set; }
        public BackgroundFunc second_background { get; set; }
        public ContrastCurve contrast_curve { get; set; }
        public ToneDeltaPairFunc tone_delta_pair { get; set; }

        private Gee.HashMap<DynamicScheme, HCTColor?> hct_cache = new Gee.HashMap<DynamicScheme, HCTColor?> ();

        public delegate TonalPalette PaletteFunc (DynamicScheme s);

        public delegate ToneDeltaPair ToneDeltaPairFunc (DynamicScheme s);

        public delegate DynamicColor BackgroundFunc (DynamicScheme s);

        public delegate double ToneFunc (DynamicScheme s);

        public DynamicColor (string name,
            PaletteFunc palette,
            ToneFunc tonev,
            bool? is_background,
            BackgroundFunc? background,
            BackgroundFunc? second_background,
            ContrastCurve? contrast_curve,
            ToneDeltaPairFunc? tone_delta_pair) {
            this.name = name;
            this.palette = palette;
            this.tonev = tonev;
            this.is_background = is_background;
            this.background = background;
            this.second_background = second_background;
            this.contrast_curve = contrast_curve;
            this.tone_delta_pair = tone_delta_pair;
        }

        public DynamicColor.from_palette (string name,
                                          PaletteFunc palette,
                                          ToneFunc tonev) {
            new DynamicColor (
                name,
                palette,
                tonev,
                false,
                null,
                null,
                null,
                null
            );
        }

        public HCTColor get_hct (DynamicScheme scheme) {
            double tone = get_tone (scheme);
            HCTColor tanswer = palette (scheme).get_hct (tone);

            if (hct_cache.size > 4) {
                hct_cache.clear ();
            }

            hct_cache.set (scheme, tanswer);
            return tanswer;
        }

        public double get_tone (DynamicScheme scheme) {
            bool decreasing_contrast = scheme.contrast_level < 0;

            if (tone_delta_pair != null) {
                ToneDeltaPair tone_delta_pair = tone_delta_pair (scheme);
                DynamicColor role_a = tone_delta_pair.role_a;
                DynamicColor role_b = tone_delta_pair.role_b;
                double delta = tone_delta_pair.delta;
                TonePolarity polarity = tone_delta_pair.polarity;
                bool stay_together = tone_delta_pair.stay_together;

                DynamicColor bg = background (scheme);
                double bg_tone = bg.get_tone (scheme);

                bool a_is_nearer =
                    (polarity == TonePolarity.NEARER
                     || (polarity == TonePolarity.LIGHTER && !scheme.is_dark)
                     || (polarity == TonePolarity.DARKER && scheme.is_dark));

                DynamicColor nearer = a_is_nearer ? role_a : role_b;
                DynamicColor farther = a_is_nearer ? role_b : role_a;
                bool am_nearer = name == nearer.name;
                double expansion_dir = scheme.is_dark ? 1.0 : -1.0;

                double n_contrast = nearer.contrast_curve.get (scheme.contrast_level);
                double f_contrast = farther.contrast_curve.get (scheme.contrast_level);

                double n_initial_tone = nearer.tonev (scheme);
                double n_tone = Contrast.ratio_of_tones (bg_tone, n_initial_tone) >= n_contrast
                    ? n_initial_tone
                    : foreground_tone (bg_tone, n_contrast);

                double f_initial_tone = farther.tonev (scheme);
                double f_tone = Contrast.ratio_of_tones (bg_tone, f_initial_tone) >= f_contrast
                    ? f_initial_tone
                    : foreground_tone (bg_tone, f_contrast);

                if (decreasing_contrast) {
                    n_tone = foreground_tone (bg_tone, n_contrast);
                    f_tone = foreground_tone (bg_tone, f_contrast);
                }

                if ((f_tone - n_tone) * expansion_dir < delta) {
                    f_tone = MathUtils.clamp (0.0, 100.0, n_tone + delta * expansion_dir);
                    if ((f_tone - n_tone) * expansion_dir < delta) {
                        n_tone = MathUtils.clamp (0.0, 100.0, f_tone - delta * expansion_dir);
                    }
                }

                if (50.0 <= n_tone && n_tone < 60.0) {
                    if (expansion_dir > 0) {
                        n_tone = 60.0;
                        f_tone = Math.fmax (f_tone, n_tone + delta * expansion_dir);
                    } else {
                        n_tone = 49.0;
                        f_tone = Math.fmin (f_tone, n_tone + delta * expansion_dir);
                    }
                } else if (50.0 <= f_tone && f_tone < 60.0) {
                    if (stay_together) {
                        if (expansion_dir > 0) {
                            n_tone = 60.0;
                            f_tone = Math.fmax (f_tone, n_tone + delta * expansion_dir);
                        } else {
                            n_tone = 49.0;
                            f_tone = Math.fmin (f_tone, n_tone + delta * expansion_dir);
                        }
                    } else {
                        f_tone = expansion_dir > 0 ? 60.0 : 49.0;
                    }
                }

                return am_nearer ? n_tone : f_tone;
            } else {
                double answer = tonev (scheme);

                if (background == null) {
                    return answer;
                }

                double bg_tone = background (scheme).get_tone (scheme);
                double desired_ratio = contrast_curve.get (scheme.contrast_level);

                if (Contrast.ratio_of_tones (bg_tone, answer) >= desired_ratio) {
                    // Do nothing
                } else {
                    answer = foreground_tone (bg_tone, desired_ratio);
                }

                if (decreasing_contrast) {
                    answer = foreground_tone (bg_tone, desired_ratio);
                }

                if (is_background && 50.0 <= answer && answer < 60.0) {
                    answer = Contrast.ratio_of_tones (49.0, bg_tone) >= desired_ratio ? 49.0 : 60.0;
                }

                if (second_background != null) {
                    double bg_tone1 = background (scheme).get_tone (scheme);
                    double bg_tone2 = second_background (scheme).get_tone (scheme);

                    double upper = Math.fmax (bg_tone1, bg_tone2);
                    double lower = Math.fmin (bg_tone1, bg_tone2);

                    if (Contrast.ratio_of_tones (upper, answer) >= desired_ratio &&
                        Contrast.ratio_of_tones (lower, answer) >= desired_ratio) {
                        return answer;
                    }

                    double light_option = Contrast.lighter (upper, desired_ratio);
                    double dark_option = Contrast.darker (lower, desired_ratio);

                    List<double?> availables = new List<double?> ();
                    if (light_option != -1.0) {
                        availables.append (light_option);
                    }
                    if (dark_option != -1.0) {
                        availables.append (dark_option);
                    }

                    bool prefers_light =
                        tone_prefers_light_foreground (bg_tone1) ||
                        tone_prefers_light_foreground (bg_tone2);

                    if (prefers_light) {
                        return light_option == -1.0 ? 100.0 : light_option;
                    }
                    if (availables.length () == 1) {
                        return availables.nth_data (0);
                    }
                    return dark_option == -1.0 ? 0.0 : dark_option;
                }

                return answer;
            }
        }

        public double foreground_tone (double bg_tone, double ratio) {
            double lighter_tone = Contrast.lighter_unsafe (bg_tone, ratio);
            double darker_tone = Contrast.darker_unsafe (bg_tone, ratio);
            double lighter_ratio = Contrast.ratio_of_tones (lighter_tone, bg_tone);
            double darker_ratio = Contrast.ratio_of_tones (darker_tone, bg_tone);
            bool prefer_lighter = tone_prefers_light_foreground (bg_tone);

            if (prefer_lighter) {
                // Handle edge cases where the initial contrast ratio is high and neither lighter nor darker tones pass
                bool negligible_difference =
                    Math.fabs (lighter_ratio - darker_ratio) < 0.1 && lighter_ratio < ratio && darker_ratio < ratio;

                if (lighter_ratio >= ratio || lighter_ratio >= darker_ratio || negligible_difference) {
                    return lighter_tone;
                } else {
                    return darker_tone;
                }
            } else {
                return darker_ratio >= ratio || darker_ratio >= lighter_ratio ? darker_tone : lighter_tone;
            }
        }

        public static double enable_light_foreground (double tone) {
            if (tone_prefers_light_foreground (tone) && !tone_allows_light_foreground (tone)) {
                return 49.0;
            }
            return tone;
        }

        public static bool tone_prefers_light_foreground (double tone) {
            return Math.round (tone) < 60;
        }

        /** Tones less than ~50 always permit white at 4.5 contrast. */
        public static bool tone_allows_light_foreground (double tone) {
            return Math.round (tone) <= 49;
        }
    }
}
