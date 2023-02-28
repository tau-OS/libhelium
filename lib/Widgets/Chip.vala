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
* A Chip is an element that can facilitate entering information, making selections, filtering content, or triggering actions.
*/
public class He.Chip : Gtk.ToggleButton, Gtk.Actionable {
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
  
  private bool _active;
  /**
   * The active state of the button.
   */
  public bool active {
      set {
          _active = value;
      }

      get {
          return _active;
      }
  }

  /**
  * Creates a new Chip.
  * @param label The text to display in the chip.
  *
     * @since 1.0
     */
  public Chip(string label) {
    this.label = label;
  }

  construct {
    this.add_css_class ("chip");
    this.color = He.Colors.NONE;
  }
}
