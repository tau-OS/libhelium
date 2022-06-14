/**
 * A Window is a container that has an {@link AppBar} and can be moved, resized, and closed.
 * It may be a top-level window or a dialog. The title bar can be made always visible.
 * Has an optional back button. The back button is only visible if has_back_button is true.
 */
public class He.Window : Gtk.Window {
    private new He.AppBar title = new He.AppBar ();

    /**
     * The parent window of this window. If this is null, then this is a top-level window.
     */
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

    /**
     * If this is a modal window.
     */
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

    /**
     * If the window has a title bar.
     */
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

    /**
     * If the window has a back button.
     */
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