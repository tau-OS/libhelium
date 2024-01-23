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
*
*/
[GtkTemplate (ui = "/com/fyralabs/Helium1/Demo/settings.ui")]
public class Demo.SettingsWindow : He.SettingsWindow {
  private MainWindow _window;
  private uint fwscale_timeout;
  private static GLib.Settings tau_appearance_settings;

  [GtkChild]
  unowned Gtk.ColorButton clr_btn;
  [GtkChild]
  unowned He.Slider slider;

  static construct {
    tau_appearance_settings = new GLib.Settings ("com.fyralabs.desktop.appearance");
  }

  public SettingsWindow (MainWindow window) {
    base (window);
    _window = window;

    Gdk.RGBA default_color = {
      0.5490f,
      0.3372f,
      0.7490f,
      1.0f
    };
    clr_btn.set_rgba (
      this._window.app.default_accent_color == null ?
      default_color :
      He.Color.to_gdk_rgba (this._window.app.default_accent_color)
    );
    clr_btn.color_set.connect (() => {
      // do thing with color
      var color = clr_btn.rgba;

      clr_btn.set_rgba (color);

      He.Color.RGBColor rgb_color = He.Color.from_gdk_rgba (color);

      this._window.app.default_accent_color = rgb_color;
    });

    var font_weight_adjustment = new Gtk.Adjustment (-1, 0.75, 2.0, 0.0858, 0, 0);

    slider.scale.set_adjustment (font_weight_adjustment);
    slider.scale.draw_value = false;
    slider.scale.add_mark (1.0, Gtk.PositionType.BOTTOM, null);
    slider.scale.add_mark (1.5, Gtk.PositionType.BOTTOM, null);
    slider.scale.add_mark (2.0, Gtk.PositionType.BOTTOM, null);

    tau_appearance_settings.bind ("font-weight", font_weight_adjustment, "value", SettingsBindFlags.GET);

    // Setting scale is slow, so we wait while pressed to keep UI responsive
    font_weight_adjustment.value_changed.connect (() => {
        if (fwscale_timeout != 0) {
            GLib.Source.remove (fwscale_timeout);
        }

        fwscale_timeout = Timeout.add (300, () => {
            fwscale_timeout = 0;
            tau_appearance_settings.set_double ("font-weight", font_weight_adjustment.value);
            return false;
        });
    });
  }
}
