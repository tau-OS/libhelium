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
 * A SwitchBar is a widget that is used to identify primarily a switchable
 * view below it.
 */
public class He.SwitchBar : He.Bin, Gtk.Buildable {
    private Gtk.Label title_label = new Gtk.Label (null);
    private Gtk.Label subtitle_label = new Gtk.Label (null);
    private Gtk.Box info_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
    private Gtk.ToggleButton main_button;
    private Gtk.Widget? _sensitive_widget;
    Binding? sensitive_binding;

    public signal void activated ();

    /**
     * Sets the title of the switchbar.
     */
    public string title {
        get {
            return title_label.get_text ();
        }
        set {
            if (value != null) {
                title_label.set_visible (true);
                title_label.set_text (value);
            } else {
                title_label.set_visible (false);
            }
        }
    }

    /**
     * Sets the subtitle of the switchbar.
     */
    public string subtitle {
        get {
            return subtitle_label.get_text ();
        }
        set {
            if (value != null) {
                subtitle_label.set_visible (true);
                subtitle_label.set_text (value);
            } else {
                subtitle_label.set_visible (false);
            }
        }
    }

    /**
     * The switch related to this switchbar.
     */
    public He.Switch main_switch = new He.Switch ();

    /**
     * Sets the sensitive widget of the switchbar, if any.
     */
    public Gtk.Widget? sensitive_widget {
        get {
            return _sensitive_widget;
        }
        set {
            if (_sensitive_widget == value)
                return;

            sensitive_binding?.unbind ();

            if (value != null) {
                _sensitive_widget = value;
                sensitive_binding = main_switch.iswitch.bind_property ("active", _sensitive_widget, "sensitive", SYNC_CREATE);
            }
        }
    }

    /**
     * Constructs a new switchbar.
     *
     * @since 1.0
     */
    public SwitchBar () {
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BoxLayout));
    }

    construct {
        title_label.xalign = 0;
        title_label.add_css_class ("cb-title");
        title_label.set_visible (false);

        subtitle_label.xalign = 0;
        subtitle_label.add_css_class ("cb-subtitle");
        subtitle_label.wrap = true;
        subtitle_label.ellipsize = Pango.EllipsizeMode.END;
        subtitle_label.set_visible (false);

        info_box.append (title_label);
        info_box.append (subtitle_label);
        info_box.valign = Gtk.Align.CENTER;
        info_box.hexpand = true;

        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 16);
        box.append (info_box);
        box.append (main_switch);

        main_button = new Gtk.ToggleButton ();
        main_button.hexpand = true;
        main_button.add_css_class ("switchbar");
        main_button.set_parent (this);
        main_button.toggled.connect (on_activate);

        activated.connect (() => {
            main_button.active = true;
        });

        box.set_parent (main_button);
    }

    private void on_activate () {
        if (main_switch != null)
            main_switch.iswitch.set_active (main_button.active);
    }
}