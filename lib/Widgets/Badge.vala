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
* A Badge is a small status indicator that can be used to provide additional information about an object.
*/
public class He.Badge : He.Bin {
    private Gtk.Overlay overlay = new Gtk.Overlay ();
    private Gtk.Box box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
    private Gtk.Label _label;

    /**
    * The child of the badge.
    *
     * @since 1.0
     */
    public new Gtk.Widget? child {
        get {
            return overlay.get_child ();
        }

        set {
            overlay.set_child (value);
        }
    }

    public string? label {
        get {
            return _label?.get_text ();
        }

        set {
            if (value == null) {
                box.remove_css_class ("badge-info");
                box.remove (_label);
                box.valign = Gtk.Align.START;
                box.width_request = 10;
                box.height_request = 10;
                _label = null;
                return;
            }

            if (_label == null) {
                _label = new Gtk.Label (null);
                box.valign = Gtk.Align.END;
                box.add_css_class ("badge-info");
                box.width_request = 0;
                box.height_request = 0;
                box.append (_label);
            }

            _label.set_text (value);
        }
    }

    public Badge () {
        base ();
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BinLayout));
    }

    construct {
        box.valign = Gtk.Align.START;
        box.halign = Gtk.Align.END;
        box.width_request = 10;
        box.height_request = 10;
        box.add_css_class ("badge");

        overlay.add_overlay (box);
        overlay.set_parent (this);
    }
}
