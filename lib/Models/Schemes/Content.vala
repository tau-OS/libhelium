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
     * A theme in which the primary color does not shift. Useful for content.
     */
    public Scheme generate (Color.CAM16Color accent, bool is_dark, bool is_contrast) {
        var hue = accent.h;
        var chroma = accent.c;

        var primary = chroma;
        var secondary = Math.fmax (chroma - 32.0, chroma * 0.5);
        var tertiary = He.Color.fix_disliked ({ hue, Math.fmax (chroma + 16.0, chroma / 0.3), accent.s }).c;
        var neutral = chroma / 8.0;
        var neutral2 = ((chroma / 8.0) + 4.0);

        var primary_hue = MathUtils.sanitize_degrees (hue);
        var secondary_hue = MathUtils.sanitize_degrees (hue);
        var tertiary_hue = MathUtils.sanitize_degrees (hue + 61.0);

        return Scheme () {
                   // _  _ ____ _  _ ___ ____ ____ _
                   // |\ | |___ |  |  |  |__/ |__| |
                   // | \| |___ |__|  |  |  \ |  | |___
                   surface_bg_hex = Color.hct_to_hex (hue, neutral, is_dark ? 6.0 : 98.0),
                   surface_bg_variant_hex = Color.hct_to_hex (hue, neutral, is_dark ? 24.0 : 90.0),
                   surface_fg_hex = Color.hct_to_hex (hue, neutral, is_dark ? 98.0 : 10.0),
                   surface_fg_variant_hex = Color.hct_to_hex (hue, neutral, is_dark ? 80.0 : 30.0),
                   inverse_surface_bg_hex = Color.hct_to_hex (hue, neutral, is_dark ? 90.0 : 20.0),
                   inverse_surface_fg_hex = Color.hct_to_hex (hue, neutral, is_dark ? 20.0 : 95.0),

                   surface_bright_bg_hex = Color.hct_to_hex (hue, neutral, is_dark ? is_contrast ? 34.0 : 24.0 : is_contrast ? 98.0 : 98.0),
                   surface_dim_bg_hex = Color.hct_to_hex (hue, neutral, is_dark ? is_contrast ? 6.0 : 6.0 : is_contrast ? 75.0 : 87.0),

                   surface_container_lowest_bg_hex = Color.hct_to_hex (hue, neutral, is_dark ? is_contrast ? 0.0 : 4.0 : is_contrast ? 100.0 : 100.0),
                   surface_container_low_bg_hex = Color.hct_to_hex (hue, neutral, is_dark ? is_contrast ? 12.0 : 10.0 : is_contrast ? 95.0 : 96.0),
                   surface_container_bg_hex = Color.hct_to_hex (hue, neutral, is_dark ? is_contrast ? 20.0 : 12.0 : is_contrast ? 90.0 : 94.0),
                   surface_container_high_bg_hex = Color.hct_to_hex (hue, neutral, is_dark ? is_contrast ? 25.0 : 17.0 : is_contrast ? 85.0 : 92.0),
                   surface_container_highest_bg_hex = Color.hct_to_hex (hue, neutral, is_dark ? is_contrast ? 30.0 : 22.0 : is_contrast ? 80.0 : 90.0),

                   // ___  ____ _ _  _ ____ ____ _   _
                   // |__] |__/ | |\/| |__| |__/  \_/
                   // |    |  \ | |  | |  | |  \   |
                   primary_hex = Color.hct_to_hex (primary_hue, primary, is_dark ? is_contrast ? 90.0 : 80.0 : is_contrast ? 20.0 : 40.0),
                   on_primary_hex = Color.hct_to_hex (primary_hue, primary, is_dark ? 20.0 : 100.0),
                   primary_container_hex = Color.hct_to_hex (primary_hue, primary, is_dark ? is_contrast ? 40.0 : 30.0 : is_contrast ? 70.0 : 90.0),
                   on_primary_container_hex = Color.hct_to_hex (primary_hue, primary, is_dark ? 90.0 : 10.0),
                   inverse_primary_hex = Color.hct_to_hex (primary_hue, primary, is_dark ? 40.0 : 80.0),

                   // ____ ____ ____ ____ _  _ ___  ____ ____ _   _
                   // [__  |___ |    |  | |\ | |  \ |__| |__/  \_/
                   // ___] |___ |___ |__| | \| |__/ |  | |  \   |
                   secondary_hex = Color.hct_to_hex (secondary_hue, secondary, is_dark ? is_contrast ? 90.0 : 80.0 : is_contrast ? 20.0 : 40.0),
                   on_secondary_hex = Color.hct_to_hex (secondary_hue, secondary, is_dark ? 20.0 : 100.0),
                   secondary_container_hex = Color.hct_to_hex (secondary_hue, secondary, is_dark ? is_contrast ? 40.0 : 30.0 : is_contrast ? 70.0 : 90.0),
                   on_secondary_container_hex = Color.hct_to_hex (secondary_hue, secondary, is_dark ? 90.0 : 10.0),

                   // ___ ____ ____ ___ _ ____ ____ _   _
                   // |  |___ |__/  |  | |__| |__/  \_/
                   // |  |___ |  \  |  | |  | |  \   |
                   tertiary_hex = Color.hct_to_hex (tertiary_hue, tertiary, is_dark ? is_contrast ? 90.0 : 80.0 : is_contrast ? 20.0 : 40.0),
                   on_tertiary_hex = Color.hct_to_hex (tertiary_hue, tertiary, is_dark ? 20.0 : 100.0),
                   tertiary_container_hex = Color.hct_to_hex (tertiary_hue, tertiary, is_dark ? is_contrast ? 40.0 : 30.0 : is_contrast ? 70.0 : 90.0),
                   on_tertiary_container_hex = Color.hct_to_hex (tertiary_hue, tertiary, is_dark ? 90.0 : 10.0),

                   // ____ _  _ ___ _    _ _  _ ____
                   // |  | |  |  |  |    | |\ | |___
                   // |__| |__|  |  |___ | | \| |___
                   outline_hex = Color.hct_to_hex (hue, neutral2, is_dark ? 60.0 : 50.0),
                   outline_variant_hex = Color.hct_to_hex (hue, neutral2, is_dark ? is_contrast ? 45.0 : 30.0 : is_contrast ? 60.0 : 80.0),

                   // ____ _  _ ____ ___  ____ _ _ _
                   // [__  |__| |__| |  \ |  | | | |
                   // ___] |  | |  | |__/ |__| |_|_|
                   shadow_hex = Color.hct_to_hex (hue, neutral, is_dark ? 0.0 : 0.0),
                   scrim_hex = Color.hct_to_hex (hue, neutral, is_dark ? 0.0 : 0.0)
        };
    }
}