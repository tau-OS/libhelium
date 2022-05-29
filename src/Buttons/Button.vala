abstract class He.Button : Gtk.Button {
    public abstract He.Colors color { get; set; }

    construct {
        this.color = He.Colors.BLUE;
    }
}

