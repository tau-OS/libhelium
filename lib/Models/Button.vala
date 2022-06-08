public abstract class He.Button : Gtk.Button, Gtk.Buildable {
    public abstract He.Colors color { get; set; }

    public string icon {
        set {
            set_icon_name(value);
        }

        owned get {
            return icon_name;
        }
    }

    construct {
        this.color = He.Colors.PURPLE;
    }
}
