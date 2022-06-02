public class He.Window : Gtk.Window {
    construct {
        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        this.set_titlebar (box);
    }
}