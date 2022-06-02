public abstract class He.Button : Gtk.Button, Gtk.Buildable {
    public abstract He.Colors color { get; set; }

    construct {
        this.color = He.Colors.PURPLE;
    }
}
