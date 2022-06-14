/**
* An Album is a helper widget to making an app responsive.
*/
class He.Album : He.Bin, Gtk.Buildable {
  private signal void children_updated();
  private signal void minimum_requested_width_changed();
  
  private uint _tick_callback;
  private int minimum_requested_width = 0;
  
  private GLib.List<He.AlbumPage> children = new GLib.List<He.AlbumPage> ();
  private Gtk.Box _box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
  private Gtk.Stack main_stack = new Gtk.Stack ();
  
  /**
  * The folded state of the album.
  */
  public bool folded { get; set; default = false; }
  
  
  /**
  * The stack of album pages.
  */
  private Gtk.Stack _stack = new Gtk.Stack ();
  public Gtk.Stack stack {
    get { return _stack; }
  }
  
  /**
  * Add a child to the album, should only be used in the context of a UI or Blueprint file. There should be no need to use this method in code.
  */
  public new void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
    this.append((He.AlbumPage) child);
  }
  
  static construct {
    set_layout_manager_type (typeof (Gtk.BoxLayout));
  }
  
  construct {
    this.children_updated.connect(() => {
      update_minimum_requested_width();
    });
    
    this._tick_callback = this.add_tick_callback(() => {
      update_folded();
      
      return true;
    });
    
    this.notify["folded"].connect(() => {
      update_view();
    });
    
    update_view();
    
    update_minimum_requested_width();
    
    main_stack.add_child(this._box);
    main_stack.add_child(this._stack);
    main_stack.set_parent (this);
    
    this.add_css_class ("unfolded");
  }
  
  ~Album() {
    this.remove_tick_callback(this._tick_callback);
    this.main_stack.unparent();
  }
  
  private void update_minimum_requested_width() {
    var res_width = 0;
    var width = this.get_width();
    
    foreach (var child in this.children) {
      int visible_size = int.max (get_page_size (child), (int) (width));
      res_width += visible_size;
    }
    
    this.minimum_requested_width = (res_width + 200);
    
    minimum_requested_width_changed();
  }

  private int get_page_size (Gtk.Widget w) {
    Gtk.Requisition req;
    w.get_preferred_size(out req, null);
    return req.width;
  }
  
  private new void append(He.AlbumPage widget) {
    this.children.append(widget);
    children_updated();
  }
  
  private void update_folded() {
    if (this.get_width() < this.minimum_requested_width) {
      this.folded = true;
    } else {
      this.folded = false;
    }
  }
  
  private void update_view() {
    if (this.folded) {
      main_stack.set_visible_child (_stack);
      foreach (var child in this.children) {
        if (this._box != null) {
          child.unparent ();
        }
        if (child.navigatable) {
          this._stack.add_child(child);
          this._stack.set_visible_child(child);
        }
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
}