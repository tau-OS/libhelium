public abstract class He.View : Gtk.Box, Gtk.Buildable {
    private He.ViewTitle title_label = new He.ViewTitle();
    private He.ViewSubTitle subtitle_label = new He.ViewSubTitle();
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

    public void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
        if (type == "view-button") {
            title_button_box.append ((Gtk.Widget) child);
        } else {
            box.append ((Gtk.Widget) child);
        }
    }

    construct {
        title_label.visible = false;
        subtitle_label.visible = false;

        box.margin_start = box.margin_end = box.margin_bottom = 18;
        box.spacing = 6;
        box.orientation = Gtk.Orientation.VERTICAL;

        title_box.append (title_label);
        title_box.append (subtitle_label);

        title_button_box.valign = Gtk.Align.START;
        title_button_box.append (title_box);

        this.orientation = Gtk.Orientation.VERTICAL;
        this.append (title_button_box);

        var scroll = new Gtk.ScrolledWindow ();
        scroll.hscrollbar_policy = Gtk.PolicyType.NEVER;
        scroll.vexpand = true;
        scroll.set_child (box);

        this.append (scroll);
    }
}
