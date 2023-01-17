/*
* Copyright (c) 2022-2023 Fyra Labs
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
 * A modal window that accepts SettingsLists or SettingsPages
 */
 public class He.SettingsWindow : He.Window, Gtk.Buildable {
    private Gtk.Box box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
    private Gtk.Stack stack = new Gtk.Stack ();
    private He.AppBar appbar = new He.AppBar ();
    private He.ViewSwitcher switcher = new He.ViewSwitcher ();
    private Gtk.Label viewtitle = new Gtk.Label (null);

    /**
     * Add SettingsList or SettingsPage children to this window
     */
    public void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
        if (child.get_type () == typeof (He.SettingsList)) {
            add_list (child as He.SettingsList);
        } else if (child.get_type () == typeof (He.SettingsPage)) {
            add_page (child as He.SettingsPage);
        } else {
            warning (@"Child of type $(child.get_type ().to_string ()) is not supported.");
            ((He.Window) this).add_child (builder, child, type);
        }
    }

    /**
     * Add a Settings Page to this window
     */
    public void add_page (He.SettingsPage page) {
        if (page.title == null) {
            page.title = @"Page $(stack.pages.get_n_items () + 1)";
        }
        stack.add_titled (page as Gtk.Widget, page.title, page.title);
    }

    /**
     * Add a Settings List to this window
     */
    public void add_list (He.SettingsList list) {
        if (list.title == null || list.title == "") {
            list.title = @"Page $(stack.pages.get_n_items () + 1)";
        }
        var page = new He.SettingsPage (list.title);
        page.add_list (list);
        add_page (page);
    }

    /**
     * Create a new Settings Window.
     *
     * @since 1.0
     */
    public SettingsWindow (Gtk.Window? parent) {
        this.parent = parent;
    }

    construct {
        this.stack.pages.items_changed.connect (on_pages_changed);

        viewtitle.label = "Settings";
        viewtitle.add_css_class ("view-title");
        viewtitle.xalign = 0;
        viewtitle.valign = Gtk.Align.CENTER;
        viewtitle.margin_top = 6;
        viewtitle.margin_start = 18;
        viewtitle.margin_end = 12;
        viewtitle.margin_bottom = 6;

        appbar.show_buttons = true;
        appbar.flat = true;
        appbar.show_back = false;
        appbar.hexpand = true;

        switcher.stack = stack;
        switcher.set_margin_start (18);
        switcher.set_margin_end (18);
        stack.set_margin_start (18);
        stack.set_margin_end (18);

        box.append (appbar);
        box.append (switcher);
        box.append (stack);

        this.set_child (box);

        this.set_size_request (360, 400);
        this.set_default_size (360, 400);
        this.has_title = false;
        this.set_focusable (true);

        this.set_modal (true);

        on_pages_changed (0, 0, this.stack.pages.get_n_items ());
    }

    ~SettingsWindow () {
        this.unparent ();
    }

    private void on_pages_changed (uint position, uint removed, uint added) {
        if (this.stack.pages.get_n_items () <= 1) {
            if (this.switcher.get_parent () != null && this.switcher.get_parent () == this.box) {
                this.box.remove (switcher);
                this.box.insert_child_after (viewtitle, appbar);
            } else if (this.viewtitle.get_parent () == null) {
                this.box.insert_child_after (viewtitle, appbar);
            } else {
                // Everything has been added
                return;
            }
        } else {
            if (this.viewtitle.get_parent () != null && this.viewtitle.get_parent () == this.box) {
                this.box.remove (viewtitle);
                this.box.insert_child_after (switcher, appbar);
            } else if (this.switcher.get_parent () == null) {
                this.box.insert_child_after (switcher, appbar);
            } else {
                // Everything has been added
                return;
            }
        }
    }
}