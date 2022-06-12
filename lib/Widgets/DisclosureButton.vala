public class He.DisclosureButton : He.Button {
  private He.Colors _color;
  /**
   * The color of the button.
   */
  public override He.Colors color {
      set {
          _color = He.Colors.NONE;
      }

      get {
          return _color;
      }
  }

  /**
   * Sets the icon of the button.
   */
  public new string icon {
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
