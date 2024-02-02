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
*/

/**
* A Progressbar indicates the progress of some process and contains
* a disable-able Stop Indicator for accessibility purposes.
*/
public class He.ProgressBar : He.Bin, Gtk.Buildable {
    private Gtk.Box main_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
    private Gtk.Box stop_indicator = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

    /**
     * The progressbar inside the Progressbar.
     */
    public Gtk.ProgressBar progressbar = new Gtk.ProgressBar ();

    /**
     * Sets the visibility of the stop indicator of the Progressbar.
     */
    private bool _stop_indicator_visibility;
    public bool stop_indicator_visibility {
        get {
             return _stop_indicator_visibility;
        }
        set {
            _stop_indicator_visibility = value;
            if (_stop_indicator_visibility) {
                stop_indicator.set_visible (true);
            } else {
                stop_indicator.set_visible (false);
            }
        }
    }


    /**
     * Constructs a new Progressbar.
     *
     * @since 1.0
     */
    public ProgressBar () {
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BoxLayout));
    }

    construct {
        stop_indicator.margin_end = 4;
        stop_indicator.valign = Gtk.Align.CENTER;
        stop_indicator.halign = Gtk.Align.END;
        stop_indicator.set_visible (true);
        stop_indicator.add_css_class ("stop-indicator");

        var pb_overlay = new Gtk.Overlay ();
        pb_overlay.hexpand = true;
        pb_overlay.add_overlay (stop_indicator);
        pb_overlay.set_child (progressbar);

        main_box.append (pb_overlay);
        main_box.valign = Gtk.Align.CENTER;
        main_box.hexpand = true;
        main_box.add_css_class ("progressbar");
        main_box.set_parent (this);
    }
}