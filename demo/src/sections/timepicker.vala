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
[GtkTemplate (ui = "/com/fyralabs/Helium1/Demo/timepicker.ui")]
public class Demo.TimePicker : He.Bin {
    [GtkChild]
    private unowned Gtk.Box picker_box;
    [GtkChild]
    private unowned Gtk.Label selected_label;

    construct {
        // Default time picker (12h format)
        var time_picker = new He.TimePicker ();
        time_picker.hexpand = true;
        time_picker.time_changed.connect (() => {
            selected_label.label = "Selected: %s".printf (time_picker.time.format ("%I:%M %p"));
        });
        selected_label.label = "Selected: %s".printf (time_picker.time.format ("%I:%M %p"));
        picker_box.append (time_picker);

        // Time picker with custom formats
        var time_picker_custom = new He.TimePicker.with_format ("%-I:%M %p", "%H:%M");
        time_picker_custom.hexpand = true;
        picker_box.append (time_picker_custom);
    }
}
