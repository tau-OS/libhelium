interface He.AlbumPageInterface : Gtk.Widget {
  public abstract int min_width { get; set; }
  public abstract bool navigatable { get; set; }
}

/**
 * An AlbumPage is a widget that holds a single view, for use in an Album.
 */
class He.AlbumPage : Gtk.Widget, Gtk.Buildable, He.AlbumPageInterface {

  /**
   * The child widget of the AlbumPage.
   */
  private Gtk.Widget _child;
  public Gtk.Widget child {
    set {
      if (_child != null) {
        _child.unparent();
      }

      _child = value;
      _child.set_parent(this);
      if (navigatable) {
        if (this.min_width != 0) {
          _child.set_size_request(this.min_width, -1);
        } else {
          this.hexpand = true;
        }
      } else {
        this.hexpand = false;
        this.hexpand_set = true;
      }
    }

    get {
      return _child;
    }
  }

  /**
   * The minimum width of the AlbumPage.
   */
  public int min_width { get; set; }

  /**
   * Whether the AlbumPage is navigatable.
   */
  public bool navigatable { get; set; }

  /**
   * Add a child to the welcome screen, should only be used in the context of a UI or Blueprint file. There should be no need to use this method in code.
   */
  public void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
    this.child = (Gtk.Widget)child;
  }

  /**
   * Constructs a new AlbumPage.
   */
  public AlbumPage (Gtk.Widget child, int min_width, bool navigatable) {
    this.child = child;
    this.min_width = min_width;
    this.navigatable = navigatable;
  }

  static construct {
    set_layout_manager_type (typeof (Gtk.BinLayout));
  }
}