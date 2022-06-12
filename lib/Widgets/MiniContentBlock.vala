/**
* A MiniContentBlock is a content block that is used to display content in a small area.
*/
public class He.MiniContentBlock : He.Bin {
    private Gtk.Label title_label = new Gtk.Label(null);
    private Gtk.Label subtitle_label = new Gtk.Label(null);
    private Gtk.Box info_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 6);
    private Gtk.Image image = new Gtk.Image();
    private He.Button _primary_button;
    private Gtk.Box btn_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
    
    /**
    * The title of the content block.
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
    * The subtitle of the content block.
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
    * The icon of the content block.
    */
    public string icon {
        get {
            return image.get_icon_name ();
        }
        
        set {
            image.set_from_icon_name (value);
        }
    }
    
    /**
    * Another way to set the icon of the content block using a GLib.Icon.
    */
    public GLib.Icon gicon {
        set {
            image.set_from_gicon (value);
        }
    }
    
    /**
    * The primary button of the content block.
    */
    public He.Button primary_button {
        get {
            return _primary_button;
        }
        
        set {
            if (_primary_button != null) {
                btn_box.remove (_primary_button);
            }
            
            value.hexpand = true;
            value.halign = Gtk.Align.END;
            _primary_button = value;
            value.add_css_class ("fill-button");
            value.add_css_class ("pill");
            btn_box.append (_primary_button);
        }
    }
    
    /**
    * Constructs a new MiniContentBlock.
    * @param title The title of the content block.
    * @param subtitle The subtitle of the content block.
    * @param primary_button The primary button of the content block.
    */
    public MiniContentBlock(string title, string subtitle, He.Button primary_button) {
        this.title = title;
        this.subtitle = subtitle;
        this.primary_button = primary_button;
    }
    
    static construct {
        set_layout_manager_type (typeof (Gtk.BoxLayout));
    }
    
    construct {
        this.image.pixel_size = ((Gtk.IconSize)32);
        
        this.title_label.xalign = 0;
        this.title_label.add_css_class ("cb-title");
        this.subtitle_label.xalign = 0;
        this.subtitle_label.add_css_class ("cb-subtitle");
        this.subtitle_label.wrap = true;
        this.subtitle_label.ellipsize = Pango.EllipsizeMode.END;
        
        this.info_box.append(this.title_label);
        this.info_box.append(this.subtitle_label);
        this.info_box.valign = Gtk.Align.CENTER;
        
        var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 18);
        box.append(this.image);
        box.append(this.info_box);
        box.append(this.btn_box);
        
        box.set_parent(this);
        
        this.add_css_class ("mini-content-block");
    }
}