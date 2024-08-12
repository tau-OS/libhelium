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

    public DynamicColor highest_surface (DynamicScheme s) {
        return s.is_dark ? surface_bright () : surface_dim ();
    }

    public DynamicColor primary_key () {
        return new DynamicColor.from_palette (
                                              /* name= */ "primary_palette_key_color",
                                              /* palette= */ (s) => s.primary,
                                              /* tone= */ (s) => s.primary.key_color.t);
    }

    public DynamicColor secondary_key () {
        return new DynamicColor.from_palette (
                                              /* name= */ "secondary_palette_key_color",
                                              /* palette= */ (s) => s.secondary,
                                              /* tone= */ (s) => s.secondary.key_color.t);
    }

    public DynamicColor tertiary_key () {
        return new DynamicColor.from_palette (
                                              /* name= */ "tertiary_palette_key_color",
                                              /* palette= */ (s) => s.tertiary,
                                              /* tone= */ (s) => s.tertiary.key_color.t);
    }

    public DynamicColor neutral_key () {
        return new DynamicColor.from_palette (
                                              /* name= */ "neutral_palette_key_color",
                                              /* palette= */ (s) => s.neutral,
                                              /* tone= */ (s) => s.neutral.key_color.t);
    }

    public DynamicColor neutral_variant_key () {
        return new DynamicColor.from_palette (
                                              /* name= */ "neutral_variant_palette_key_color",
                                              /* palette= */ (s) => s.neutral_variant,
                                              /* tone= */ (s) => s.neutral_variant.key_color.t);
    }

    public DynamicColor background () {
        return new DynamicColor (
                                 "background",
                                 (s) => s.neutral,
                                 (s) => s.is_dark ? 6.0 : 98.0,
                                 true,
                                 null,
                                 null,
                                 null,
                                 null);
    }

    public DynamicColor on_background () {
        return new DynamicColor (
                                 /* name= */ "on_background",
                                 /* palette= */ (s) => s.neutral,
                                 /* tone= */ (s) => s.is_dark ? 90.0 : 10.0,
                                 /* isBackground= */ false,
                                 /* background= */ (s) => highest_surface (s),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ new ContrastCurve (4.5, 7.0, 11.0, 21.0),
                                 /* toneDeltaPair= */ null);
    }

    public DynamicColor surface () {
        return new DynamicColor (
                                 "surface",
                                 (s) => s.neutral,
                                 (s) => s.is_dark ? 6.0 : 98.0,
                                 true,
                                 null,
                                 null,
                                 null,
                                 null);
    }

    public DynamicColor surface_variant () {
        return new DynamicColor (
                                 /* name= */ "surface_variant",
                                 /* palette= */ (s) => s.neutral_variant,
                                 /* tone= */ (s) => s.is_dark ? 30.0 : 90.0,
                                 /* isBackground= */ true,
                                 /* background= */ null,
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ null,
                                 /* toneDeltaPair= */ null);
    }

    public DynamicColor on_surface () {
        return new DynamicColor (
                                 /* name= */ "on_surface",
                                 /* palette= */ (s) => s.neutral,
                                 /* tone= */ (s) => s.is_dark ? 90.0 : 10.0,
                                 /* isBackground= */ false,
                                 /* background= */ (s) => highest_surface (s),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ new ContrastCurve (4.5, 7.0, 11.0, 21.0),
                                 /* toneDeltaPair= */ null);
    }

    public DynamicColor on_surface_variant () {
        return new DynamicColor (
                                 /* name= */ "on_surface_variant",
                                 /* palette= */ (s) => s.neutral_variant,
                                 /* tone= */ (s) => s.is_dark ? 80.0 : 30.0,
                                 /* isBackground= */ false,
                                 /* background= */ (s) => highest_surface (s),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ new ContrastCurve (3.0, 4.5, 7.0, 11.0),
                                 /* toneDeltaPair= */ null);
    }

    public DynamicColor outline () {
        return new DynamicColor (
                                 /* name= */ "outline",
                                 /* palette= */ (s) => s.neutral_variant,
                                 /* tone= */ (s) => s.is_dark ? 60.0 : 50.0,
                                 /* isBackground= */ false,
                                 /* background= */ (s) => highest_surface (s),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ new ContrastCurve (1.5, 3.0, 4.5, 7.0),
                                 /* toneDeltaPair= */ null);
    }

    public DynamicColor outline_variant () {
        return new DynamicColor (
                                 /* name= */ "outline_variant",
                                 /* palette= */ (s) => s.neutral_variant,
                                 /* tone= */ (s) => s.is_dark ? 30.0 : 80.0,
                                 /* isBackground= */ false,
                                 /* background= */ (s) => highest_surface (s),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ new ContrastCurve (1.0, 1.0, 3.0, 4.5),
                                 /* toneDeltaPair= */ null);
    }

    public DynamicColor inverse_surface () {
        return new DynamicColor (
                                 /* name= */ "inverse_surface",
                                 /* palette= */ (s) => s.neutral,
                                 /* tone= */ (s) => s.is_dark ? 90.0 : 20.0,
                                 /* isBackground= */ false,
                                 /* background= */ null,
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ null,
                                 /* toneDeltaPair= */ null);
    }

    public DynamicColor inverse_on_surface () {
        return new DynamicColor (
                                 /* name= */ "inverse_on_surface",
                                 /* palette= */ (s) => s.neutral,
                                 /* tone= */ (s) => s.is_dark ? 20.0 : 95.0,
                                 /* isBackground= */ false,
                                 /* background= */ (s) => inverse_surface (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ new ContrastCurve (4.5, 7.0, 11.0, 21.0),
                                 /* toneDeltaPair= */ null);
    }

    public DynamicColor inverse_primary () {
        return new DynamicColor (
                                 /* name= */ "inverse_primary",
                                 /* palette= */ (s) => s.primary,
                                 /* tone= */ (s) => s.is_dark ? 40.0 : 80.0,
                                 /* isBackground= */ false,
                                 /* background= */ (s) => inverse_surface (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ new ContrastCurve (3.0, 4.5, 7.0, 7.0),
                                 /* toneDeltaPair= */ null);
    }

    public DynamicColor surface_bright () {
        return new DynamicColor (
                                 /* name= */ "surface_bright",
                                 /* palette= */ (s) => s.neutral,
                                 /* tone= */ (s) =>
                                 s.is_dark ? new ContrastCurve (24.0, 24.0, 29.0, 34.0).get (s.contrast_level) : 98.0,
                                 /* isBackground= */ true,
                                 /* background= */ null,
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ null,
                                 /* toneDeltaPair= */ null);
    }

    public DynamicColor surface_dim () {
        return new DynamicColor (
                                 /* name= */ "surface_dim",
                                 /* palette= */ (s) => s.neutral,
                                 /* tone= */ (s) =>
                                 s.is_dark ? 6.0 : new ContrastCurve (87.0, 87.0, 80.0, 75.0).get (s.contrast_level),
                                 /* isBackground= */ true,
                                 /* background= */ null,
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ null,
                                 /* toneDeltaPair= */ null);
    }

    public DynamicColor surface_container_lowest () {
        return new DynamicColor (
                                 /* name= */ "surface_container_lowest",
                                 /* palette= */ (s) => s.neutral,
                                 /* tone= */ (s) =>
                                 s.is_dark ? new ContrastCurve (4.0, 4.0, 2.0, 0.0).get (s.contrast_level) : 100.0,
                                 /* isBackground= */ true,
                                 /* background= */ null,
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ null,
                                 /* toneDeltaPair= */ null);
    }

    public DynamicColor surface_container_low () {
        return new DynamicColor (
                                 /* name= */ "surface_container_low",
                                 /* palette= */ (s) => s.neutral,
                                 /* tone= */ (s) =>
                                 s.is_dark ? new ContrastCurve (10.0, 10.0, 11.0, 12.0).get (s.contrast_level)
                                           : new ContrastCurve (96.0, 96.0, 96.0, 95.0).get (s.contrast_level),
                                 /* isBackground= */ true,
                                 /* background= */ null,
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ null,
                                 /* toneDeltaPair= */ null);
    }

    public DynamicColor surface_container () {
        return new DynamicColor (
                                 /* name= */ "surface_container",
                                 /* palette= */ (s) => s.neutral,
                                 /* tone= */ (s) =>
                                 s.is_dark ? new ContrastCurve (12.0, 12.0, 16.0, 20.0).get (s.contrast_level)
                                           : new ContrastCurve (94.0, 94.0, 92.0, 90.0).get (s.contrast_level),
                                 /* isBackground= */ true,
                                 /* background= */ null,
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ null,
                                 /* toneDeltaPair= */ null);
    }

    public DynamicColor surface_container_high () {
        return new DynamicColor (
                                 /* name= */ "surface_container_high",
                                 /* palette= */ (s) => s.neutral,
                                 /* tone= */ (s) =>
                                 s.is_dark ? new ContrastCurve (17.0, 17.0, 21.0, 25.0).get (s.contrast_level)
                                           : new ContrastCurve (92.0, 92.0, 88.0, 85.0).get (s.contrast_level),
                                 /* isBackground= */ true,
                                 /* background= */ null,
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ null,
                                 /* toneDeltaPair= */ null);
    }

    public DynamicColor surface_container_highest () {
        return new DynamicColor (
                                 /* name= */ "surface_container_high",
                                 /* palette= */ (s) => s.neutral,
                                 /* tone= */ (s) =>
                                 s.is_dark ? new ContrastCurve (22.0, 22.0, 26.0, 30.0).get (s.contrast_level)
                                             : new ContrastCurve (90.0, 90.0, 84.0, 80.0).get (s.contrast_level),
                                 /* isBackground= */ true,
                                 /* background= */ null,
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ null,
                                 /* toneDeltaPair= */ null);
    }

    public DynamicColor primary () {
        return new DynamicColor (
                                 /* name= */ "primary",
                                 /* palette= */ (s) => s.primary,
                                 /* tone= */ (s) => s.is_dark ? 80.0 : 40.0,
                                 /* isBackground= */ true,
                                 /* background= */ (s) => highest_surface (s),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ new ContrastCurve (3.0, 4.5, 7.0, 7.0),
                                 /* toneDeltaPair= */ (s) =>
                                 new ToneDeltaPair (primary_container (), primary (), 10.0, TonePolarity.NEARER, false));
    }

    public DynamicColor on_primary () {
        return new DynamicColor (
                                 /* name= */ "on_primary",
                                 /* palette= */ (s) => s.primary,
                                 /* tone= */ (s) => {
            if (is_monochrome (s)) {
                return s.is_dark ? 10.0 : 90.0;
            }
            return s.is_dark ? 20.0 : 100.0;
        },
                                 /* isBackground= */ false,
                                 /* background= */ (s) => primary (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ new ContrastCurve (4.5, 7.0, 11.0, 21.0),
                                 /* toneDeltaPair= */ null);
    }

    public DynamicColor primary_container () {
        return new DynamicColor (
                                 /* name= */ "primary_container",
                                 /* palette= */ (s) => s.primary,
                                 /* tone= */ (s) => {
            if (is_monochrome (s)) {
                return s.is_dark ? 60.0 : 49.0;
            }
            if (!is_fidelity (s)) {
                return s.is_dark ? 30.0 : 90.0;
            }
            return s.hct.t;
        },
                                 /* isBackground= */ true,
                                 /* background= */ (s) => highest_surface (s),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ new ContrastCurve (1.0, 1.0, 3.0, 4.5),
                                 /* toneDeltaPair= */ (s) =>
                                 new ToneDeltaPair (primary_container (), primary (), 10.0, TonePolarity.NEARER, false));
    }

    public DynamicColor on_primary_container () {
        return new DynamicColor (
                                 /* name= */ "on_primary_container",
                                 /* palette= */ (s) => s.primary,
                                 /* tone= */ (s) => {
            if (is_monochrome (s)) {
                return s.is_dark ? 90.0 : 10.0;
            }
            if (!is_fidelity (s)) {
                return s.is_dark ? 90.0 : 30.0;
            }
            return primary_container ().foreground_tone (primary_container ().get_tone (s), 4.5);
        },
                                 /* isBackground= */ false,
                                 /* background= */ (s) => primary_container (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ new ContrastCurve (3.0, 4.5, 7.0, 11.0),
                                 /* toneDeltaPair= */ null);
    }

    public DynamicColor secondary () {
        return new DynamicColor (
                                 /* name= */ "secondary",
                                 /* palette= */ (s) => s.secondary,
                                 /* tone= */ (s) => s.is_dark ? 80.0 : 40.0,
                                 /* isBackground= */ true,
                                 /* background= */ (s) => highest_surface (s),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ new ContrastCurve (3.0, 4.5, 7.0, 7.0),
                                 /* toneDeltaPair= */ (s) =>
                                 new ToneDeltaPair (secondary_container (), secondary (), 10.0, TonePolarity.NEARER, false));
    }

    public DynamicColor on_secondary () {
        return new DynamicColor (
                                 /* name= */ "on_secondary",
                                 /* palette= */ (s) => s.secondary,
                                 /* tone= */ (s) => {
            if (is_monochrome (s)) {
                return s.is_dark ? 10.0 : 100.0;
            }
            return s.is_dark ? 20.0 : 100.0;
        },
                                 /* isBackground= */ false,
                                 /* background= */ (s) => secondary (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ new ContrastCurve (4.5, 7.0, 11.0, 21.0),
                                 /* toneDeltaPair= */ null);
    }

    public DynamicColor secondary_container () {
        return new DynamicColor (
                                 /* name= */ "secondary_container",
                                 /* palette= */ (s) => s.secondary,
                                 /* tone= */ (s) => {
            double initial = s.is_dark ? 30.0 : 90.0;
            if (is_fidelity (s)) {
                return initial;
            } else if (is_monochrome (s)) {
                return s.is_dark ? 30.0 : 85.0;
            }
            return find_desired_chroma_by_tone (s.secondary.hue, s.secondary.chroma, initial, !s.is_dark);
        },
                                 /* isBackground= */ true,
                                 /* background= */ (s) => highest_surface (s),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ new ContrastCurve (1.0, 1.0, 3.0, 4.5),
                                 /* toneDeltaPair= */ (s) =>
                                 new ToneDeltaPair (secondary_container (), secondary (), 10.0, TonePolarity.NEARER, false));
    }

    public DynamicColor on_secondary_container () {
        return new DynamicColor (
                                 /* name= */ "on_secondary_container",
                                 /* palette= */ (s) => s.secondary,
                                 /* tone= */ (s) => {
            if (is_monochrome (s)) {
                return s.is_dark ? 90.0 : 10.0;
            }
            if (!is_fidelity (s)) {
                return s.is_dark ? 90.0 : 30.0;
            }
            return secondary_container ().foreground_tone (secondary_container ().get_tone (s), 4.5);
        },
                                 /* isBackground= */ false,
                                 /* background= */ (s) => secondary_container (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ new ContrastCurve (3.0, 4.5, 7.0, 11.0),
                                 /* toneDeltaPair= */ null);
    }

    public DynamicColor tertiary () {
        return new DynamicColor (
                                 /* name= */ "tertiary",
                                 /* palette= */ (s) => s.tertiary,
                                 /* tone= */ (s) => {
            if (is_monochrome (s)) {
                return s.is_dark ? 90.0 : 25.0;
            }
            return s.is_dark ? 80.0 : 40.0;
        },
                                 /* isBackground= */ true,
                                 /* background= */ (s) => highest_surface (s),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ new ContrastCurve (3.0, 4.5, 7.0, 7.0),
                                 /* toneDeltaPair= */ (s) =>
                                 new ToneDeltaPair (tertiary_container (), tertiary (), 10.0, TonePolarity.NEARER, false));
    }

    public DynamicColor on_tertiary () {
        return new DynamicColor (
                                 /* name= */ "on_tertiary",
                                 /* palette= */ (s) => s.tertiary,
                                 /* tone= */ (s) => {
            if (is_monochrome (s)) {
                return s.is_dark ? 10.0 : 90.0;
            }
            return s.is_dark ? 20.0 : 100.0;
        },
                                 /* isBackground= */ false,
                                 /* background= */ (s) => tertiary (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ new ContrastCurve (4.5, 7.0, 11.0, 21.0),
                                 /* toneDeltaPair= */ null);
    }

    public DynamicColor tertiary_container () {
        return new DynamicColor (
                                 /* name= */ "tertiary_container",
                                 /* palette= */ (s) => s.tertiary,
                                 /* tone= */ (s) => {
            if (is_monochrome (s)) {
                return s.is_dark ? 60.0 : 49.0;
            }
            if (!is_fidelity (s)) {
                return s.is_dark ? 30.0 : 90.0;
            }
            HCTColor proposed = s.tertiary.get_hct (s.hct.t);
            var disliked = fix_disliked (proposed);

            return disliked.t;
        },
                                 /* isBackground= */ true,
                                 /* background= */ (s) => highest_surface (s),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ new ContrastCurve (1.0, 1.0, 3.0, 4.5),
                                 /* toneDeltaPair= */ (s) =>
                                 new ToneDeltaPair (tertiary_container (), tertiary (), 10.0, TonePolarity.NEARER, false));
    }

    public DynamicColor on_tertiary_container () {
        return new DynamicColor (
                                 /* name= */ "on_tertiary_container",
                                 /* palette= */ (s) => s.tertiary,
                                 /* tone= */ (s) => {
            if (is_monochrome (s)) {
                return s.is_dark ? 0.0 : 100.0;
            }
            if (!is_fidelity (s)) {
                return s.is_dark ? 90.0 : 30.0;
            }

            return on_tertiary_container ().foreground_tone (tertiary_container ().get_tone (s), 4.5);
        },
                                 /* isBackground= */ false,
                                 /* background= */ (s) => tertiary_container (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ new ContrastCurve (3.0, 4.5, 7.0, 11.0),
                                 /* toneDeltaPair= */ null);
    }

    public DynamicColor shadow () {
        return new DynamicColor (
                                 /* name= */ "shadow",
                                 /* palette= */ (s) => s.neutral,
                                 /* tone= */ (s) => 0.0,
                                 /* isBackground= */ false,
                                 /* background= */ null,
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ null,
                                 /* toneDeltaPair= */ null);
    }

    public DynamicColor scrim () {
        return new DynamicColor (
                                 /* name= */ "scrim",
                                 /* palette= */ (s) => s.neutral,
                                 /* tone= */ (s) => 0.0,
                                 /* isBackground= */ false,
                                 /* background= */ null,
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ null,
                                 /* toneDeltaPair= */ null);
    }

    public DynamicColor error () {
        return new DynamicColor (
                                 /* name= */ "error",
                                 /* palette= */ (s) => s.error,
                                 /* tone= */ (s) => s.is_dark ? 80.0 : 40.0,
                                 /* isBackground= */ true,
                                 /* background= */ (s) => highest_surface (s),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ new ContrastCurve (3.0, 4.5, 7.0, 7.0),
                                 /* toneDeltaPair= */ (s) =>
                                 new ToneDeltaPair (error_container (), error (), 10.0, TonePolarity.NEARER, false));
    }

    public DynamicColor on_error () {
        return new DynamicColor (
                                 /* name= */ "on_error",
                                 /* palette= */ (s) => s.error,
                                 /* tone= */ (s) => s.is_dark ? 20.0 : 100.0,
                                 /* isBackground= */ false,
                                 /* background= */ (s) => error (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ new ContrastCurve (4.5, 7.0, 11.0, 21.0),
                                 /* toneDeltaPair= */ null);
    }

    public DynamicColor error_container () {
        return new DynamicColor (
                                 /* name= */ "error_container",
                                 /* palette= */ (s) => s.error,
                                 /* tone= */ (s) => s.is_dark ? 30.0 : 90.0,
                                 /* isBackground= */ true,
                                 /* background= */ (s) => highest_surface (s),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ new ContrastCurve (1.0, 1.0, 3.0, 4.5),
                                 /* toneDeltaPair= */ (s) =>
                                 new ToneDeltaPair (error_container (), error (), 10.0, TonePolarity.NEARER, false));
    }

    public DynamicColor on_error_container () {
        return new DynamicColor (
                                 /* name= */ "on_error_container",
                                 /* palette= */ (s) => s.error,
                                 /* tone= */ (s) => {
            if (is_monochrome (s)) {
                return s.is_dark ? 90.0 : 10.0;
            }
            return s.is_dark ? 90.0 : 30.0;
        },
                                 /* isBackground= */ false,
                                 /* background= */ (s) => error_container (),
                                 /* secondBackground= */ null,
                                 /* contrastCurve= */ new ContrastCurve (3.0, 4.5, 7.0, 11.0),
                                 /* toneDeltaPair= */ null);
    }

    static double find_desired_chroma_by_tone (double hue, double chroma, double tone, bool by_decreasing_tone) {
        double answer = tone;

        HCTColor closest_to_chroma = from_params (hue, chroma, tone);
        if (closest_to_chroma.c < chroma) {
            double chroma_peak = closest_to_chroma.c;
            while (closest_to_chroma.c < chroma) {
                answer += by_decreasing_tone ? -1.0 : 1.0;
                HCTColor potential_solution = from_params (hue, chroma, answer);
                if (chroma_peak > potential_solution.c) {
                    break;
                }
                if (Math.fabs (potential_solution.c - chroma) < 0.4) {
                    break;
                }

                double potential_delta = Math.fabs (potential_solution.c - chroma);
                double current_delta = Math.fabs (closest_to_chroma.c - chroma);
                if (potential_delta < current_delta) {
                    closest_to_chroma = potential_solution;
                }
                chroma_peak = Math.fmax (chroma_peak, potential_solution.c);
            }
        }

        return answer;
    }

    private static bool is_fidelity (DynamicScheme scheme) {
        return scheme.variant == SchemeVariant.CONTENT;
    }

    private static bool is_monochrome (DynamicScheme scheme) {
        return scheme.variant == SchemeVariant.MONOCHROME;
    }
}