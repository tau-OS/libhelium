/**
 * A ViewAux shows a view with an optional side pane.
 */
public class He.ViewAux : He.View {
    private Gtk.Box box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12) {
        homogeneous = true
    };
    private Gtk.Box left_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
    private Gtk.Box right_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
    private Gtk.Revealer revealer = new Gtk.Revealer ();

    /**
     * Shows/hides the side pane.
     */
    private bool _show_aux;
    public bool show_aux {
        get { return _show_aux; }
        set {
            _show_aux = value;
            revealer.reveal_child = value;
        }
    }

    /**
     * Adds a widget to ViewAux whether it is the main view or the side pane, should only be used in the context of a UI or Blueprint file. There should be no need to use this method in code.
     */
    public override void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
        if (type == "left") {
            left_box.append ((Gtk.Widget) child);
        } else if (type == "right") {
            right_box.append ((Gtk.Widget) child);
        } else {
            ((He.View) this).add_child (builder, child, type);
        }
    }

    ~ViewAux () {
        revealer.unparent ();
        left_box.unparent ();
        right_box.unparent ();
        box.unparent ();
        this.unparent ();
    }

    construct {
        box.hexpand = true;
        box.append (left_box);

        var separator = new Gtk.Separator (Gtk.Orientation.VERTICAL);

        var revealer_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
        revealer_box.hexpand = false;
        revealer_box.vexpand = true;

        revealer_box.append (separator);
        revealer_box.append (revealer);

        revealer.set_transition_type (Gtk.RevealerTransitionType.CROSSFADE);
        revealer.set_child (right_box);
        box.append (revealer_box);
        
        this.add (box);
    }
}