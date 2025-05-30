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

        public unowned PaletteFunc palette;
        public unowned ToneFunc tonev;
        public unowned BackgroundFunc background;
        public unowned BackgroundFunc second_background;
        public unowned ToneDeltaPairFunc tone_delta_pair;

        public DynamicColor (string name,
            PaletteFunc palette,
            ToneFunc? tonev,
            double chromamult,
            bool? is_background,
            BackgroundFunc? background,
            BackgroundFunc? second_background,
            ContrastCurve? contrast_curve,
            ToneDeltaPairFunc? tone_delta_pair) {
            this.name = name;
            this.palette = palette;
            this.tonev = tonev != null ? tonev : get_init_tone ();
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
                                          ToneFunc ? tonev) {
            new DynamicColor (
                              name,
                              palette,
                              tonev != null ? tonev : get_init_tone (),
                              1.0,
                              false,
                              null,
                              null,
                              null,
                              null
            );
        }

        private ToneFunc get_init_tone () {
            if (background == null) {
                return (s) => 50;
            }
            return (s) => background (s) != null ? background (s).get_tone (s, background (s)) : 50;
        }

        public HCTColor get_hct (DynamicScheme scheme, DynamicColor color) {
            var palette = palette (scheme);
            var tone = get_tone (scheme, color);
            var hue = palette.hue;
            var chroma = palette.chroma * chromamult;

            return from_params (hue, chroma, tone);
        }

        public double get_hue (DynamicScheme scheme) {
            double answer = palette (scheme).hue;
            return answer;
        }

        public double get_tone (DynamicScheme scheme, DynamicColor? color) {
            if (tone_delta_pair != null) {
                ToneDeltaPair tone_delta_pair = tone_delta_pair (scheme);
                DynamicColor role_a = tone_delta_pair.role_a;
                DynamicColor role_b = tone_delta_pair.role_b;
                TonePolarity polarity = tone_delta_pair.polarity;
                ToneResolve resolve = tone_delta_pair.resolve;
                var absolute_delta = (polarity == TonePolarity.DARKER ||
                                      (polarity == TonePolarity.RELATIVE_LIGHTER && scheme.is_dark) ||
                                      (polarity == TonePolarity.RELATIVE_DARKER && !scheme.is_dark)) ?
                    tone_delta_pair.delta * -1 :
                    tone_delta_pair.delta;

                var am_role_a = color.name == role_a.name;
                var self_role = am_role_a ? role_a : role_b;
                var ref_role = am_role_a ? role_b : role_a;
                var self_tone = self_role.tonev (scheme);
                var ref_tone = ref_role.tonev (scheme);
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
                        // Adjust the tones for contrast, if background and contrast curve
                        // are defined.
                        var bg_tone = background.get_tone (scheme, background);
                        var self_contrast = scheme.contrast_level;
                        self_tone = Contrast.ratio_of_tones (bg_tone, self_tone) >= self_contrast &&
                            scheme.contrast_level >= 0.0 ?
                            self_tone :
                            foreground_tone (bg_tone, self_contrast);
                    }
                }

                // This can avoid the awkward tones for background colors including the
                // access fixed colors. Accent fixed dim colors should not be adjusted.
                if (is_background) {
                    if (self_tone >= 57.0) {
                        self_tone = MathUtils.clamp_double (65.0, 100.0, self_tone);
                    } else {
                        self_tone = MathUtils.clamp_double (0.0, 49.0, self_tone);
                    }
                }

                return self_tone;
            } else {
                // Case 1: No tone delta pair; just solve for itself.
                var answer = tonev (scheme);

                if (background == null ||
                    background (scheme) == null ||
                    contrast_curve == null) {
                    return answer; // No adjustment for colors with no background.
                }

                var bg_tone = color.background (scheme).get_tone (scheme, color.background (scheme));
                var desired_ratio = contrast_curve.get (scheme.contrast_level);

                // Recalculate the tone from desired contrast ratio if the current
                // contrast ratio is not enough or desired contrast level is decreasing
                // (<0).
                answer = Contrast.ratio_of_tones (bg_tone, answer) >= desired_ratio &&
                    scheme.contrast_level >= 0.0 ?
                    answer :
                    foreground_tone (bg_tone, desired_ratio);

                // This can avoid the awkward tones for background colors including the
                // access fixed colors. Accent fixed dim colors should not be adjusted.
                if (is_background) {
                    if (answer >= 57.0) {
                        answer = MathUtils.clamp_double (65.0, 100.0, answer);
                    } else {
                        answer = MathUtils.clamp_double (0.0, 49.0, answer);
                    }
                }

                if (second_background == null ||
                    second_background (scheme) == null) {
                    return answer;
                }

                // Case 2: Adjust for dual backgrounds.
                var bg1 = background (scheme);
                var bg2 = second_background (scheme);
                var bg_tone1 = bg1.get_tone (scheme, bg1);
                var bg_tone2 = bg2.get_tone (scheme, bg2);
                var upper = Math.fmax (bg_tone1, bg_tone2);
                var lower = Math.fmin (bg_tone1, bg_tone2);

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
                var has_light_option = light_option != -1.0;
                var has_dark_option = dark_option != -1.0;

                var prefers_light = tone_prefers_light_foreground (bg_tone1) ||
                    tone_prefers_light_foreground (bg_tone2);
                if (prefers_light) {
                    return (light_option < 0.0) ? 100.0 : light_option;
                }

                // If exactly one option is available
                if (has_light_option && !has_dark_option) {
                    return light_option;
                } else if (!has_light_option && has_dark_option) {
                    return dark_option;
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
