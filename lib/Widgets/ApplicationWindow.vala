/**
* An ApplicationWindow is a Window for holding the main content of an application.
*/
public class He.ApplicationWindow : Gtk.ApplicationWindow {
    /**
    * Creates a new ApplicationWindow.
    * @param application The application associated with this window.
    */
    public ApplicationWindow (He.Application app) {
        Object (application: app);
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
