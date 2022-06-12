/**
* A Badge is a small status indicator that can be used to provide additional information about an object.
*/
public class He.Badge : Gtk.Widget,  Gtk.Buildable {
    private Gtk.Overlay overlay = new Gtk.Overlay ();
    private Gtk.Box box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
    private Gtk.Label _label;

    /**
    * The child of the badge.
    */
    public Gtk.Widget? child {
        get {
            return overlay.get_child();
        }

        set {
            overlay.set_child(value);
        }
    }

    /**
    * Add a child to the badge, should only be used in the context of a UI or Blueprint file. There should be no need to use this method in code.
    */
  public void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
    this.child = (Gtk.Widget) child;
  }

    public string? label {
        get {
            return _label?.get_text ();
        }

        set {
            if (value == null) {
                box.remove_css_class ("badge-info");
                box.remove(_label);
                box.valign = Gtk.Align.START;
                box.width_request = 10;
                box.height_request = 10;                
                _label = null;
                return;
            }

            if (_label == null) {
                _label = new Gtk.Label (null);
                box.valign = Gtk.Align.END;
                box.add_css_class ("badge-info");
                box.width_request = 0;
                box.height_request = 0;                
                box.append (_label);
            }

            _label.set_text (value);
        }
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BinLayout));
    }

    construct {
        box.valign = Gtk.Align.START;
        box.halign = Gtk.Align.END;
        box.width_request = 10;
        box.height_request = 10;        
        box.add_css_class ("badge");

        overlay.add_overlay (box);

        overlay.set_parent (this);
    }

    ~Badge () {
        this.overlay.unparent ();
    }
}