namespace He {
    public enum GroupedButtonSize {
        SMALL,
        MEDIUM,
        LARGE,
        XLARGE
    }

    public class GroupedButton : Gtk.Widget {
        private Gtk.Box button_box;
        private GroupedButtonSize _size;
        private Gee.ArrayList<Gtk.Widget> buttons;

        // Signals
        public signal void widget_added(Gtk.Widget widget);
        public signal void widget_removed(Gtk.Widget widget);

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

        public GroupedButton.with_size(GroupedButtonSize size) {
            this();
            this.size = size;
        }

        public GroupedButton.with_names(string size_name) {
            this();
            this.size_name = size_name;
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
            widget_added(widget);
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
