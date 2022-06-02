public class He.ContentBlockImageCluster : Gtk.Box, Gtk.Buildable {
  private Gtk.Label title_label = new Gtk.Label(null);
  private Gtk.Label subtitle_label = new Gtk.Label(null);
  private Gtk.Image image = new Gtk.Image();
  private Gtk.Grid grid = new Gtk.Grid();
  private Gtk.Box info_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 12);

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

  // please don't tell me that I can just rely on the value of the enum, I already know that, but I don't want to
  public enum ImagePosition {
    TOP_LEFT,
    BOTTOM_LEFT,
    TOP_RIGHT,
    BOTTOM_RIGHT;

    public int get_column() {
      switch (this) {
        case ImagePosition.TOP_LEFT:
        case ImagePosition.BOTTOM_LEFT:
          return 0;
        case ImagePosition.TOP_RIGHT:
        case ImagePosition.BOTTOM_RIGHT:
          return 1;
      }
      return 0;
    }

    public int get_row() {
      switch (this) {
        case ImagePosition.TOP_LEFT:
        case ImagePosition.TOP_RIGHT:
          return 0;
        case ImagePosition.BOTTOM_LEFT:
        case ImagePosition.BOTTOM_RIGHT:
          return 1;
      }
      return 0;
    }
  }

  public void set_image(He.ContentBlockImage image, ImagePosition position) {
    image.requested_height = 64;
    image.requested_width = 64;

    this.grid.attach(image, position.get_column(), position.get_row(), 1, 1);
  }

  public void remove_image(He.ContentBlockImage image) {
    this.grid.remove(image);
  }

  public ContentBlockImageCluster(string title, string subtitle, string icon) {
      this.title = title;
      this.subtitle = subtitle;
      this.icon = icon;
  }

  public void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
    switch (type) {
      case "top_left":
        this.set_image((He.ContentBlockImage)child, ImagePosition.TOP_LEFT);
        break;
      case "bottom_left":
        this.set_image((He.ContentBlockImage)child, ImagePosition.BOTTOM_LEFT);
        break;
      case "top_right":
        this.set_image((He.ContentBlockImage)child, ImagePosition.TOP_RIGHT);
        break;
      case "bottom_right":
        this.set_image((He.ContentBlockImage)child, ImagePosition.BOTTOM_RIGHT);
        break;
    }
}

  construct {
      this.orientation = Gtk.Orientation.HORIZONTAL;
      this.add_css_class ("content-block");
      
      image.icon_size = ((Gtk.IconSize)64);
      image.halign = Gtk.Align.START;
      title_label.xalign = 0;
      title_label.add_css_class ("cb-title");
      subtitle_label.xalign = 0;
      subtitle_label.add_css_class ("cb-subtitle");
      
      info_box.append(image);
      info_box.append(title_label);
      info_box.append(subtitle_label);

      grid.column_spacing = 12;
      grid.row_spacing = 12;
      grid.hexpand = true;
      grid.halign = Gtk.Align.END;

      //  button_box.halign = Gtk.Align.END;

      this.append(info_box);
      this.append(grid);
  }
}