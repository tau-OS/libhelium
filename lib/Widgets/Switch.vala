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
* A Switch is a widget that is used to toggle a setting on or off,
* or to indicate two modes via a toggle (ex. Light/Dark).
*/
public class He.Switch : He.Bin, Gtk.Buildable {
    private Gtk.Box main_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
    private Gtk.Image left_icon_img = new Gtk.Image ();
    private Gtk.Image right_icon_img = new Gtk.Image ();

    /**
     * The switch inside the Switch.
     */
    public Gtk.Switch iswitch = new Gtk.Switch ();

    /**
     * Sets the left icon of the Switch.
     */
    private string _left_icon;
    public string left_icon {
        get {
            return _left_icon;
        }
        set {
            _left_icon = value;
            if (_left_icon != null) {
                left_icon_img.set_from_icon_name (_left_icon);
            }
        }
    }

    /**
     * Sets the right icon of the Switch.
     */
    private string _right_icon;
    public string right_icon {
        get {
            return _right_icon;
        }
        set {
            _right_icon = value;
            if (_right_icon != null) {
                right_icon_img.set_from_icon_name (_right_icon);
            }
        }
    }

    /**
     * Constructs a new Switch.
     *
     * @since 1.0
     */
    public Switch () {
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BoxLayout));
    }

    construct {
        left_icon_img.halign = Gtk.Align.END;
        left_icon_img.valign = Gtk.Align.CENTER;
        left_icon_img.margin_end = 4;
        left_icon_img.add_css_class ("negative");

        right_icon_img.halign = Gtk.Align.START;
        right_icon_img.valign = Gtk.Align.CENTER;
        right_icon_img.margin_start = 4;
        right_icon_img.add_css_class ("positive");

        iswitch.halign = Gtk.Align.CENTER;
        iswitch.valign = Gtk.Align.CENTER;

        left_icon = "window-close-symbolic";
        right_icon = "emblem-default-symbolic";

        if (iswitch.active) {
            right_icon_img.opacity = 1;
            left_icon_img.opacity = 0;
            left_icon_img.remove_css_class ("active");
        } else {
            left_icon_img.opacity = 1;
            right_icon_img.opacity = 0;
            left_icon_img.add_css_class ("active");
        }
        iswitch.notify["active"].connect (() => {
            if (iswitch.active) {
                right_icon_img.opacity = 1;
                left_icon_img.opacity = 0;
                left_icon_img.remove_css_class ("active");
            } else {
                left_icon_img.opacity = 1;
                right_icon_img.opacity = 0;
                left_icon_img.add_css_class ("active");
            }
        });

        var switch_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
            homogeneous = true,
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER,
            can_focus = false,
            can_target = false
        };
        switch_box.append (left_icon_img);
        switch_box.append (right_icon_img);

        var switch_overlay = new Gtk.Overlay () {
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER
        };
        switch_overlay.add_overlay (switch_box);
        switch_overlay.set_child (iswitch);

        main_box.append (switch_overlay);
        main_box.valign = Gtk.Align.CENTER;
        main_box.hexpand = true;
        main_box.add_css_class ("switch");
        main_box.set_parent (this);
    }
}
