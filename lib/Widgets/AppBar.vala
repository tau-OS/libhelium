public class He.AppBar : Gtk.Box, Gtk.Buildable {
    public Gtk.HeaderBar? title;
    private Gtk.Button back_button = new Gtk.Button ();
    private Gtk.SelectionModel pages;
    private GLib.List<He.AlbumPage> _albumpages;
    private unowned GLib.List<He.AlbumPage> ap_link;

    private Gtk.Stack _stack;
    public Gtk.Stack stack {
        get {
            return _stack;
        }

        set {
            if (this.pages != null) {
                this.pages.items_changed.disconnect (on_pages_changed);
            }

            _stack = value;
            pages = value.pages;

            pages.items_changed.connect (on_pages_changed);
        }
    }

    private bool _flat;
    public bool flat {
        get {
            return _flat;
        }
        set {
            _flat = value;

            if (_flat) {
                title.add_css_class ("flat");
            } else {
                title.remove_css_class ("flat");
            }
        }
    }

    private bool _show_buttons;
    public bool show_buttons {
        get {
            return _show_buttons;
        }
        set {
            _show_buttons = value;

            if (_show_buttons) {
                title.set_decoration_layout (":maximize,close");
            } else {
                title.set_decoration_layout (":");
            }
        }
    }

    private bool _show_back;
    public bool show_back {
        get {
            return _show_back;
        }
        set {
            _show_back = value;

            back_button.set_visible (value);
        }
    }

    public void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
        title.pack_end ((Gtk.Widget)child);
    }

    construct {
        title = new Gtk.HeaderBar ();
        title.hexpand = true;

        // Remove default gtk title here because HIG
        var title_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        title.set_title_widget (title_box);

        back_button.set_icon_name ("go-previous-symbolic");
        back_button.set_tooltip_text ("Go Back");
        back_button.clicked.connect (() => {
            stack.set_visible_child (ap_link.data);
        });
        title.pack_start (back_button);

        this.append (title);
    }

    private void on_pages_changed (uint position, uint removed, uint added) {
        ap_link = this._albumpages.nth (position - 1);
    }
}
