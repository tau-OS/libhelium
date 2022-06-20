/**
 * A helper widget that implements a View that displays items.
 */
public abstract class He.View : Gtk.Widget, Gtk.Buildable {
    private He.ViewTitle title_label = new He.ViewTitle();
    private He.ViewSubTitle subtitle_label = new He.ViewSubTitle();
    private He.ViewSwitcher titleswitcher = new He.ViewSwitcher();
    private Gtk.Box title_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
    private Gtk.Box title_button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
    private Gtk.Box box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

    /**
     * The title of the view.
     */
    public string title {
        get {
            return title_label.label;
        }
        set {
            if (value != null) {
                title_label.label = value;
                title_label.visible = true;
            } else {
                title_label.visible = false;
            }
        }
    }

    /**
     * The stack of the view.
     */
    public Gtk.Stack stack {
        get {
            return stack;
        }
        set {
            if (value != null) {
                titleswitcher.stack = value;
                titleswitcher.visible = true;
            } else {
                titleswitcher.visible = false;
            }
        }
    }

    /**
     * The subtitle of the view.
     */
    public string subtitle {
        get {
            return subtitle_label.label;
        }
        set {
            if (value != null) {
                subtitle_label.label = value;
                subtitle_label.visible = true;
            } else {
                subtitle_label.visible = false;
            }
        }
    }

    /**
     * Whether the view child has margins or is full-bleed.
     */
    public bool has_margins {
        get {
            return box.margin_top > 0 || 
                   box.margin_bottom > 0 ||
                   box.margin_left > 0 ||
                   box.margin_right > 0;
        }
        set {
            box.margin_bottom = value ? 18 : 0;
            box.margin_end = value ? 18 : 0;
            box.margin_start = value ? 18 : 0;
        }
    }

    /**
     * Add a child to the welcome screen, should only be used in the context of a UI or Blueprint file. There should be no need to use this method in code.
     */
    public virtual void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
        if (type == "view-button") {
            title_button_box.append ((Gtk.Widget) child);
        } else {
            box.append ((Gtk.Widget) child);
        }
    }

    /**
     * Add a child directly to the view. Used only in code.
     */
    public void add (Gtk.Widget widget) {
        box.append (widget);
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BoxLayout));
    }

    construct {
        title_label.visible = false;
        subtitle_label.visible = false;
        titleswitcher.visible = false;
        box.spacing = 6;
        box.orientation = Gtk.Orientation.VERTICAL;

        title_box.valign = Gtk.Align.CENTER;

        if (title != null) {
            title_box.append (title_label);
            title_box.append (subtitle_label);
        }

        if (titleswitcher != null) {
            title_button_box.margin_start = title_button_box.margin_end = 18;
            title_button_box.margin_bottom = title_button_box.margin_top = 12;
            title_box.append (titleswitcher);
        }

        title_button_box.valign = Gtk.Align.START;
        title_button_box.append (title_box);

        var scroll = new Gtk.ScrolledWindow ();
        scroll.hscrollbar_policy = Gtk.PolicyType.NEVER;
        scroll.vexpand = true;
        scroll.set_child (box);

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.append (title_button_box);
        main_box.append (scroll);
        main_box.set_parent (this);
    }
}
