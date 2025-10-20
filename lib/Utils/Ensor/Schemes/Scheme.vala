/*
 * Copyright (c) 2024 Fyra Labs
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA
 */

/**
 * A class that contains the color scheme of the app.
 */
public class He.Scheme {
    public Scheme () {
    }

    /**
     * Finds the tone that maximizes chroma for a given palette within bounds.
     */
    public double t_max_c (TonalPalette palette, double lower_bound = 0.0, double upper_bound = 100.0, double chroma_multiplier = 1.0) {
        // Ensure bounds are valid
        lower_bound = MathUtils.clamp_double (0.0, 100.0, lower_bound);
        upper_bound = MathUtils.clamp_double (lower_bound, 100.0, upper_bound);
        double target_chroma = palette.chroma * chroma_multiplier;
        double answer = find_best_tone_for_chroma (palette.hue, target_chroma, 100.0, true);
        return MathUtils.clamp_double (lower_bound, upper_bound, answer);
    }

    /**
     * Finds the tone that minimizes chroma for a given palette within bounds.
     */
    public double t_min_c (TonalPalette palette, double lower_bound = 0.0, double upper_bound = 100.0) {
        // Ensure bounds are valid
        lower_bound = MathUtils.clamp_double (0.0, 100.0, lower_bound);
        upper_bound = MathUtils.clamp_double (lower_bound, 100.0, upper_bound);
        double answer = find_best_tone_for_chroma (palette.hue, palette.chroma, 0.0, false);
        return MathUtils.clamp_double (lower_bound, upper_bound, answer);
    }

    private double find_best_tone_for_chroma (double hue, double chroma, double tone, bool by_decreasing_tone) {
        double answer = tone;
        HCTColor best_candidate = from_params (hue, chroma, answer);

        while (best_candidate.c < chroma) {
            if (tone < 0.0 || tone > 100.0) {
                break;
            }

            tone += by_decreasing_tone ? -1.0 : 1.0;
            HCTColor candidate = from_params (hue, chroma, tone);

            if (best_candidate.c < candidate.c) {
                best_candidate = candidate;
                answer = tone;
            }
        }

        return answer;
    }

    private DynamicScheme clone_scheme (DynamicScheme scheme, bool is_dark, double contrast_level) {
        return new DynamicScheme (
                                  scheme.hct,
                                  scheme.variant,
                                  is_dark,
                                  contrast_level,
                                  scheme.primary,
                                  scheme.secondary,
                                  scheme.tertiary,
                                  scheme.neutral,
                                  scheme.neutral_variant,
                                  scheme.error,
                                  scheme.platform
        );
    }

    private DynamicColor copy_with_overrides (DynamicColor color, string? name = null, BackgroundFunc? background_override = null) {
        return new DynamicColor (
                                 name ?? color.name,
                                 color.palette,
                                 color.tone,
                                 color.chromamult,
                                 color.is_background,
                                 background_override != null ? background_override : color.background,
                                 color.second_background,
                                 color.contrast_curve,
                                 color.tone_delta_pair,
                                 color.contrast_curve_func,
                                 color.chroma_multiplier_func,
                                 color.opacity
        ).build ();
    }

    private DynamicColor copy_with_name (DynamicColor color, string name) {
        return copy_with_overrides (color, name, null);
    }

    public ContrastCurve get_curve (double def_c) {
        if (def_c == 1.0) { // 1.0 to keep things simple
            return new ContrastCurve (1.0, 1.0, 4.5, 11.0);
        } else if (def_c == 1.5) {
            return new ContrastCurve (1.5, 1.5, 3.0, 4.5);
        } else if (def_c == 3.0) {
            return new ContrastCurve (3.0, 3.0, 4.5, 7.0);
        } else if (def_c == 4.5) {
            return new ContrastCurve (4.5, 4.5, 7.0, 11.0);
        } else if (def_c == 6.0) {
            return new ContrastCurve (6.0, 6.0, 7.0, 11.0);
        } else if (def_c == 7.0) {
            return new ContrastCurve (7.0, 7.0, 11.0, 21.0);
        } else if (def_c == 9.0) {
            return new ContrastCurve (9.0, 9.0, 11.0, 21.0);
        } else if (def_c == 11.0) {
            return new ContrastCurve (11.0, 11.0, 21.0, 21.0);
        } else if (def_c == 21.0) {
            return new ContrastCurve (21.0, 21.0, 21.0, 21.0);
        } else {
            // Shouldn't happen - clamp to valid range
            double valid_c = MathUtils.max (1.0, def_c);
            return new ContrastCurve (valid_c, valid_c, 7.0, 21.0);
        }
    }

    public DynamicColor primary_key () {
        return new DynamicColor.from_palette (
                                              /* name= */ "primary_palette_key_color",
                                              /* palette= */ (s) => s.primary,
                                              /* tone= */ (s) => s.primary.key_color.t
        );
    }

    public DynamicColor secondary_key () {
        return new DynamicColor.from_palette (
                                              /* name= */ "secondary_palette_key_color",
                                              /* palette= */ (s) => s.secondary,
                                              /* tone= */ (s) => s.secondary.key_color.t
        );
    }

    public DynamicColor tertiary_key () {
        return new DynamicColor.from_palette (
                                              /* name= */ "tertiary_palette_key_color",
                                              /* palette= */ (s) => s.tertiary,
                                              /* tone= */ (s) => s.tertiary.key_color.t
        );
    }

    public DynamicColor neutral_key () {
        return new DynamicColor.from_palette (
                                              /* name= */ "neutral_palette_key_color",
                                              /* palette= */ (s) => s.neutral,
                                              /* tone= */ (s) => s.neutral.key_color.t
        );
    }

    public DynamicColor neutral_variant_key () {
        return new DynamicColor.from_palette (
                                              /* name= */ "neutral_variant_palette_key_color",
                                              /* palette= */ (s) => s.neutral_variant,
                                              /* tone= */ (s) => s.neutral_variant.key_color.t
        );
    }

    public DynamicColor background () {
        return copy_with_name (surface (), "background");
    }

    public DynamicColor on_background () {
        return copy_with_name (on_surface (), "on_background");
    }

    public DynamicColor surface () {
        return new DynamicColor (
                                 /* name= */ "surface",
                                 /* palette= */ (s) => s.neutral,
                                 /* tone= */ (s) => {
            if (s.is_dark) {
                return 4.0;
            }

            if (HCTColor.hue_is_yellow (s.neutral.hue)) {
                return 99.0;
            }

            if (s.variant == SchemeVariant.VIBRANT) {
                return 97.0;
            }

            return 98.0;
        },
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ true,
                                 /* background= */ null,
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ null,
                                 /* toneDeltaPair= */ null
        ).build ();
    }

    public DynamicColor surface_variant () {
        return copy_with_name (surface_container_highest (), "surface_variant");
    }

    public DynamicColor surface_tint () {
        return copy_with_name (primary (), "surface_tint");
    }

    public DynamicColor on_surface () {
        return new DynamicColor (
                                 /* name= */ "on_surface",
                                 /* palette= */ (s) => s.neutral,
                                 /* tone= */ (s) => {
            if (s.variant == SchemeVariant.VIBRANT) {
                return t_max_c (s.neutral, 0.0, 100.0, 1.1);
            }

            DynamicColor background = s.platform == SchemePlatform.DESKTOP ? (s.is_dark ? surface_bright () : surface_dim ()) : surface_container_high ();
            return background.get_tone_from_scheme (s);
        },
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ false,
                                 /* background= */ (s) => {
            if (s.platform == SchemePlatform.DESKTOP) {
                return s.is_dark ? surface_bright () : surface_dim ();
            }

            return surface_container_high ();
        },
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ null,
                                 /* toneDeltaPair= */ null,
                                 /* contrastCurveFunc= */ (s) => s.is_dark ? get_curve (11.0) : get_curve (9.0),
                                 /* chromaMultiplierFunc= */ (s) => {
            if (s.platform == SchemePlatform.DESKTOP) {
                if (s.variant == SchemeVariant.MUTED) {
                    return 2.2;
                } else if (s.variant == SchemeVariant.DEFAULT) {
                    return 1.7;
                } else if (s.variant == SchemeVariant.SALAD) {
                    return HCTColor.hue_is_yellow (s.neutral.hue) ? (s.is_dark ? 3.0 : 2.3) : 1.6;
                }
            }

            return 1.0;
        }).build ();
    }

    public DynamicColor on_surface_variant () {
        return new DynamicColor (
                                 /* name= */ "on_surface_variant",
                                 /* palette= */ (s) => s.neutral,
                                 /* tone= */ null,
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ false,
                                 /* background= */ (s) => {
            if (s.platform == SchemePlatform.DESKTOP) {
                return s.is_dark ? surface_bright () : surface_dim ();
            }

            return surface_container_high ();
        },
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ null,
                                 /* toneDeltaPair= */ null,
                                 /* contrastCurveFunc= */ (s) => s.platform == SchemePlatform.DESKTOP ? (s.is_dark ? get_curve (6.0) : get_curve (4.5)) : get_curve (7.0),
                                 /* chromaMultiplierFunc= */ (s) => {
            if (s.platform == SchemePlatform.DESKTOP) {
                if (s.variant == SchemeVariant.MUTED) {
                    return 2.2;
                } else if (s.variant == SchemeVariant.DEFAULT) {
                    return 1.7;
                } else if (s.variant == SchemeVariant.SALAD) {
                    return HCTColor.hue_is_yellow (s.neutral.hue) ? (s.is_dark ? 3.0 : 2.3) : 1.6;
                }
            }

            return 1.0;
        }).build ();
    }

    public DynamicColor outline () {
        return new DynamicColor (
                                 /* name= */ "outline",
                                 /* palette= */ (s) => s.neutral,
                                 /* tone= */ null,
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ false,
                                 /* background= */ (s) => {
            if (s.platform == SchemePlatform.DESKTOP) {
                return s.is_dark ? surface_bright () : surface_dim ();
            }

            return surface_container_high ();
        },
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ null,
                                 /* toneDeltaPair= */ null,
                                 /* contrastCurveFunc= */ (s) => s.platform == SchemePlatform.DESKTOP ? get_curve (3.0) : get_curve (4.5),
                                 /* chromaMultiplierFunc= */ (s) => {
            if (s.platform == SchemePlatform.DESKTOP) {
                if (s.variant == SchemeVariant.MUTED) {
                    return 2.2;
                } else if (s.variant == SchemeVariant.DEFAULT) {
                    return 1.7;
                } else if (s.variant == SchemeVariant.SALAD) {
                    return HCTColor.hue_is_yellow (s.neutral.hue) ? (s.is_dark ? 3.0 : 2.3) : 1.6;
                }
            }

            return 1.0;
        }).build ();
    }

    public DynamicColor outline_variant () {
        return new DynamicColor (
                                 /* name= */ "outline_variant",
                                 /* palette= */ (s) => s.neutral,
                                 /* tone= */ null,
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ false,
                                 /* background= */ (s) => {
            if (s.platform == SchemePlatform.DESKTOP) {
                return s.is_dark ? surface_bright () : surface_dim ();
            }

            return surface_container_high ();
        },
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ null,
                                 /* toneDeltaPair= */ null,
                                 /* contrastCurveFunc= */ (s) => s.platform == SchemePlatform.DESKTOP ? get_curve (1.5) : get_curve (3.0),
                                 /* chromaMultiplierFunc= */ (s) => {
            if (s.platform == SchemePlatform.DESKTOP) {
                if (s.variant == SchemeVariant.MUTED) {
                    return 2.2;
                } else if (s.variant == SchemeVariant.DEFAULT) {
                    return 1.7;
                } else if (s.variant == SchemeVariant.SALAD) {
                    return HCTColor.hue_is_yellow (s.neutral.hue) ? (s.is_dark ? 3.0 : 2.3) : 1.6;
                }
            }

            return 1.0;
        }).build ();
    }

    public DynamicColor inverse_surface () {
        return new DynamicColor (
                                 /* name= */ "inverse_surface",
                                 /* palette= */ (s) => s.neutral,
                                 /* tone= */ (s) => s.is_dark ? 98.0 : 4.0,
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ true,
                                 /* background= */ null,
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ null,
                                 /* toneDeltaPair= */ null
        ).build ();
    }

    public DynamicColor inverse_on_surface () {
        return new DynamicColor (
                                 /* name= */ "inverse_on_surface",
                                 /* palette= */ (s) => s.neutral,
                                 /* tone= */ null,
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ false,
                                 /* background= */ (s) => inverse_surface (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ get_curve (7.0),
                                 /* toneDeltaPair= */ null
        ).build ();
    }

    public DynamicColor inverse_primary () {
        return new DynamicColor (
                                 /* name= */ "inverse_primary",
                                 /* palette= */ (s) => s.primary,
                                 /* tone= */ (s) => t_max_c (s.primary),
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ false,
                                 /* background= */ (s) => inverse_surface (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ get_curve (6.0),
                                 /* toneDeltaPair= */ null
        ).build ();
    }

    public DynamicColor surface_bright () {
        return new DynamicColor (
                                 /* name= */ "surface_bright",
                                 /* palette= */ (s) => s.neutral,
                                 /* tone= */ (s) => {
            if (s.is_dark) {
                return 18.0;
            }

            if (HCTColor.hue_is_yellow (s.neutral.hue)) {
                return 99.0;
            }

            if (s.variant == SchemeVariant.VIBRANT) {
                return 97.0;
            }

            return 98.0;
        },
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ true,
                                 /* background= */ null,
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ null,
                                 /* toneDeltaPair= */ null,
                                 /* contrastCurveFunc= */ null,
                                 /* chromaMultiplierFunc= */ (s) => {
            if (s.is_dark) {
                if (s.variant == SchemeVariant.MUTED) {
                    return 2.5;
                } else if (s.variant == SchemeVariant.DEFAULT) {
                    return 1.7;
                } else if (s.variant == SchemeVariant.SALAD) {
                    return HCTColor.hue_is_yellow (s.neutral.hue) ? 2.7 : 1.75;
                } else if (s.variant == SchemeVariant.VIBRANT) {
                    return 1.36;
                }
            }

            return 1.0;
        }).build ();
    }

    public DynamicColor surface_dim () {
        return new DynamicColor (
                                 /* name= */ "surface_dim",
                                 /* palette= */ (s) => s.neutral,
                                 /* tone= */ (s) => {
            if (s.is_dark) {
                return 4.0;
            }

            if (HCTColor.hue_is_yellow (s.neutral.hue)) {
                return 90.0;
            }

            if (s.variant == SchemeVariant.VIBRANT) {
                return 85.0;
            }

            return 87.0;
        },
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ true,
                                 /* background= */ null,
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ null,
                                 /* toneDeltaPair= */ null,
                                 /* contrastCurveFunc= */ null,
                                 /* chromaMultiplierFunc= */ (s) => {
            if (!s.is_dark) {
                if (s.variant == SchemeVariant.MUTED) {
                    return 2.5;
                } else if (s.variant == SchemeVariant.DEFAULT) {
                    return 1.7;
                } else if (s.variant == SchemeVariant.SALAD) {
                    return HCTColor.hue_is_yellow (s.neutral.hue) ? 2.7 : 1.75;
                } else if (s.variant == SchemeVariant.VIBRANT) {
                    return 1.36;
                }
            }

            return 1.0;
        }).build ();
    }

    public DynamicColor surface_container_lowest () {
        return new DynamicColor (
                                 /* name= */ "surface_container_lowest",
                                 /* palette= */ (s) => s.neutral,
                                 /* tone= */ (s) => s.is_dark ? 0.0 : 100.0,
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ true,
                                 /* background= */ null,
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ null,
                                 /* toneDeltaPair= */ null
        ).build ();
    }

    public DynamicColor surface_container_low () {
        return new DynamicColor (
                                 /* name= */ "surface_container_low",
                                 /* palette= */ (s) => s.neutral,
                                 /* tone= */ (s) => {
            if (s.platform == SchemePlatform.DESKTOP) {
                if (s.is_dark) {
                    return 6.0;
                }

                if (HCTColor.hue_is_yellow (s.neutral.hue)) {
                    return 98.0;
                }

                if (s.variant == SchemeVariant.VIBRANT) {
                    return 95.0;
                }

                return 96.0;
            }

            return 96.0;
        },
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ true,
                                 /* background= */ null,
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ null,
                                 /* toneDeltaPair= */ null,
                                 /* contrastCurveFunc= */ null,
                                 /* chromaMultiplierFunc= */ (s) => {
            if (s.platform == SchemePlatform.DESKTOP) {
                if (s.variant == SchemeVariant.MUTED) {
                    return 1.3;
                } else if (s.variant == SchemeVariant.DEFAULT) {
                    return 1.25;
                } else if (s.variant == SchemeVariant.SALAD) {
                    return HCTColor.hue_is_yellow (s.neutral.hue) ? 1.3 : 1.15;
                } else if (s.variant == SchemeVariant.VIBRANT) {
                    return 1.08;
                }
            }

            return 1.0;
        }).build ();
    }

    public DynamicColor surface_container () {
        return new DynamicColor (
                                 /* name= */ "surface_container",
                                 /* palette= */ (s) => s.neutral,
                                 /* tone= */ (s) => {
            if (s.platform == SchemePlatform.DESKTOP) {
                if (s.is_dark) {
                    return 9.0;
                }

                if (HCTColor.hue_is_yellow (s.neutral.hue)) {
                    return 96.0;
                }

                if (s.variant == SchemeVariant.VIBRANT) {
                    return 92.0;
                }

                return 94.0;
            }

            return 94.0;
        },
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ true,
                                 /* background= */ null,
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ null,
                                 /* toneDeltaPair= */ null,
                                 /* contrastCurveFunc= */ null,
                                 /* chromaMultiplierFunc= */ (s) => {
            if (s.platform == SchemePlatform.DESKTOP) {
                if (s.variant == SchemeVariant.MUTED) {
                    return 1.6;
                } else if (s.variant == SchemeVariant.DEFAULT) {
                    return 1.4;
                } else if (s.variant == SchemeVariant.SALAD) {
                    return HCTColor.hue_is_yellow (s.neutral.hue) ? 1.6 : 1.3;
                } else if (s.variant == SchemeVariant.VIBRANT) {
                    return 1.15;
                }
            }

            return 1.0;
        }).build ();
    }

    public DynamicColor surface_container_high () {
        return new DynamicColor (
                                 /* name= */ "surface_container_high",
                                 /* palette= */ (s) => s.neutral,
                                 /* tone= */ (s) => {
            if (s.platform == SchemePlatform.DESKTOP) {
                if (s.is_dark) {
                    return 12.0;
                }

                if (HCTColor.hue_is_yellow (s.neutral.hue)) {
                    return 94.0;
                }

                if (s.variant == SchemeVariant.VIBRANT) {
                    return 90.0;
                }

                return 92.0;
            }

            return 92.0;
        },
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ true,
                                 /* background= */ null,
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ null,
                                 /* toneDeltaPair= */ null,
                                 /* contrastCurveFunc= */ null,
                                 /* chromaMultiplierFunc= */ (s) => {
            if (s.platform == SchemePlatform.DESKTOP) {
                if (s.variant == SchemeVariant.MUTED) {
                    return 1.9;
                } else if (s.variant == SchemeVariant.DEFAULT) {
                    return 1.5;
                } else if (s.variant == SchemeVariant.SALAD) {
                    return HCTColor.hue_is_yellow (s.neutral.hue) ? 1.95 : 1.45;
                } else if (s.variant == SchemeVariant.VIBRANT) {
                    return 1.22;
                }
            }

            return 1.0;
        }).build ();
    }

    public DynamicColor surface_container_highest () {
        return new DynamicColor (
                                 /* name= */ "surface_container_highest",
                                 /* palette= */ (s) => s.neutral,
                                 /* tone= */ (s) => {
            if (s.is_dark) {
                return 15.0;
            }

            if (HCTColor.hue_is_yellow (s.neutral.hue)) {
                return 92.0;
            }

            if (s.variant == SchemeVariant.VIBRANT) {
                return 88.0;
            }

            return 90.0;
        },
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ true,
                                 /* background= */ null,
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ null,
                                 /* toneDeltaPair= */ null,
                                 /* contrastCurveFunc= */ null,
                                 /* chromaMultiplierFunc= */ (s) => {
            if (s.variant == SchemeVariant.MUTED) {
                return 2.2;
            } else if (s.variant == SchemeVariant.DEFAULT) {
                return 1.7;
            } else if (s.variant == SchemeVariant.SALAD) {
                return HCTColor.hue_is_yellow (s.neutral.hue) ? 2.3 : 1.6;
            } else if (s.variant == SchemeVariant.VIBRANT) {
                return 1.29;
            }

            return 1.0;
        }).build ();
    }

    public DynamicColor primary () {
        return new DynamicColor (
                                 /* name= */ "primary",
                                 /* palette= */ (s) => s.primary,
                                 /* tone= */ (s) => {
            if (s.variant == SchemeVariant.MUTED) {
                if (s.platform == SchemePlatform.DESKTOP) {
                    return s.is_dark ? 80.0 : 40.0;
                }

                return 90.0;
            }

            if (s.variant == SchemeVariant.DEFAULT) {
                if (s.platform == SchemePlatform.DESKTOP) {
                    return s.is_dark ? 80.0 : t_max_c (s.primary);
                }

                return t_max_c (s.primary, 0, 90);
            }

            if (s.variant == SchemeVariant.SALAD) {
                return t_max_c (
                                s.primary,
                                0,
                                HCTColor.hue_is_yellow (s.primary.hue)
                                                               ? 25
                                                               : HCTColor.hue_is_cyan (s.primary.hue) ? 88 : 98);
            }

            return t_max_c (s.primary, 0, HCTColor.hue_is_cyan (s.primary.hue) ? 88 : 98);
        },
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ true,
                                 /* background= */ (s) => {
            if (s.platform == SchemePlatform.DESKTOP) {
                return s.is_dark ? surface_bright () : surface_dim ();
            }

            return surface_container_high ();
        },
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ null,
                                 /* toneDeltaPair= */ (s) => s.platform == SchemePlatform.DESKTOP ? new ToneDeltaPair (primary_container (), primary (), 5.0, TonePolarity.RELATIVE_LIGHTER, ToneResolve.FARTHER) : null,
                                 /* contrastCurveFunc= */ (s) => s.platform == SchemePlatform.DESKTOP ? get_curve (4.5) : get_curve (7.0)
        ).build ();
    }

    public DynamicColor primary_dim () {
        return new DynamicColor (
                                 /* name= */ "primary_dim",
                                 /* palette= */ (s) => s.primary,
                                 /* tone= */ (s) => {
            if (s.variant == SchemeVariant.MUTED) {
                return 85.0;
            }

            if (s.variant == SchemeVariant.DEFAULT) {
                return t_max_c (s.primary, 0, 90);
            }

            return t_max_c (s.primary);
        },
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ true,
                                 /* background= */ (s) => surface_container_high (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ null,
                                 /* toneDeltaPair= */ (s) => new ToneDeltaPair (primary_dim (), primary (), 5.0, TonePolarity.DARKER, ToneResolve.FARTHER),
                                 /* contrastCurveFunc= */ (s) => get_curve (4.5)
        ).build ();
    }

    public DynamicColor primary_fixed () {
        return new DynamicColor (
                                 /* name= */ "primary_fixed",
                                 /* palette= */ (s) => s.primary,
                                 /* tone= */ (s) => {
            DynamicScheme temp_scheme = clone_scheme (s, false, 0.0);
            return primary_container ().get_tone_from_scheme (temp_scheme);
        },
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ true,
                                 /* background= */ (s) => s.is_dark ? surface_bright () : surface_dim (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ null,
                                 /* toneDeltaPair= */ null
        ).build ();
    }

    public DynamicColor primary_fixed_dim () {
        return new DynamicColor (
                                 /* name= */ "primary_fixed_dim",
                                 /* palette= */ (s) => s.primary,
                                 /* tone= */ (s) => primary_fixed ().get_tone_from_scheme (s),
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ true,
                                 /* background= */ null,
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ null,
                                 /* toneDeltaPair= */ (s) => new ToneDeltaPair (primary_fixed_dim (), primary_fixed (), 5.0, TonePolarity.DARKER, ToneResolve.EXACT)
        ).build ();
    }

    public DynamicColor on_primary_fixed () {
        return new DynamicColor (
                                 /* name= */ "on_primary_fixed",
                                 /* palette= */ (s) => s.primary,
                                 /* tone= */ null,
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ false,
                                 /* background= */ (s) => primary_fixed_dim (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ null,
                                 /* toneDeltaPair= */ null,
                                 /* contrastCurveFunc= */ (s) => get_curve (7.0)
        ).build ();
    }

    public DynamicColor on_primary_fixed_variant () {
        return new DynamicColor (
                                 /* name= */ "on_primary_fixed_variant",
                                 /* palette= */ (s) => s.primary,
                                 /* tone= */ null,
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ false,
                                 /* background= */ (s) => primary_fixed_dim (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ null,
                                 /* toneDeltaPair= */ null,
                                 /* contrastCurveFunc= */ (s) => get_curve (4.5)
        ).build ();
    }

    public DynamicColor on_primary () {
        return new DynamicColor (
                                 /* name= */ "on_primary",
                                 /* palette= */ (s) => s.primary,
                                 /* tone= */ null,
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ false,
                                 /* background= */ (s) => s.platform == SchemePlatform.DESKTOP ? primary () : primary_dim (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ null,
                                 /* toneDeltaPair= */ null,
                                 /* contrastCurveFunc= */ (s) => s.platform == SchemePlatform.DESKTOP ? get_curve (6.0) : get_curve (7.0)
        ).build ();
    }

    public DynamicColor primary_container () {
        return new DynamicColor (
                                 /* name= */ "primary_container",
                                 /* palette= */ (s) => s.primary,
                                 /* tone= */ (s) => {
            if (s.variant == SchemeVariant.MUTED) {
                return s.is_dark ? 30.0 : 90.0;
            }

            if (s.variant == SchemeVariant.DEFAULT) {
                if (s.is_dark) {
                    return 80.0;
                } else {
                    return t_max_c (s.primary);
                }
            }

            if (s.variant == SchemeVariant.SALAD) {
                return s.is_dark
                                         ? t_max_c (s.primary, 30, 93)
                                         : t_max_c (s.primary, 78, HCTColor.hue_is_cyan (s.primary.hue) ? 88 : 90);
            }

            return s.is_dark
                                     ? t_min_c (s.primary, 66, 93)
                                     : t_max_c (s.primary, 66, HCTColor.hue_is_cyan (s.primary.hue) ? 88 : 93);
        },
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ true,
                                 /* background= */ (s) => {
            if (s.platform == SchemePlatform.DESKTOP) {
                return s.is_dark ? surface_bright () : surface_dim ();
            }

            return null;
        },
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ null,
                                 /* toneDeltaPair= */ null,
                                 /* contrastCurveFunc= */ (s) => (s.platform == SchemePlatform.DESKTOP && s.contrast_level > 0.0) ? get_curve (1.5) : null,
                                 /* chromaMultiplierFunc= */ (s) => 1.0
        ).build ();
    }

    public DynamicColor on_primary_container () {
        return new DynamicColor (
                                 /* name= */ "on_primary_container",
                                 /* palette= */ (s) => s.primary,
                                 /* tone= */ null,
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ false,
                                 /* background= */ (s) => primary_container (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ null,
                                 /* toneDeltaPair= */ null,
                                 /* contrastCurveFunc= */ (s) => s.platform == SchemePlatform.DESKTOP ? get_curve (6.0) : get_curve (7.0)
        ).build ();
    }

    public DynamicColor secondary () {
        return new DynamicColor (
                                 /* name= */ "secondary",
                                 /* palette= */ (s) => s.secondary,
                                 /* tone= */ (s) => {
            if (s.variant == SchemeVariant.DEFAULT) {
                // DEFAULT uses bounded dynamic selection
                return s.is_dark
                                             ? 80.0
                                             : t_max_c (s.secondary);
            } else if (s.variant == SchemeVariant.MUTED) {
                return s.is_dark
                                             ? t_min_c (s.secondary, 0, 98)
                                             : t_max_c (s.secondary);
            } else if (s.variant == SchemeVariant.SALAD) {
                return t_max_c (s.secondary, 0, s.is_dark ? 90 : 98);
            } else { // VIBRANT and other variants
                return s.is_dark
                                             ? t_max_c (s.secondary, 75, 85)
                                             : t_max_c (s.secondary, 35, 45);
            }
        },
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ true,
                                 /* background= */ (s) => s.is_dark ? surface_bright () : surface_dim (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ get_curve (4.5),
                                 /* toneDeltaPair= */ (s) => new ToneDeltaPair (secondary_container (), secondary (), 5.0, TonePolarity.RELATIVE_LIGHTER, ToneResolve.FARTHER)
        ).build ();
    }

    public DynamicColor on_secondary () {
        return new DynamicColor (
                                 /* name= */ "on_secondary",
                                 /* palette= */ (s) => s.secondary,
                                 /* tone= */ null,
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ false,
                                 /* background= */ (s) => secondary (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ get_curve (6.0),
                                 /* toneDeltaPair= */ null
        ).build ();
    }

    public DynamicColor secondary_dim () {
        return new DynamicColor (
                                 /* name= */ "secondary_dim",
                                 /* palette= */ (s) => s.secondary,
                                 /* tone= */ (s) => { return t_max_c (s.secondary, 0, 90); },
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ false,
                                 /* background= */ (s) => surface_container_high (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ get_curve (4.5),
                                 /* toneDeltaPair= */ (s) => new ToneDeltaPair (secondary_dim (), secondary (), 5.0, TonePolarity.DARKER, ToneResolve.FARTHER)
        ).build ();
    }

    public DynamicColor secondary_fixed () {
        return new DynamicColor (
                                 /* name= */ "secondary_fixed",
                                 /* palette= */ (s) => s.secondary,
                                 /* tone= */ (s) => {
            DynamicScheme temp_scheme = clone_scheme (s, false, 0.0);
            return secondary_container ().get_tone_from_scheme (temp_scheme);
        },
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ true,
                                 /* background= */ (s) => s.is_dark ? surface_bright () : surface_dim (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ null,
                                 /* toneDeltaPair= */ null
        ).build ();
    }

    public DynamicColor secondary_fixed_dim () {
        return new DynamicColor (
                                 /* name= */ "secondary_fixed_dim",
                                 /* palette= */ (s) => s.secondary,
                                 /* tone= */ (s) => secondary_fixed ().get_tone_from_scheme (s),
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ true,
                                 /* background= */ (s) => surface_container_high (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ null,
                                 /* toneDeltaPair= */ (s) => new ToneDeltaPair (secondary_fixed_dim (), secondary_fixed (), 5.0, TonePolarity.DARKER, ToneResolve.EXACT)
        ).build ();
    }

    public DynamicColor on_secondary_fixed () {
        return new DynamicColor (
                                 /* name= */ "on_secondary_fixed",
                                 /* palette= */ (s) => s.secondary,
                                 /* tone= */ null,
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ false,
                                 /* background= */ (s) => secondary_fixed_dim (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ get_curve (7.0),
                                 /* toneDeltaPair= */ null
        ).build ();
    }

    public DynamicColor on_secondary_fixed_variant () {
        return new DynamicColor (
                                 /* name= */ "on_secondary_fixed_variant",
                                 /* palette= */ (s) => s.secondary,
                                 /* tone= */ null,
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ false,
                                 /* background= */ (s) => secondary_fixed_dim (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ get_curve (4.5),
                                 /* toneDeltaPair= */ null
        ).build ();
    }

    public DynamicColor secondary_container () {
        return new DynamicColor (
                                 /* name= */ "secondary_container",
                                 /* palette= */ (s) => s.secondary,
                                 /* tone= */ (s) => {
            if (s.variant == SchemeVariant.DEFAULT) {
                return s.is_dark ? 25.0 : 90.0;
            } else if (s.variant == SchemeVariant.MUTED) {
                return s.is_dark
                                             ? t_max_c (s.secondary, 20, 30)
                                             : t_min_c (s.secondary, 85, 95);
            } else if (s.variant == SchemeVariant.VIBRANT) {
                return s.is_dark
                                             ? t_min_c (s.secondary, 30, 40)
                                             : t_max_c (s.secondary, 84, 90);
            } else if (s.variant == SchemeVariant.SALAD) {
                return s.is_dark ? 15.0 : t_max_c (s.secondary, 90, 95);
            } else { // Other variants
                return s.is_dark
                                             ? 25.0
                                             : 90.0;
            }
        },
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ true,
                                 /* background= */ (s) => s.is_dark ? surface_bright () : surface_dim (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ null,
                                 /* toneDeltaPair= */ null,
                                 /* contrastCurveFunc= */ (s) => s.contrast_level > 0 ? get_curve (1.5) : null,
                                 /* chromaMultiplierFunc= */ (s) => { return 1.0; }).build ();
    }

    public DynamicColor on_secondary_container () {
        return new DynamicColor (
                                 /* name= */ "on_secondary_container",
                                 /* palette= */ (s) => s.secondary,
                                 /* tone= */ null,
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ false,
                                 /* background= */ (s) => secondary_container (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ get_curve (6.0),
                                 /* toneDeltaPair= */ null
        ).build ();
    }

    public DynamicColor tertiary () {
        return new DynamicColor (
                                 /* name= */ "tertiary",
                                 /* palette= */ (s) => s.tertiary,
                                 /* tone= */ (s) => {
            if (s.variant == SchemeVariant.DEFAULT) {
                // DEFAULT uses bounded dynamic selection
                return s.is_dark ? t_max_c (s.tertiary, 0, 98) : t_max_c (s.tertiary);
            } else if (s.variant == SchemeVariant.MUTED || s.variant == SchemeVariant.SALAD) {
                return t_max_c (
                                s.tertiary,
                                /* lowerBound= */ 0,
                                /* upperBound= */ HCTColor.hue_is_cyan (s.tertiary.hue)
                                                             ? 88
                                                             : (s.is_dark ? 98 : 100));
            } else { // VIBRANT and other variants
                return s.is_dark
                                             ? t_max_c (s.tertiary, 75, 85)
                                             : t_max_c (s.tertiary, 35, 45);
            }
        },
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ true,
                                 /* background= */ (s) => s.is_dark ? surface_bright () : surface_dim (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ get_curve (4.5),
                                 /* toneDeltaPair= */ (s) => new ToneDeltaPair (tertiary_container (), tertiary (), 5.0, TonePolarity.RELATIVE_LIGHTER, ToneResolve.FARTHER)
        ).build ();
    }

    public DynamicColor tertiary_dim () {
        return new DynamicColor (
                                 /* name= */ "tertiary_dim",
                                 /* palette= */ (s) => s.tertiary,
                                 /* tone= */ (s) => { return t_max_c (s.tertiary, 0, 90); },
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ false,
                                 /* background= */ (s) => surface_container_high (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ get_curve (4.5),
                                 /* toneDeltaPair= */ (s) => new ToneDeltaPair (tertiary_dim (), tertiary (), 5.0, TonePolarity.DARKER, ToneResolve.FARTHER)
        ).build ();
    }

    public DynamicColor tertiary_fixed () {
        return new DynamicColor (
                                 /* name= */ "tertiary_fixed",
                                 /* palette= */ (s) => s.tertiary,
                                 /* tone= */ (s) => {
            DynamicScheme temp_scheme = clone_scheme (s, false, 0.0);
            return tertiary_container ().get_tone_from_scheme (temp_scheme);
        },
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ true,
                                 /* background= */ (s) => s.is_dark ? surface_bright () : surface_dim (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ null,
                                 /* toneDeltaPair= */ null
        ).build ();
    }

    public DynamicColor tertiary_fixed_dim () {
        return new DynamicColor (
                                 /* name= */ "tertiary_fixed_dim",
                                 /* palette= */ (s) => s.tertiary,
                                 /* tone= */ (s) => tertiary_fixed ().get_tone_from_scheme (s),
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ true,
                                 /* background= */ (s) => surface_container_high (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ null,
                                 /* toneDeltaPair= */ (s) => new ToneDeltaPair (tertiary_fixed_dim (), tertiary_fixed (), 5.0, TonePolarity.DARKER, ToneResolve.EXACT)
        ).build ();
    }

    public DynamicColor on_tertiary_fixed () {
        return new DynamicColor (
                                 /* name= */ "on_tertiary_fixed",
                                 /* palette= */ (s) => s.tertiary,
                                 /* tone= */ null,
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ false,
                                 /* background= */ (s) => tertiary_fixed_dim (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ get_curve (7.0),
                                 /* toneDeltaPair= */ null
        ).build ();
    }

    public DynamicColor on_tertiary_fixed_variant () {
        return new DynamicColor (
                                 /* name= */ "on_tertiary_fixed_variant",
                                 /* palette= */ (s) => s.tertiary,
                                 /* tone= */ null,
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ false,
                                 /* background= */ (s) => tertiary_fixed_dim (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ get_curve (4.5),
                                 /* toneDeltaPair= */ null
        ).build ();
    }

    public DynamicColor on_tertiary () {
        return new DynamicColor (
                                 /* name= */ "on_tertiary",
                                 /* palette= */ (s) => s.tertiary,
                                 /* tone= */ null,
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ false,
                                 /* background= */ (s) => tertiary (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ get_curve (6.0),
                                 /* toneDeltaPair= */ null
        ).build ();
    }

    public DynamicColor tertiary_container () {
        return new DynamicColor (
                                 /* name= */ "tertiary_container",
                                 /* palette= */ (s) => s.tertiary,
                                 /* tone= */ (s) => {
            if (s.variant == SchemeVariant.DEFAULT) {
                return t_max_c (s.tertiary, 0, s.is_dark ? 93 : 100);;
            } else if (s.variant == SchemeVariant.MUTED) {
                return s.is_dark
                                             ? t_max_c (s.tertiary, 0, 93)
                                             : t_max_c (s.tertiary, 0, 96);
            } else if (s.variant == SchemeVariant.SALAD) {
                return t_max_c (
                                s.tertiary,
                                /* lowerBound= */ 75,
                                /* upperBound= */ HCTColor.hue_is_cyan (s.tertiary.hue)
                                                             ? 88
                                                             : (s.is_dark ? 93 : 100));
            } else { // VIBRANT and other variants
                return s.is_dark
                                             ? t_max_c (s.tertiary, 0, 93)
                                             : t_max_c (s.tertiary, 72, 100);
            }
        },
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ true,
                                 /* background= */ (s) => s.is_dark ? surface_bright () : surface_dim (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ null,
                                 /* toneDeltaPair= */ null,
                                 /* contrastCurveFunc= */ (s) => {
            return s.contrast_level > 0 ? get_curve (1.5) : null;
        },
                                 /* chromaMultiplierFunc= */ (s) => {
            return 1.0;
        }).build ();
    }

    public DynamicColor on_tertiary_container () {
        return new DynamicColor (
                                 /* name= */ "on_tertiary_container",
                                 /* palette= */ (s) => s.tertiary,
                                 /* tone= */ null,
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ false,
                                 /* background= */ (s) => tertiary_container (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ get_curve (6.0),
                                 /* toneDeltaPair= */ null
        ).build ();
    }

    public DynamicColor shadow () {
        return new DynamicColor (
                                 /* name= */ "shadow",
                                 /* palette= */ (s) => s.neutral,
                                 /* tone= */ (s) => 0.0,
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ false,
                                 /* background= */ null,
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ null,
                                 /* toneDeltaPair= */ null
        ).build ();
    }

    public DynamicColor scrim () {
        return new DynamicColor (
                                 /* name= */ "scrim",
                                 /* palette= */ (s) => s.neutral,
                                 /* tone= */ (s) => 0.0,
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ false,
                                 /* background= */ null,
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ null,
                                 /* toneDeltaPair= */ null
        ).build ();
    }

    public DynamicColor error_dim () {
        return new DynamicColor (
                                 /* name= */ "error_dim",
                                 /* palette= */ (s) => s.error,
                                 /* tone= */ (s) => t_min_c (s.error),
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ true,
                                 /* background= */ (s) => surface_container_high (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ get_curve (4.5),
                                 /* toneDeltaPair= */ (s) => new ToneDeltaPair (error_dim (), error (), 5.0, TonePolarity.DARKER, ToneResolve.FARTHER)
        ).build ();
    }

    public DynamicColor error () {
        return new DynamicColor (
                                 /* name= */ "error",
                                 /* palette= */ (s) => s.error,
                                 /* tone= */ (s) => s.is_dark ? t_min_c (s.error, 0, 98) : t_max_c (s.error),
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ true,
                                 /* background= */ (s) => s.is_dark ? surface_bright () : surface_dim (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ get_curve (4.5),
                                 /* toneDeltaPair= */ (s) => new ToneDeltaPair (error_container (), error (), 5.0, TonePolarity.RELATIVE_LIGHTER, ToneResolve.FARTHER)
        ).build ();
    }

    public DynamicColor on_error () {
        return new DynamicColor (
                                 /* name= */ "on_error",
                                 /* palette= */ (s) => s.error,
                                 /* tone= */ null,
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ false,
                                 /* background= */ (s) => error (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ get_curve (6.0),
                                 /* toneDeltaPair= */ null
        ).build ();
    }

    public DynamicColor error_container () {
        return new DynamicColor (
                                 /* name= */ "error_container",
                                 /* palette= */ (s) => s.error,
                                 /* tone= */ (s) => {
            if (s.is_dark) {
                return t_min_c (s.error, 30, 93);
            }

            if (s.variant == SchemeVariant.DEFAULT) {
                return 90.0;
            }

            return t_max_c (s.error, 0, 90);
        },
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ true,
                                 /* background= */ (s) => s.is_dark ? surface_bright () : surface_dim (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ get_curve (1.0),
                                 /* toneDeltaPair= */ null
        ).build ();
    }

    public DynamicColor on_error_container () {
        return new DynamicColor (
                                 /* name= */ "on_error_container",
                                 /* palette= */ (s) => s.error,
                                 /* tone= */ null,
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ false,
                                 /* background= */ (s) => error_container (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ get_curve (6.0),
                                 /* toneDeltaPair= */ null
        ).build ();
    }

    public DynamicColor control_activated () {
        return copy_with_name (primary_container (), "control_activated");
    }

    public DynamicColor control_normal () {
        return copy_with_name (on_surface_variant (), "control_normal");
    }

    public DynamicColor text_primary_inverse () {
        return copy_with_name (inverse_on_surface (), "text_primary_inverse");
    }
}