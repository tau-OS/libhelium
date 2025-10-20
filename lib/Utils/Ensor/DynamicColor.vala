namespace He {
    public delegate TonalPalette ? PaletteFunc (DynamicScheme s);

    public delegate ToneDeltaPair ? ToneDeltaPairFunc (DynamicScheme s);

    public delegate DynamicColor ? BackgroundFunc (DynamicScheme s);

    public delegate double ? ToneFunc (DynamicScheme s);

    public delegate double ? DoubleFunc (DynamicScheme s);

    public delegate ContrastCurve ? ContrastCurveFunc (DynamicScheme s);

    public class DynamicColor : Object {
        public string name { get; set; }
        public bool is_background { get; set; }
        public double chromamult { get; set; }
        public ContrastCurve? contrast_curve { get; set; }

        public PaletteFunc palette;
        public ToneFunc tone;
        public BackgroundFunc? background;
        public BackgroundFunc? second_background;
        public ToneDeltaPairFunc? tone_delta_pair;
        public DoubleFunc? chroma_multiplier_func;
        public ContrastCurveFunc? contrast_curve_func;
        public DoubleFunc? opacity;

        public DynamicColor (string name,
            PaletteFunc palette,
            ToneFunc? tone,
            double chromamult,
            bool? is_background,
            BackgroundFunc? background,
            BackgroundFunc? second_background,
            ContrastCurve? contrast_curve,
            ToneDeltaPairFunc? tone_delta_pair = null,
            ContrastCurveFunc? contrast_curve_func = null,
            DoubleFunc? chroma_multiplier_func = null,
            DoubleFunc? opacity = null) {
            this.name = name;
            this.palette = palette;
            this.tone = tone;
            this.chromamult = chromamult;
            this.is_background = is_background;
            this.background = background;
            this.second_background = second_background;
            this.contrast_curve = contrast_curve;
            this.tone_delta_pair = tone_delta_pair;
            this.contrast_curve_func = contrast_curve_func;
            this.chroma_multiplier_func = chroma_multiplier_func;
            this.opacity = opacity;
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
                                     this.tone_delta_pair,
                                     this.contrast_curve_func,
                                     this.chroma_multiplier_func,
                                     this.opacity
            );
        }

        public HCTColor get_hct (DynamicScheme scheme, DynamicColor color) {
            var palette = color.palette (scheme);
            var tone = color.get_tone (scheme, color);
            var hue = palette.hue;
            double chroma = color.chroma_multiplier_func != null? color.chroma_multiplier_func (scheme) : (color.chromamult == -1 ? 1 : color.chromamult);

            // Ensure non-negative chroma
            chroma = Math.fmax (0.0, chroma);
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
                           DynamicColor? bg = background (s);
                           return bg != null? bg.get_tone_from_scheme (s) : 50.0;
                };
            }
        }

        public double get_tone_from_scheme (DynamicScheme scheme) {
            return get_tone (scheme, this);
        }

        public double get_tone (DynamicScheme scheme, DynamicColor? color) {
            DynamicColor current = color ?? this;
            ToneDeltaPairFunc? pair_func = current.tone_delta_pair;

            if (pair_func != null) {
                ToneDeltaPair? pair = pair_func (scheme);

                if (pair == null) {
                    // Treat null responses the same as absent tone delta pair definitions.
                    // Continue with the default tone path below.
                } else {
                    DynamicColor role_a = pair.role_a;
                    DynamicColor role_b = pair.role_b;
                    TonePolarity polarity = pair.polarity;
                    ToneResolve resolve = pair.resolve;
                    double absolute_delta = (polarity == TonePolarity.DARKER ||
                                             (polarity == TonePolarity.RELATIVE_LIGHTER && scheme.is_dark) ||
                                             (polarity == TonePolarity.RELATIVE_DARKER && !scheme.is_dark)) ?
                        pair.delta * -1 :
                        pair.delta;

                    bool am_role_a = current.name == role_a.name;
                    DynamicColor self_role = am_role_a ? role_a : role_b;
                    DynamicColor ref_role = am_role_a ? role_b : role_a;
                    double self_tone = self_role.tone (scheme);
                    double ref_tone = ref_role.tone (scheme);
                    double relative_delta = absolute_delta * (am_role_a ? 1 : -1);

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

                    DynamicColor? primary_background = current.background != null? current.background (scheme) : null;

                    unowned ContrastCurve? contrast_curve_value = current.contrast_curve;
                    ContrastCurve? generated_curve = null;

                    if (contrast_curve_value == null && current.contrast_curve_func != null) {
                        generated_curve = current.contrast_curve_func (scheme);
                        contrast_curve_value = generated_curve;
                    }

                    if (primary_background != null && contrast_curve_value != null) {
                        var bg_tone = primary_background.get_tone (scheme, primary_background);
                        var desired_ratio = contrast_curve_value.get (scheme.contrast_level);
                        self_tone = Contrast.ratio_of_tones (bg_tone, self_tone) >= desired_ratio &&
                            scheme.contrast_level >= 0.0 ?
                            self_tone :
                            current.foreground_tone (bg_tone, desired_ratio);
                    }

                    // This can avoid the awkward tones for background colors including the
                    // access fixed colors. Accent fixed dim colors should not be adjusted.
                    if (current.is_background && !current.name.has_suffix ("_fixed_dim")) {
                        if (self_tone >= 57.0) {
                            self_tone = MathUtils.clamp_double (65.0, 100.0, self_tone);
                        } else {
                            self_tone = MathUtils.clamp_double (0.0, 49.0, self_tone);
                        }
                    }

                    return finalize_tone_for_light_on_roles (scheme, current, self_tone);
                }
            }

            // Case 1: No tone delta pair; just solve for itself.
            double answer = current.tone (scheme);

            DynamicColor? primary_background = current.background != null? current.background (scheme) : null;

            unowned ContrastCurve? primary_curve = current.contrast_curve;
            ContrastCurve? generated_primary_curve = null;

            if (primary_curve == null && current.contrast_curve_func != null) {
                generated_primary_curve = current.contrast_curve_func (scheme);
                primary_curve = generated_primary_curve;
            }

            if (primary_background == null ||
                primary_curve == null) {
                return finalize_tone_for_light_on_roles (scheme, current, answer); // No adjustment for colors with no background.
            }

            double bg_tone_primary = primary_background.get_tone (scheme, primary_background);
            double desired = primary_curve.get (scheme.contrast_level);

            // Recalculate the tone from desired contrast ratio if the current
            // contrast ratio is not enough or desired contrast level is decreasing
            // (<0).
            answer = Contrast.ratio_of_tones (bg_tone_primary, answer) >= desired &&
                scheme.contrast_level >= 0.0 ?
                answer :
                foreground_tone (bg_tone_primary, desired);

            // This can avoid the awkward tones for background colors including the
            // access fixed colors. Accent fixed dim colors should not be adjusted.
            if (current.is_background && !current.name.has_suffix ("_fixed_dim")) {
                if (answer >= 57.0) {
                    answer = MathUtils.clamp_double (65.0, 100.0, answer);
                } else {
                    answer = MathUtils.clamp_double (0.0, 49.0, answer);
                }
            }

            DynamicColor? secondary_background = current.second_background != null? current.second_background (scheme) : null;

            if (secondary_background == null ||
                primary_curve == null) {
                return finalize_tone_for_light_on_roles (scheme, current, answer);
            }

            // Case 2: Adjust for dual backgrounds.
            double bg_tone1 = primary_background.get_tone (scheme, primary_background);
            double bg_tone2 = secondary_background.get_tone (scheme, secondary_background);
            double upper = MathUtils.max (bg_tone1, bg_tone2);
            double lower = MathUtils.min (bg_tone1, bg_tone2);

            if (Contrast.ratio_of_tones (upper, answer) >= desired &&
                Contrast.ratio_of_tones (lower, answer) >= desired) {
                return answer;
            }

            // The darkest light tone that satisfies the desired ratio,
            // or -1 if such ratio cannot be reached.
            double light_option = Contrast.lighter (upper, desired);

            // The lightest dark tone that satisfies the desired ratio,
            // or -1 if such ratio cannot be reached.
            double dark_option = Contrast.darker (lower, desired);

            // Determine available options
            double[] availables = {};
            if (light_option != -1) {
                availables += (light_option);
            }
            if (dark_option != -1) {
                availables += (dark_option);
            }

            bool prefers_light = tone_prefers_light_foreground (bg_tone1) ||
                tone_prefers_light_foreground (bg_tone2);
            double resolved_tone;

            if (prefers_light) {
                resolved_tone = (light_option < 0.0) ? 100.0 : light_option;
            } else if (availables.length == 1) {
                resolved_tone = availables[0];
            } else {
                resolved_tone = (dark_option < 0.0) ? 0.0 : dark_option;
            }

            return finalize_tone_for_light_on_roles (scheme, current, resolved_tone);
        }

        public double foreground_tone (double bg_tone, double ratio) {
            double lighter_tone = Contrast.lighter_unsafe (bg_tone, ratio);
            double darker_tone = Contrast.darker_unsafe (bg_tone, ratio);
            double lighter_ratio = Contrast.ratio_of_tones (lighter_tone, bg_tone);
            double darker_ratio = Contrast.ratio_of_tones (darker_tone, bg_tone);
            bool prefer_lighter = tone_prefers_light_foreground (bg_tone);

            // Clamp tones to valid range
            lighter_tone = MathUtils.clamp_double (0.0, 100.0, lighter_tone);
            darker_tone = MathUtils.clamp_double (0.0, 100.0, darker_tone);

            // At very low contrast (near 1.0), prefer maintaining readability
            if (ratio < 1.5) {
                // For very low contrast, use the tone preference to maintain some distinction
                if (prefer_lighter) {
                    // If background is dark, ensure we don't go too dark
                    return lighter_tone;
                } else {
                    // If background is light, ensure we don't go too light
                    return darker_tone;
                }
            }

            if (prefer_lighter) {
                // Handle edge cases where the initial contrast ratio is high and neither lighter nor darker tones pass
                bool negligible_difference =
                    MathUtils.abs (lighter_ratio - darker_ratio) < 0.1 && lighter_ratio < ratio && darker_ratio < ratio;

                // Prefer lighter tone if it meets the ratio, or if it's closer to meeting it
                if (lighter_ratio >= ratio || lighter_ratio >= darker_ratio || negligible_difference) {
                    return lighter_tone;
                } else {
                    return darker_tone;
                }
            } else {
                // For lighter backgrounds, prefer darker foreground
                // Use darker tone if it meets the ratio, or if it's at least as good as lighter
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

        private static bool should_force_light_mode_on_white (string name) {
            if (name == "inverse_on_surface") {
                return true;
            }

            if (!name.has_prefix ("on_")) {
                return false;
            }

            if (name.contains ("_surface") || name.contains ("_container") || name.contains ("_fixed") || name.contains ("_background")) {
                return false;
            }

            return true;
        }

        private static double finalize_tone_for_light_on_roles (DynamicScheme scheme, DynamicColor color, double tone) {
            if (!scheme.is_dark && should_force_light_mode_on_white (color.name)) {
                return 100.0;
            }

            return tone;
        }
    }
}