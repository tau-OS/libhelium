public class He.ViewSwitcher : Gtk.Box, Gtk.Buildable {
    private Gtk.Box box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);

    public void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
        if (type == "stack") {
            this.append ((Gtk.Widget)child);
        } else {
            box.append ((Gtk.Widget)child);
        }
    }

    private string _stack_child_name;
    public string stack_child_name {
        get {
            // TODO: Figure this out better:
            //  Gtk.Widget? child = null;
            //  string child_label = "";
            //  for (box.get_first_child (); child != null; child = box.get_next_sibling ()) {
            //      print(((Gtk.ToggleButton) child).get_label ());
            //      if (((Gtk.ToggleButton) child).get_active ()) {
            //          child_label = ((Gtk.ToggleButton) child).get_label ();
            //          _stack_child_name = child_label;
            //      }
            //  }
            return _stack_child_name;
        }

        set {
            _stack_child_name = value;
        }
    }

    construct {
        box.margin_top = box.margin_bottom = 12;
        this.add_css_class ("viewswitcher");
        this.orientation = Gtk.Orientation.VERTICAL;
        this.append (box);
    }
}