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

    public double t_max_c (TonalPalette palette, double lower_bound = 0.0, double upper_bound = 100.0, double chroma_multiplier = 1.0) {
        double answer = find_best_tone_for_chroma (palette.hue, palette.chroma * chroma_multiplier, 100.0, true);
        return MathUtils.clamp_double (lower_bound, upper_bound, answer);
    }

    public double t_min_c (TonalPalette palette, double lower_bound = 0.0, double upper_bound = 100.0) {
        double answer = find_best_tone_for_chroma (palette.hue, palette.chroma, 0.0, false);
        return MathUtils.clamp_double (lower_bound, upper_bound, answer);
    }

    public double find_best_tone_for_chroma (double hue, double chroma, double tone, bool by_decreasing_tone) {
        double answer = tone;
        HCTColor best_candidate = from_params (hue, chroma, answer);

        while (best_candidate.c < chroma) {
            if (tone < 0.0 || tone > 100.0) {
                break;
            }
            tone += by_decreasing_tone ? -1.0 : 1.0;
            HCTColor new_candidate = from_params (hue, chroma, tone);
            if (best_candidate.c < new_candidate.c) {
                best_candidate = new_candidate;
                answer = tone;
            }
        }

        return answer;
    }

    public ContrastCurve get_curve (double def_c) {
        if (def_c == 1.5) {
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
            // Shouldn't happen.
            return new ContrastCurve (def_c, def_c, 7.0, 21.0);
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
        return surface ().build ();
    }

    public DynamicColor on_background () {
        return on_surface ().build ();
    }

    public DynamicColor surface () {
        return new DynamicColor (
                                 /* name= */ "surface",
                                 /* palette= */ (s) => s.neutral,
                                 /* tone= */ (s) => s.is_dark ? 4.0 : (hue_is_yellow (s.neutral.hue) ? 99.0 : s.variant == SchemeVariant.VIBRANT ? 97.0 : 98.0),
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ true,
                                 /* background= */ null,
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ null,
                                 /* toneDeltaPair= */ null
        ).build ();
    }

    public DynamicColor surface_variant () {
        return surface_container_highest ().build ();
    }

    public DynamicColor on_surface () {
        return new DynamicColor (
                                 /* name= */ "on_surface",
                                 /* palette= */ (s) => s.neutral,
                                 /* tone= */ (s) => 100.0,
                                 /* chroma_multiplier */ 1.7,
                                 /* isBackground= */ false,
                                 /* background= */ (s) => s.is_dark ? surface_bright () : surface_dim (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ get_curve (9.0),
                                 /* toneDeltaPair= */ null
        ).build ();
    }

    public DynamicColor on_surface_variant () {
        return new DynamicColor (
                                 /* name= */ "on_surface_variant",
                                 /* palette= */ (s) => s.neutral_variant,
                                 /* tone= */ null,
                                 /* chroma_multiplier */ 1.7,
                                 /* isBackground= */ false,
                                 /* background= */ (s) => s.is_dark ? surface_bright () : surface_dim (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ get_curve (4.5),
                                 /* toneDeltaPair= */ null
        ).build ();
    }

    public DynamicColor outline () {
        return new DynamicColor (
                                 /* name= */ "outline",
                                 /* palette= */ (s) => s.neutral_variant,
                                 /* tone= */ null,
                                 /* chroma_multiplier */ 1.7,
                                 /* isBackground= */ false,
                                 /* background= */ (s) => s.is_dark ? surface_bright () : surface_dim (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ get_curve (3.0),
                                 /* toneDeltaPair= */ null
        ).build ();
    }

    public DynamicColor outline_variant () {
        return new DynamicColor (
                                 /* name= */ "outline_variant",
                                 /* palette= */ (s) => s.neutral_variant,
                                 /* tone= */ null,
                                 /* chroma_multiplier */ 1.7,
                                 /* isBackground= */ false,
                                 /* background= */ (s) => s.is_dark ? surface_bright () : surface_dim (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ get_curve (1.5),
                                 /* toneDeltaPair= */ null
        ).build ();
    }

    public DynamicColor inverse_surface () {
        return new DynamicColor (
                                 /* name= */ "inverse_surface",
                                 /* palette= */ (s) => s.neutral,
                                 /* tone= */ (s) => s.is_dark ? 98.0 : 4.0,
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ false,
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
                                 /* tone= */ (s) => s.is_dark ? 18.0 : hue_is_yellow (s.neutral.hue) ? 99.0 : s.variant == SchemeVariant.VIBRANT ? 97.0 : 98.0,
                                 /* chroma_multiplier */ 1.7,
                                 /* isBackground= */ true,
                                 /* background= */ null,
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ null,
                                 /* toneDeltaPair= */ null
        ).build ();
    }

    public DynamicColor surface_dim () {
        return new DynamicColor (
                                 /* name= */ "surface_dim",
                                 /* palette= */ (s) => s.neutral,
                                 /* tone= */ (s) => s.is_dark ? 4.0 : hue_is_yellow (s.neutral.hue) ? 90.0 : s.variant == SchemeVariant.VIBRANT ? 85.0 : 87.0,
                                 /* chroma_multiplier */ 1.7,
                                 /* isBackground= */ true,
                                 /* background= */ null,
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ null,
                                 /* toneDeltaPair= */ null
        ).build ();
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
                                 /* tone= */ (s) => s.is_dark ? 6.0 : hue_is_yellow (s.neutral.hue) ? 98.0 : s.variant == SchemeVariant.VIBRANT ? 95.0 : 96.0,
                                 /* chroma_multiplier */ 1.25,
                                 /* isBackground= */ true,
                                 /* background= */ null,
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ null,
                                 /* toneDeltaPair= */ null
        ).build ();
    }

    public DynamicColor surface_container () {
        return new DynamicColor (
                                 /* name= */ "surface_container",
                                 /* palette= */ (s) => s.neutral,
                                 /* tone= */ (s) => s.is_dark ? 9.0 : hue_is_yellow (s.neutral.hue) ? 96.0 : s.variant == SchemeVariant.VIBRANT ? 92.0 : 94.0,
                                 /* chroma_multiplier */ 1.4,
                                 /* isBackground= */ true,
                                 /* background= */ null,
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ null,
                                 /* toneDeltaPair= */ null
        ).build ();
    }

    public DynamicColor surface_container_high () {
        return new DynamicColor (
                                 /* name= */ "surface_container_high",
                                 /* palette= */ (s) => s.neutral,
                                 /* tone= */ (s) => s.is_dark ? 12.0 : hue_is_yellow (s.neutral.hue) ? 94.0 : s.variant == SchemeVariant.VIBRANT ? 90.0 : 92.0,
                                 /* chroma_multiplier */ 1.5,
                                 /* isBackground= */ true,
                                 /* background= */ null,
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ null,
                                 /* toneDeltaPair= */ null
        ).build ();
    }

    public DynamicColor surface_container_highest () {
        return new DynamicColor (
                                 /* name= */ "surface_container_highest",
                                 /* palette= */ (s) => s.neutral,
                                 /* tone= */ (s) => s.is_dark ? 15.0 : hue_is_yellow (s.neutral.hue) ? 92.0 : s.variant == SchemeVariant.VIBRANT ? 88.0 : 90.0,
                                 /* chroma_multiplier */ 1.7,
                                 /* isBackground= */ true,
                                 /* background= */ null,
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ null,
                                 /* toneDeltaPair= */ null
        ).build ();
    }

    public DynamicColor primary () {
        return new DynamicColor (
                                 /* name= */ "primary",
                                 /* palette= */ (s) => s.primary,
                                 /* tone= */ (s) => s.is_dark ? 80.0 : t_max_c (s.primary),
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ true,
                                 /* background= */ (s) => s.is_dark ? surface_bright () : surface_dim (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ get_curve (4.5),
                                 /* toneDeltaPair= */ (s) => new ToneDeltaPair (primary_container (), primary (), 5.0, TonePolarity.RELATIVE_LIGHTER, ToneResolve.FARTHER)
        ).build ();
    }

    public DynamicColor on_primary () {
        return new DynamicColor (
                                 /* name= */ "on_primary",
                                 /* palette= */ (s) => s.primary,
                                 /* tone= */ null,
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ false,
                                 /* background= */ (s) => primary (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ get_curve (9.0),
                                 /* toneDeltaPair= */ null
        ).build ();
    }

    public DynamicColor primary_container () {
        return new DynamicColor (
                                 /* name= */ "primary_container",
                                 /* palette= */ (s) => s.primary,
                                 /* tone= */ (s) => s.is_dark ? t_min_c (s.primary, 35, 93) : t_max_c (s.primary, 0, 90),
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ true,
                                 /* background= */ (s) => s.is_dark ? surface_bright () : surface_dim (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ get_curve (1.5),
                                 /* toneDeltaPair= */ null
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
                                 /* contrastCurve= */ get_curve (6.0),
                                 /* toneDeltaPair= */ null
        ).build ();
    }

    public DynamicColor secondary () {
        return new DynamicColor (
                                 /* name= */ "secondary",
                                 /* palette= */ (s) => s.secondary,
                                 /* tone= */ (s) => s.is_dark ? 80.0 : t_max_c (s.secondary),
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
                                 /* contrastCurve= */ get_curve (9.0),
                                 /* toneDeltaPair= */ null
        ).build ();
    }

    public DynamicColor secondary_container () {
        return new DynamicColor (
                                 /* name= */ "secondary_container",
                                 /* palette= */ (s) => s.secondary,
                                 /* tone= */ (s) => s.is_dark ? 25.0 : 90.0,
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ true,
                                 /* background= */ (s) => s.is_dark ? surface_bright () : surface_dim (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ get_curve (1.5),
                                 /* toneDeltaPair= */ null
        ).build ();
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
                                 /* tone= */ (s) => s.is_dark ? t_max_c (s.tertiary, 0, 98) : t_max_c (s.tertiary),
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ true,
                                 /* background= */ (s) => s.is_dark ? surface_bright () : surface_dim (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ get_curve (4.5),
                                 /* toneDeltaPair= */ (s) => new ToneDeltaPair (tertiary_container (), tertiary (), 5.0, TonePolarity.RELATIVE_LIGHTER, ToneResolve.FARTHER)
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
                                 /* contrastCurve= */ get_curve (9.0),
                                 /* toneDeltaPair= */ null
        ).build ();
    }

    public DynamicColor tertiary_container () {
        return new DynamicColor (
                                 /* name= */ "tertiary_container",
                                 /* palette= */ (s) => s.tertiary,
                                 /* tone= */ (s) => { return s.is_dark ? t_min_c (s.tertiary, 0, 93) : t_max_c (s.tertiary); },
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ true,
                                 /* background= */ (s) => s.is_dark ? surface_bright () : surface_dim (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ get_curve (1.5),
                                 /* toneDeltaPair= */ null
        ).build ();
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

    public DynamicColor error () {
        return new DynamicColor (
                                 /* name= */ "error",
                                 /* palette= */ (s) => s.error,
                                 /* tone= */ (s) => s.is_dark ? 80.0 : t_max_c (s.error),
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
                                 /* contrastCurve= */ get_curve (9.0),
                                 /* toneDeltaPair= */ null
        ).build ();
    }

    public DynamicColor error_container () {
        return new DynamicColor (
                                 /* name= */ "error_container",
                                 /* palette= */ (s) => s.error,
                                 /* tone= */ (s) => s.is_dark ? t_min_c (s.error, 30, 93) : t_max_c (s.error, 0, 90),
                                 /* chroma_multiplier */ 1.0,
                                 /* isBackground= */ true,
                                 /* background= */ (s) => s.is_dark ? surface_bright () : surface_dim (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ get_curve (1.5),
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
                                 /* contrastCurve= */ get_curve (4.5),
                                 /* toneDeltaPair= */ null
        ).build ();
    }
}