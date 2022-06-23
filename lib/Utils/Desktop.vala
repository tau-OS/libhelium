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
            if (_prefers_color_scheme == null) {
                setup_prefers_color_scheme ();
            }
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
            
            portal.setting_changed.connect ((scheme, key, value) => {
                if (scheme == "org.freedesktop.appearance" && key == "color-scheme") {
                    prefers_color_scheme = (ColorScheme) value.get_uint32 ();
                }
            });
            
            return;
        } catch (Error e) {
            debug ("%s", e.message);
        }
        
        prefers_color_scheme = ColorScheme.NO_PREFERENCE;
    }
    
    /**
    * The accent color preference.
    */
    private string? _accent_color;
    public string accent_color {
        get {
            if (_accent_color == null) {
                setup_accent_color ();
            }
            return _accent_color;
        }
        private set {
            _accent_color = value;
            if (_accent_color == null) {
                setup_accent_color ();
            }
        }
    }

    /**
     * The foreground color that pairs well with the accent color.
     *
 * @since 1.0
 */
    private string? _foreground;
    public string foreground {
        get {
            if (_foreground == null) {
                setup_accent_color ();
            }
            return _foreground;
        }
        private set {
            _foreground = value;
            if (_foreground == null) {
                setup_accent_color ();
            }
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
            
            VariantIter iter = accent.iterator ();
            iter.next ("d", out cr);
            iter.next ("d", out cg);
            iter.next ("d", out cb);

            if (ColorScheme.DARK == prefers_color_scheme) {
                accent_color = hexcode (cr, cg, cb);
                var fg_color = He.Misc.fix_fg_contrast (cr, cg, cb, 1.0, 1.0, 1.0);
                foreground = hexcode (fg_color[0], fg_color[1], fg_color[1]);
            } else {
                accent_color = hexcode (cr, cg, cb);
                var fg_color = He.Misc.fix_fg_contrast (cr, cg, cb, 0.0, 0.0, 0.0);
                foreground = hexcode (fg_color[0], fg_color[1], fg_color[1]);
            }
            
            portal.setting_changed.connect ((scheme, key, value) => {
                if (scheme == "org.freedesktop.appearance" && key == "accent-color") {
                    accent = value.get_variant ();
                    iter = accent.iterator ();
                    iter.next ("d", out cr);
                    iter.next ("d", out cg);
                    iter.next ("d", out cb);
                    if (ColorScheme.DARK == prefers_color_scheme) {
                        accent_color = hexcode (cr, cg, cb);
                        var fg_color = He.Misc.fix_fg_contrast (cr*255, cg*255, cb*255, 255, 255, 255);
                        foreground = hexcode (fg_color[0]/255, fg_color[1]/255, fg_color[1]/255);
                    } else {
                        accent_color = hexcode (cr, cg, cb);
                        var fg_color = He.Misc.fix_fg_contrast (cr*255, cg*255, cb*255, 0, 0, 0);
                        foreground = hexcode (fg_color[0]/255, fg_color[1]/255, fg_color[1]/255);
                    }
                }
            });
            
            return;
        } catch (Error e) {
            debug ("%s", e.message);
        }

        // If we can't get the accent color, use the default.
        if (ColorScheme.DARK == prefers_color_scheme) {
            accent_color = "#BEA0DB";
            var fg_color = He.Misc.fix_fg_contrast (190, 160, 219, 255, 255, 255);
            foreground = hexcode (fg_color[0]/255, fg_color[1]/255, fg_color[1]/255);
        } else {
            accent_color = "#8C56BF";
            var fg_color = He.Misc.fix_fg_contrast (140, 86, 191, 0, 0, 0);
            foreground = hexcode (fg_color[0]/255, fg_color[1]/255, fg_color[1]/255);
        }
    }

    private string hexcode (double r, double g, double b) {
        return "#" + "%02x%02x%02x".printf (
            (int)(r * 255),
            (int)(g * 255),
            (int)(b * 255)
        );
    }
}
