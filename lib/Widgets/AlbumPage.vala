interface He.AlbumPageInterface : Gtk.Widget {
  public abstract int min_width { get; set; }
  public abstract bool navigatable { get; set; }
}

class He.AlbumPage : Gtk.Box, Gtk.Buildable, He.AlbumPageInterface {
  private Gtk.Widget _child;
  public Gtk.Widget child {
    set {
      if (_child != null) {
        this.remove(_child);
      }

      _child = value;
      this.append(_child);
    }

    get {
      return _child;
    }
  }
  public int min_width { get; set; }
  public bool navigatable { get; set; default = true; }

  public void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
    this.child = (Gtk.Widget)child;
  }

  public AlbumPage (Gtk.Widget child, int min_width, bool navigatable) {
    this.child = child;
    this.min_width = min_width;
    this.navigatable = navigatable;
  }

  construct {
    this.homogeneous = true;
  }
}