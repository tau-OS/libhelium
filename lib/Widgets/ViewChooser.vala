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
 * A ViewChooser is a chooser switcher that filters a stack's view.
 */
public class He.ViewChooser : He.Bin {
    private Gtk.SelectionModel _stack_pages;
    private List<Gtk.ToggleButton> _buttons;
    private Gtk.Box menu_box;
    private Gtk.Label menu_label;

    private Gtk.Stack _stack;
    /**
     * The stack that is controlled by this chooser switcher.
     *
     * @since 1.0
     */
    public Gtk.Stack stack {
        get { return this._stack; }
        set {
            if (this._stack == value)return;

            if (this._stack_pages != null) {
                this._stack_pages.selection_changed.disconnect (on_selected_stack_page_changed);
                this._stack_pages.items_changed.disconnect (on_stack_pages_changed);
            }

            this._stack = value;
            this._stack_pages = value.pages;

            this._stack_pages.selection_changed.connect (on_selected_stack_page_changed);
            this._stack_pages.items_changed.connect (on_stack_pages_changed);

            on_stack_pages_changed (0, 0, this._stack_pages.get_n_items ());
        }
    }

    /**
     * Creates a new ViewChooser.
     */
    public ViewChooser () {
        base ();
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BoxLayout));
    }

    construct {
        this.valign = Gtk.Align.CENTER;

        menu_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);

        menu_label = new Gtk.Label ("");
        menu_label.add_css_class ("view-title");

        var menu_img = new Gtk.Image ();
        menu_img.icon_name = "pan-down-symbolic";

        var menu_child_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        menu_child_box.append (menu_label);
        menu_child_box.append (menu_img);

        var menu_popover = new Gtk.Popover ();
        menu_popover.child = menu_box;
        menu_popover.has_arrow = false;

        var menu = new Gtk.MenuButton ();
        menu.add_css_class ("flat");
        menu.add_css_class ("view-chooser");
        menu.popover = menu_popover;
        menu.child = menu_child_box;

        menu_box.width_request = menu_child_box.get_width ();
        menu_child_box.notify["width"].connect (() => {
            menu_box.width_request = menu_child_box.get_width ();
        });

        menu.set_parent (this);
    }

    private void on_stack_pages_changed (uint position, uint removed, uint added) {
        while (removed-- > 0 && this._buttons.nth (position) != null) {
            unowned var button_link = this._buttons.nth (position);

            button_link.data.unparent ();

            unowned var link = button_link;
            button_link = button_link.next;

            this._buttons.delete_link (link);
        }

        while (added-- > 0) {
            unowned var button_link = this._buttons.nth (position);

            var button = new Gtk.ToggleButton () {
                active = this._stack_pages.is_selected (position)
            };
            button.add_css_class ("flat");

            var button_label = new Gtk.Label ("");

            var button_img = new Gtk.Image () {
                hexpand = true,
                halign = Gtk.Align.END,
                icon_name = "emblem-ok-symbolic"
            };

            var button_child_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6) {
                height_request = 42
            };
            button_child_box.append (button_label);
            button_child_box.append (button_img);

            button.child = button_child_box;

            this._stack_pages.get_item (position).bind_property ("title", button_label, "label", SYNC_CREATE);

            button.bind_property ("active", button_img, "visible", SYNC_CREATE);

            button.toggled.connect (() => on_button_toggled (button));
            button.set_parent (menu_box);

            if (!this._buttons.is_empty ()) {
                button.set_group ((Gtk.ToggleButton) this._buttons.nth_data (0));
            }

            this._buttons.insert_before (button_link, button);

            position++;
        }

        this._stack_pages.get_item (position).bind_property ("title", menu_label, "label", SYNC_CREATE);
    }

    private void on_selected_stack_page_changed (uint position, uint n_items) {
        unowned var button_link = this._buttons.nth (position);

        while (n_items-- > 0 && button_link != null) {
            button_link.data.active = this._stack_pages.is_selected (position++);
            this._stack_pages.get_item (position).bind_property ("title", menu_label, "label", SYNC_CREATE);
            button_link = button_link.next;
        }
    }

    private void on_button_toggled (Gtk.ToggleButton button) {
        // Don't do anything if this stack has 1 or less items
        if (this._stack_pages.get_n_items () <= 1) {
            return;
        }

        unowned int position = this._buttons.index (button);
        if (button.active) {
            this._stack_pages.select_item (position, true);
            this._stack_pages.get_item (position).bind_property ("title", menu_label, "label", SYNC_CREATE);
            return;
        }

        this._stack_pages.unselect_item (position);
    }

    public void stack_clear () {
        if (this._stack_pages.get_n_items () >= 1) {
            for (int i = 0; i <= this._stack_pages.get_n_items (); i++) {
                this._stack_pages.get_item (i).dispose ();
            }
        }

        if (!this._buttons.is_empty ()) {
            for (int i = 0; i <= this._buttons.length (); i++) {
                this._buttons.remove (this._buttons.nth_data (i));
            }
        }
    }
}