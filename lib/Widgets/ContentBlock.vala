public class He.ContentBlock : Gtk.Box, Gtk.Buildable {
    private Gtk.Label title_label = new Gtk.Label(null);
    private Gtk.Label subtitle_label = new Gtk.Label(null);
    private Gtk.Image image = new Gtk.Image();
    private Gtk.Box info_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 12);
    private Gtk.Box button_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 24);
    private He.TintButton _secondary_button;
    private He.FillButton _primary_button;

    public string title {
        get {
            return title_label.get_text ();
        }
        set {
            title_label.set_text (value);
        }
    }

    public string subtitle {
        get {
            return subtitle_label.get_text ();
        }
        set {
            subtitle_label.set_text (value);
        }
    }

    public string icon {
        get {
            return image.get_icon_name ();
        }

        set {
            image.set_from_icon_name (value);
        }
    }

    public He.TintButton secondary_button {
        set {
            if (_secondary_button != null) {
                button_box.remove (_secondary_button);
            }

            value.add_css_class ("pill");
            _secondary_button = value;
            button_box.prepend(_secondary_button);
        }

        get {
            return _secondary_button;
        }
    }

    public He.FillButton primary_button {
        get {
            return _primary_button;
        }

        set {
            if (_primary_button != null) {
                button_box.remove (_primary_button);
            }

            value.add_css_class ("pill");
            _primary_button = value;
            button_box.append (_primary_button);
        }
    }

    public ContentBlock(string title, string subtitle, string icon, He.FillButton primary_button, He.TintButton secondary_button) {
        this.title = title;
        this.subtitle = subtitle;
        this.icon = icon;
        this.primary_button = primary_button;
        this.secondary_button = secondary_button;
    }

    construct {
        this.orientation = Gtk.Orientation.VERTICAL;
        this.add_css_class ("content-block");
        
        image.pixel_size = ((Gtk.IconSize)64);
        image.halign = Gtk.Align.START;
        title_label.xalign = 0;
        title_label.add_css_class ("cb-title");
        subtitle_label.xalign = 0;
        subtitle_label.add_css_class ("cb-subtitle");
        
        info_box.append(image);
        info_box.append(title_label);
        info_box.append(subtitle_label);

        button_box.halign = Gtk.Align.END;

        this.append(info_box);
        this.append(button_box);
    }
}