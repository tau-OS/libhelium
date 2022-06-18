/**
 * A helper class to derive Buttons from.
 */
public abstract class He.Button : Gtk.Button, Gtk.Buildable {

    /**
     * The color of the button.
     */
    public abstract He.Colors color { get; set; }

    /**
     * The icon of the Button.
     */
    public string icon {
        set {
            set_icon_name(value);
        }

        owned get {
            return icon_name;
        }
    }
}
