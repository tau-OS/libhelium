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
[CCode (gir_namespace = "He", gir_version = "1", cheader_filename = "libhelium-1.h")]
namespace He.Schemes {
    public class Vibrant : Scheme {
        private const double PRIMARY = 150.0;
        private const double SECONDARY = 32.0;
        private const double TERTIARY = 48.0;
        private const double NEUTRAL = 24.0;
        private const double NEUTRAL2 = 32.0;
        private const double[] HUES = {0, 41, 61, 101, 131, 181, 251, 301, 360};
        private const double[] SECONDARY_ROTATIONS = {45, 95, 45, 20, 45, 90, 45, 45, 45};
        private const double[] TERTIARY_ROTATIONS = {120, 120, 20, 45, 20, 15, 20, 120, 120};

        public Vibrant (Color.CAM16Color cam16_color, Desktop desktop) {
            base (cam16_color, desktop);

            var is_dark = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme;

            // _  _ ____ _  _ ___ ____ ____ _
            // |\ | |___ |  |  |  |__/ |__| |
            // | \| |___ |__|  |  |  \ |  | |___
            neutral_background_hex = Color.hct_to_hex (hue, NEUTRAL, is_dark ? 10.0 : 99.0);
            neutral_background_variant_hex = Color.hct_to_hex (hue, NEUTRAL, is_dark ? 30.0 : 90.0);
            neutral_foreground_hex = Color.hct_to_hex (hue, NEUTRAL, is_dark ? 99.0 : 10.0);
            neutral_foreground_variant_hex = Color.hct_to_hex (hue, NEUTRAL, is_dark ? 80.0 : 30.0);
            inverse_neutral_background_hex = Color.hct_to_hex (hue, NEUTRAL, is_dark ? 90.0 : 20.0);
            inverse_neutral_foreground_hex = Color.hct_to_hex (hue, NEUTRAL, is_dark ? 20.0 : 95.0);
            // ___  ____ _ _  _ ____ ____ _   _
            // |__] |__/ | |\/| |__| |__/  \_/
            // |    |  \ | |  | |  | |  \   |
            double primary_hue = MathUtils.sanitize_degrees (hue);
            primary_hex = Color.hct_to_hex (primary_hue, PRIMARY, is_dark ? 80.0 : 40.0);
            on_primary_hex = Color.hct_to_hex (primary_hue, PRIMARY, is_dark ? 20.0 : 100.0);
            primary_container_hex = Color.hct_to_hex (primary_hue, PRIMARY, is_dark ? 30.0 : 90.0);
            on_primary_container_hex = Color.hct_to_hex (primary_hue, PRIMARY, is_dark ? 90.0 : 10.0);
            inverse_primary_hex = Color.hct_to_hex (primary_hue, PRIMARY, is_dark ? 40.0 : 80.0);
            // ____ ____ ____ ____ _  _ ___  ____ ____ _   _
            // [__  |___ |    |  | |\ | |  \ |__| |__/  \_/
            // ___] |___ |___ |__| | \| |__/ |  | |  \   |
            double secondary_hue = Color.get_rotated_hue (hue, HUES, SECONDARY_ROTATIONS);
            secondary_hex = Color.hct_to_hex (secondary_hue, SECONDARY, is_dark ? 80.0 : 40.0);
            on_secondary_hex = Color.hct_to_hex (secondary_hue, SECONDARY, is_dark ? 20.0 : 100.0);
            secondary_container_hex = Color.hct_to_hex (secondary_hue, SECONDARY, is_dark ? 30.0 : 90.0);
            on_secondary_container_hex = Color.hct_to_hex (secondary_hue, SECONDARY, is_dark ? 90.0 : 10.0);
            // ___ ____ ____ ___ _ ____ ____ _   _
            //  |  |___ |__/  |  | |__| |__/  \_/
            //  |  |___ |  \  |  | |  | |  \   |
            double tertiary_hue = Color.get_rotated_hue (hue, HUES, TERTIARY_ROTATIONS);
            tertiary_hex = Color.hct_to_hex (tertiary_hue, TERTIARY, is_dark ? 80.0 : 40.0);
            on_tertiary_hex = Color.hct_to_hex (tertiary_hue, TERTIARY, is_dark ? 20.0 : 100.0);
            tertiary_container_hex = Color.hct_to_hex (tertiary_hue, TERTIARY, is_dark ? 30.0 : 90.0);
            on_tertiary_container_hex = Color.hct_to_hex (tertiary_hue, TERTIARY, is_dark ? 90.0 : 10.0);
            // ____ _  _ ___ _    _ _  _ ____
            // |  | |  |  |  |    | |\ | |___
            // |__| |__|  |  |___ | | \| |___
            outline_hex = Color.hct_to_hex (hue, NEUTRAL2, is_dark ? 60.0 : 50.0);
            outline_variant_hex = Color.hct_to_hex (hue, NEUTRAL2, is_dark ? 30.0 : 80.0);

            // ____ _  _ ____ ___  ____ _ _ _
            // [__  |__| |__| |  \ |  | | | |
            // ___] |  | |  | |__/ |__| |_|_|
            shadow_hex = Color.hct_to_hex (hue, NEUTRAL, is_dark ? 0.0 : 0.0);
            scrim_hex = Color.hct_to_hex (hue, NEUTRAL, is_dark ? 0.0 : 0.0);
        }
    }
}
