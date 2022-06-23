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
* A SideBar is a complementary component containing its own AppBar, title, subtitle, and elements.
*/
public class He.SideBar : He.Bin, Gtk.Buildable {
    private He.AppBar titlebar = new He.AppBar();
    private He.ViewTitle title_label = new He.ViewTitle();
    private He.ViewSubTitle subtitle_label = new He.ViewSubTitle();
    private Gtk.Box box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

    /**
    * The title of the SideBar.
    */
    public string title {
        get {
            return title_label.label;
        }
        set {
            title_label.label = value;
        }
    }

    /**
    * The subtitle of the SideBar.
    */
    public string subtitle {
        get {
            return subtitle_label.label;
        }
        set {
            subtitle_label.label = value;
        }
    }

    private bool _show_buttons;
    /**
    * Whether the SideBar should show the buttons.
    */
    public bool show_buttons {
        get {
            return _show_buttons;
        }
        set {
            _show_buttons = value;

            titlebar.show_buttons = _show_buttons;
        }
    }

    private bool _show_back;
    /**
    * Whether the back button should be shown.
    */
    public bool show_back {
        get {
            return _show_back;
        }
        set {
            _show_back = value;

            titlebar.show_back = _show_back;
        }
    }

    private Gtk.Stack _stack;
    /**
    * The stack that the SideBar's AppBar is attached to.
    */
    public Gtk.Stack stack {
        get {
            return _stack;
        }

        set {
            _stack = value;
            titlebar.stack = _stack;
        }
    }

    /**
    * Create a new SideBar.
    * @param title The title of the SideBar.
    * @param subtitle The subtitle of the SideBar.
    */
    public SideBar(string title, string subtitle) {
        this.title = title;
        this.subtitle = subtitle;
    }

    /**
    * Add a child to the sidebar, should only be used in the context of a UI or Blueprint file. There should be no need to use this method in code.
    *
 * @since 1.0
 */
    public new void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
        if (type == "titlebar-button") {
            titlebar.title.pack_end ((Gtk.Widget) child);
        } else {
            box.append ((Gtk.Widget) child);
        }
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BoxLayout));
    }

    construct {
        this.hexpand = false;
        this.hexpand_set = true;
        titlebar.flat = true;

        box.margin_start = box.margin_end = 18;
        box.orientation = Gtk.Orientation.VERTICAL;

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.hexpand = true;
        main_box.append (titlebar);
        main_box.append (title_label);
        main_box.append (subtitle_label);
        main_box.append (box);

        main_box.set_parent (this);
    }
}
