public class He.Window : Gtk.Window {
    private bool _has_title;
    public bool has_title {
        get {
            return _has_title;
        }
        set {
            _has_title = value;
            if (!value) {
                var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
                this.set_titlebar (box);
            } else {
                var title = new He.AppBar ();
                title.add_css_class ("flat");
                this.set_titlebar (title);
            }
        }
    }

    construct {
        has_title = false;
    }
}