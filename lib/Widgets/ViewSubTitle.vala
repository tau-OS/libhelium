/*
* Copyright (c) 2022 Fyra Labs
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
 * A ViewSubTitle is a view's subtitle.
 */
[Version (deprecated = true)]
public class He.ViewSubTitle : He.Bin, Gtk.Buildable {
    private Gtk.Label? _label;
    /**
     * Sets the subtitle text.
     *
     * @since 1.0
     */
    public string? label {
        set {
            _label.set_text (value);
        }

        get {
            return _label.get_text ();
        }
    }

    /**
     * Creates a new ViewSubTitle.
     */
    public ViewSubTitle () {
        base ();
    }

    construct {
        _label = new Gtk.Label ("");
        _label.xalign = 0;
        _label.valign = Gtk.Align.CENTER;
        _label.add_css_class ("view-subtitle");
        _label.margin_top = 6;
        _label.margin_start = 18;
        _label.margin_end = 12;
        _label.margin_bottom = 6;

        _label.set_parent (this);
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BinLayout));
    }
}
