namespace He {
    abstract class Button : Gtk.Button, Gtk.Buildable {
        public abstract He.Colors color { get; set; }

        construct {
            this.color = He.Colors.GREEN;
        }
    }
}
