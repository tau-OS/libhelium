public class He.WelcomeScreen : Gtk.Box, Gtk.Buildable {
    private Gtk.Box action_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
    private Gtk.Box button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
    private Gtk.Label description_label = new Gtk.Label ("");
    private Gtk.Label appname_label = new Gtk.Label ("");

    private string _appname;
    public string appname {
        get { return _appname; }
        set {
            _appname = value;
            if (appname_label != null)
                appname_label.label = "Welcome to " + value;
        }
    }

    private string _description;
    public string description {
        get { return _description; }
        set {
            _description = value;
            if (description_label != null)
                description_label.label = value;
        }
    }

    public void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
        if (type == "action") {
            ((Gtk.Button) child).set_label (((Gtk.Button) child).get_label () + " →");
            action_box.append ((Gtk.Widget) child);
        } else if (type == "action-button") {
            button_box.append ((Gtk.Widget) child);
        }
    }

    public WelcomeScreen (string appname, string description) {
        this.appname = appname;
        this.description = description;
    }

    ~WelcomeScreen () {
        get_first_child ().unparent ();
        this.unparent ();
    }

    construct {
        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        main_box.add_css_class ("content-block");
        main_box.hexpand = true;

        action_box.valign = Gtk.Align.START;
        action_box.halign = Gtk.Align.START;

        button_box.valign = Gtk.Align.END;
        button_box.halign = Gtk.Align.END;
        button_box.margin_bottom = button_box.margin_end = 18;

        appname_label.xalign = 0;
        appname_label.valign = Gtk.Align.START;
        appname_label.margin_bottom = appname_label.margin_top = 12;
        appname_label.add_css_class ("view-title");

        description_label.xalign = 0;
        description_label.valign = Gtk.Align.START;
        description_label.vexpand = true;
        description_label.margin_bottom = description_label.margin_top = 12;

        main_box.append (appname_label);
        main_box.append (action_box);
        main_box.append (description_label);
        main_box.append (button_box);

        this.append (main_box);
        this.set_size_request (360, 400);
        this.margin_top = this.margin_bottom = 6;
        this.margin_start = this.margin_end = 12;
    }
}