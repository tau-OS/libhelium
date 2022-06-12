/**
 * An Iconic Button is used in a {@link BottomBar} to display an action.
 */
public class He.IconicButton : Gtk.Button, Gtk.Buildable {
  /**
   * The icon name to display.
   */
  public string icon {
    get {
      return this.get_icon_name ();
    }
    set {
      this.set_icon_name (value);
    }
  }

  /**
   * Constructs a new IconicButton.
   * @param icon The icon name to display.
   */
  public IconicButton(string icon) {
    this.icon = icon;
  }

  construct {
    this.add_css_class ("flat");
    this.valign = Gtk.Align.CENTER;
  }
}
