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
    
    private void setup_accent_color () {
        try {
            portal = Portal.Settings.get ();

            float cr, cg, cb = 0;
            
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

            accent_color = hexcode (cr, cg, cb);

            warning ("accent color is %s", accent_color);
            
            portal.setting_changed.connect ((scheme, key, value) => {
                if (scheme == "org.freedesktop.appearance" && key == "accent-color") {
                    accent = value.get_variant ();
                    iter = accent.iterator ();
                    iter.next ("d", out cr);
                    iter.next ("d", out cg);
                    iter.next ("d", out cb);
                    accent_color = hexcode (cr, cg, cb);

                    warning ("accent color changed to %s", accent_color);
                }
            });
            
            return;
        } catch (Error e) {
            debug ("%s", e.message);
        }

        // If we can't get the accent color, use the default.
        accent_color = "#8C56BF";
    }

    private string hexcode (float r, float g, float b) {
        return "#" + "%02x%02x%02x".printf (
            (int)(r * 255),
            (int)(g * 255),
            (int)(b * 255)
        );
    }
}
