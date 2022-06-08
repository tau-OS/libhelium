public abstract class He.View : Gtk.Box, Gtk.Buildable {
    private He.ViewTitle title_label = new He.ViewTitle();
    private He.ViewSubTitle subtitle_label = new He.ViewSubTitle();
    private He.ViewSwitcher titleswitcher = new He.ViewSwitcher();
    private Gtk.Box title_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
    private Gtk.Box title_button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
    private Gtk.Box box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

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

    public virtual void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
        if (type == "view-button") {
            title_button_box.append ((Gtk.Widget) child);
        } else {
            box.append ((Gtk.Widget) child);
        }
    }

    public void add (Gtk.Widget widget) {
        box.append (widget);
    }

    construct {
        title_label.visible = false;
        subtitle_label.visible = false;
        titleswitcher.visible = false;

        box.margin_start = box.margin_end = box.margin_bottom = 18;
        box.spacing = 6;
        box.orientation = Gtk.Orientation.VERTICAL;

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
        this.append (title_button_box);

        var scroll = new Gtk.ScrolledWindow ();
        scroll.hscrollbar_policy = Gtk.PolicyType.NEVER;
        scroll.vexpand = true;
        scroll.set_child (box);

        this.orientation = Gtk.Orientation.VERTICAL;
        this.append (scroll);
    }
}
