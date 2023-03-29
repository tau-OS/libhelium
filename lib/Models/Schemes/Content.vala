/*
* Copyright (c) 2023 Fyra Labs
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/
[CCode (gir_namespace = "He", gir_version = "1", cheader_filename = "libhelium-1.h")]
namespace He.Schemes {
    public class Content : Scheme {
        private static double primary = chroma;
        private static double secondary = Math.fmax (chroma - 32.0, chroma * 0.5);
        private static double tertiary = Math.fmax (chroma + 16.0, chroma / 0.3);
        private static double neutral = chroma / 16.0;
        private static double neutral2 = ((chroma / 8.0) + 4.0);

        public Content (Color.CAM16Color cam16_color, Desktop desktop) {
            base (cam16_color, desktop);

            var is_dark = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme;

            // _  _ ____ _  _ ___ ____ ____ _
            // |\ | |___ |  |  |  |__/ |__| |
            // | \| |___ |__|  |  |  \ |  | |___
            neutral_background_hex = Color.hct_to_hex (hue, neutral, is_dark ? 10.0 : 99.0);
            neutral_background_variant_hex = Color.hct_to_hex (hue, neutral, is_dark ? 30.0 : 90.0);
            neutral_foreground_hex = Color.hct_to_hex (hue, neutral, is_dark ? 99.0 : 10.0);
            neutral_foreground_variant_hex = Color.hct_to_hex (hue, neutral, is_dark ? 80.0 : 30.0);
            inverse_neutral_background_hex = Color.hct_to_hex (hue, neutral, is_dark ? 90.0 : 20.0);
            inverse_neutral_foreground_hex = Color.hct_to_hex (hue, neutral, is_dark ? 20.0 : 95.0);
            // ___  ____ _ _  _ ____ ____ _   _
            // |__] |__/ | |\/| |__| |__/  \_/
            // |    |  \ | |  | |  | |  \   |
            primary_hex = Color.hct_to_hex (hue, primary, is_dark ? 80.0 : 40.0);
            on_primary_hex = Color.hct_to_hex (hue, primary, is_dark ? 20.0 : 100.0);
            primary_container_hex = Color.hct_to_hex (hue, primary, is_dark ? 30.0 : 90.0);
            on_primary_container_hex = Color.hct_to_hex (hue, primary, is_dark ? 90.0 : 10.0);
            inverse_primary_hex = Color.hct_to_hex (hue, primary, is_dark ? 40.0 : 80.0);
            // ____ ____ ____ ____ _  _ ___  ____ ____ _   _
            // [__  |___ |    |  | |\ | |  \ |__| |__/  \_/
            // ___] |___ |___ |__| | \| |__/ |  | |  \   |
            secondary_hex = Color.hct_to_hex (hue, secondary, is_dark ? 80.0 : 40.0);
            on_secondary_hex = Color.hct_to_hex (hue, secondary, is_dark ? 20.0 : 100.0);
            secondary_container_hex = Color.hct_to_hex (hue, secondary, is_dark ? 30.0 : 90.0);
            on_secondary_container_hex = Color.hct_to_hex (hue, secondary, is_dark ? 90.0 : 10.0);
            // ___ ____ ____ ___ _ ____ ____ _   _
            //  |  |___ |__/  |  | |__| |__/  \_/
            //  |  |___ |  \  |  | |  | |  \   |
            double tertiary_hue = MathUtils.sanitize_degrees (hue + 60.0);
            tertiary_hex = Color.hct_to_hex (tertiary_hue, tertiary, is_dark ? 80.0 : 40.0);
            on_tertiary_hex = Color.hct_to_hex (tertiary_hue, tertiary, is_dark ? 20.0 : 100.0);
            tertiary_container_hex = Color.hct_to_hex (tertiary_hue, tertiary, is_dark ? 30.0 : 90.0);
            on_tertiary_container_hex = Color.hct_to_hex (tertiary_hue, tertiary, is_dark ? 90.0 : 10.0);
            // ____ _  _ ___ _    _ _  _ ____
            // |  | |  |  |  |    | |\ | |___
            // |__| |__|  |  |___ | | \| |___
            outline_hex = Color.hct_to_hex (hue, neutral2, is_dark ? 60.0 : 50.0);
            outline_variant_hex = Color.hct_to_hex (hue, neutral2, is_dark ? 30.0 : 80.0);

            // ____ _  _ ____ ___  ____ _ _ _
            // [__  |__| |__| |  \ |  | | | |
            // ___] |  | |  | |__/ |__| |_|_|
            shadow_hex = Color.hct_to_hex (hue, neutral, is_dark ? 0.0 : 0.0);
            scrim_hex = Color.hct_to_hex (hue, neutral, is_dark ? 0.0 : 0.0);
        }
    }
}
