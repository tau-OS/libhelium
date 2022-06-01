namespace He {
    class ContentBlock : Gtk.Box, Gtk.Buildable {
        construct {
            this.add_css_class ("content-block");
        }
    }
}
