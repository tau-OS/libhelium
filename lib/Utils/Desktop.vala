/*
* Copyright (c) 2022 Fyra Labs
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
        set {
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
    * The dark mode strength preference.
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
    * The Ensor scheme preference enum, which is used to determine the Ensor scheme of the desktop.
    */
    public enum EnsorScheme {
        DEFAULT,
        VIBRANT,
        MUTED,
        MONOCHROMATIC
    }

    /**
    * The Ensor color scheme preference.
    */
    private EnsorScheme? _ensor_scheme = null;
    public EnsorScheme ensor_scheme {
        get {
            return _ensor_scheme;
        }
        private set {
            _ensor_scheme = value;
        }
    }

    private void setup_ensor_scheme () {
        try {
            portal = Portal.Settings.get ();

            ensor_scheme = (EnsorScheme) portal.read (
                "org.freedesktop.appearance",
                "ensor-scheme"
            ).get_variant ().get_uint32 ();

            return;
        } catch (Error e) {
            debug ("%s", e.message);
        }

        ensor_scheme = EnsorScheme.DEFAULT;
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

    private He.Color.RGBColor? parse_accent_color (GLib.Variant val) {
        // The accent color is stored as a Gdk.RGBA in the GVariant format "(ddd)"
        // where r,g,b,a are floats between 0.0 and 1.0, except in the case of no preference.
        double cr, cg, cb = 0.0;

        VariantIter iter = val.iterator ();
        iter.next ("d", out cr);
        iter.next ("d", out cg);
        iter.next ("d", out cb);

        // If any of the values are out of range, the accent is "no preference".
        if (
            !(cr >= 0.0 && cr <= 1.0 && cg >= 0.0 && cg <= 1.0 && cb >= 0.0 && cb <= 1.0)
        ) {
            return null;
        }

        He.Color.RGBColor rgb_color = {
            cr * 255,
            cg * 255,
            cb * 255
        };

        return rgb_color;
    }

    private void setup_accent_color () {
        try {
            portal = Portal.Settings.get ();

            var accent = portal.read (
                "org.freedesktop.appearance",
                "accent-color"
            ).get_variant ();

            accent_color = parse_accent_color (accent);

            return;
        } catch (Error e) {
            debug ("%s", e.message);
        }

        accent_color = null;
    }

    /**
     * The system font weight preference.
     */
    private double _font_weight = 1.0;
    public double font_weight {
        get {
            return _font_weight;
        }
        set {
            _font_weight = value;
        }
    }

    private void setup_font_weight () {
        try {
            portal = Portal.Settings.get ();

            var fw = portal.read (
                "org.freedesktop.appearance",
                "font-weight"
            ).get_variant ().get_double ();

            font_weight = (double) fw;

            return;
        } catch (Error e) {
            debug ("%s", e.message);
        }

        font_weight = 1.0;
    }

    private void init_handle_settings_change () {
        portal.setting_changed.connect ((scheme, key, val) => {
            if (scheme == "org.freedesktop.appearance" && key == "accent-color") {
                accent_color = parse_accent_color (val);
            }

            if (scheme == "org.freedesktop.appearance" && key == "font-weight") {
                font_weight = (double) val.get_double ();
            }

            if (scheme == "org.freedesktop.appearance" && key == "dark-mode-strength") {
                dark_mode_strength = (DarkModeStrength) val.get_uint32 ();
            }

            if (scheme == "org.freedesktop.appearance" && key == "ensor-scheme") {
                ensor_scheme = (EnsorScheme) val.get_uint32 ();
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
        setup_ensor_scheme ();
        setup_font_weight ();
        init_handle_settings_change ();
    }
}
