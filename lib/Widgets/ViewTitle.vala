/**
 * A ViewTitle is a widget that displays a view's title.
 */
public class He.ViewTitle : Gtk.Widget, Gtk.Buildable {
    private Gtk.Label? _label;
    /**
     * Sets the title of the view.
     */
    public string? label {
        set {
            _label.set_text(value);
        }

        get {
            return _label.get_text();
        }
    }   

    construct {
        _label = new Gtk.Label ("");
        _label.xalign = 0;
        _label.valign = Gtk.Align.CENTER;
        _label.add_css_class ("view-title");
        _label.margin_top = 6;
        _label.margin_start = 18;
        _label.margin_end = 12;
        _label.margin_bottom = 12;

        _label.set_parent (this);
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BinLayout));
    }
}
