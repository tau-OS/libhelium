public class He.Window : Gtk.Window {
    private new He.AppBar title = new He.AppBar ();

    private new Gtk.Window? _parent;
    public new Gtk.Window? parent {
        get {
            return this.get_transient_for();
        }
        set {
            _parent = value;
            set_transient_for (value);
        }
    }

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
    }
}