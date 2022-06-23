/**
* A ContentBlockImageCluster is a cluster of images that are rendered together in the same content block.
*/
public class He.ContentBlockImageCluster : He.Bin {
  private Gtk.Label title_label = new Gtk.Label(null);
  private Gtk.Label subtitle_label = new Gtk.Label(null);
  private Gtk.Image image = new Gtk.Image();
  private Gtk.Grid grid = new Gtk.Grid();
  private Gtk.Box info_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 12);
  
  /**
  * The title of the cluster.
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
  * The subtitle of the cluster.
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
  * The image of the cluster.
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
  * The position of the cluster image in the cluster.
  */
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
  
  /** 
  * Sets an image to be displayed in the cluster.
  * @param image The image to display.
  * @param position The position of the image in the cluster.
  */
  public void set_image(He.ContentBlockImage image, ImagePosition position) {
    image.requested_height = 64;
    image.requested_width = 64;
    
    this.grid.attach(image, position.get_column(), position.get_row(), 1, 1);
  }
  
  /**
  * Removes an image from the cluster.
  * @param image The image to remove.
  */
  public void remove_image(He.ContentBlockImage image) {
    this.grid.remove(image);
  }
  
  public ContentBlockImageCluster(string title, string subtitle, string icon) {
    this.title = title;
    this.subtitle = subtitle;
    this.icon = icon;
  }
  
  /**
  * Adds an image child to the cluster. The image will be displayed in the cluster in the position specified by the position type.
  * Should only be used in UI or Blueprint files.
  */
  public override void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
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
    
    grid.column_spacing = 12;
    grid.row_spacing = 12;
    grid.hexpand = true;
    grid.halign = Gtk.Align.END;
    
    var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
    box.append(info_box);
    box.append(grid);
    
    box.set_parent(this);
  }
}