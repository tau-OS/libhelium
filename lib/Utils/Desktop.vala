/*
 * Copyright (c) 2022-2025 Fyra Labs
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
     * The Ensor scheme preference enum, which is used to determine the Ensor scheme of the desktop.
     */
    public enum EnsorScheme {
        DEFAULT,
        VIBRANT,
        MUTED,
        MONOCHROMATIC,
        SALAD;

        public SchemeVariant to_variant () {
            switch (this) {
            case DEFAULT :
                return SchemeVariant.DEFAULT;
            case VIBRANT :
                return SchemeVariant.VIBRANT;
            case MUTED:
                return SchemeVariant.MUTED;
            case MONOCHROMATIC:
                return SchemeVariant.MONOCHROME;
            case SALAD:
                return SchemeVariant.SALAD;
            default:
                return SchemeVariant.DEFAULT;
            }
        }
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
    private RGBColor? _accent_color;
    public RGBColor? accent_color {
        get {
            return _accent_color;
        }
        set {
            _accent_color = value;
        }
    }

    private RGBColor ? parse_accent_color (GLib.Variant val) {
        // The accent color is stored as a Gdk.RGBA in the GVariant format "(ddd)"
        // where r,g,b,a are floats between 0.0 and 1.0, except in the case of no preference.
        double cr, cg, cb = 0.0;

        VariantIter iter = val.iterator ();
        iter.next ("d", out cr);
        iter.next ("d", out cg);
        iter.next ("d", out cb);

        // If any of the values are out of range, the accent is "no preference".
        if (!(cr >= 0.0 && cr <= 1.0 && cg >= 0.0 && cg <= 1.0 && cb >= 0.0 && cb <= 1.0)) {
            return null;
        }

        RGBColor rgb_color = {
            cr,
            cg,
            cb
        };

        return rgb_color;
    }

    private double ? extract_double (Variant val) {
        if (val.is_of_type (VariantType.DOUBLE)) {
            return val.get_double ();
        }

        if (val.is_of_type (VariantType.VARIANT)) {
            return extract_double (val.get_variant ());
        }

        Variant.Class classifier = val.classify ();

        if ((classifier == Variant.Class.MAYBE || classifier == Variant.Class.TUPLE) && val.n_children () > 0) {
            return extract_double (val.get_child_value (0));
        }

        return null;
    }

    private void setup_accent_color () {
        try {
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

    /**
     * The system UI roundness preference.
     */
    private double _roundness = 1.0;
    public double roundness {
        get {
            return _roundness;
        }
        set {
            _roundness = value;
        }
    }

    private void setup_roundness () {
        try {
            var round = portal.read (
                                     "org.freedesktop.appearance",
                                     "roundness"
            ).get_variant ().get_double ();

            roundness = (double) round;

            return;
        } catch (Error e) {
            debug ("%s", e.message);
        }

        roundness = 1.0;
    }

    /**
     * The system contrast preference.
     */
    private double? _contrast = 0.0;
    public double contrast {
        get {
            return _contrast;
        }
        set {
            _contrast = value;
        }
    }

    private void setup_contrast () {
        try {
            var contrast_variant = portal.read (
                                                "org.freedesktop.appearance",
                                                "contrast"
            ).get_variant ();

            var raw_contrast = extract_double (contrast_variant);

            if (raw_contrast != null) {
                // XDG portal reports contrast in the range [-1, 1]; clamp just in case.
                double clamped = He.MathUtils.clamp_double (-1.0, 1.0, (double) raw_contrast);
                // Round to 2 decimal places to avoid floating point precision issues
                contrast = Math.round (clamped * 100) / 100;
                return;
            }
        } catch (Error e) {
            debug ("%s", e.message);
        }

        contrast = 0.0;
    }

    private void init_handle_settings_change () {
        portal.setting_changed.connect ((scheme, key, val) => {
            if (scheme == "org.freedesktop.appearance" && key == "accent-color") {
                accent_color = parse_accent_color (val);
            }

            if (scheme == "org.freedesktop.appearance" && key == "font-weight") {
                font_weight = (double) val.get_double ();
            }

            if (scheme == "org.freedesktop.appearance" && key == "roundness") {
                roundness = (double) val.get_double ();
            }

            if (scheme == "org.freedesktop.appearance" && key == "ensor-scheme") {
                ensor_scheme = (EnsorScheme) val.get_uint32 ();
            }

            if (scheme == "org.freedesktop.appearance" && key == "contrast") {
                var raw_contrast = extract_double (val);
                if (raw_contrast != null) {
                    double clamped = He.MathUtils.clamp_double (-1.0, 1.0, (double) raw_contrast);
                    // Round to 2 decimal places to avoid floating point precision issues
                    contrast = Math.round (clamped * 100) / 100;
                } else {
                    contrast = 0.0;
                }
            }

            if (scheme == "org.freedesktop.appearance" && key == "color-scheme") {
                prefers_color_scheme = (ColorScheme) val.get_uint32 ();
            }
        });
    }

    construct {
        try {
            portal = Portal.Settings.get ();
            setup_prefers_color_scheme ();
            setup_contrast ();
            setup_roundness ();
            setup_accent_color ();
            setup_ensor_scheme ();
            setup_font_weight ();
            init_handle_settings_change ();
        } catch (Error e) {
            debug ("%s", e.message);
        }
    }
}