/**
 * An Iconic Button is used in a {@link BottomBar} to display an action.
 */
public class He.IconicButton : He.Button {
  /**
   * The icon name to display.
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
   * The tooltip text to display.
   */
  private string _tooltip;
  public new string tooltip {
    get {
      return this.get_tooltip_text ();
    }
    set {
      _tooltip = value;
      this.set_tooltip_text (_tooltip);
    }
  }

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
   * Constructs a new IconicButton.
   * @param icon The icon name to display.
   */
  public IconicButton(string icon) {
    this.icon = icon;
  }

  construct {
    this.add_css_class ("flat");
    this.valign = Gtk.Align.CENTER;
    this.color = He.Colors.NONE;
  }
}
