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
[GtkTemplate (ui = "/com/fyralabs/Helium1/Demo/datepicker.ui")]
public class Demo.DatePicker : He.Bin {
    [GtkChild]
    private unowned Gtk.Box picker_box;
    [GtkChild]
    private unowned Gtk.Label selected_label;

    construct {
        // Default date picker
        var date_picker = new He.DatePicker ();
        date_picker.hexpand = true;
        date_picker.notify["date"].connect (() => {
            selected_label.label = "Selected: %s".printf (date_picker.date.format ("%B %d, %Y"));
        });
        selected_label.label = "Selected: %s".printf (date_picker.date.format ("%B %d, %Y"));
        picker_box.append (date_picker);

        // Date picker with custom format
        var date_picker_custom = new He.DatePicker.with_format ("%Y-%m-%d");
        date_picker_custom.hexpand = true;
        picker_box.append (date_picker_custom);
    }
}
