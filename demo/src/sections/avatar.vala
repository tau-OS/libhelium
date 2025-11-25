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
[GtkTemplate (ui = "/com/fyralabs/Helium1/Demo/avatar.ui")]
public class Demo.Avatar : He.Bin {
    [GtkChild]
    private unowned Gtk.Box sizes_box;
    [GtkChild]
    private unowned Gtk.Box status_box;

    construct {
        // Different sizes
        var avatar_24 = new He.Avatar (24, null, "Amy Liu", false);
        avatar_24.set_valign (Gtk.Align.CENTER);
        sizes_box.append (avatar_24);

        var avatar_32 = new He.Avatar (32, null, "Ben Carter", false);
        avatar_32.set_valign (Gtk.Align.CENTER);
        sizes_box.append (avatar_32);

        var avatar_48 = new He.Avatar (48, null, "Carlos Mendez", false);
        avatar_48.set_valign (Gtk.Align.CENTER);
        sizes_box.append (avatar_48);

        var avatar_64 = new He.Avatar (64, null, "Diana Ross", false);
        avatar_64.set_valign (Gtk.Align.CENTER);
        sizes_box.append (avatar_64);

        var avatar_96 = new He.Avatar (96, null, "Erik Johansson", false);
        sizes_box.append (avatar_96);

        // Status indicators
        var status_none = new He.Avatar (56, null, "Fiona Chen", false);
        status_box.append (status_none);

        var status_green = new He.Avatar (56, null, "George Miller", true, He.Avatar.StatusColor.GREEN);
        status_box.append (status_green);

        var status_yellow = new He.Avatar (56, null, "Hannah Park", true, He.Avatar.StatusColor.YELLOW);
        status_box.append (status_yellow);

        var status_red = new He.Avatar (56, null, "Ivan Petrov", true, He.Avatar.StatusColor.RED);
        status_box.append (status_red);
    }
}
