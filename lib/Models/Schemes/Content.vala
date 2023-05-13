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
    public Scheme generate (Color.CAM16Color accent, bool is_dark) {
        var hue = accent.h;
        var chroma = accent.c;

        var primary = chroma;
        var secondary = Math.fmax (chroma - 32.0, chroma * 0.5);
        var tertiary = Math.fmax (chroma + 16.0, chroma / 0.3);
        var tertiary_hue = MathUtils.sanitize_degrees (hue + 60.0);
        var neutral = chroma / 16.0;
        var neutral2 = ((chroma / 8.0) + 4.0);

        return Scheme () {
            // _  _ ____ _  _ ___ ____ ____ _
            // |\ | |___ |  |  |  |__/ |__| |
            // | \| |___ |__|  |  |  \ |  | |___
            neutral_background_hex = Color.hct_to_hex (hue, neutral, is_dark ? 10.0 : 99.0),
            neutral_background_variant_hex = Color.hct_to_hex (hue, neutral, is_dark ? 30.0 : 90.0),
            neutral_foreground_hex = Color.hct_to_hex (hue, neutral, is_dark ? 99.0 : 10.0),
            neutral_foreground_variant_hex = Color.hct_to_hex (hue, neutral, is_dark ? 80.0 : 30.0),
            inverse_neutral_background_hex = Color.hct_to_hex (hue, neutral, is_dark ? 90.0 : 20.0),
            inverse_neutral_foreground_hex = Color.hct_to_hex (hue, neutral, is_dark ? 20.0 : 95.0),

            // ___  ____ _ _  _ ____ ____ _   _
            // |__] |__/ | |\/| |__| |__/  \_/
            // |    |  \ | |  | |  | |  \   |
            primary_hex = Color.hct_to_hex (hue, primary, is_dark ? 80.0 : 40.0),
            on_primary_hex = Color.hct_to_hex (hue, primary, is_dark ? 20.0 : 100.0),
            primary_container_hex = Color.hct_to_hex (hue, primary, is_dark ? 30.0 : 90.0),
            on_primary_container_hex = Color.hct_to_hex (hue, primary, is_dark ? 90.0 : 10.0),
            inverse_primary_hex = Color.hct_to_hex (hue, primary, is_dark ? 40.0 : 80.0),

            // ____ ____ ____ ____ _  _ ___  ____ ____ _   _
            // [__  |___ |    |  | |\ | |  \ |__| |__/  \_/
            // ___] |___ |___ |__| | \| |__/ |  | |  \   |
            secondary_hex = Color.hct_to_hex (hue, secondary, is_dark ? 80.0 : 40.0),
            on_secondary_hex = Color.hct_to_hex (hue, secondary, is_dark ? 20.0 : 100.0),
            secondary_container_hex = Color.hct_to_hex (hue, secondary, is_dark ? 30.0 : 90.0),
            on_secondary_container_hex = Color.hct_to_hex (hue, secondary, is_dark ? 90.0 : 10.0),

            // ___ ____ ____ ___ _ ____ ____ _   _
            //  |  |___ |__/  |  | |__| |__/  \_/
            //  |  |___ |  \  |  | |  | |  \   |
            tertiary_hex = Color.hct_to_hex (tertiary_hue, tertiary, is_dark ? 80.0 : 40.0),
            on_tertiary_hex = Color.hct_to_hex (tertiary_hue, tertiary, is_dark ? 20.0 : 100.0),
            tertiary_container_hex = Color.hct_to_hex (tertiary_hue, tertiary, is_dark ? 30.0 : 90.0),
            on_tertiary_container_hex = Color.hct_to_hex (tertiary_hue, tertiary, is_dark ? 90.0 : 10.0),

            // ____ _  _ ___ _    _ _  _ ____
            // |  | |  |  |  |    | |\ | |___
            // |__| |__|  |  |___ | | \| |___
            outline_hex = Color.hct_to_hex (hue, neutral2, is_dark ? 60.0 : 50.0),
            outline_variant_hex = Color.hct_to_hex (hue, neutral2, is_dark ? 30.0 : 80.0),

            // ____ _  _ ____ ___  ____ _ _ _
            // [__  |__| |__| |  \ |  | | | |
            // ___] |  | |  | |__/ |__| |_|_|
            shadow_hex = Color.hct_to_hex (hue, neutral, is_dark ? 0.0 : 0.0),
            scrim_hex = Color.hct_to_hex (hue, neutral, is_dark ? 0.0 : 0.0),
        };
    }
}
