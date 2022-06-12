public class He.DisclosureButton : Gtk.Button, Gtk.Buildable {
  /**
   * Sets the icon of the button.
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
   * Creates a new DisclosureButton.
   * @param icon The name of the icon to use.
   */
  public DisclosureButton(string icon) {
    this.icon = icon;
  }

  construct {
    this.add_css_class ("disclosure-button");
    this.valign = Gtk.Align.CENTER;
  }
}
