/**
* An ApplicationWindow is a Window for holding the main content of an application.
*/
public class He.ApplicationWindow : Gtk.ApplicationWindow {
    /**
    * Creates a new ApplicationWindow.
    * @param app The application associated with this window.
    */
    public ApplicationWindow (He.Application app) {
        Object (application: app);

        var base_path = app.get_resource_base_path ();
        if (base_path == null) {
            return;
        }

        string base_uri = "resource://" + base_path;
        File base_file = File.new_for_uri (base_uri);

        if (base_file.get_child ("gtk/help-overlay.ui").query_exists (null)) {
            Gtk.Builder builder = new Gtk.Builder.from_file (base_path + "/gtk/help-overlay.ui");
            this.set_help_overlay (builder.get_object ("help_overlay") as Gtk.ShortcutsWindow);
        }
    }

    private new He.AppBar title = new He.AppBar ();

    private new bool _modal;
    public new bool modal {
        get {
            return modal;
        }
        set {
            _modal = value;
            set_modal (value);
        }
    }

    private bool _has_title;
    public bool has_title {
        get {
            return _has_title;
        }
        set {
            _has_title = value;
            if (!value) {
                var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
                this.set_titlebar (box);
            } else {
                title.add_css_class ("flat");
                this.set_titlebar (title);
            }
        }
    }

    private new bool _has_back_button;
    public new bool has_back_button {
        get {
            return has_back_button;
        }
        set {
            _has_back_button = value;
            title.show_back = value;
        }
    }

    construct {
        has_title = false;
        has_back_button = false;
    }
}
