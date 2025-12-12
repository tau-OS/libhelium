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
public class He.Desktop : GLib.Object {
#if HAVE_PORTAL
    private Portal.Settings? portal = null;
#endif

    private uint fallback_poll_id = 0;

    public enum ColorScheme {
        NO_PREFERENCE,
        DARK,
        LIGHT
    }

    private ColorScheme _prefers_color_scheme = ColorScheme.NO_PREFERENCE;
    public ColorScheme prefers_color_scheme {
        get { return _prefers_color_scheme; }
        set { _prefers_color_scheme = value; }
    }

    public enum EnsorScheme {
        DEFAULT,
        VIBRANT,
        MUTED,
        MONOCHROMATIC,
        SALAD;

        public SchemeVariant to_variant () {
            switch (this) {
            case DEFAULT:
                return SchemeVariant.DEFAULT;
            case VIBRANT:
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

    private EnsorScheme _ensor_scheme = EnsorScheme.DEFAULT;
    public EnsorScheme ensor_scheme {
        get { return _ensor_scheme; }
        private set { _ensor_scheme = value; }
    }

    private RGBColor? _accent_color = null;
    public RGBColor? accent_color {
        get { return _accent_color; }
        set { _accent_color = value; }
    }

    private double _font_weight = 1.0;
    public double font_weight {
        get { return _font_weight; }
        set { _font_weight = value; }
    }

    private double _roundness = 1.0;
    public double roundness {
        get { return _roundness; }
        set { _roundness = value; }
    }

    private double _contrast = 0.0;
    public double contrast {
        get { return _contrast; }
        set { _contrast = value; }
    }

    /**
     * 0 = compact, 1 = normal, 2 = comfortable
     */
    private uint _density = 0;
    public uint density {
        get { return _density; }
        set { _density = (value > 2) ? 0 : value; }
    }

    // -------------------------------------------------------------------------
    // Platform detection + macOS fallback helpers
    // -------------------------------------------------------------------------

    private static bool is_macos () {
        Posix.utsname u;
        if (Posix.uname (out u) != 0) {
            return false;
        }
        return u.sysname == "Darwin";
    }

    private static string? macos_defaults_read (string domain, string key) {
        string stdout_str;
        string stderr_str;
        int status;

        string cmd;
        if (domain == "-g" || domain == "NSGlobalDomain") {
            cmd = "defaults read -g %s".printf (GLib.Shell.quote (key));
        } else {
            cmd = "defaults read %s %s".printf (
                GLib.Shell.quote (domain),
                GLib.Shell.quote (key)
            );
        }

        try {
            GLib.Process.spawn_command_line_sync (
                cmd,
                out stdout_str,
                out stderr_str,
                out status
            );
        } catch (GLib.Error e) {
            return null;
        }

        if (status != 0) {
            return null;
        }

        var s = stdout_str.strip ();
        return s.length > 0 ? s : null;
    }

    private static bool? macos_defaults_read_bool (string domain, string key) {
        var s = macos_defaults_read (domain, key);
        if (s == null) {
            return null;
        }

        switch (s.down ()) {
        case "1":
        case "true":
        case "yes":
            return true;
        case "0":
        case "false":
        case "no":
            return false;
        default:
            return null;
        }
    }

    private static int? macos_defaults_read_int (string domain, string key) {
        var s = macos_defaults_read (domain, key);
        if (s == null) {
            return null;
        }

        try {
            return int.parse (s);
        } catch (GLib.Error e) {
            return null;
        }
    }

    private static RGBColor? macos_read_accent_color () {
        // Prefer AppleHighlightColor (often contains normalized RGB).
        // Example: "0.776471 0.815686 0.992157 Blue"
        var highlight = macos_defaults_read ("-g", "AppleHighlightColor");
        if (highlight != null) {
            var parts = highlight.split (" ");
            if (parts.length >= 3) {
                try {
                    double r = double.parse (parts[0]);
                    double g = double.parse (parts[1]);
                    double b = double.parse (parts[2]);

                    if (r >= 0.0 && r <= 1.0 &&
                        g >= 0.0 && g <= 1.0 &&
                        b >= 0.0 && b <= 1.0) {
                        RGBColor c = { r, g, b };
                        return c;
                    }
                } catch (GLib.Error e) {
                    // fall through
                }
            }
        }

        // Fallback: AppleAccentColor index mapping (approximate sRGB).
        // Common values: -1 (Graphite), 0..6 (colors)
        var idx = macos_defaults_read_int ("-g", "AppleAccentColor");
        if (idx == null) {
            return null;
        }

        RGBColor c;
        switch ((int) idx) {
        case -1: // Graphite
            c = { 0.56, 0.56, 0.58 };
            return c;
        case 0: // Red
            c = { 1.00, 0.23, 0.19 };
            return c;
        case 1: // Orange
            c = { 1.00, 0.58, 0.00 };
            return c;
        case 2: // Yellow
            c = { 1.00, 0.80, 0.00 };
            return c;
        case 3: // Green
            c = { 0.14, 0.79, 0.35 };
            return c;
        case 4: // Blue
            c = { 0.00, 0.48, 1.00 };
            return c;
        case 5: // Purple
            c = { 0.69, 0.32, 0.87 };
            return c;
        case 6: // Pink
            c = { 1.00, 0.18, 0.33 };
            return c;
        default:
            return null;
        }
    }

    private ColorScheme fallback_color_scheme () {
        if (is_macos ()) {
            // If AppleInterfaceStyle is "Dark", dark mode is enabled.
            // If missing, macOS is effectively light mode.
            var style = macos_defaults_read ("-g", "AppleInterfaceStyle");
            if (style != null && style.down () == "dark") {
                return ColorScheme.DARK;
            }
            return ColorScheme.LIGHT;
        }

        return ColorScheme.NO_PREFERENCE;
    }

    private EnsorScheme fallback_ensor_scheme () {
        return EnsorScheme.DEFAULT;
    }

    private double fallback_font_weight () {
        if (is_macos ()) {
            var bold = macos_defaults_read_bool (
                "com.apple.universalaccess",
                "boldText"
            );
            return (bold != null && (bool) bold) ? 1.15 : 1.0;
        }
        return 1.0;
    }

    private double fallback_roundness () {
        return 1.0;
    }

    private double fallback_contrast () {
        if (is_macos ()) {
            var inc = macos_defaults_read_bool (
                "com.apple.universalaccess",
                "increaseContrast"
            );
            return (inc != null && (bool) inc) ? 1.0 : 0.0;
        }
        return 0.0;
    }

    private uint fallback_density () {
        return is_macos () ? 1u : 0u;
    }

    // -------------------------------------------------------------------------
    // Existing parsing helpers
    // -------------------------------------------------------------------------

    private RGBColor? parse_accent_color (GLib.Variant val) {
        // Accent color stored like "(ddd)" for r,g,b (0..1).
        double cr, cg, cb = 0.0;

        GLib.VariantIter iter = val.iterator ();
        iter.next ("d", out cr);
        iter.next ("d", out cg);
        iter.next ("d", out cb);

        if (!(cr >= 0.0 && cr <= 1.0 && cg >= 0.0 && cg <= 1.0 &&
              cb >= 0.0 && cb <= 1.0)) {
            return null;
        }

        RGBColor rgb_color = { cr, cg, cb };
        return rgb_color;
    }

    private double? extract_double (GLib.Variant val) {
        if (val.is_of_type (GLib.VariantType.DOUBLE)) {
            return val.get_double ();
        }

        if (val.is_of_type (GLib.VariantType.VARIANT)) {
            return extract_double (val.get_variant ());
        }

        GLib.Variant.Class classifier = val.classify ();

        if ((classifier == GLib.Variant.Class.MAYBE ||
             classifier == GLib.Variant.Class.TUPLE) &&
            val.n_children () > 0) {
            return extract_double (val.get_child_value (0));
        }

        return null;
    }

    // -------------------------------------------------------------------------
    // Portal endpoints with fallbacks
    // -------------------------------------------------------------------------

    private void setup_prefers_color_scheme () {
#if HAVE_PORTAL
        if (portal != null) {
            try {
                prefers_color_scheme = (ColorScheme) portal
                    .read ("org.freedesktop.appearance", "color-scheme")
                    .get_variant ()
                    .get_uint32 ();
                return;
            } catch (GLib.Error e) {
                GLib.debug ("%s", e.message);
            }
        }
#endif
        prefers_color_scheme = fallback_color_scheme ();
    }

    private void setup_ensor_scheme () {
#if HAVE_PORTAL
        if (portal != null) {
            try {
                ensor_scheme = (EnsorScheme) portal
                    .read ("org.freedesktop.appearance", "ensor-scheme")
                    .get_variant ()
                    .get_uint32 ();
                return;
            } catch (GLib.Error e) {
                GLib.debug ("%s", e.message);
            }
        }
#endif
        ensor_scheme = fallback_ensor_scheme ();
    }

    private void setup_accent_color () {
#if HAVE_PORTAL
        if (portal != null) {
            try {
                var accent = portal
                    .read ("org.freedesktop.appearance", "accent-color")
                    .get_variant ();
                accent_color = parse_accent_color (accent);
                return;
            } catch (GLib.Error e) {
                GLib.debug ("%s", e.message);
            }
        }
#endif
        accent_color = is_macos () ? macos_read_accent_color () : null;
    }

    private void setup_font_weight () {
#if HAVE_PORTAL
        if (portal != null) {
            try {
                var fw = portal
                    .read ("org.freedesktop.appearance", "font-weight")
                    .get_variant ()
                    .get_double ();
                font_weight = (double) fw;
                return;
            } catch (GLib.Error e) {
                GLib.debug ("%s", e.message);
            }
        }
#endif
        font_weight = fallback_font_weight ();
    }

    private void setup_roundness () {
#if HAVE_PORTAL
        if (portal != null) {
            try {
                var round = portal
                    .read ("org.freedesktop.appearance", "roundness")
                    .get_variant ()
                    .get_double ();
                roundness = (double) round;
                return;
            } catch (GLib.Error e) {
                GLib.debug ("%s", e.message);
            }
        }
#endif
        roundness = fallback_roundness ();
    }

    private void setup_contrast () {
#if HAVE_PORTAL
        if (portal != null) {
            try {
                var contrast_variant = portal
                    .read ("org.freedesktop.appearance", "contrast")
                    .get_variant ();

                var raw_contrast = extract_double (contrast_variant);
                if (raw_contrast != null) {
                    double clamped = He.MathUtils.clamp_double (
                        -1.0,
                        1.0,
                        (double) raw_contrast
                    );
                    contrast = GLib.Math.round (clamped * 100) / 100;
                    return;
                }
            } catch (GLib.Error e) {
                GLib.debug ("%s", e.message);
            }
        }
#endif
        contrast = fallback_contrast ();
    }

    private void setup_density () {
#if HAVE_PORTAL
        if (portal != null) {
            try {
                var density_val = portal
                    .read ("org.freedesktop.appearance", "density")
                    .get_variant ()
                    .get_uint32 ();

                density = (density_val <= 2) ? density_val : 0;
                return;
            } catch (GLib.Error e) {
                GLib.debug ("%s", e.message);
            }
        }
#endif
        density = fallback_density ();
    }

    // -------------------------------------------------------------------------
    // Change notification: portal signal on Linux, polling fallback on macOS
    // -------------------------------------------------------------------------

    private void init_handle_settings_change () {
#if HAVE_PORTAL
        if (portal == null) {
            return;
        }

        portal.setting_changed.connect ((scheme, key, val) => {
            if (scheme != "org.freedesktop.appearance") {
                return;
            }

            if (key == "accent-color") {
                accent_color = parse_accent_color (val);
            } else if (key == "font-weight") {
                font_weight = (double) val.get_double ();
            } else if (key == "roundness") {
                roundness = (double) val.get_double ();
            } else if (key == "ensor-scheme") {
                ensor_scheme = (EnsorScheme) val.get_uint32 ();
            } else if (key == "contrast") {
                var raw_contrast = extract_double (val);
                if (raw_contrast != null) {
                    double clamped = He.MathUtils.clamp_double (
                        -1.0,
                        1.0,
                        (double) raw_contrast
                    );
                    contrast = GLib.Math.round (clamped * 100) / 100;
                } else {
                    contrast = 0.0;
                }
            } else if (key == "color-scheme") {
                prefers_color_scheme = (ColorScheme) val.get_uint32 ();
            } else if (key == "density") {
                var density_val = val.get_uint32 ();
                density = (density_val <= 2) ? density_val : 0;
            }
        });
#endif
    }

    private void init_handle_settings_change_fallback () {
        if (!is_macos ()) {
            return;
        }

        if (fallback_poll_id != 0) {
            GLib.Source.remove (fallback_poll_id);
            fallback_poll_id = 0;
        }

        fallback_poll_id = GLib.Timeout.add_seconds (2, () => {
            prefers_color_scheme = fallback_color_scheme ();
            accent_color = macos_read_accent_color ();
            contrast = fallback_contrast ();
            font_weight = fallback_font_weight ();
            return true;
        });
    }

    construct {
#if HAVE_PORTAL
        try {
            portal = Portal.Settings.get ();
        } catch (GLib.Error e) {
            GLib.debug ("%s", e.message);
            portal = null;
        }
#endif

        setup_prefers_color_scheme ();
        setup_contrast ();
        setup_roundness ();
        setup_accent_color ();
        setup_ensor_scheme ();
        setup_font_weight ();
        setup_density ();

        init_handle_settings_change ();
        init_handle_settings_change_fallback ();
    }

    ~Desktop () {
        if (fallback_poll_id != 0) {
            GLib.Source.remove (fallback_poll_id);
            fallback_poll_id = 0;
        }
    }
}
