/**
 * A ContentBlock displays a single block of content, which contains an icon, text and optional buttons.
 */
public class He.ContentBlock : Gtk.Widget, Gtk.Buildable {
    private Gtk.Label title_label = new Gtk.Label(null);
    private Gtk.Label subtitle_label = new Gtk.Label(null);
    private Gtk.Image image = new Gtk.Image();
    private Gtk.Box info_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 12);
    private Gtk.Box button_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 24);
    private He.Button _secondary_button;
    private He.Button _primary_button;

    /** 
     * Sets the title of the content block.
     * @param title The title of the content block.
     */
    public string title {
        get {
            return title_label.get_text ();
        }
        set {
            title_label.set_text (value);
        }
    }

    /** 
     * Sets the subtitle of the content block.
     * @param subtitle The subtitle of the content block.
     */
    public string subtitle {
        get {
            return subtitle_label.get_text ();
        }
        set {
            subtitle_label.set_text (value);
        }
    }

    /** 
     * Sets the icon of the content block.
     * @param icon The icon of the content block.
     */
    public string icon {
        get {
            return image.get_icon_name ();
        }

        set {
            image.set_from_icon_name (value);
        }
    }
    
    public GLib.Icon gicon {
        set {
            image.set_from_gicon (value);
        }
    }

    /** 
     * Sets the secondary button of the content block.
     * @param secondary_button The secondary button of the content block.
     */
    public He.Button secondary_button {
        set {
            if (_secondary_button != null) {
                button_box.remove (_secondary_button);
            }

            value.add_css_class ("tint-button");
            value.add_css_class ("pill");
            _secondary_button = value;
            button_box.prepend(_secondary_button);
        }

        get {
            return _secondary_button;
        }
    }

    /** 
     * Sets the primary button of the content block.
     * @param primary_button The primary button of the content block.
     */
    public He.Button primary_button {
        get {
            return _primary_button;
        }

        set {
            if (_primary_button != null) {
                button_box.remove (_primary_button);
            }

            value.add_css_class ("fill-button");
            value.add_css_class ("pill");
            _primary_button = value;
            button_box.append (_primary_button);
        }
    }

    /** 
     * Constructs a new ContentBlock.
     * @param title The title of the content block.
     * @param subtitle The subtitle of the content block.
     * @param icon The icon of the content block.
     * @param secondary_button The secondary button of the content block.
     * @param primary_button The primary button of the content block.
     */
    public ContentBlock(string title, string subtitle, string icon, He.Button primary_button, He.Button secondary_button) {
        this.title = title;
        this.subtitle = subtitle;
        this.icon = icon;
        this.primary_button = primary_button;
        this.secondary_button = secondary_button;
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BoxLayout));
    }

    construct {
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
        button_box.hexpand = true;

        var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        box.append(info_box);
        box.append(button_box);
        box.set_parent(this);
    }

    ~ContentBlock() {
        this.info_box.unparent();
        this.button_box.unparent();
        this.dispose();
    }
}