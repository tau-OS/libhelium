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
 * A helper class to derive Buttons from.
 *
 * @since 1.0
 */
public class He.ButtonContent : Gtk.Widget, Gtk.Buildable {
	private Gtk.Label lbl = new Gtk.Label ("");
	public Gtk.Image image = new Gtk.Image ();

    /**
     * The icon of the Button.
     * @since 1.0
     */
    public string icon {
        set {
            if (value != null)
                image.set_from_icon_name(value);
        }

        owned get {
            return image.get_icon_name ();
        }
    }
    
    /**
     * The label of the Button.
     * @since 1.0
     */
    public string label {
        set {
            if (value != null)
                lbl.set_label(value);
        }

        owned get {
            return lbl.label;
        }
    }
    
    construct {
        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
    	box.append (image);
    	box.append (lbl);
    	box.set_parent (this);
    }
    
    static construct {
        set_layout_manager_type (typeof (Gtk.BoxLayout));
    }

    ~ButtonContent () {
        Gtk.Widget child;

        while ((child = this.get_first_child ()) != null)
            child.unparent ();

        this.unparent ();
    }
}
