/*
 * Copyright (c) 2022-2024 Fyra Labs
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
 * An ApplicationWindow is a Window for holding the main content of an application.
 */
public class He.ApplicationWindow : Gtk.ApplicationWindow {
    /**
     * Creates a new ApplicationWindow.
     * @param app The application associated with this window.
     *
     * @since 1.0
     */
    public ApplicationWindow (He.Application app) {
        Object (application: app);
    }

    private He.AppBar appbar = new He.AppBar ();

    /**
     * Whether this window should display a title.
     */
    private bool _has_title;
    public bool has_title {
        get {
            return _has_title;
        }
        set {
            _has_title = value;
            if (!value) {
                var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
                box.visible = false;
                this.set_titlebar (box);
            } else {
                appbar.add_css_class ("flat");
                this.set_titlebar (appbar);
            }
        }
    }

    /**
     * Whether this window should display a back button.
     */
    private bool _has_back_button;
    public bool has_back_button {
        get {
            return has_back_button;
        }
        set {
            _has_back_button = value;
            appbar.show_back = value;
        }
    }

    construct {
        has_title = false;
        has_back_button = false;
    }
}
