/*
* Copyright (c) 2022-2023 Fyra Labs
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
 * A modal window that accepts SettingsLists or SettingsPages
 */
 public class He.SettingsWindow : He.Window, Gtk.Buildable {
    private Gtk.Box box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
    private Gtk.Stack stack = new Gtk.Stack ();
    private He.ViewSwitcher switcher = new He.ViewSwitcher ();
    private He.ViewTitle viewtitle = new He.ViewTitle ();
    private Gtk.Button close_button = new Gtk.Button ();

    /**
     * Add SettingsList or SettingsPage children to this window
     */
    public void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
        if (type == "list") {
            add_list (child as He.SettingsList);
        } else if (type == "page") {
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

        close_button.set_icon_name ("window-close-symbolic");
        close_button.halign = Gtk.Align.START;
        close_button.valign = Gtk.Align.START;
        close_button.margin_top = 24;
        close_button.margin_start = 24;
        close_button.margin_bottom = 24;
        close_button.add_css_class ("circular");
        close_button.set_tooltip_text (_("Close"));
        close_button.clicked.connect (close);

        switcher.stack = stack;
        switcher.set_margin_start (24);
        switcher.set_margin_end (24);
        stack.set_margin_start (24);
        stack.set_margin_end (24);

        var title_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
        title_box.append (close_button);
        title_box.append (switcher);

        box.append (title_box);
        box.append (stack);

        this.set_child (box);

        this.set_size_request (360, 400);
        this.set_default_size (360, 400);
        this.has_title = false;
        this.set_focusable (true);

        this.set_modal (true);
        this.resizable = false;
        this.add_css_class ("dialog-content");

        on_pages_changed (0, 0, this.stack.pages.get_n_items ());
    }

    private void on_pages_changed (uint position, uint removed, uint added) {
        if (this.stack.pages.get_n_items () <= 1) {
            if (this.switcher.get_parent () != null && this.switcher.get_parent () == this.box) {
                this.box.remove (switcher);
                this.box.insert_child_after (viewtitle, close_button);
            } else if (this.viewtitle.get_parent () == null) {
                this.box.insert_child_after (viewtitle, close_button);
            } else {
                // Everything has been added
                return;
            }
        } else {
            if (this.viewtitle.get_parent () != null && this.viewtitle.get_parent () == this.box) {
                this.box.remove (viewtitle);
                this.box.insert_child_after (switcher, close_button);
            } else if (this.switcher.get_parent () == null) {
                this.box.insert_child_after (switcher, close_button);
            } else {
                // Everything has been added
                return;
            }
        }
    }
}
