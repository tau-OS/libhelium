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
 * A ViewMono is a component containing its own AppBar, title, subtitle, and elements.
 */
public class He.ViewMono : He.Bin, Gtk.Buildable {
    private He.AppBar titlebar = new He.AppBar ();
    private Gtk.Box box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

    /**
     * The title of the view.
     */
    public Gtk.Widget? title {
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
     * The title widget of the view.
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
     * The subtitle of the view.
     */
    public string subtitle {
        get {
            return titlebar.viewsubtitle_label;
        }
        set {
            if (value != "") {
                titlebar.viewsubtitle_label = value;
            } else {
                titlebar.viewsubtitle_label = null;
            }
        }
    }

    private bool _show_right_title_buttons;
    /**
     * Whether the ViewMono should show the buttons.
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
     * Whether the ViewMono should show the buttons.
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
     * The stack that the ViewMono's AppBar is attached to.
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
     * The stack that the ViewMono's AppBar is attached to.
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
     * Create a new ViewMono.
     * @param title The title of the ViewMono.
     * @param subtitle The subtitle of the ViewMono.
     */
    public ViewMono (Gtk.Widget? title, string? subtitle) {
        base ();
        this.title = title;
        this.subtitle = subtitle;
    }

    /**
     * Add a child to the view, should only be used in the context of a UI or Blueprint file. There should be no need to use this method in code.
     *
     * @since 1.0
     */
    public new void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
        if (type == "titlebar-button") {
            titlebar.append ((Gtk.Widget) child);
        } else if (type == "titlebar-menu") {
            titlebar.append_menu ((Gtk.Widget) child);
        } else if (type == "titlebar-toggle") {
            titlebar.append_toggle ((Gtk.Widget) child);
        } else {
            box.append ((Gtk.Widget) child);
        }
    }

    /**
     * Add a titlebar button to the view's appbar.
     *
     * @since 1.0
     */
    public new void add_titlebar_button (Gtk.Button child) {
        titlebar.append (child);
    }

    /**
     * Add a titlebar menu to the view's appbar.
     *
     * @since 1.0
     */
    public new void add_titlebar_menu (Gtk.MenuButton child) {
        titlebar.append_menu (child);
    }

    /**
     * Add a titlebar toggle to the view's appbar.
     *
     * @since 1.0
     */
    public new void add_titlebar_toggle (Gtk.ToggleButton child) {
        titlebar.append_toggle (child);
    }

    /**
     * Add a child to the view.
     *
     * @since 1.0
     */
    public new void append (Gtk.Widget child) {
        box.append (child);
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BoxLayout));
    }

    construct {
        this.hexpand = false;
        this.hexpand_set = true;
        has_margins = true;

        box.orientation = Gtk.Orientation.VERTICAL;

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.hexpand = true;
        main_box.append (titlebar);
        main_box.append (box);

        main_box.set_parent (this);

        this.add_css_class ("main-view");
    }
}