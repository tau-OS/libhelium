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

public enum He.GroupButtonSize {
    SMALL,
    MEDIUM,
    LARGE,
    XLARGE
}

public enum He.GroupButtonColor {
    PRIMARY,
    SECONDARY,
    TERTIARY,
    SURFACE
}

public class He.GroupedButton : Gtk.Widget {
    private Gtk.Box button_box;
    private GroupButtonSize _size;
    private GroupButtonColor _color;
    private Gee.ArrayList<Gtk.Widget> buttons;

    // Signals
    public signal void active_changed(int index, Gtk.Widget widget);

    public GroupButtonSize size {
        get { return _size; }
        set {
            if (_size != value) {
                _size = value;
                update_styling();
                notify_property("size");
                notify_property("size-name");
            }
        }
    }

    public GroupButtonColor color {
        get { return _color; }
        set {
            if (_color != value) {
                _color = value;
                update_styling();
                notify_property("color");
                notify_property("color-name");
            }
        }
    }

    public string size_name {
        get {
            switch (_size) {
            case GroupButtonSize.SMALL: return "small";
            case GroupButtonSize.MEDIUM: return "medium";
            case GroupButtonSize.LARGE: return "large";
            case GroupButtonSize.XLARGE: return "xlarge";
            default: return "medium";
            }
        }
        set {
            switch (value.down()) {
            case "small":
                size = GroupButtonSize.SMALL;
                break;
            case "medium":
            case "default":
                size = GroupButtonSize.MEDIUM;
                break;
            case "large":
                size = GroupButtonSize.LARGE;
                break;
            case "xlarge":
            case "extra-large":
                size = GroupButtonSize.XLARGE;
                break;
            default:
                warning("Unknown size: %s, using medium", value);
                size = GroupButtonSize.MEDIUM;
                break;
            }
        }
    }

    public string color_name {
        get {
            switch (_color) {
            case GroupButtonColor.PRIMARY: return "primary";
            case GroupButtonColor.SECONDARY: return "secondary";
            case GroupButtonColor.TERTIARY: return "tertiary";
            case GroupButtonColor.SURFACE: return "surface";
            default: return "primary";
            }
        }
        set {
            switch (value.down()) {
            case "primary":
                color = GroupButtonColor.PRIMARY;
                break;
            case "secondary":
                color = GroupButtonColor.SECONDARY;
                break;
            case "tertiary":
                color = GroupButtonColor.TERTIARY;
                break;
            case "surface":
                color = GroupButtonColor.SURFACE;
                break;
            default:
                warning("Unknown color: %s, using primary", value);
                color = GroupButtonColor.PRIMARY;
                break;
            }
        }
    }

    public int button_count {
        get { return buttons.size; }
    }

    construct {
        _size = GroupButtonSize.MEDIUM;
        _color = GroupButtonColor.PRIMARY;
        buttons = new Gee.ArrayList<Gtk.Widget> ();

        button_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
        button_box.set_parent(this);

        // Set margins
        this.margin_start = 18;
        this.margin_end = 18;
        this.margin_top = 6;
        this.margin_bottom = 6;

        add_css_class("grouped-button");
        update_styling();
    }

    public GroupedButton() {
    }

    public GroupedButton.with_size_and_color(GroupButtonSize size, GroupButtonColor color) {
        this.size = size;
        this.color = color;
    }

    public void add_widget(Gtk.Widget widget) {
        buttons.add(widget);
        button_box.append(widget);
        update_widget_styling(widget);
        update_layout();
    }

    public void remove_widget(Gtk.Widget widget) {
        if (buttons.remove(widget)) {
            button_box.remove(widget);
            update_layout();
        }
    }

    // Helper methods
    public Gtk.Widget? get_widget_at_index(int index) {
        if (index >= 0 && index < buttons.size) {
            return buttons[index];
        }
        return null;
    }

    public void set_active_widget(Gtk.Widget widget) {
        foreach (var w in buttons) {
            w.remove_css_class("active");
            w.add_css_class("inactive");
        }

        if (widget in buttons) {
            widget.remove_css_class("inactive");
            widget.add_css_class("active");

            int index = buttons.index_of(widget);
            active_changed(index, widget);
        }
    }

    public void set_active_index(int index) {
        var widget = get_widget_at_index(index);
        if (widget != null) {
            set_active_widget(widget);
        }
    }

    public int get_active_index() {
        for (int i = 0; i < buttons.size; i++) {
            if (buttons[i].has_css_class("active")) {
                return i;
            }
        }
        return -1;
    }

    private void update_styling() {
        // Remove old size classes
        remove_css_class("small");
        remove_css_class("medium");
        remove_css_class("large");
        remove_css_class("xlarge");

        // Remove old color classes
        remove_css_class("primary");
        remove_css_class("secondary");
        remove_css_class("tertiary");
        remove_css_class("surface");

        // Add new size class
        switch (_size) {
        case GroupButtonSize.SMALL :
            add_css_class("small");
            break;
        case GroupButtonSize.MEDIUM:
            add_css_class("medium");
            break;
        case GroupButtonSize.LARGE:
            add_css_class("large");
            break;
        case GroupButtonSize.XLARGE:
            add_css_class("xlarge");
            break;
        }

        // Add new color class
        switch (_color) {
        case GroupButtonColor.PRIMARY:
            add_css_class("primary");
            break;
        case GroupButtonColor.SECONDARY:
            add_css_class("secondary");
            break;
        case GroupButtonColor.TERTIARY:
            add_css_class("tertiary");
            break;
        case GroupButtonColor.SURFACE:
            add_css_class("surface");
            break;
        }

        update_layout();
        foreach (var widget in buttons) {
            update_widget_styling(widget);
        }
    }

    private void update_widget_styling(Gtk.Widget widget) {
        // Remove old classes
        widget.remove_css_class("active");
        widget.remove_css_class("inactive");
        widget.remove_css_class("open");

        // Add state class (assuming first widget is active for demo)
        if (buttons.size > 0 && buttons[0] == widget) {
            widget.add_css_class("active");
        } else {
            widget.add_css_class("inactive");
        }

        // For MenuButton widgets, monitor popover state for active styling
        if (widget is Gtk.MenuButton) {
            var menu_button = widget as Gtk.MenuButton;
            if (menu_button.popover != null) {
                menu_button.popover.notify["visible"].connect(() => {
                    if (menu_button.popover.visible) {
                        widget.add_css_class("open");
                    } else {
                        widget.remove_css_class("open");
                    }
                });
            }
        }
    }

    private void update_layout() {
        int spacing = 0;
        switch (_size) {
        case GroupButtonSize.SMALL:
            spacing = 18;
            break;
        case GroupButtonSize.MEDIUM:
            spacing = 8;
            break;
        case GroupButtonSize.LARGE:
            spacing = 6;
            break;
        case GroupButtonSize.XLARGE:
            spacing = 4;
            break;
        }
        button_box.spacing = spacing;
    }
}
