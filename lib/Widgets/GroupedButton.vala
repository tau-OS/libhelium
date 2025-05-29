namespace He {
    public enum GroupedButtonSize {
        SMALL,
        MEDIUM,
        LARGE,
        XLARGE
    }

    public enum GroupedButtonColor {
        PRIMARY,
        SECONDARY,
        TERTIARY,
        SURFACE
    }

    public class GroupedButton : Gtk.Widget {
        private Gtk.Box button_box;
        private GroupedButtonSize _size;
        private GroupedButtonColor _color;
        private Gee.ArrayList<Gtk.Widget> buttons;

        // Signals
        public signal void active_changed(int index, Gtk.Widget widget);
        public signal void widget_added(Gtk.Widget widget);
        public signal void widget_removed(Gtk.Widget widget);

        public GroupedButtonSize size {
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

        public GroupedButtonColor color {
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
                default: return "surface";
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
                notify_property("homogeneous");
            }
        }

        public GroupedButton() {
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
            update_layout();
        }

        public GroupedButton.with_size_and_color(GroupedButtonSize size, GroupedButtonColor color) {
            this();
            this.size = size;
            this.color = color;
        }

        public GroupedButton.with_names(string size_name, string color_name) {
            this();
            this.size_name = size_name;
            this.color_name = color_name;
        }

        private void update_layout() {
            int spacing = 0;
            switch (_size) {
            case GroupedButtonSize.SMALL:
                spacing = 12;
                break;
            case GroupedButtonSize.MEDIUM:
                spacing = 8;
                break;
            case GroupedButtonSize.LARGE:
                spacing = 8;
                break;
            case GroupedButtonSize.XLARGE:
                spacing = 8;
                break;
            }
            button_box.spacing = spacing;
        }

        public void add_widget(Gtk.Widget widget) {
            buttons.add(widget);
            button_box.append(widget);
            update_widget_styling(widget);
            setup_widget_gestures(widget, buttons.size - 1);
            widget_added(widget);

            // Ensure proper initial styling
            widget.add_css_class("inactive");
        }

        public void remove_widget(Gtk.Widget widget) {
            if (buttons.remove(widget)) {
                button_box.remove(widget);
                widget_removed(widget);
            }
        }

        public void clear_widgets() {
            foreach (var widget in buttons) {
                button_box.remove(widget);
            }
            buttons.clear();
        }

        // Convenience methods for specific button types
        public void add_button(Gtk.Button button) {
            add_widget(button);
        }

        public void add_menu_button(Gtk.MenuButton menu_button) {
            add_widget(menu_button);
        }

        // Helper methods for .ui files
        public void add_button_with_label(string label) {
            var button = new Gtk.Button.with_label(label);
            add_widget(button);
        }

        public void add_menu_button_with_label(string label) {
            var button = new Gtk.MenuButton();
            button.label = label;
            add_widget(button);
        }

        public Gtk.Widget? get_widget_at_index(int index) {
            if (index >= 0 && index < buttons.size) {
                return buttons[index];
            }
            return null;
        }

        public void set_active_widget(Gtk.Widget widget) {
            // Check if widget is in our buttons list
            int index = buttons.index_of(widget);
            if (index >= 0) {
                // Toggle the active state
                if (widget.has_css_class("active")) {
                    // Currently active, make it inactive
                    widget.remove_css_class("active");
                    widget.add_css_class("inactive");
                } else {
                    // Currently inactive, make it active
                    widget.remove_css_class("inactive");
                    widget.add_css_class("active");
                }
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
            // Returns the first active button index, or -1 if none active
            for (int i = 0; i < buttons.size; i++) {
                if (buttons[i].has_css_class("active")) {
                    return i;
                }
            }
            return -1;
        }

        // New method to get all active indices
        public Gee.ArrayList<int> get_active_indices() {
            var active_indices = new Gee.ArrayList<int> ();
            for (int i = 0; i < buttons.size; i++) {
                if (buttons[i].has_css_class("active")) {
                    active_indices.add(i);
                }
            }
            return active_indices;
        }

        // New method to get all active widgets
        public Gee.ArrayList<Gtk.Widget> get_active_widgets() {
            var active_widgets = new Gee.ArrayList<Gtk.Widget> ();
            foreach (var widget in buttons) {
                if (widget.has_css_class("active")) {
                    active_widgets.add(widget);
                }
            }
            return active_widgets;
        }

        // Method to set multiple buttons active at once
        public void set_active_indices(Gee.ArrayList<int> indices) {
            // First, make all buttons inactive
            foreach (var widget in buttons) {
                widget.remove_css_class("active");
                widget.add_css_class("inactive");
            }

            // Then activate the specified indices
            foreach (int index in indices) {
                var widget = get_widget_at_index(index);
                if (widget != null) {
                    widget.remove_css_class("inactive");
                    widget.add_css_class("active");
                }
            }
        }

        // Method to clear all active states
        public void clear_active() {
            foreach (var widget in buttons) {
                widget.remove_css_class("active");
                widget.add_css_class("inactive");
            }
        }

        // Check if a specific button is active
        public bool is_active(int index) {
            var widget = get_widget_at_index(index);
            return widget != null && widget.has_css_class("active");
        }

        // Get count of active buttons
        public int get_active_count() {
            int count = 0;
            foreach (var widget in buttons) {
                if (widget.has_css_class("active")) {
                    count++;
                }
            }
            return count;
        }

        // Template child setup helper for .ui files
        public void setup_template_children() {
            // This method can be called from .ui files to ensure proper setup
            update_styling();
        }

        private void setup_widget_gestures(Gtk.Widget widget, int index) {
            var gesture = new Gtk.GestureClick();

            gesture.pressed.connect(() => {
                start_press_animation(widget, index);
            });

            gesture.released.connect(() => {
                end_press_animation(widget);
                set_active_widget(widget);
            });

            widget.add_controller(gesture);

            // Also handle regular button clicks for Gtk.Button widgets
            if (widget is Gtk.Button) {
                var button = widget as Gtk.Button;
                button.clicked.connect(() => {
                    set_active_widget(widget);
                });
            }
        }

        private void start_press_animation(Gtk.Widget widget, int index) {
            // Add pressed class to the clicked button
            widget.add_css_class("pressed");

            // Add animating class to container for CSS sibling selectors
            add_css_class("animating");

            // Add helper classes for adjacent buttons
            if (index > 0) {
                var prev_button = buttons[index - 1];
                prev_button.add_css_class("before-pressed");
            }
        }

        private void end_press_animation(Gtk.Widget widget) {
            // Remove pressed class from the clicked button
            widget.remove_css_class("pressed");

            // Remove animating class from container
            remove_css_class("animating");

            // Remove helper classes from all buttons
            foreach (var button in buttons) {
                button.remove_css_class("before-pressed");
            }
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

            foreach (var widget in buttons) {
                update_widget_styling(widget);
            }
        }

        private void update_widget_styling(Gtk.Widget widget) {
            // Remove old classes
            widget.remove_css_class("active");
            widget.remove_css_class("inactive");

            // Remove extra classes
            widget.remove_css_class("text-button");
            widget.remove_css_class("fill-button");
            widget.remove_css_class("outline-button");
            widget.remove_css_class("tint-button");
            widget.remove_css_class("textual-button");
            widget.remove_css_class("disclosure-button");
            widget.remove_css_class("iconic-button");

            widget.add_css_class("inactive");

            // For MenuButton widgets, monitor popover state for active styling
            if (widget is Gtk.MenuButton) {
                var menu_button = widget as Gtk.MenuButton;
                if (menu_button.popover != null) {
                    menu_button.popover.notify["visible"].connect(() => {
                        if (menu_button.popover.visible) {
                            set_active_widget(widget);
                        }
                    });
                }
            }
        }

        public override void dispose() {
            if (button_box != null) {
                button_box.unparent();
                button_box = null;
            }
            base.dispose();
        }

        public override void measure(Gtk.Orientation orientation, int for_size, out int minimum, out int natural, out int minimum_baseline, out int natural_baseline) {
            button_box.measure(orientation, for_size, out minimum, out natural, out minimum_baseline, out natural_baseline);
        }

        public override Gtk.SizeRequestMode get_request_mode() {
            return button_box.get_request_mode();
        }

        public override void size_allocate(int width, int height, int baseline) {
            button_box.allocate(width, height, baseline, null);
        }
    }
}
