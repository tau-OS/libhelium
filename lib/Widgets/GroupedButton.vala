namespace He {
/**
 * Size variants for the grouped button widget
 */
    public enum GroupedButtonSize {
        /**
         * Small size variant
         */
        SMALL,
        /**
         * Medium size variant (default)
         */
        MEDIUM,
        /**
         * Large size variant
         */
        LARGE,
        /**
         * Extra large size variant
         */
        XLARGE
    }

/**
 * A container widget that groups multiple buttons together with consistent styling
 *
 * GroupedButton provides a way to display multiple buttons as a cohesive group
 * with proper spacing and size management. It automatically applies size styling
 * to He.Button widgets added to it.
 */
    public class GroupedButton : Gtk.Widget {
        private Gtk.Box button_box;
        private GroupedButtonSize _size;
        private Gee.ArrayList<Gtk.Widget> buttons;
        private bool _segmented = false;

        /**
         * Emitted when a widget is added to the grouped button
         */
        public signal void widget_added(Gtk.Widget widget);

        /**
         * Emitted when a widget is removed from the grouped button
         */
        public signal void widget_removed(Gtk.Widget widget);

        /**
         * The size variant of the grouped button
         *
         * Controls the size of buttons within the group and the spacing between them.
         * Automatically updates He.Button widgets to match the selected size.
         */
        public GroupedButtonSize size {
            get { return _size; }
            set {
                if (_size != value) {
                    _size = value;
                    update_styling();
                    update_layout();
                    notify_property("size");
                    notify_property("size-name");
                }
            }
        }

        /**
         * The size variant as a string name
         *
         * Alternative way to set the size using string values:
         * "small", "medium", "large", or "xlarge"/"extra-large"
         */
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

        /**
         * The number of buttons/widgets in the group
         */
        public int button_count {
            get { return buttons.size; }
        }

        /**
         * Whether all buttons should have equal width
         *
         * When true, all buttons in the group will be allocated equal space.
         * When false, buttons will size according to their natural size.
         */
        public bool homogeneous {
            get { return button_box.homogeneous; }
            set {
                button_box.homogeneous = value;
                notify_property("homogeneous");
            }
        }

        /**
         * Whether to use segmented button styling
         *
         * When true, uses the "segmented-button" CSS class instead of "grouped-button".
         * This provides the same styling as the deprecated SegmentedButton widget.
         */
        public bool segmented {
            get { return _segmented; }
            set {
                if (_segmented != value) {
                    _segmented = value;
                    update_css_class();
                    notify_property("segmented");
                }
            }
        }

        /**
         * Creates a new grouped button with default medium size
         */
        public GroupedButton() {
            _size = GroupedButtonSize.MEDIUM;
            buttons = new Gee.ArrayList<Gtk.Widget> ();

            button_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
            button_box.set_parent(this);

            // Set margins
            this.margin_start = 18;
            this.margin_end = 18;
            this.margin_top = 6;
            this.margin_bottom = 6;

            update_css_class();
            update_styling();
            update_layout();
        }

        /**
         * Creates a new grouped button with the specified size
         *
         * @param size The size variant to use for the grouped button
         */
        public GroupedButton.with_size(GroupedButtonSize size) {
            this();
            this.size = size;
        }

        /**
         * Creates a new grouped button with the specified size name
         *
         * @param size_name The size variant as a string ("small", "medium", "large", "xlarge")
         */
        public GroupedButton.with_names(string size_name) {
            this();
            this.size_name = size_name;
        }

        private void update_css_class() {
            remove_css_class("grouped-button");
            remove_css_class("segmented-button");
            if (_segmented) {
                add_css_class("segmented-button");
            } else {
                add_css_class("grouped-button");
            }
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

        /**
         * Adds a widget (typically a button) to the group
         *
         * The widget will be automatically styled to match the group's size if it's
         * an He.Button instance. Emits the widget_added signal.
         *
         * @param widget The widget to add to the group
         */
        public void add_widget(Gtk.Widget widget) {
            buttons.add(widget);
            button_box.append(widget);
            update_widget_styling(widget);
            widget_added(widget);
        }

        /**
         * Removes a widget from the group
         *
         * If the widget is found in the group, it will be removed and the
         * widget_removed signal will be emitted.
         *
         * @param widget The widget to remove from the group
         */
        public void remove_widget(Gtk.Widget widget) {
            if (buttons.remove(widget)) {
                button_box.remove(widget);
                widget_removed(widget);
            }
        }

        /**
         * Removes all widgets from the group
         *
         * Clears all buttons/widgets from the grouped button container.
         */
        public void clear_widgets() {
            foreach (var widget in buttons) {
                button_box.remove(widget);
            }
            buttons.clear();
        }

        /**
         * Gets the widget at the specified index
         *
         * Returns null if the index is out of bounds.
         *
         * @param index The zero-based index of the widget to retrieve
         * @return The widget at the specified index, or null if index is invalid
         */
        public Gtk.Widget? get_widget_at_index(int index) {
            if (index >= 0 && index < buttons.size) {
                return buttons[index];
            }
            return null;
        }

        private void update_styling() {
            foreach (var widget in buttons) {
                update_widget_styling(widget);
            }
        }

        private void update_widget_styling(Gtk.Widget widget) {
            // Apply size to He.Button widgets
            if (widget is He.Button) {
                var he_button = widget as He.Button;
                switch (_size) {
                case GroupedButtonSize.SMALL :
                    he_button.size = He.ButtonSize.SMALL;
                    break;
                case GroupedButtonSize.MEDIUM:
                    he_button.size = He.ButtonSize.MEDIUM;
                    break;
                case GroupedButtonSize.LARGE:
                    he_button.size = He.ButtonSize.LARGE;
                    break;
                case GroupedButtonSize.XLARGE:
                    he_button.size = He.ButtonSize.XLARGE;
                    break;
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
