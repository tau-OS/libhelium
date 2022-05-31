namespace He {
    [SingleInstance]
    public class Desktop : Object {
        private Portal.Settings? portal = null;

        public enum ColorScheme {
            NO_PREFERENCE,
            DARK,
            LIGHT
        }

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
    }
}