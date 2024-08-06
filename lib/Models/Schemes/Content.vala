/*
 * Copyright (c) 2023 Fyra Labs
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
public class He.ContentScheme : SchemeFactory, Object {
    /**
     * A theme in which the primary color does not shift. Useful for content such as Album Art, Images, etc. suppling color for UI.
     */
    public Scheme generate (Color.CAM16Color accent, bool is_dark, double contrast) {
        var hue = accent.h;
        var chroma = accent.c;
        He.Color.LABColor lab = He.Color.xyz_to_lab (He.Color.cam16_to_xyz (accent));

        var primary_hue = hue;
        var secondary_hue = hue;

        var tertiary_analog = new TemperatureCache ({ hue, chroma, lab.l }).get_complement ();
        var tertiary_hue = He.Color.fix_disliked (tertiary_analog).h;

        var primary = chroma;
        var secondary = Math.fmax (chroma - 32.0, chroma * 0.5);
        var tertiary = He.Color.fix_disliked (tertiary_analog).c;
        var neutral = chroma / 8.0;
        var neutral_variant = ((chroma / 8.0) + 4.0);

        return Scheme () {
                   // _  _ ____ _  _ ___ ____ ____ _
                   // |\ | |___ |  |  |  |__/ |__| |
                   // | \| |___ |__|  |  |  \ |  | |___
                   surface_bg_hex = Color.hct_to_hex (hue, neutral, is_dark ? 6.0 : 98.0),
                   surface_bg_variant_hex = Color.hct_to_hex (hue, neutral, is_dark ? 30.0 : 90.0),
                   surface_fg_hex = Color.hct_to_hex (hue, neutral, is_dark ? new ContrastCurve (contrast, 85, 90, 95, 100).contrast_level : new ContrastCurve (contrast, 15, 10, 5, 0).contrast_level),
                   surface_fg_variant_hex = Color.hct_to_hex (hue, neutral, is_dark ? new ContrastCurve (contrast, 85, 90, 95, 99).contrast_level : new ContrastCurve (contrast, 25, 30, 35, 40).contrast_level),
                   inverse_surface_bg_hex = Color.hct_to_hex (hue, neutral, is_dark ? 90.0 : 20.0),
                   inverse_surface_fg_hex = Color.hct_to_hex (hue, neutral, is_dark ? new ContrastCurve (contrast, 7, 5, 3, 0).contrast_level : new ContrastCurve (contrast, 85, 90, 95, 100).contrast_level),

                   surface_bright_bg_hex = Color.hct_to_hex (hue, neutral, is_dark ? new ContrastCurve (contrast, 22, 24, 30, 34).contrast_level : 98.0),
                   surface_dim_bg_hex = Color.hex_from_hct ({ hue, neutral }, is_dark ? 6.0 : new ContrastCurve (contrast, 84, 87, 80, 75).contrast_level),

                   surface_container_lowest_bg_hex = Color.hct_to_hex (hue, neutral, is_dark ? new ContrastCurve (contrast, 2, 4, 2, 0).contrast_level : 100.0),
                   surface_container_low_bg_hex = Color.hct_to_hex (hue, neutral, is_dark ? new ContrastCurve (contrast, 8, 10, 11, 12).contrast_level : new ContrastCurve (contrast, 94, 96, 96, 95).contrast_level),
                   surface_container_bg_hex = Color.hct_to_hex (hue, neutral, is_dark ? new ContrastCurve (contrast, 10, 12, 18, 20).contrast_level : new ContrastCurve (contrast, 92, 94, 92, 90).contrast_level),
                   surface_container_high_bg_hex = Color.hct_to_hex (hue, neutral, is_dark ? new ContrastCurve (contrast, 12, 17, 22, 25).contrast_level : new ContrastCurve (contrast, 90, 92, 90, 85).contrast_level),
                   surface_container_highest_bg_hex = Color.hct_to_hex (hue, neutral, is_dark ? new ContrastCurve (contrast, 17, 22, 27, 30).contrast_level : new ContrastCurve (contrast, 88, 90, 85, 80).contrast_level),

                   // ___  ____ _ _  _ ____ ____ _   _
                   // |__] |__/ | |\/| |__| |__/  \_/
                   // |    |  \ | |  | |  | |  \   |
                   primary_hex = Color.hct_to_hex (primary_hue, primary, is_dark ? new ContrastCurve (contrast, 75, 80, 85, 90).contrast_level : new ContrastCurve (contrast, 45, 40, 35, 20).contrast_level),
                   on_primary_hex = Color.hct_to_hex (primary_hue, primary, is_dark ? new ContrastCurve (contrast, 15, 20, 25, 30).contrast_level : new ContrastCurve (contrast, 90, 100, 100, 100).contrast_level),
                   primary_container_hex = Color.hct_to_hex (primary_hue, primary, is_dark ? new ContrastCurve (contrast, 25, 30, 35, 40).contrast_level : new ContrastCurve (contrast, 95, 90, 85, 70).contrast_level),
                   on_primary_container_hex = Color.hct_to_hex (primary_hue, primary, is_dark ? new ContrastCurve (contrast, 85, 90, 100, 100).contrast_level : new ContrastCurve (contrast, 20, 10, 0, 0).contrast_level),
                   inverse_primary_hex = Color.hct_to_hex (primary_hue, primary, is_dark ? new ContrastCurve (contrast, 45, 40, 35, 20).contrast_level : new ContrastCurve (contrast, 75, 80, 85, 90).contrast_level),

                   // ____ ____ ____ ____ _  _ ___  ____ ____ _   _
                   // [__  |___ |    |  | |\ | |  \ |__| |__/  \_/
                   // ___] |___ |___ |__| | \| |__/ |  | |  \   |
                   secondary_hex = Color.hct_to_hex (secondary_hue, secondary, is_dark ? new ContrastCurve (contrast, 75, 80, 85, 90).contrast_level : new ContrastCurve (contrast, 45, 40, 35, 20).contrast_level),
                   on_secondary_hex = Color.hct_to_hex (secondary_hue, secondary, is_dark ? new ContrastCurve (contrast, 15, 20, 25, 30).contrast_level : new ContrastCurve (contrast, 90, 100, 100, 100).contrast_level),
                   secondary_container_hex = Color.hct_to_hex (secondary_hue, secondary, is_dark ? new ContrastCurve (contrast, 25, 30, 35, 40).contrast_level : new ContrastCurve (contrast, 95, 90, 85, 70).contrast_level),
                   on_secondary_container_hex = Color.hct_to_hex (secondary_hue, secondary, is_dark ? new ContrastCurve (contrast, 85, 90, 100, 100).contrast_level : new ContrastCurve (contrast, 20, 10, 0, 0).contrast_level),

                   // ___ ____ ____ ___ _ ____ ____ _   _
                   // |  |___ |__/  |  | |__| |__/  \_/
                   // |  |___ |  \  |  | |  | |  \   |
                   tertiary_hex = Color.hct_to_hex (tertiary_hue, tertiary, is_dark ? new ContrastCurve (contrast, 75, 80, 85, 90).contrast_level : new ContrastCurve (contrast, 45, 40, 35, 20).contrast_level),
                   on_tertiary_hex = Color.hct_to_hex (tertiary_hue, tertiary, is_dark ? new ContrastCurve (contrast, 15, 20, 25, 30).contrast_level : new ContrastCurve (contrast, 90, 100, 100, 100).contrast_level),
                   tertiary_container_hex = Color.hct_to_hex (tertiary_hue, tertiary, is_dark ? new ContrastCurve (contrast, 25, 30, 35, 40).contrast_level : new ContrastCurve (contrast, 95, 90, 85, 70).contrast_level),
                   on_tertiary_container_hex = Color.hct_to_hex (tertiary_hue, tertiary, is_dark ? new ContrastCurve (contrast, 85, 90, 100, 100).contrast_level : new ContrastCurve (contrast, 20, 10, 0, 0).contrast_level),

                   // ____ _  _ ___ _    _ _  _ ____
                   // |  | |  |  |  |    | |\ | |___
                   // |__| |__|  |  |___ | | \| |___
                   outline_hex = Color.hct_to_hex (hue, neutral_variant, is_dark ? new ContrastCurve (contrast, 55, 60, 70, 80).contrast_level : new ContrastCurve (contrast, 45, 50, 60, 70).contrast_level),
                   outline_variant_hex = Color.hct_to_hex (hue, neutral_variant, is_dark ? new ContrastCurve (contrast, 30, 30, 40, 45).contrast_level : new ContrastCurve (contrast, 80, 80, 70, 60).contrast_level),

                   // ____ _  _ ____ ___  ____ _ _ _
                   // [__  |__| |__| |  \ |  | | | |
                   // ___] |  | |  | |__/ |__| |_|_|
                   shadow_hex = Color.hct_to_hex (hue, neutral, is_dark ? 0.0 : 0.0),
                   scrim_hex = Color.hct_to_hex (hue, neutral, is_dark ? 0.0 : 0.0)
        };
    }
}
