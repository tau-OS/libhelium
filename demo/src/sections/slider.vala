/*
 * Copyright (c) 2024 Fyra Labs
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
[GtkTemplate (ui = "/com/fyralabs/Helium1/Demo/slider.ui")]
public class Demo.Slider : He.Bin {
    [GtkChild]
    private unowned Gtk.Box slider_box;
    [GtkChild]
    private unowned Gtk.Label slider_value_label;

    construct {
        // Standard slider with icons
        var slider_standard = new He.Slider ();
        slider_standard.set_range (0, 100);
        slider_standard.value = 50;
        slider_standard.left_icon = "audio-volume-low-symbolic";
        slider_standard.right_icon = "audio-volume-high-symbolic";
        slider_standard.hexpand = true;
        slider_standard.value_changed.connect (() => {
            slider_value_label.label = "Value: %.0f".printf (slider_standard.value);
        });
        slider_box.append (slider_standard);

        // Wavy animated slider
        var slider_wavy = new He.Slider ();
        slider_wavy.set_range (0, 100);
        slider_wavy.value = 30;
        slider_wavy.is_wavy = true;
        slider_wavy.animate = true;
        slider_wavy.left_icon = "display-brightness-symbolic";
        slider_wavy.right_icon = "display-brightness-symbolic";
        slider_wavy.hexpand = true;
        slider_box.append (slider_wavy);

        // Slider with stop indicators
        var slider_stops = new He.Slider ();
        slider_stops.set_range (0, 100);
        slider_stops.value = 75;
        slider_stops.stop_indicator_visibility = true;
        slider_stops.add_mark (0, null);
        slider_stops.add_mark (25, null);
        slider_stops.add_mark (50, null);
        slider_stops.add_mark (75, null);
        slider_stops.add_mark (100, null);
        slider_stops.hexpand = true;
        slider_box.append (slider_stops);

        // Simple slider without icons
        var slider_simple = new He.Slider ();
        slider_simple.set_range (0, 100);
        slider_simple.value = 60;
        slider_simple.hexpand = true;
        slider_box.append (slider_simple);
    }
}
