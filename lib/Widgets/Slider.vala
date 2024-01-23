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
* A Slider is a widget that is used to select a value by means of a
* dial running across a trough. Contains optional icons for the slider
* purpose, and a disable-able stop indicator for accessibility purposes.
*/
public class He.Slider : He.Bin, Gtk.Buildable {
    private Gtk.Box main_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
    private Gtk.Box stop_indicator = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
    private Gtk.Image left_icon_img = new Gtk.Image ();
    private Gtk.Image right_icon_img = new Gtk.Image ();

    /**
     * The scale inside the Slider.
     */
    public Gtk.Scale slider = new Gtk.Scale (Gtk.Orientation.HORIZONTAL, null);

    /**
     * Sets the left icon of the Slider.
     */
     public string left_icon {
        get {
            return left_icon_img.get_icon_name ();
        }
        set {
            if (value != null) {
                left_icon_img.set_visible (true);
                left_icon_img.set_from_icon_name (value);
            } else {
                left_icon_img.set_visible (false);
            }
        }
    }

    /**
     * Sets the right icon of the Slider.
     */
     public string right_icon {
        get {
            return right_icon_img.get_icon_name ();
        }
        set {
            if (value != null) {
                right_icon_img.set_visible (true);
                right_icon_img.set_from_icon_name (value);
            } else {
                right_icon_img.set_visible (false);
            }
        }
    }

    /**
     * Sets the visibility of the stop indicator of the Slider.
     */
     public bool stop_indicator_visibility {
        get {
            return value;
        }
        set {
            if (value) {
                stop_indicator.set_visible (true);
            } else {
                stop_indicator.set_visible (false);
            }
        }
    }

     /**
      * Constructs a new Slider.
      *
     * @since 1.0
     */
    public Slider () {
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BoxLayout));
    }

    construct {
        left_icon_img.xalign = 0;
        left_icon_img.set_visible (false);

        right_icon_img.xalign = 1;
        right_icon_img.set_visible (false);

        stop_indicator.margin_end = 4;
        stop_indicator.valign = Gtk.Align.CENTER;
        stop_indicator.halign = Gtk.Align.END;
        stop_indicator.set_visible (false);
        stop_indicator.add_css_class ("stop-indicator");

        var slider_overlay = new Gtk.Overlay ();
        slider_overlay.add_overlay (stop_indicator);
        slider_overlay.set_child (slider);

        main_box.append (left_icon_img);
        main_box.append (slider_overlay);
        main_box.append (right_icon_img);
        main_box.valign = Gtk.Align.CENTER;
        main_box.hexpand = true;
        main_box.add_css_class ("slider");
        main_box.set_parent (this);
    }
}