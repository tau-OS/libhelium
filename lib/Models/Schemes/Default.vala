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
    public class Default : Scheme {
        private const double PRIMARY = 48.0;
        private const double SECONDARY = 16.0;
        private const double TERTIARY = 24.0;
        private const double NEUTRAL = 4.0;
        private const double NEUTRAL2 = 8.0;

        public Default (Color.CAM16Color cam16_color, Desktop desktop) {
            base ();
            hue = cam16_color.h;
            chroma = cam16_color.C;

            // _  _ ____ _  _ ___ ____ ____ _    
            // |\ | |___ |  |  |  |__/ |__| |    
            // | \| |___ |__|  |  |  \ |  | |___
            neutral_background_hex = Color.hct_to_hex (hue, NEUTRAL, Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 10.0 : 99.0);
            neutral_background_variant_hex = Color.hct_to_hex (hue, NEUTRAL, Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 30.0 : 90.0);
            neutral_foreground_hex = Color.hct_to_hex (hue, NEUTRAL, Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 99.0 : 10.0);
            neutral_foreground_variant_hex = Color.hct_to_hex (hue, NEUTRAL, Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 80.0 : 30.0);
            inverse_neutral_background_hex = Color.hct_to_hex (hue, NEUTRAL, Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 90.0 : 20.0);
            inverse_neutral_foreground_hex = Color.hct_to_hex (hue, NEUTRAL, Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 20.0 : 95.0);
            // ___  ____ _ _  _ ____ ____ _   _ 
            // |__] |__/ | |\/| |__| |__/  \_/  
            // |    |  \ | |  | |  | |  \   | 
            primary_hex = Color.hct_to_hex (hue, PRIMARY, Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 80.0 : 40.0);
            on_primary_hex = Color.hct_to_hex (hue, PRIMARY, Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 20.0 : 100.0);
            primary_container_hex = Color.hct_to_hex (hue, PRIMARY, Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 30.0 : 90.0);
            on_primary_container_hex = Color.hct_to_hex (hue, PRIMARY, Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 90.0 : 10.0);
            inverse_primary_hex = Color.hct_to_hex (hue, PRIMARY, Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 40.0 : 80.0);
            // ____ ____ ____ ____ _  _ ___  ____ ____ _   _ 
            // [__  |___ |    |  | |\ | |  \ |__| |__/  \_/  
            // ___] |___ |___ |__| | \| |__/ |  | |  \   |
            secondary_hex = Color.hct_to_hex (hue, SECONDARY, Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 80.0 : 40.0);
            on_secondary_hex = Color.hct_to_hex (hue, SECONDARY, Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 20.0 : 100.0);
            secondary_container_hex = Color.hct_to_hex (hue, SECONDARY, Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 30.0 : 90.0);
            on_secondary_container_hex = Color.hct_to_hex (hue, SECONDARY, Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 90.0 : 10.0);
            // ___ ____ ____ ___ _ ____ ____ _   _ 
            //  |  |___ |__/  |  | |__| |__/  \_/  
            //  |  |___ |  \  |  | |  | |  \   |
            double tertiary_hue = MathUtils.sanitize_degrees (hue + 60.0);
            tertiary_hex = Color.hct_to_hex (tertiary_hue, TERTIARY, Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 80.0 : 40.0);
            on_tertiary_hex = Color.hct_to_hex (tertiary_hue, TERTIARY, Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 20.0 : 100.0);
            tertiary_container_hex = Color.hct_to_hex (tertiary_hue, TERTIARY, Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 30.0 : 90.0);
            on_tertiary_container_hex = Color.hct_to_hex (tertiary_hue, TERTIARY, Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 90.0 : 10.0);
            // ____ _  _ ___ _    _ _  _ ____ 
            // |  | |  |  |  |    | |\ | |___ 
            // |__| |__|  |  |___ | | \| |___
            outline_hex = Color.hct_to_hex (hue, NEUTRAL2, Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 60.0 : 50.0);    
            outline_variant_hex = Color.hct_to_hex (hue, NEUTRAL2, Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 30.0 : 80.0);
            // ____ _  _ ____ ___  ____ _ _ _ 
            // [__  |__| |__| |  \ |  | | | | 
            // ___] |  | |  | |__/ |__| |_|_|
            shadow_hex = Color.hct_to_hex (hue, NEUTRAL, Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 0.0 : 0.0);    
            scrim_hex = Color.hct_to_hex (hue, NEUTRAL, Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 0.0 : 0.0);
        }
    }
}