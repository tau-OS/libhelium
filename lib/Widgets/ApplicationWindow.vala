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

        var base_path = app.get_resource_base_path ();
        if (base_path == null) {
            return;
        }

        string base_uri = "resource://" + base_path;
        File base_file = File.new_for_uri (base_uri);

        if (base_file.get_child ("gtk/help-overlay.ui").query_exists (null)) {
            Gtk.Builder builder = new Gtk.Builder.from_file (base_path + "/gtk/help-overlay.ui");
            this.set_help_overlay (builder.get_object ("help_overlay") as Gtk.ShortcutsWindow);
        }
    }

    private new He.AppBar title = new He.AppBar ();

    private new bool _modal;
    public new bool modal {
        get {
            return modal;
        }
        set {
            _modal = value;
            set_modal (value);
        }
    }

    private bool _has_title;
    public bool has_title {
        get {
            return _has_title;
        }
        set {
            _has_title = value;
            if (!value) {
                var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
                this.set_titlebar (box);
            } else {
                title.add_css_class ("flat");
                this.set_titlebar (title);
            }
        }
    }

    private new bool _has_back_button;
    public new bool has_back_button {
        get {
            return has_back_button;
        }
        set {
            _has_back_button = value;
            title.show_back = value;
        }
    }

    construct {
        has_title = false;
        has_back_button = false;
    }
}
