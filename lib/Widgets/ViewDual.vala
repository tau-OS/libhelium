/**
 * A ViewDual is a view that displays two views side by side.
 */
public class He.ViewDual : He.View {
    private Gtk.Box box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12) {
        homogeneous = true,
        hexpand = true
    };
    private Gtk.Box left_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
    private Gtk.Box right_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

    /**
     * Adds children to either the left or right side of the view, should only be used in the context of a UI or Blueprint file. There should be no need to use this method in code.
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

    construct {
        box.append (left_box);
        box.append (right_box);
        
        this.add (box);
    }
}