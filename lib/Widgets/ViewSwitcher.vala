public class He.ViewSwitcher : Gtk.Box, Gtk.Buildable {
    private Gtk.Box box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);

    public void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
        if (type == "stack") {
            this.append ((Gtk.Widget)child);
        } else if (type == "stack-title") {
            box.append ((Gtk.Widget)child);
        }
    }

    private string _stack_child;
    public string stack_child {
        get {
            // TODO: Figure this out better:
            string label = "";
            get_child_label (out label);
            _stack_child = label;
            return _stack_child;
        }

        set {
            _stack_child = value;
        }
    }

    construct {
        box.margin_top = box.margin_bottom = 12;
        this.add_css_class ("viewswitcher");
        this.orientation = Gtk.Orientation.VERTICAL;
        this.append (box);
    }

    private string get_child_label (out string label) {
        Gtk.ToggleButton child = null;

        for (box.get_first_child(); child != null; box.get_next_sibling ()) {
            if (child.active)
                label = child.get_label ();
                print (label);
                return label;
        }

        return "a";
    }
}