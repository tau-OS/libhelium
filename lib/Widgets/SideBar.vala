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
* A SideBar is a complementary component containing its own AppBar, title, subtitle, and elements.
*/
public class He.SideBar : He.Bin, Gtk.Buildable {
    private He.AppBar titlebar = new He.AppBar ();
    private Gtk.Box box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

    /**
     * The title of the sidebar.
     */
     public string title {
        get {
            return titlebar.viewtitle_label;
        }
        set {
            if (value != null && titlewidget == null) {
                titlebar.viewtitle_label = value;
            } else {
                titlebar.viewtitle_label = null;
            }
        }
    }

    /**
     * The title widget of the sidebar.
     */
     public Gtk.Widget? titlewidget {
        get {
            return titlebar.viewtitle_widget;
        }
        set {
            if (value != null) {
                titlebar.viewtitle_widget = value;
            } else {
                titlebar.viewtitle_widget = null;
            }
        }
    }

    /**
     * The title of the sidebar.
     */
     public string subtitle {
        get {
            return titlebar.viewsubtitle_label;
        }
        set {
            if (value != null) {
                titlebar.viewsubtitle_label = value;
            } else {
                titlebar.viewsubtitle_label = null;
            }
        }
    }

    private bool _show_right_title_buttons;
    /**
    * Whether the SideBar should show the buttons.
    */
    public bool show_right_title_buttons {
        get {
            return _show_right_title_buttons;
        }
        set {
            _show_right_title_buttons = value;

            titlebar.show_right_title_buttons = _show_right_title_buttons;
        }
    }
    
    private bool _show_left_title_buttons;
    /**
    * Whether the SideBar should show the buttons.
    */
    public bool show_left_title_buttons {
        get {
            return _show_left_title_buttons;
        }
        set {
            _show_left_title_buttons = value;

            titlebar.show_left_title_buttons = _show_left_title_buttons;
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

    private Gtk.ScrolledWindow _scroller;
    /**
    * The stack that the SideBar's AppBar is attached to.
    */
    public Gtk.ScrolledWindow scroller {
        get {
            return _scroller;
        }

        set {
            _scroller = value;
            titlebar.scroller = _scroller;
        }
    }

    /**
     * Whether the view child has margins or is full-bleed.
     */
     public bool has_margins {
        get {
            return box.margin_top > 0 ||
                   box.margin_bottom > 0 ||
                   box.margin_start > 0 ||
                   box.margin_end > 0;
        }
        set {
            box.margin_bottom = value ? 12 : 0;
            box.margin_end = value ? 18 : 0;
            box.margin_start = value ? 18 : 0;
        }
    }

    /**
    * Create a new SideBar.
    * @param title The title of the SideBar.
    * @param subtitle The subtitle of the SideBar.
    */
    public SideBar (string title, string subtitle) {
        base ();
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
            titlebar.btn_box.append ((Gtk.Widget) child);
            ((Gtk.Widget) child).add_css_class ("disclosure-button");
            ((Gtk.Widget) child).remove_css_class ("image-button");
            titlebar.btn_box.visible = true;
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
        has_margins = true;

        box.orientation = Gtk.Orientation.VERTICAL;

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.hexpand = true;
        main_box.append (titlebar);
        main_box.append (box);

        main_box.set_parent (this);

        this.add_css_class ("sidebar-view");
    }
}
