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
 * A ViewDual is a view that displays two views side by side.
 */
public class He.ViewDual : He.View {
    private Gtk.Box box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12) {
        homogeneous = true,
        hexpand = true
    };
    private Gtk.Box left_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
    private Gtk.Box right_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

    /**
     * Adds children to either the left or right side of the view, should only be used in the context of a UI or Blueprint file. There should be no need to use this method in code.
     *
     * @since 1.0
     */
    public override void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
        if (type == "left") {
            left_box.append ((Gtk.Widget) child);
        } else if (type == "right") {
            right_box.append ((Gtk.Widget) child);
        } else {
            ((He.View) this).add_child (builder, child, type);
        }
    }

    construct {
        box.append (left_box);
        box.append (right_box);

        this.add (box);
    }
}
