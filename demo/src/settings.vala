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
*
*/
[GtkTemplate (ui = "/co/tauos/Helium1/Demo/settings.ui")]
public class Demo.SettingsWindow : He.SettingsWindow {
  private MainWindow _window;

  [GtkChild]
  unowned Gtk.ColorButton clr_btn;
  
  construct {
    Gdk.RGBA default_color = {
      0.5490f,
      0.3372f,
      0.7490f,
      1.0f
    };

    clr_btn.set_rgba (this._window.app.default_accent_color == null ? default_color : He.Color.to_gdk_rgba(this._window.app.default_accent_color));
    clr_btn.color_set.connect (() => {
      // do thing with color
      var color = clr_btn.rgba;

      He.Color.RGBColor rgb_color = He.Color.from_gdk_rgba(color);
      
      this._window.app.default_accent_color = rgb_color;
    });
  }

  public SettingsWindow(MainWindow window) {
    base(window);
    _window = window;
  }
}