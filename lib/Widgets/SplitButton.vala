/*
 * Copyright (c) 2025 Fyra Labs
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

namespace He {
/**
 * Size variants for the split button widget
 */
    public enum SplitButtonSize {
        SMALL,
        MEDIUM,
        LARGE,
        EXTRA_LARGE;

        public string to_css_class() {
            switch (this) {
            case SMALL: return "split-button-small";
            case MEDIUM: return "split-button-medium";
            case LARGE: return "split-button-large";
            case EXTRA_LARGE: return "split-button-xlarge";
            default: return "split-button-medium";
            }
        }
    }

/**
 * Specification for menu items with icon and action support
 */
    public class MenuItemSpec : Object {
        public string label { get; set; }
        public string? icon_name { get; set; }
        public string? action_name { get; set; }
        public Variant? action_target { get; set; }

        public MenuItemSpec(string label, string? icon_name = null, string? action_name = null, Variant? action_target = null) {
            this.label = label;
            this.icon_name = icon_name;
            this.action_name = action_name;
            this.action_target = action_target;
        }
    }

/**
 * A modern split button widget with separated main and menu buttons
 */
    public delegate void SimpleCallback();

    public class SplitButton : Gtk.Box {
        private Gtk.Button _main_button;
        private He.MenuButton _menu_button;
        private SplitButtonSize _size = SplitButtonSize.MEDIUM;
        private string _current_size_class = "";

        // Simple callback management
        private GLib.SimpleActionGroup? _callback_actions;
        private uint _callback_counter = 0;

        // ButtonContent for main button label support
        private He.ButtonContent? _button_content;

        /**
         * The size variant of the split button
         */
        public SplitButtonSize size {
            get { return _size; }
            set {
                if (_size != value) {
                    _size = value;
                    update_size_styling();
                    notify_property("size");
                }
            }
        }

        /**
         * Direct access to the main action button
         */
        public Gtk.Button main_button {
            get { return _main_button; }
        }

        /**
         * Direct access to the dropdown menu button
         */
        public He.MenuButton menu_button {
            get { return _menu_button; }
        }

        /**
         * The menu model for the dropdown
         */
        public GLib.MenuModel? menu_model {
            get { return _menu_button.menu_model; }
            set { _menu_button.menu_model = value; }
        }

        /**
         * The button content for the main button (icon + label)
         */
        public He.ButtonContent? button_content {
            get { return _button_content; }
            set {
                if (_button_content != value) {
                    if (_button_content != null) {
                        _main_button.child = null;
                    }
                    _button_content = value;
                    if (_button_content != null) {
                        _main_button.child = _button_content;
                        _main_button.icon_name = null;
                    } else {
                        _main_button.child = null;
                    }
                    notify_property("button-content");
                }
            }
        }

        /**
         * Icon displayed on the main button
         */
        public string? icon_name {
            owned get {
                if (_button_content != null) {
                    return _button_content.icon;
                }
                return _main_button.icon_name;
            }
            set {
                if (_button_content != null) {
                    _button_content.icon = value ?? "";
                } else {
                    _main_button.icon_name = value;
                }
            }
        }

        /**
         * Label displayed on the main button (requires button_content to be set)
         */
        public string? label {
            owned get {
                if (_button_content != null) {
                    return _button_content.label;
                }
                return null;
            }
            set {
                if (value != null) {
                    if (_button_content == null) {
                        _button_content = new He.ButtonContent();
                        // Preserve existing icon if any
                        if (_main_button.icon_name != null) {
                            _button_content.icon = _main_button.icon_name;
                        }
                        _main_button.child = _button_content;
                        _main_button.icon_name = null;
                    }
                    _button_content.label = value;
                } else if (_button_content != null) {
                    _button_content.label = "";
                }
            }
        }

        /**
         * Tooltip text for the main button
         */
        public new string? tooltip_text {
            get { return _main_button.tooltip_text; }
            set { _main_button.tooltip_text = value; }
        }

        /**
         * Tooltip text for the menu button
         */
        public string? menu_tooltip_text {
            get { return _menu_button.tooltip_text; }
            set { _menu_button.tooltip_text = value; }
        }

        /**
         * Whether both buttons are sensitive
         */
        public new bool sensitive {
            get { return base.sensitive; }
            set {
                if (base.sensitive != value) {
                    base.sensitive = value;
                    _main_button.sensitive = value;
                    _menu_button.sensitive = value;
                }
            }
        }

        /**
         * Emitted when the main button is clicked
         */
        public signal void clicked();

        /**
         * Creates a new split button
         */
        public SplitButton() {
            Object(
                   orientation : Gtk.Orientation.HORIZONTAL,
                   spacing : 4
            );

            setup_widgets();
            setup_styling();
            connect_signals();
        }

        /**
         * Creates a split button with initial configuration
         */
        public SplitButton.with_config(string? icon_name = null,
                                       string? tooltip_text = null,
                                       string? menu_tooltip_text = null,
                                       SplitButtonSize size = SplitButtonSize.MEDIUM) {
            this();

            if (icon_name != null) {
                this.icon_name = icon_name;
            }

            if (tooltip_text != null) {
                this.tooltip_text = tooltip_text;
            }

            if (menu_tooltip_text != null) {
                this.menu_tooltip_text = menu_tooltip_text;
            } else {
                this.menu_tooltip_text = _("Show more options");
            }

            this.size = size;
        }

        /**
         * Initialize the child widgets
         */
        private void setup_widgets() {
            _main_button = new Gtk.Button() {
                has_frame = false,
                hexpand = false
            };

            _menu_button = new He.MenuButton();
            _menu_button.icon_name = "pan-down-symbolic";

            append(_main_button);
            append(_menu_button);
        }

        /**
         * Setup CSS styling
         */
        private void setup_styling() {
            add_css_class("split-button");
            _main_button.add_css_class("split-button-main");
            _menu_button.add_css_class("split-button-menu");
            update_size_styling();
        }

        /**
         * Connect internal signals
         */
        private void connect_signals() {
            _main_button.clicked.connect(() => clicked());
        }

        /**
         * Update CSS classes for the current size
         */
        private void update_size_styling() {
            if (_current_size_class.length > 0) {
                remove_css_class(_current_size_class);
            }

            _current_size_class = _size.to_css_class();
            add_css_class(_current_size_class);
        }

        /**
         * Set menu from an array of specifications
         */
        public void set_menu_from_specs(MenuItemSpec[] specs) {
            var menu = new Menu();

            foreach (var spec in specs) {
                var menu_item = create_menu_item_from_spec(spec);
                menu.append_item(menu_item);
            }

            menu_model = menu;
        }

        /**
         * Add a simple menu item with a callback function
         */
        public void add_menu_item(string label, owned SimpleCallback callback, string? icon_name = null) {
            if (_callback_actions == null) {
                _callback_actions = new SimpleActionGroup();
                insert_action_group("cb", _callback_actions);
            }

            GLib.Menu menu;
            if (menu_model == null) {
                menu = new Menu();
                menu_model = menu;
            } else {
                menu = menu_model as GLib.Menu;
                if (menu == null) {
                    warning("Cannot add item to non-Menu model");
                    return;
                }
            }

            var action_name = @"cb_$(++_callback_counter)";
            var action = new SimpleAction(action_name, null);

            // Accept the signal parameter and invoke our no-arg callback
            action.activate.connect((parameter) => {
                callback();
            });

            _callback_actions.add_action(action);

            var menu_item = new MenuItem(label, @"cb.$(action_name)");
            if (icon_name != null) {
                menu_item.set_icon(new ThemedIcon(icon_name));
            }

            menu.append_item(menu_item);

            // Trigger He.MenuButton to rebuild from the updated model
            _menu_button.menu_model = menu;
        }

        private void clear_menu_callbacks() {
            if (_callback_actions != null) {
                // Remove the action group from this widget
                insert_action_group("cb", null);
                _callback_actions = null;
                _callback_counter = 0;
            }
        }

        /**
         * Add a menu item using MenuItemSpec (for action-based items)
         */
        public void add_menu_item_spec(MenuItemSpec spec) {
            GLib.Menu menu;

            if (menu_model == null) {
                menu = new Menu();
                menu_model = menu;
            } else {
                menu = menu_model as GLib.Menu;
                if (menu == null) {
                    warning("Cannot add item to non-Menu model");
                    return;
                }
            }

            var menu_item = create_menu_item_from_spec(spec);
            menu.append_item(menu_item);

            // Trigger He.MenuButton to rebuild from the updated model
            _menu_button.menu_model = menu;
        }

        /**
         * Convenience method to create menu from simple string arrays
         */
        public void set_simple_menu(string[] labels, string[]? actions = null) {
            var specs = new MenuItemSpec[labels.length];

            for (int i = 0; i < labels.length; i++) {
                string? action = (actions != null && i < actions.length) ? actions[i] : null;
                specs[i] = new MenuItemSpec(labels[i], null, action);
            }

            set_menu_from_specs(specs);
        }

        /**
         * Add a menu separator
         */
        public void add_menu_separator() {
            GLib.Menu menu;

            if (menu_model == null) {
                menu = new Menu();
                menu_model = menu;
            } else {
                menu = menu_model as GLib.Menu;
                if (menu == null) {
                    warning("Cannot add separator to non-Menu model");
                    return;
                }
            }

            menu.append_section(null, new Menu());

            // Trigger He.MenuButton to rebuild from the updated model
            _menu_button.menu_model = menu;
        }

        /**
         * Clear all menu items
         */
        public void clear_menu() {
            menu_model = null;
        }

        /**
         * Create a menu item from specification
         */
        private GLib.MenuItem create_menu_item_from_spec(MenuItemSpec spec) {
            var menu_item = new MenuItem(spec.label, spec.action_name);

            if (spec.icon_name != null) {
                var icon = new ThemedIcon(spec.icon_name);
                menu_item.set_icon(icon);
            }

            if (spec.action_target != null && spec.action_name != null) {
                menu_item.set_action_and_target_value(spec.action_name, spec.action_target);
            }

            return menu_item;
        }

        /**
         * Convenience method to configure the split button
         */
        public SplitButton configure(string? icon_name = null,
                                     string? tooltip_text = null,
                                     string? menu_tooltip_text = null,
                                     SplitButtonSize? size = null) {
            if (icon_name != null) {
                this.icon_name = icon_name;
            }

            if (tooltip_text != null) {
                this.tooltip_text = tooltip_text;
            }

            if (menu_tooltip_text != null) {
                this.menu_tooltip_text = menu_tooltip_text;
            }

            if (size != null) {
                this.size = size;
            }

            return this;
        }

        /**
         * Apply suggested action styling to both buttons
         */
        public void set_suggested_action(bool suggested = true) {
            if (suggested) {
                _main_button.add_css_class("suggested-action");
                _menu_button.add_css_class("suggested-action");
            } else {
                _main_button.remove_css_class("suggested-action");
                _menu_button.remove_css_class("suggested-action");
            }
        }

        /**
         * Apply destructive action styling to both buttons
         */
        public void set_destructive_action(bool destructive = true) {
            if (destructive) {
                _main_button.add_css_class("destructive-action");
                _menu_button.add_css_class("destructive-action");
            } else {
                _main_button.remove_css_class("destructive-action");
                _menu_button.remove_css_class("destructive-action");
            }
        }

        /**
         * Clean up resources when the widget is destroyed
         */
        public override void dispose() {
            clear_menu_callbacks();
            base.dispose();
        }
    }
}
