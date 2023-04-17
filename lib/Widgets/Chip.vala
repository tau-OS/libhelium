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
* A Chip is an element that can facilitate entering information, making selections, filtering content, or triggering actions.
*/
public class He.Chip : Gtk.ToggleButton, Gtk.Actionable {
  He.ButtonContent chip_box = new He.ButtonContent ();

  private string _chip_label;
  public string chip_label {
    get { return _chip_label; }
    set {
      _chip_label = value;
      chip_box.label = _chip_label;
    }
  }

  /**
   * Creates a new Chip.
   * @param label The text to display in the chip.
   *
   * @since 1.0
   */
  public Chip (string label) {
    chip_box.label = label;
  }

  construct {
    this.add_css_class ("chip");

    chip_box = new He.ButtonContent ();
    chip_box.get_first_child ().get_first_child ().visible = false;
    chip_box.icon = "";

    notify["active"].connect (() => {
      if (this.active) {
        chip_box.get_first_child ().get_first_child ().visible = true;
        chip_box.icon = "emblem-default-symbolic";
      } else {
        chip_box.get_first_child ().get_first_child ().visible = false;
        chip_box.icon = "";
      }
    });

    chip_box.set_parent (this);
  }
}
