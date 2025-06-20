namespace He {
    public delegate TonalPalette PaletteFunc (DynamicScheme s);

    public delegate ToneDeltaPair ToneDeltaPairFunc (DynamicScheme s);

    public delegate DynamicColor BackgroundFunc (DynamicScheme s);

    public delegate double ToneFunc (DynamicScheme s);

    public class DynamicColor : Object {
        public string name { get; set; }
        public bool is_background { get; set; }
        public double chromamult { get; set; }
        public ContrastCurve contrast_curve { get; set; }

        public PaletteFunc palette;
        public ToneFunc tone;
        public BackgroundFunc background;
        public BackgroundFunc second_background;
        public ToneDeltaPairFunc tone_delta_pair;

        public DynamicColor (string name,
            PaletteFunc palette,
            ToneFunc? tone,
            double chromamult,
            bool? is_background,
            BackgroundFunc? background,
            BackgroundFunc? second_background,
            ContrastCurve? contrast_curve,
            ToneDeltaPairFunc? tone_delta_pair) {
            this.name = name;
            this.palette = palette;
            this.tone = tone;

            this.chromamult = chromamult;
            this.is_background = is_background;
            this.background = background;
            this.chromamult = chromamult;
            this.second_background = second_background;
            this.contrast_curve = contrast_curve;
            this.tone_delta_pair = tone_delta_pair;
        }

        public DynamicColor.from_palette (string name,
                                          PaletteFunc palette,
                                          ToneFunc ? tone) {
            new DynamicColor (
                              name,
                              palette,
                              tone,
                              1.0,
                              false,
                              null,
                              null,
                              null,
                              null
            );
        }

        public DynamicColor build () {
            if (this.tone == null) {
                this.tone = get_initial_tone_from_background (this.background);
            }

            return new DynamicColor (
                                     this.name,
                                     this.palette,
                                     this.tone,
                                     this.chromamult,
                                     this.is_background,
                                     this.background,
                                     this.second_background,
                                     this.contrast_curve,
                                     this.tone_delta_pair
            );
        }

        public HCTColor get_hct (DynamicScheme scheme, DynamicColor color) {
            var palette = color.palette (scheme);
            var tone = color.get_tone (scheme, color);
            var hue = palette.hue;
            double chroma = color.chromamult == -1 ? 1 : color.chromamult;
            var fchroma = palette.chroma * chroma;

            return from_params (hue, fchroma, tone);
        }

        public double get_hue (DynamicScheme scheme) {
            double answer = palette (scheme).hue;
            return answer;
        }

        public ToneFunc get_initial_tone_from_background (BackgroundFunc? background) {
            if (background == null) {
                return (s) => 50.0;
            } else {
                return (s) => {
                           return background (s) != null ? background (s).get_tone_from_scheme (s) : 50.0;
                };
            }
        }

        public double get_tone_from_scheme (DynamicScheme scheme) {
            return get_tone (scheme, this);
        }

        public double get_tone (DynamicScheme scheme, DynamicColor? color) {
            if (tone_delta_pair != null) {
                DynamicColor role_a = tone_delta_pair (scheme).role_a;
                DynamicColor role_b = tone_delta_pair (scheme).role_b;
                TonePolarity polarity = tone_delta_pair (scheme).polarity;
                ToneResolve resolve = tone_delta_pair (scheme).resolve;
                var absolute_delta = (polarity == TonePolarity.DARKER ||
                                      (polarity == TonePolarity.RELATIVE_LIGHTER && scheme.is_dark) ||
                                      (polarity == TonePolarity.RELATIVE_DARKER && !scheme.is_dark)) ?
                    tone_delta_pair (scheme).delta* -1 :
                    tone_delta_pair (scheme).delta;

                var am_role_a = color.name == role_a.name;
                var self_role = am_role_a ? role_a : role_b;
                var ref_role = am_role_a ? role_b : role_a;
                var self_tone = self_role.tone (scheme);
                var ref_tone = ref_role.get_tone (scheme, this);
                var relative_delta = absolute_delta * (am_role_a ? 1 : -1);

                if (resolve == ToneResolve.EXACT) {
                    self_tone = MathUtils.clamp_double (0, 100, ref_tone + relative_delta);
                } else if (resolve == ToneResolve.NEARER) {
                    if (relative_delta > 0) {
                        self_tone = MathUtils.clamp_double (
                                                            0, 100,
                                                            MathUtils.clamp_double (ref_tone, ref_tone + relative_delta, self_tone));
                    } else {
                        self_tone = MathUtils.clamp_double (
                                                            0, 100,
                                                            MathUtils.clamp_double (ref_tone + relative_delta, ref_tone, self_tone));
                    }
                } else if (resolve == ToneResolve.FARTHER) {
                    if (relative_delta > 0) {
                        self_tone = MathUtils.clamp_double (ref_tone + relative_delta, 100, self_tone);
                    } else {
                        self_tone = MathUtils.clamp_double (0, ref_tone + relative_delta, self_tone);
                    }
                }

                if (color.background (scheme) != null && color.contrast_curve != null) {
                    DynamicColor background = color.background (scheme);
                    ContrastCurve contrast_curve = color.contrast_curve;
                    if (background != null && contrast_curve != null) {
                        var bg_tone = background.get_tone (scheme, this);
                        var self_contrast = scheme.contrast_level;
                        self_tone = Contrast.ratio_of_tones (bg_tone, self_tone) >= self_contrast &&
                            scheme.contrast_level >= 0.0 ?
                            self_tone :
                            color.foreground_tone (bg_tone, self_contrast);
                    }
                }

                // This can avoid the awkward tones for background colors including the
                // access fixed colors. Accent fixed dim colors should not be adjusted.
                if (color.is_background) {
                    if (self_tone >= 57.0) {
                        self_tone = MathUtils.clamp_double (65.0, 100.0, self_tone);
                    } else {
                        self_tone = MathUtils.clamp_double (0.0, 49.0, self_tone);
                    }
                }

                return self_tone;
            } else {
                // Case 1: No tone delta pair; just solve for itself.
                var answer = tone (scheme);

                if (color.background == null ||
                    color.background (scheme) == null ||
                    color.contrast_curve == null) {
                    return answer; // No adjustment for colors with no background.
                }

                var bg_tone = color.background (scheme).get_tone (scheme, color.background (scheme));
                var desired_ratio = color.contrast_curve.get (scheme.contrast_level);

                // Recalculate the tone from desired contrast ratio if the current
                // contrast ratio is not enough or desired contrast level is decreasing
                // (<0).
                answer = Contrast.ratio_of_tones (bg_tone, answer) >= desired_ratio &&
                    scheme.contrast_level >= 0.0 ?
                    answer :
                    foreground_tone (bg_tone, desired_ratio);

                // This can avoid the awkward tones for background colors including the
                // access fixed colors. Accent fixed dim colors should not be adjusted.
                if (color.is_background) {
                    if (answer >= 57.0) {
                        answer = MathUtils.clamp_double (65.0, 100.0, answer);
                    } else {
                        answer = MathUtils.clamp_double (0.0, 49.0, answer);
                    }
                }

                if (color.second_background == null ||
                    color.second_background (scheme) == null) {
                    return answer;
                }

                // Case 2: Adjust for dual backgrounds.
                var bg1 = color.background (scheme);
                var bg2 = color.second_background (scheme);
                var bg_tone1 = bg1.get_tone (scheme, bg1);
                var bg_tone2 = bg2.get_tone (scheme, bg2);
                var upper = MathUtils.max (bg_tone1, bg_tone2);
                var lower = MathUtils.min (bg_tone1, bg_tone2);

                if (Contrast.ratio_of_tones (upper, answer) >= desired_ratio &&
                    Contrast.ratio_of_tones (lower, answer) >= desired_ratio) {
                    return answer;
                }

                // The darkest light tone that satisfies the desired ratio,
                // or -1 if such ratio cannot be reached.
                var light_option = Contrast.lighter (upper, desired_ratio);

                // The lightest dark tone that satisfies the desired ratio,
                // or -1 if such ratio cannot be reached.
                var dark_option = Contrast.darker (lower, desired_ratio);

                // Determine available options
                double[] availables = {};
                if (light_option != -1) {
                    availables += (light_option);
                }
                if (dark_option != -1) {
                    availables += (dark_option);
                }

                var prefers_light = tone_prefers_light_foreground (bg_tone1) ||
                    tone_prefers_light_foreground (bg_tone2);
                if (prefers_light) {
                    return (light_option < 0.0) ? 100.0 : light_option;
                }
                if (availables.length == 1) {
                    return availables[0];
                }

                return (dark_option < 0.0) ? 0.0 : dark_option;
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
                    MathUtils.abs (lighter_ratio - darker_ratio) < 0.1 && lighter_ratio < ratio && darker_ratio < ratio;

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
                return 49;
            }
            return tone;
        }

        public static bool tone_prefers_light_foreground (double tone) {
            return MathUtils.round (tone) < 60;
        }

        /** Tones less than ~50 always permit white at 4.5 contrast. */
        public static bool tone_allows_light_foreground (double tone) {
            return MathUtils.round (tone) <= 49;
        }
    }
}