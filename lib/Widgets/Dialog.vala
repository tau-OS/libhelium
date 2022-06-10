public class He.Dialog : He.Window {
    private Gtk.Label title_label = new Gtk.Label(null);
    private Gtk.Label subtitle_label = new Gtk.Label(null);
    private Gtk.Label info_label = new Gtk.Label(null);
    private Gtk.Image image = new Gtk.Image();
    private Gtk.Box info_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 24);
    private Gtk.Box button_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 24);
    private He.TintButton _secondary_button;
    private He.FillButton _primary_button;
    private He.TextButton _cancel_button;
    private Gtk.WindowHandle dialog_handle = new Gtk.WindowHandle ();


    public new string title {
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

    public string info {
        get {
            return info_label.get_text ();
        }
        set {
            info_label.set_text (value);
        }
    }

    public string icon {
        get {
            return image.get_icon_name ();
        }

        set {
            image.pixel_size = ((Gtk.IconSize)64);
            image.set_from_icon_name (value);
        }
    }

    public He.TintButton secondary_button {
        set {
            if (_secondary_button != null) {
                button_box.remove (_secondary_button);
            }

            _secondary_button = value;
            button_box.prepend(_secondary_button);
            button_box.reorder_child_after (_secondary_button, _cancel_button);
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

            _primary_button = value;
            button_box.append (_primary_button);

            if (_secondary_button != null) {
                button_box.reorder_child_after (_primary_button, _secondary_button);
            }
        }
    }

    public Dialog(bool modal, Gtk.Window? parent, string title, string subtitle, string info, string icon, He.FillButton? primary_button, He.TintButton? secondary_button) {
        this.modal = modal;
        this.parent = parent;
        this.title = title;
        this.subtitle = subtitle;
        this.info = info;
        this.icon = icon;
        this.primary_button = primary_button;
        this.secondary_button = secondary_button;
    }

    ~Dialog() {
        this.unparent();
        this.dialog_handle.dispose();
    }

    construct {
        image.valign = Gtk.Align.CENTER;
        title_label.add_css_class ("view-title");
        subtitle_label.xalign = 0;
        subtitle_label.add_css_class ("view-subtitle");
        info_label.add_css_class ("body");
        info_label.xalign = 0;
        info_label.vexpand = true;
        info_label.valign = Gtk.Align.START;
        
        info_box.append(image);
        info_box.append(title_label);
        info_box.append(subtitle_label);
        info_box.append(info_label);

        _cancel_button = new He.TextButton ("Cancel");
        _cancel_button.clicked.connect (() => {
            this.close ();
        });

        button_box.homogeneous = true;
        button_box.append (_cancel_button);

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 24);
        main_box.vexpand = true;
        main_box.margin_end = main_box.margin_start = main_box.margin_top = main_box.margin_bottom = 24;
        main_box.append(info_box);
        main_box.append(button_box);
        dialog_handle.set_child (main_box);

        this.set_child (dialog_handle);
        this.resizable = false;
        this.set_size_request (360, 400);
        this.has_title = false;
    }
}