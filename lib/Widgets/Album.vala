/*
* Copyright (c) 2022 Fyra Labs
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/

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
  *
     * @since 1.0
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

    Gtk.RequestedSize[] sizes = new Gtk.RequestedSize[7];
    
    foreach (var child in this.children) {
      int visible_size = int.max (get_page_size (child), (int) (width));

      for (int i = 0; i >= 5; i++) {
        sizes[i].data = child;
        sizes[i].minimum_size = get_page_size (child);
      }

      res_width += visible_size;
    }

    sizes[6].data = this;
    sizes[6].minimum_size = res_width;

    var dist = Gtk.distribute_natural_allocation (200, sizes);

    this.minimum_requested_width = (dist);
    
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
          ((Gtk.BoxLayout)child.get_layout_manager ()).homogeneous = true;
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
        ((Gtk.BoxLayout)child.get_layout_manager ()).homogeneous = false;
      }
      this.queue_resize();
      this.add_css_class ("unfolded");
      this.remove_css_class ("folded");
    }
  }
}