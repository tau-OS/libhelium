/*
* Copyright (c) 2022 Fyra Labs
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

/**
* Helper class to deal with desktop-specific settings.
*/
[SingleInstance]
public class He.Desktop : Object {
    private Portal.Settings? portal = null;
    
    /**
    * The color scheme preference enum, which is used to determine the color scheme of the desktop.
    */
    public enum ColorScheme {
        NO_PREFERENCE,
        DARK,
        LIGHT
    }
    
    /**
    * The color scheme preference.
    */
    private ColorScheme? _prefers_color_scheme = null;
    public ColorScheme prefers_color_scheme {
        get {
            return _prefers_color_scheme;
        }
        private set {
            _prefers_color_scheme = value;
        }
    }
    
    private void setup_prefers_color_scheme () {
        try {
            portal = Portal.Settings.get ();
            
            prefers_color_scheme = (ColorScheme) portal.read (
                "org.freedesktop.appearance",
                "color-scheme"
            ).get_variant ().get_uint32 ();
            
            return;
        } catch (Error e) {
            debug ("%s", e.message);
        }
        
        prefers_color_scheme = ColorScheme.NO_PREFERENCE;
    }
    
    /**
    * The dark mode strength preference enum, which is used to determine the dark mode strength of the desktop.
    */
    public enum DarkModeStrength {
        MEDIUM,
        HARSH,
        SOFT
    }
    
    /**
    * The color scheme preference.
    */
    private DarkModeStrength? _dark_mode_strength = null;
    public DarkModeStrength dark_mode_strength {
        get {
            return _dark_mode_strength;
        }
        private set {
            _dark_mode_strength = value;
        }
    }
    
    private void setup_dark_mode_strength () {
        try {
            portal = Portal.Settings.get ();
            
            dark_mode_strength = (DarkModeStrength) portal.read (
                "org.freedesktop.appearance",
                "dark-mode-strength"
            ).get_variant ().get_uint32 ();
            
            return;
        } catch (Error e) {
            debug ("%s", e.message);
        }
        
        dark_mode_strength = DarkModeStrength.MEDIUM;
    }
    
    /**
    * The accent color preference.
    */
    private He.Color.RGBColor? _accent_color;
    public He.Color.RGBColor? accent_color {
        get {
            return _accent_color;
        }
        set {
            _accent_color = value;
        }
    }

    private Gdk.RGBA? _wallpaper_accent_color;
    public Gdk.RGBA? wallpaper_accent_color {
        get {
            return _wallpaper_accent_color;
        }
        set {
            _wallpaper_accent_color = value;
        }
    }
    
    private void setup_accent_color () {
        try {
            portal = Portal.Settings.get ();

            double cr, cg, cb = 0;
            
            // The accent color is stored as a Gdk.RGBA in the GVariant format "(ddd)"
            // where r,g,b,a are floats between 0.0 and 1.0.
            var accent = portal.read (
                "org.freedesktop.appearance",
                "accent-color"
            ).get_variant ();
            
            if (accent.get_type().equal(VariantType.UINT32)) {
                if (accent.get_uint32() == 0) { // Multicolor
                    accent_color = null;
                    return;
                }

                if (accent.get_uint32() == 1) { // Wallpaper
                    He.Color.RGBColor rgb_color = {
                        (int) (wallpaper_accent_color.red * 255),
                        (int) (wallpaper_accent_color.green * 255),
                        (int) (wallpaper_accent_color.blue * 255)
                    };
                    accent_color = rgb_color;
                    return;
                }
            }

            VariantIter iter = accent.iterator ();
            iter.next ("d", out cr);
            iter.next ("d", out cg);
            iter.next ("d", out cb);

            // from https://github.com/wash2/hue-chroma-accent

            He.Color.RGBColor rgb_color = {
                (int) (cr * 255),
                (int) (cg * 255),
                (int) (cb * 255)
            };

            accent_color = rgb_color;
            
            return;
        } catch (Error e) {
            debug ("%s", e.message);
        }

        accent_color = null;
    }

    private void init_handle_settings_change() {
        portal.setting_changed.connect ((scheme, key, val) => {
            if (scheme == "org.freedesktop.appearance" && key == "accent-color") {
                if (val.get_type().equal(VariantType.UINT32) && val.get_uint32() == 0) { // Multicolor
                    accent_color = null;
    
                    return;
                }
                if (val.get_type().equal(VariantType.UINT32) && val.get_uint32() == 1) { // Wallpaper
                    He.Color.RGBColor rgb_color = He.Color.from_gdk_rgba (wallpaper_accent_color);
    
                    accent_color = rgb_color;
                    return;
                }

                double cr, cg, cb = 0;
                var iter = val.iterator ();
                iter.next ("d", out cr);
                iter.next ("d", out cg);
                iter.next ("d", out cb);

                He.Color.RGBColor rgb_color = {
                    (int) (cr * 255),
                    (int) (cg * 255),
                    (int) (cb * 255)
                };

                accent_color = rgb_color;
            }
            
            if (scheme == "org.freedesktop.appearance" && key == "dark-mode-strength") {
                dark_mode_strength = (DarkModeStrength) val.get_uint32 ();
            }

            if (scheme == "org.freedesktop.appearance" && key == "color-scheme") {
                prefers_color_scheme = (ColorScheme) val.get_uint32 ();
            }
        });
    }

    construct {
        setup_prefers_color_scheme ();
        setup_accent_color ();
        setup_dark_mode_strength ();
        init_handle_settings_change ();
    }
}
