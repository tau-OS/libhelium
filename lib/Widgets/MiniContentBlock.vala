public class He.MiniContentBlock : Gtk.Box {
  private Gtk.Label title_label = new Gtk.Label(null);
  private Gtk.Label subtitle_label = new Gtk.Label(null);
  private Gtk.Box info_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 6);
  private Gtk.Image image = new Gtk.Image();
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

  public He.FillButton primary_button {
    get {
        return _primary_button;
    }

    set {
        if (_primary_button != null) {
            this.remove (_primary_button);
        }

        value.hexpand = true;
        value.halign = Gtk.Align.END;
        value.add_css_class ("pill");
        _primary_button = value;
        this.append (_primary_button);
    }
  }

  public MiniContentBlock(string title, string subtitle, string icon, He.FillButton primary_button) {
    this.title = title;
    this.subtitle = subtitle;
    this.icon = icon;
    this.primary_button = primary_button;
  }

  construct {
    this.image.pixel_size = ((Gtk.IconSize)48);

    this.title_label.xalign = 0;
    this.title_label.add_css_class ("cb-title");
    this.subtitle_label.xalign = 0;
    this.subtitle_label.add_css_class ("cb-subtitle");

    this.info_box.append(this.title_label);
    this.info_box.append(this.subtitle_label);
    this.info_box.valign = Gtk.Align.CENTER;
    
    this.append(this.image);
    this.append(this.info_box);

    this.spacing = 18;
    this.add_css_class ("mini-content-block");
  }
}