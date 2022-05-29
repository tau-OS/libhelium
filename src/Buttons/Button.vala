abstract class libhelium.Button : Gtk.Button {
    public abstract libhelium.Colors color { get; set; }

    construct {
        this.color = libhelium.Colors.BLUE;
    }
}

