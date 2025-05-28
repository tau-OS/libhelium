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

public enum He.GroupedButtonSize {
    SMALL,
    MEDIUM,
    LARGE,
    XLARGE
}

public enum He.GroupedButtonColor {
    PRIMARY,
    SECONDARY,
    TERTIARY,
    SURFACE
}

public class He.GroupedButton : Gtk.Widget {
    private Gtk.Box button_box;
    private GroupedButtonSize _size;
    private GroupedButtonColor _color;
    private Gee.ArrayList<Gtk.Widget> buttons;

    // Animation state
    private int pressed_button_index = -1;
    private double squeeze_progress = 0.0; // 0.0 to 1.0
    private uint animation_timeout_id = 0;

    // Signals
    public signal void active_changed(int index, Gtk.Widget widget);

    public GroupedButtonSize size {
        get { return _size; }
        set {
            if (_size != value) {
                _size = value;
                update_styling();
            }
        }
    }

    public GroupedButtonColor color {
        get { return _color; }
        set {
            if (_color != value) {
                _color = value;
                update_styling();
            }
        }
    }

    public string size_name {
        get {
            switch (_size) {
            case GroupedButtonSize.SMALL: return "small";
            case GroupedButtonSize.MEDIUM: return "medium";
            case GroupedButtonSize.LARGE: return "large";
            case GroupedButtonSize.XLARGE: return "xlarge";
            default: return "medium";
            }
        }
        set {
            switch (value.down()) {
            case "small":
                size = GroupedButtonSize.SMALL;
                break;
            case "medium":
            case "default":
                size = GroupedButtonSize.MEDIUM;
                break;
            case "large":
                size = GroupedButtonSize.LARGE;
                break;
            case "xlarge":
            case "extra-large":
                size = GroupedButtonSize.XLARGE;
                break;
            default:
                warning("Unknown size: %s, using medium", value);
                size = GroupedButtonSize.MEDIUM;
                break;
            }
        }
    }

    public string color_name {
        get {
            switch (_color) {
            case GroupedButtonColor.PRIMARY: return "primary";
            case GroupedButtonColor.SECONDARY: return "secondary";
            case GroupedButtonColor.TERTIARY: return "tertiary";
            case GroupedButtonColor.SURFACE: return "surface";
            default: return "primary";
            }
        }
        set {
            switch (value.down()) {
            case "primary":
                color = GroupedButtonColor.PRIMARY;
                break;
            case "secondary":
                color = GroupedButtonColor.SECONDARY;
                break;
            case "tertiary":
                color = GroupedButtonColor.TERTIARY;
                break;
            case "surface":
                color = GroupedButtonColor.SURFACE;
                break;
            default:
                warning("Unknown color: %s, using surface", value);
                color = GroupedButtonColor.SURFACE;
                break;
            }
        }
    }

    public int button_count {
        get { return buttons.size; }
    }

    public bool homogeneous {
        get { return button_box.homogeneous; }
        set {
            button_box.homogeneous = value;
        }
    }

    construct {
        _size = GroupedButtonSize.MEDIUM;
        _color = GroupedButtonColor.PRIMARY;
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

    public GroupedButton.with_size_and_color(GroupedButtonSize size, GroupedButtonColor color) {
        this.size = size;
        this.color = color;
    }

    public GroupedButton.with_names(string size_name, string color_name) {
        this.size_name = size_name;
        this.color_name = color_name;
    }

    public void add_widget(Gtk.Widget widget) {
        buttons.add(widget);
        button_box.append(widget);
        update_widget_styling(widget);
        setup_widget_gestures(widget, buttons.size - 1);
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

    private void setup_widget_gestures(Gtk.Widget widget, int index) {
        var gesture = new Gtk.GestureClick();

        gesture.pressed.connect(() => {
            start_squeeze_animation(index);
        });

        gesture.released.connect(() => {
            end_squeeze_animation();
        });

        widget.add_controller(gesture);
    }

    private void start_squeeze_animation(int index) {
        pressed_button_index = index;
        animate_squeeze(true);
    }

    private void end_squeeze_animation() {
        animate_squeeze(false);
    }

    private void animate_squeeze(bool expanding) {
        if (animation_timeout_id != 0) {
            Source.remove(animation_timeout_id);
        }

        animation_timeout_id = Timeout.add(16, () => { // ~60fps
            if (expanding) {
                squeeze_progress = Math.fmin(squeeze_progress + 0.15, 1.0);
            } else {
                squeeze_progress = Math.fmax(squeeze_progress - 0.15, 0.0);
            }

            queue_allocate(); // Request re-layout

            bool continue_animation = expanding ?
                squeeze_progress<1.0 : squeeze_progress>0.0;

            if (!continue_animation) {
                animation_timeout_id = 0;
                if (!expanding) {
                    pressed_button_index = -1;
                }
            }

            return continue_animation;
        });
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
        case GroupedButtonSize.SMALL :
            add_css_class("small");
            break;
        case GroupedButtonSize.MEDIUM:
            add_css_class("medium");
            break;
        case GroupedButtonSize.LARGE:
            add_css_class("large");
            break;
        case GroupedButtonSize.XLARGE:
            add_css_class("xlarge");
            break;
        }

        // Add new color class
        switch (_color) {
        case GroupedButtonColor.PRIMARY:
            add_css_class("primary");
            break;
        case GroupedButtonColor.SECONDARY:
            add_css_class("secondary");
            break;
        case GroupedButtonColor.TERTIARY:
            add_css_class("tertiary");
            break;
        case GroupedButtonColor.SURFACE:
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
        case GroupedButtonSize.SMALL:
            spacing = 18;
            break;
        case GroupedButtonSize.MEDIUM:
            spacing = 8;
            break;
        case GroupedButtonSize.LARGE:
            spacing = 6;
            break;
        case GroupedButtonSize.XLARGE:
            spacing = 4;
            break;
        }
        button_box.spacing = spacing;
    }

    public override void dispose() {
        // Clean up animation
        if (animation_timeout_id != 0) {
            Source.remove(animation_timeout_id);
            animation_timeout_id = 0;
        }

        if (button_box != null) {
            button_box.unparent();
            button_box = null;
        }
        base.dispose();
    }

    public override void size_allocate(int width, int height, int baseline) {
        if (pressed_button_index == -1 || squeeze_progress == 0.0) {
            // Normal allocation
            button_box.allocate(width, height, baseline, null);
            return;
        }

        // Custom allocation with squeeze effect
        if (buttons.size == 0) {
            button_box.allocate(width, height, baseline, null);
            return;
        }

        // Calculate base dimensions
        int spacing = get_current_spacing();
        int total_spacing = spacing * (buttons.size - 1);
        int available_width = width - total_spacing;
        int base_button_width = available_width / buttons.size;

        // Calculate animation amounts
        int expand_amount = (int) (base_button_width * 0.08 * squeeze_progress); // 8% expansion
        int shrink_amount = expand_amount / (int) (Math.fmax(1, count_adjacent_buttons())); // Distribute shrinkage

        // Create allocation rectangle for button_box
        var allocation = Gtk.Allocation();
        allocation.x = 0;
        allocation.y = 0;
        allocation.width = width;
        allocation.height = height;

        // Apply custom widths to buttons
        int x = 0;
        for (int i = 0; i < buttons.size; i++) {
            var child = buttons[i];
            int child_width = base_button_width;

            if (i == pressed_button_index) {
                // Expand pressed button
                child_width += expand_amount;
            } else if (Math.fabs(i - pressed_button_index) == 1) {
                // Shrink adjacent buttons
                child_width -= shrink_amount;
            }

            // Ensure minimum width
            child_width = (int) Math.fmax(child_width, 20);

            // Allocate this child
            var child_allocation = Gtk.Allocation();
            child_allocation.x = x;
            child_allocation.y = 0;
            child_allocation.width = child_width;
            child_allocation.height = height;

            child.size_allocate(child_allocation.width, child_allocation.height, baseline);
            x += child_width + spacing;
        }
    }

    private int get_current_spacing() {
        switch (_size) {
        case GroupedButtonSize.SMALL:
            return 18;
        case GroupedButtonSize.MEDIUM:
            return 8;
        case GroupedButtonSize.LARGE:
            return 6;
        case GroupedButtonSize.XLARGE:
            return 4;
        default:
            return 8;
        }
    }

    private int count_adjacent_buttons() {
        if (pressed_button_index == -1)return 0;

        int count = 0;
        if (pressed_button_index > 0)count++; // Left adjacent
        if (pressed_button_index < buttons.size - 1)count++; // Right adjacent
        return count;
    }

    public override void measure(Gtk.Orientation orientation, int for_size, out int minimum, out int natural, out int minimum_baseline, out int natural_baseline) {
        button_box.measure(orientation, for_size, out minimum, out natural, out minimum_baseline, out natural_baseline);
    }

    public override Gtk.SizeRequestMode get_request_mode() {
        return button_box.get_request_mode();
    }
}
