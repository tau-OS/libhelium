/*
* Copyright (c) 2023 Fyra Labs
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
* A Divider is a thin line that groups content in a view, can be full-width (default) or inset
*/
public class He.Divider : He.Bin {

    /**
    * Whether the divider is inset (has 18px of margin at the start and end) or not.
    */
    private bool _is_inset;
    public bool is_inset {
        get { return _is_inset; }
        set {
            _is_inset = value;

            if (_is_inset) {
                this.add_css_class ("inset");
            } else {
                this.remove_css_class ("inset");
            }
        }
    }

    /**
    * Creates a new Divider.
    */
    public Divider () {
        base ();
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BinLayout));
    }

    construct {
        this.hexpand = true;
        this.add_css_class ("divider");
    }
}
