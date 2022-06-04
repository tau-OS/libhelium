public class He.Banner : Gtk.Box, Gtk.Buildable {
    private Gtk.Box text_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);
    private Gtk.Box button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
  
    private Gtk.Label title_label = new Gtk.Label (null);
    private Gtk.Label description_label = new Gtk.Label (null);
    private Style _style = Style.INFO;
  
    public string title {
        get { return title_label.get_text (); }
        set { title_label.set_text (value); }
    }
    public string description {
        get { return description_label.get_text (); }
        set { description_label.set_text (value); }
    }
    public Style style {
        get { return _style; }
        set { set_banner_style (value); }
    }
  
    public enum Style {
        INFO,
        WARNING,
        ERROR
    }
  
    public void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
        if (strcmp (type, "action") == 0) {
            add_action_button ((Gtk.Widget) child);
        } else {
            this.append ((Gtk.Widget) child);
        }
    }
  
    public void add_action_button (Gtk.Widget widget) {
        if (button_box.get_first_child () == null) {
            button_box.set_visible (true);
        }

        button_box.append (widget);
    }
  
    public void remove_action (Gtk.Widget widget) {
        button_box.remove (widget);

        if (button_box.get_first_child () == null) {
            button_box.set_visible (false);
        }
    }

    public void set_banner_style (Style style) {
        this.remove_css_class ("info");
        this.remove_css_class ("warning");
        this.remove_css_class ("error");

        if (style == Style.INFO) {
            this.add_css_class ("info");
        } else if (style == Style.WARNING) {
            this.add_css_class ("warning");
        } else if (style == Style.ERROR) {
            this.add_css_class ("error");
        }

        this._style = style;
    }
  
    public Banner (string title, string description) {
        this.title = title;
        this.description = description;
    }
    
    construct {
        this.title_label.add_css_class ("header");
        this.description_label.add_css_class ("body");
        this.add_css_class ("banner");

        this.text_box.append (title_label);
        this.text_box.append (description_label);
    
        var center_layout = new Gtk.CenterLayout();
        this.layout_manager = center_layout;

        this.text_box.set_halign (Gtk.Align.START);
        this.text_box.set_margin_top (5);
        this.text_box.set_margin_bottom (5);
        this.button_box.set_halign (Gtk.Align.END);
        this.button_box.set_valign (Gtk.Align.END);
        this.button_box.set_vexpand (true);
    
        center_layout.set_start_widget(text_box);
        center_layout.set_end_widget(button_box);

        button_box.set_visible (false);
    
        this.append (text_box);
        this.append (button_box);
    }
  }
  