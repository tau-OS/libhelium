/**
 * A helper class for subclassing custom widgets.
 */
public class He.Bin : Gtk.Widget, Gtk.Buildable {
    private Gtk.Widget? child;

    /**
    * Add a child to the Bin, should only be used in the context of a UI or Blueprint file. There should be no need to use this method in code.
    */
    public void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
        this.child = (Gtk.Widget) child;
    }

    ~Bin () {
        if (this.child != null) {
            this.child.unparent ();
        }
    }

    /**
     * Grabs the widget's focus.
     * @param widget The widget to grab the focus for.
     * returns true if the grab was successful, false otherwise.
     */
    public new bool grab_focus (Gtk.Widget? widget) {
        if (widget.get_focusable () == false) {
            return false;
        }

        widget.get_root ().set_focus (widget);
        return true;
    }

    /**
     * Grabs the widget's child focus.
     * @param widget The widget to assess the child to grab the focus for.
     * returns true if the grab was successful, false otherwise.
     */
    public new bool grab_focus_child (Gtk.Widget? widget) {
        Gtk.Widget child;

        for (
             child = widget.get_first_child ();
             child != null;
             child = widget.get_next_sibling ()) {
            if (child.grab_focus ()) {
                return true;
            }
        }

        return false;
    }
}
