/*
* Copyright (c) 2022 Fyra Labs
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/

/**
 * A Disclosure Button is a view-based button that acts on said view.
 */
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
  public DisclosureButton (string icon) {
    this.icon = icon;
  }

  /**
   * Create a new DisclosureButton from an icon.
   * @param icon The icon to display on the button.
   *
     * @since 1.0
     */
    public DisclosureButton.from_icon (string icon) {
      this.icon = icon;
  }

  construct {
    this.add_css_class ("disclosure-button");
    this.valign = Gtk.Align.CENTER;
  }
}
