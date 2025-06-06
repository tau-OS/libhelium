/*
 * Copyright (c) 2022-2025 Fyra Labs
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
 * A NavigationRail is a vertical switcher that helps navigate a stack.
 */
public class He.NavigationRail : He.Bin {
    private Gtk.SelectionModel _stack_pages;
    private List<Gtk.ToggleButton> _buttons;
    private Gtk.Box main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
    private He.Button expand_button;
    private Gtk.Button? _custom_button;
    private Gtk.Widget? _custom_widget;

    private Gtk.Stack _stack;
    /**
     * The stack that is controlled by this switcher.
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
            if (value != null) {
                this._stack_pages = value.pages;
                this._stack_pages.selection_changed.connect (on_selected_stack_page_changed);
                this._stack_pages.items_changed.connect (on_stack_pages_changed);
                on_stack_pages_changed (0, 0, this._stack_pages.get_n_items ());
            }
        }
    }

    private Gtk.Orientation _orientation = Gtk.Orientation.VERTICAL;
    /**
     * The orientation of this switcher.
     *
     * @since 1.0
     */
    public Gtk.Orientation orientation {
        get { return this._orientation; }
        set {
            if (this._orientation == value)return;

            this._orientation = value;
            update_orientation_layout ();
        }
    }

    private bool _hide_labels = false;
    /**
     * Whether to hide the item labels or not. Useful if the icon for the item is descriptive enough.
     *
     * @since 1.0
     */
    public bool hide_labels {
        get { return this._hide_labels; }
        set {
            if (this._hide_labels == value)return;

            this._hide_labels = value;
            update_label_visibility ();
        }
    }

    private bool _is_expanded = true;
    /**
     * Whether the navigation rail is expanded or collapsed.
     *
     * @since 1.0
     */
    public bool is_expanded {
        get { return this._is_expanded; }
        set {
            if (this._is_expanded == value)return;

            this._is_expanded = value;
            update_expansion_state ();
        }
    }

    /**
     * Custom button to show between expand button and navigation buttons.
     *
     * @since 1.0
     */
    public Gtk.Button? custom_button {
        get { return this._custom_button; }
        set {
            if (this._custom_button == value)return;

            if (this._custom_button != null) {
                this._custom_button.unparent ();
            }

            this._custom_button = value;

            if (this._custom_button != null) {
                // Insert after expand_button, before navigation buttons
                main_box.insert_child_after (this._custom_button, expand_button);
            }
        }
    }

    /**
     * Custom widget to show after navigation buttons (vertical + expanded only).
     *
     * @since 1.0
     */
    public Gtk.Widget? custom_widget {
        get { return this._custom_widget; }
        set {
            if (this._custom_widget == value)return;

            if (this._custom_widget != null) {
                this._custom_widget.unparent ();
            }

            this._custom_widget = value;

            if (this._custom_widget != null) {
                main_box.append (this._custom_widget);
                update_custom_widget_visibility ();
            }
        }
    }

    /**
     * Creates a new NavigationRail.
     */
    public NavigationRail () {
        base ();
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BoxLayout));
    }

    construct {
        main_box.add_css_class ("navigation-rail");
        main_box.set_parent (this);
        main_box.hexpand = true;
        this._is_expanded = false;

        expand_button = new He.Button ("", "");
        expand_button.is_iconic = true;
        expand_button.halign = Gtk.Align.START;
        expand_button.valign = Gtk.Align.CENTER;
        expand_button.margin_bottom = 18;
        expand_button.tooltip_text = _("Expand/Collapse");
        expand_button.add_css_class ("navigation-rail-expand-button");
        expand_button.clicked.connect (() => {
            is_expanded = !is_expanded;
        });
        main_box.prepend (expand_button);

        this.add_css_class ("navigation-rail-container");
        update_orientation_layout ();
        update_expansion_state ();
    }

    private void update_orientation_layout () {
        main_box.orientation = this._orientation;
        ((Gtk.BoxLayout) this.get_layout_manager ()).orientation = this._orientation;

        if (this._orientation == Gtk.Orientation.VERTICAL) {
            main_box.valign = Gtk.Align.CENTER;
            main_box.halign = Gtk.Align.FILL;
            expand_button.visible = true;
            this.vexpand = true;
            this.hexpand = false;
        } else {
            main_box.valign = Gtk.Align.FILL;
            main_box.halign = Gtk.Align.CENTER;
            expand_button.visible = false;
            this.vexpand = false;
            this.hexpand = true;
        }
        update_custom_widget_visibility ();
    }

    private void update_expansion_state () {
        if (this._is_expanded) {
            main_box.add_css_class ("expanded");
            main_box.remove_css_class ("collapsed");
            expand_button.icon_name = "nav-expanded-symbolic";
            expand_button.margin_start = 42;
            expand_button.halign = Gtk.Align.START;
        } else {
            main_box.add_css_class ("collapsed");
            main_box.remove_css_class ("expanded");
            expand_button.icon_name = "nav-list-symbolic";
            expand_button.margin_start = 0;
            expand_button.halign = Gtk.Align.CENTER;
        }
        update_expanded_button ();
        update_custom_widget_visibility ();
    }

    private void update_custom_widget_visibility () {
        if (this._custom_widget != null) {
            // Only show in vertical + expanded mode
            this._custom_widget.visible = (this._orientation == Gtk.Orientation.VERTICAL && this._is_expanded);
        }
    }

    private void update_label_visibility () {
        unowned var button_link = this._buttons.first ();
        while (button_link != null) {
            var button = button_link.data;
            var button_child = button.get_child () as Gtk.Box;
            if (button_child != null) {
                var label = button_child.get_last_child () as Gtk.Label;
                var image = button_child.get_first_child () as Gtk.Image;
                if (label != null && image != null) {
                    label.visible = !this._hide_labels;
                    image.vexpand = this._hide_labels;
                }
            }
            button_link = button_link.next;
        }
    }

    private void update_expanded_button () {
        unowned var button_link = this._buttons.first ();
        while (button_link != null) {
            var button = button_link.data;
            var button_child = button.get_child () as Gtk.Box;
            if (button_child != null) {
                if (_is_expanded) {
                    button_child.orientation = Gtk.Orientation.HORIZONTAL;
                } else {
                    button_child.orientation = Gtk.Orientation.VERTICAL;
                }
            }
            button_link = button_link.next;
        }
    }

    private void update_page_icon (Gtk.StackPage page, bool is_active) {
        if (is_active) {
            if (page.icon_name.contains ("-symbolic")) {
                page.icon_name = page.icon_name.replace ("-filled", "").replace ("-symbolic", "-filled-symbolic");
            } else {
                page.icon_name = page.icon_name.replace ("-filled", "") + "-filled-symbolic";
            }
        } else {
            page.icon_name = page.icon_name.replace ("-filled", "");
        }
    }

    private void on_stack_pages_changed (uint position, uint removed, uint added) {
        // Remove buttons for removed pages
        while (removed-- > 0 && this._buttons.nth (position) != null) {
            unowned var button_link = this._buttons.nth (position);
            button_link.data.unparent ();
            unowned var link = button_link;
            button_link = button_link.next;
            this._buttons.delete_link (link);
        }

        // Add buttons for new pages
        while (added-- > 0) {
            unowned var button_link = this._buttons.nth (position);
            var page = (Gtk.StackPage) this._stack_pages.get_item (position);

            var button = new Gtk.ToggleButton () {
                active = this._stack_pages.is_selected (position),
                valign = Gtk.Align.CENTER
            };
            button.add_css_class ("navigation-rail-button");

            var button_child_image = new Gtk.Image ();
            button_child_image.valign = Gtk.Align.CENTER;
            page.bind_property ("icon_name", button_child_image, "icon_name", SYNC_CREATE);

            var button_child_label = new Gtk.Label ("");
            button_child_label.valign = Gtk.Align.CENTER;
            page.bind_property ("title", button_child_label, "label", SYNC_CREATE);

            button_child_label.visible = !this._hide_labels;
            button_child_image.vexpand = this._hide_labels;

            var button_child = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            button_child.append (button_child_image);
            button_child.append (button_child_label);

            button.toggled.connect (() => on_button_toggled (button));
            button.set_child (button_child);
            main_box.append (button);

            if (!this._buttons.is_empty ()) {
                button.set_group ((Gtk.ToggleButton) this._buttons.nth_data (0));
            }

            this._buttons.insert_before (button_link, button);

            // Update icon for active state
            update_page_icon (page, button.active);

            position++;
        }
    }

    private void on_selected_stack_page_changed (uint position, uint n_items) {
        unowned var button_link = this._buttons.nth (position);
        uint current_position = position;

        while (n_items-- > 0 && button_link != null) {
            bool is_selected = this._stack_pages.is_selected (current_position);
            button_link.data.active = is_selected;

            var page = (Gtk.StackPage) this._stack_pages.get_item (current_position);
            update_page_icon (page, is_selected);

            button_link = button_link.next;
            current_position++;
        }
    }

    private void on_button_toggled (Gtk.ToggleButton button) {
        if (this._stack_pages.get_n_items () <= 1) {
            return;
        }

        int position = this._buttons.index (button);
        if (position < 0)return;

        var page = (Gtk.StackPage) this._stack_pages.get_item (position);

        if (button.active) {
            this._stack_pages.select_item (position, true);
            update_page_icon (page, true);
        } else {
            update_page_icon (page, false);
        }
    }
}