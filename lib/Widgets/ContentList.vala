/**
 * A Content List is a list of content blocks with an optional title and description.
 */
public class He.ContentList : He.Bin, Gtk.Buildable {
    private Gtk.Box text_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);
    private Gtk.ListBox list = new Gtk.ListBox ();

    private Gtk.Label title_label = new Gtk.Label (null);
    private Gtk.Label description_label = new Gtk.Label (null);

    /**
     * The title of the content list.
     */
    public string title {
        get { return title_label.get_text (); }
        set {
            title_label.set_text (value);
            title_label.set_visible (value != null);
            if (value != null) {
                this.margin_top = 18;
            } else {
                this.margin_top = 0;
            }
        }
    }

    /**
     * The description of the content list.
     */
    public string description {
        get { return description_label.get_text (); }
        set { 
            description_label.set_text (value); 
            description_label.set_visible (value != null);
        }
    }

    /**
     * Adds a new item to the content list, should only be used in the context of a UI or Blueprint file. There should be no need to use this method in code.
     */
    public new void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
        if (((Gtk.Widget) child).get_type () == typeof (He.ContentBlock)) {
            list.append ((Gtk.Widget) child);
        } else if (((Gtk.Widget) child).get_type () == typeof (He.MiniContentBlock)) {
            list.append ((Gtk.Widget) child);
        } else {
            ((Gtk.Widget) child).set_parent (this);
        }
    }

    /**
     * Adds a new item to the content list.
     * @param child The item to add.
     */
    public void add (Gtk.Widget child) {
        if (child.get_type () == typeof (He.ContentBlock)) {
            list.append (child);
        } else if (child.get_type () == typeof (He.MiniContentBlock)) {
            list.append (child);
        } else {
            child.set_parent (this);
        }
    }

    /**
     * Removes an item from the content list.
     * @param child The item to remove.
     */
    public void remove (Gtk.Widget child) {
        if (child.get_parent () == this) {
            child.unparent ();
        } else if (child.get_parent ().get_parent () == list) {
            list.remove (child);
        }
    }

    ~ContentList () {
        if (list != null) {
            list.unparent ();
        }
        if (text_box != null) {
            text_box.unparent ();
        }
        if (title_label != null) {
            title_label.unparent ();
        }
        if (description_label != null) {
            description_label.unparent ();
        }
    }

    construct {
        this.title_label.add_css_class ("header");
        this.title_label.xalign = 0;
        this.description_label.add_css_class ("body");
        this.description_label.xalign = 0;

        var layout = new Gtk.BoxLayout (Gtk.Orientation.VERTICAL) {
            spacing = 12,
        };
        this.layout_manager = layout;

        this.text_box.append (title_label);
        this.text_box.append (description_label);

        list.set_selection_mode (Gtk.SelectionMode.NONE);
        list.add_css_class ("content-list");

        text_box.set_parent (this);
        list.set_parent (this);
    }
}