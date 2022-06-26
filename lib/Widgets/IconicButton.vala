/*
* Copyright (c) 2022 Fyra Labs
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/

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
   *
     * @since 1.0
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
