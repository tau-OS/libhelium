class He.Album : Gtk.Box, Gtk.Buildable {
  private signal void children_updated();
  private signal void minimum_requested_width_changed();

  private GLib.List<He.AlbumPageInterface> children = new GLib.List<He.AlbumPageInterface> ();
  private int minimum_requested_width = 0;
  private bool _folded = false;
  public bool folded {
    get { return _folded; }
    set {
      _folded = value;
    }
  }
  private He.Window window { get; set; }

  private Gtk.Box _box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
  private Gtk.Stack _stack = new Gtk.Stack ();
  public Gtk.Stack stack {
    get { return _stack; }
  }

  private Gtk.Stack main_stack = new Gtk.Stack ();

  public new void append(He.AlbumPageInterface widget) {
    this.children.append(widget);
    children_updated();
  }

  public new void insert_child_after(He.AlbumPageInterface widget, He.AlbumPageInterface sibling) {
    var index = this.children.index(sibling);
    if (index == -1) {
      return;
    }

    this.children.insert(widget, index);
    children_updated();
  }

  public new void prepend(He.AlbumPageInterface widget) {
    this.children.prepend(widget);
    children_updated();
  }

  public new void remove(He.AlbumPageInterface widget) {
    this.children.remove(widget);
    children_updated();
  }

  public new void reorder_child_after(He.AlbumPageInterface widget, He.AlbumPageInterface sibling) {
    var index = this.children.index(sibling);
    if (index == -1) {
      return;
    }

    this.children.remove(widget);
    this.children.insert(widget, index);
    children_updated();
  }

  private void update_folded() {
    // 200 is a magic number, but it seems to work well
    if (this.get_width() < this.minimum_requested_width + 200 || 
        this.get_width() < this.minimum_requested_width - 200 || 
        this.get_width() <= this.minimum_requested_width ) {
      this._folded = true;
    } else {
      this._folded = false;
    }
  }

  private void update_view() {
    if (this._folded) {
      main_stack.set_visible_child (_stack);
      foreach (var child in this.children) {
        if (this._box != null) {
          child.unparent ();
        }
        if (child.navigatable) {
          this._stack.add_child(child);
        }
        this._stack.set_visible_child(child);
      }
      this.queue_allocate();
      this.add_css_class ("folded");
      this.remove_css_class ("unfolded");
    } else {
      main_stack.set_visible_child (_box);
      foreach (var child in this.children) {
        if (this._stack != null) {
          child.unparent ();
        }
        this._box.append(child);
      }
      this.queue_resize();
      this.add_css_class ("unfolded");
      this.remove_css_class ("folded");
    }
  }

  public void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
    this.append((He.AlbumPageInterface) child);
  }

  private void update_minimum_requested_width() {
    var largest_width = 0;

    foreach (var child in this.children) {
      Gtk.Requisition req;
      child.get_preferred_size(out req, null);
      var child_width = req.width;

      largest_width = child_width;
    }

    this.minimum_requested_width = (largest_width + 72) * ((this.children.position (this.children.last ()) - 2)); // -2 is the number of children that are not navigatable
    minimum_requested_width_changed();
  }

  construct {
    this.children_updated.connect(() => {
      update_minimum_requested_width();
      update_view();
    });

    this.minimum_requested_width_changed.connect(() => {
      update_folded();
    });

    this.notify["parent"].connect(() => {
      this.window = He.Misc.find_ancestor_of_type<He.Window>(this);
      if (this.window == null) return;

      this.window.notify["default-width"].connect(() => {
        update_folded();
        update_view();
      });
    });

    update_minimum_requested_width();
    update_folded();
    update_view();

    main_stack.add_child(this._box);
    main_stack.add_child(this._stack);
    base.append (main_stack);

    this.add_css_class ("unfolded");
  }
}