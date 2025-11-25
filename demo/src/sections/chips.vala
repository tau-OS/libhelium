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
[GtkTemplate (ui = "/com/fyralabs/Helium1/Demo/chips.ui")]
public class Demo.Chips : He.Bin {
    [GtkChild]
    private unowned Gtk.FlowBox chips_box;
    [GtkChild]
    private unowned Gtk.FlowBox removable_chips_box;

    construct {
        // Selectable chips
        var chip1 = new He.Chip ("Music");
        chips_box.append (chip1);

        var chip2 = new He.Chip ("Videos");
        chips_box.append (chip2);

        var chip3 = new He.Chip ("Photos");
        chip3.active = true;
        chips_box.append (chip3);

        var chip4 = new He.Chip ("Documents");
        chips_box.append (chip4);

        var chip5 = new He.Chip ("Downloads");
        chips_box.append (chip5);

        // Removable chips
        var removable1 = new He.Chip ("Important");
        removable1.show_close_button = true;
        removable1.close_clicked.connect (() => {
            removable_chips_box.remove (removable1);
        });
        removable_chips_box.append (removable1);

        var removable2 = new He.Chip ("Work");
        removable2.show_close_button = true;
        removable2.close_clicked.connect (() => {
            removable_chips_box.remove (removable2);
        });
        removable_chips_box.append (removable2);

        var removable3 = new He.Chip ("Personal");
        removable3.show_close_button = true;
        removable3.close_clicked.connect (() => {
            removable_chips_box.remove (removable3);
        });
        removable_chips_box.append (removable3);

        var removable4 = new He.Chip ("Archived");
        removable4.show_close_button = true;
        removable4.close_clicked.connect (() => {
            removable_chips_box.remove (removable4);
        });
        removable_chips_box.append (removable4);
    }
}
