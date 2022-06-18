/**
* Helper class to deal with desktop-specific settings.
*/
[SingleInstance]
public class He.Desktop : Object {
    private Portal.Settings? portal = null;

    public bool accent_color_found;
    
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
    private Gdk.RGBA? _accent_color = null;
    public Gdk.RGBA accent_color {
        get {
            if (_accent_color == null) {
                setup_accent_color ();
            }
            return _accent_color;
        }
        private set {
            _accent_color = value;
        }
    }
    
    private void setup_accent_color () {
        try {
            portal = Portal.Settings.get ();
            Gdk.RGBA color_portal = {};

            float cr, cg, cb = 0;
            
            // The accent color is stored as a Gdk.RGBA in the GVariant format "(ddd)"
            // where r,g,b,a are floats between 0.0 and 1.0.
            portal.read (
                "org.freedesktop.appearance",
                "accent-color"
            ).get ("(ddd)", out cr, out cg, out cb);

            color_portal.red = (float)cr;
            color_portal.green = (float)cg;
            color_portal.blue = (float)cb;
            color_portal.alpha = 1;
            accent_color_found = true;

            accent_color = color_portal;
            
            portal.setting_changed.connect ((scheme, key, value) => {
                if (scheme == "org.freedesktop.appearance" && key == "accent-color") {
                    value.get ("(ddd)", out cr, out cg, out cb);

                    color_portal.red = (float)cr;
                    color_portal.green = (float)cg;
                    color_portal.blue = (float)cb;
                    color_portal.alpha = 1;

                    accent_color = color_portal;
                }
            });
            
            return;
        } catch (Error e) {
            debug ("%s", e.message);
        }

        accent_color.parse ("#8C56BF");
        accent_color_found = false;
    }
}
