namespace He {
    class SideBar : Gtk.Box, Gtk.Buildable {
        public void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
          this.append ((Gtk.Widget) child);
        }

        construct {
            this.orientation = Gtk.Orientation.VERTICAL;
            this.spacing = 0;
            this.width_request = 200;
            this.hexpand = false;
            this.hexpand_set = true;
        }
    }
}
