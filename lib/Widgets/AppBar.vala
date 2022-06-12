/**
* An AppBar is the header bar of an Window. It usually provides controls to manage the window, as well as optional children for more granular control.
*/
public class He.AppBar : He.Bin {
    /**
    * The title displayed in the AppBar.
    */
    public Gtk.HeaderBar? title;
    private Gtk.Button back_button = new Gtk.Button ();

    private Gtk.Stack _stack;
    /**
    * The stack that the AppBar is associated with.
    */
    public Gtk.Stack stack {
        get { return this._stack; }
        set {
            this._stack = value;
        }
    }

    private bool _flat;
    /**
    * Whether the AppBar is flat, i.e. has no bottom border.
    */
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
    /**
    * Whether the close, minimize and maximize buttons are shown.
    */
    public bool show_buttons {
        get {
            return _show_buttons;
        }
        set {
            _show_buttons = value;

            title.set_show_title_buttons (value);
        }
    }

    private bool _show_back;
    /**
    * Whether the back button is shown.
    */
    public bool show_back {
        get {
            return _show_back;
        }
        set {
            _show_back = value;

            back_button.set_visible (value);
        }
    }

    /**
    * Add a child to the AppBar, should only be used in the context of a UI or Blueprint file. There should be no need to use this method in code.
    * Please note that an AppBar should only have at most three children.
    */
    public new void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
        title.pack_end ((Gtk.Widget)child);
    }

    /**
    * Append a child to the AppBar.
    * Please note that an AppBar should only have at most three children.
    * @param child The child to append.
    */
    public void append(Gtk.Widget child) {
        title.pack_end (child);
    }

    /**
    * Remove a child from the AppBar.
    * @param child The child to remove.
    */
    public void remove(Gtk.Widget child) {
        title.remove (child);
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
            var selected_page = stack.pages.get_selection ();
            stack.pages.select_item (int.max (((int)selected_page.get_nth (0) - 1), 0), true);
        });
        title.pack_start (back_button);

        title.set_parent (this);
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BoxLayout));
    }

    ~AppBar () {
        title.unparent ();
    }
}
