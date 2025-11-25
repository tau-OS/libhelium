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
[GtkTemplate (ui = "/com/fyralabs/Helium1/Demo/colorpicker.ui")]
public class Demo.ColorPicker : He.Bin {
    [GtkChild]
    private unowned Gtk.Box colorpicker_box;
    [GtkChild]
    private unowned Gtk.Label color_label;

    construct {
        // Color picker without label
        var picker_simple = new He.ColorPickerButton ();
        picker_simple.has_label = false;
        Gdk.RGBA red = { 0.8f, 0.2f, 0.2f, 1.0f };
        picker_simple.current_color = red;
        picker_simple.color_changed.connect ((color) => {
            color_label.label = "Selected: #%02x%02x%02x".printf (
                (int)(color.red * 255),
                (int)(color.green * 255),
                (int)(color.blue * 255)
            );
        });
        colorpicker_box.append (picker_simple);

        // Color picker with label and copy button
        var picker_labeled = new He.ColorPickerButton ();
        picker_labeled.has_label = true;
        Gdk.RGBA blue = { 0.2f, 0.4f, 0.8f, 1.0f };
        picker_labeled.current_color = blue;
        picker_labeled.color_changed.connect ((color) => {
            color_label.label = "Selected: #%02x%02x%02x".printf (
                (int)(color.red * 255),
                (int)(color.green * 255),
                (int)(color.blue * 255)
            );
        });
        colorpicker_box.append (picker_labeled);

        // Another color picker with green
        var picker_green = new He.ColorPickerButton ();
        picker_green.has_label = true;
        Gdk.RGBA green = { 0.2f, 0.7f, 0.3f, 1.0f };
        picker_green.current_color = green;
        picker_green.color_changed.connect ((color) => {
            color_label.label = "Selected: #%02x%02x%02x".printf (
                (int)(color.red * 255),
                (int)(color.green * 255),
                (int)(color.blue * 255)
            );
        });
        colorpicker_box.append (picker_green);
    }
}
