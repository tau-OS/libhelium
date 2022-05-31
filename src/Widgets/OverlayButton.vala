class He.OverlayButton : Gtk.Overlay {
    private Gtk.Button button = new Gtk.Button();
    private Gtk.Box button_content = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
    private Gtk.Image image = new Gtk.Image();
    private Gtk.Label? _label;

    public signal void clicked();

    public enum Size {
        SMALL,
        MEDIUM,
        LARGE;

        public string? to_css_class() {
            switch (this) {
                case SMALL:
                    return "small";
                case MEDIUM:
                    return null;
                case LARGE:
                    return "large";
                default:
                    return null;
            }
        }
    }

    private Size? _size;
    public Size size {
        set {
            if (_size != Size.MEDIUM) button.remove_css_class (_size.to_css_class());
            if (value != Size.MEDIUM) button.add_css_class (value.to_css_class());

            _size = value;
        }

        get {
            return _size;
        }
    }

    private He.Colors _color;
    public He.Colors color {
        set {
            if (_color != He.Colors.NONE) button.remove_css_class (_color.to_css_class());
            if (value != He.Colors.NONE) button.add_css_class (value.to_css_class());

            _color = value;
        }

        get {
            return _color;
        }
    }

    public string icon {
        set {
            image.set_from_icon_name(value);
        }

        owned get {
            return image.icon_name;
        }
    }

    public string? label {
        set {
            if (value == null) {
                if (_label != null) {
                    button.remove_css_class("textual");
                    button_content.remove(_label);
                    _label = null;
                }

                return;
            }

            if (_label == null) {
                _label = new Gtk.Label(null);
                _label.add_css_class("textual");
                button_content.append(_label);
            }

            _label.set_text(value);
        }

        get {
            if (_label == null) return null;
            return _label.get_text();
        }
    }

    public OverlayButton(string icon, string? label) {
        this.icon = icon;
        if (label != null) this.label = label;
    }

    construct {
        button_content.append(image);
        button.set_child(button_content);
        button.add_css_class ("overlay-button");
        this.add_overlay(button);

        button.clicked.connect(() => {
            clicked();
        });

        this.size = Size.MEDIUM;
        this.color = He.Colors.BLUE;
    }
}