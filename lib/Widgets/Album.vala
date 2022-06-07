class He.Album : Gtk.Box, Gtk.Buildable {
  private signal void children_updated();
  private signal void minimum_requested_width_changed();

  private GLib.List<He.AlbumPageInterface> children = new GLib.List<He.AlbumPageInterface> ();
  private int minimum_requested_width = 0;
  private bool _folded = false;
  private He.Window window { get; set; }

  private Gtk.Box _box;
  private Gtk.Stack _stack;

  public void append(He.AlbumPageInterface widget) {
    this.children.append(widget);
    children_updated();
  }

  public void insert_child_after(He.AlbumPageInterface widget, He.AlbumPageInterface sibling) {
    var index = this.children.index(sibling);
    if (index == -1) {
      return;
    }

    this.children.insert(widget, index);
    children_updated();
  }

  public void prepend(He.AlbumPageInterface widget) {
    this.children.prepend(widget);
    children_updated();
  }

  public void remove(He.AlbumPageInterface widget) {
    this.children.remove(widget);
    children_updated();
  }

  public void reorder_child_after(He.AlbumPageInterface widget, He.AlbumPageInterface sibling) {
    var index = this.children.index(sibling);
    if (index == -1) {
      return;
    }

    this.children.remove(widget);
    this.children.insert(widget, index);
    children_updated();
  }

  private void update_folded() {
    print("min: %d, current: %d\n", minimum_requested_width, this.get_width());
    if (this.get_width() < this.minimum_requested_width) {
      this._folded = true;
    } else {
      this._folded = false;
    }
  }

  private void update_view() {
    if (this._box != null) {
      base.remove(this._box);
      this._box.destroy();
      this._box = null;
    }

    if (this._stack != null) {
      base.remove(this._stack);
      this._stack.destroy();
      this._stack = null;
    }

    if (this._folded) {
      this._stack = new Gtk.Stack();
      base.append(this._stack);

      foreach (var child in this.children) {
        if (!child.navigatable) continue;
        this._stack.add_child(child);
      }

    } else {
      this._box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
      base.append(this._box);

      foreach (var child in this.children) {
        this._box.append(child);
      }

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

      if (child_width > largest_width) {
        largest_width = child_width + 72; // 72 is the total padding of the child
      }
    }

    this.minimum_requested_width = largest_width * ((this.children.position (this.children.last ()) - 2)); // -2 is the number of children that are not navigatable
    minimum_requested_width_changed();
  }

  construct {
    this.children_updated.connect(() => {
      update_minimum_requested_width();
      update_view();
    });

    this.minimum_requested_width_changed.connect(() => {
      update_folded();
      update_view();
    });

    window.notify["allocated-width"].connect(() => {
      update_folded();
      update_view();
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
  }
}