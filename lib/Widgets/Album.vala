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
public class He.Album : He.Bin, Gtk.Buildable {
  private signal void children_updated();
  private signal void minimum_requested_width_changed();
  
  private uint _tick_callback;
  private int minimum_requested_width = 0;

  private GLib.List<Gtk.Revealer> children = new GLib.List<Gtk.Revealer>();
  private Gtk.Box _box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

  private int to_finish_unrevealing = 0;

  /**
  * The stack of album pages.
  */
  private Gtk.Stack _stack = new Gtk.Stack ();
  public Gtk.Stack stack {
    get { return _stack; }
  }
  
  /**
  * The folded state of the album.
  */
  public bool folded { get; set; default = false; }

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
    
    _box.set_parent(this);
    
    this.add_css_class ("unfolded");
  }
  
  ~Album() {
    this.remove_tick_callback(this._tick_callback);
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
    var revealer = new Gtk.Revealer();
    revealer.set_child(widget);
    revealer.set_reveal_child(true);
    this._box.append(revealer);
    this.children.append(revealer);
    revealer.notify["child-revealed"].connect(() => {
        if (!revealer.get_reveal_child()) {
            widget.set_visible(false);
            to_finish_unrevealing--;

            if (to_finish_unrevealing == 0) {
                stackify();
            }
        }
    });

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
      Gtk.Revealer visible_child = null;
      foreach (var child in this.children) {
        var page = (He.AlbumPage) child.get_child();

        if (page.navigatable) {
          visible_child = child;
          ((Gtk.BoxLayout)page.get_layout_manager ()).homogeneous = true;
        }
      }

     to_finish_unrevealing = 0;

     var visible_child_index = children.index(visible_child);
     for (var i = 0; i < children.length(); i++) {
        var child = children.nth_data(i);

        if (i == visible_child_index) {
            child.set_transition_type(Gtk.RevealerTransitionType.NONE);
            continue;
        }

        if (i < visible_child_index) {
            child.set_transition_type(Gtk.RevealerTransitionType.SLIDE_RIGHT);
        } else if (i > visible_child_index) {
            child.set_transition_type(Gtk.RevealerTransitionType.SLIDE_LEFT);
        }

        child.set_reveal_child(false);
        to_finish_unrevealing++;
    }

        this.add_css_class ("folded");
        this.remove_css_class ("unfolded");
    } else {
        to_finish_unrevealing = -1;
      var visible_child = (Gtk.Revealer) _stack.get_visible_child();
      var visible_child_index = children.index(visible_child);

          _stack.set_transition_type(Gtk.StackTransitionType.NONE);

            this._stack.unparent();
      this._box.set_parent(this);

     for (var i = 0; i < children.length(); i++) {
        var child = children.nth_data(i);

        child.unparent();

        var page = (He.AlbumPage) child.get_child();
        ((Gtk.BoxLayout)page.get_layout_manager ()).homogeneous = false;
        page.set_visible(false);
        child.set_reveal_child(false);

        this._box.append(child);

        if (i == visible_child_index) {
            child.set_transition_type(Gtk.RevealerTransitionType.NONE);
            page.set_visible(true);
            child.set_reveal_child(true);
        }

        if (i < visible_child_index) {
            child.set_transition_type(Gtk.RevealerTransitionType.SLIDE_LEFT);
        } else if (i > visible_child_index) {
            child.set_transition_type(Gtk.RevealerTransitionType.SLIDE_RIGHT);
        }
     }

     foreach (var child in children) {
        var page = (He.AlbumPage) child.get_child();
        page.set_visible(true);
        child.set_reveal_child(true);
    }

      this.queue_resize();
      this.add_css_class ("unfolded");
      this.remove_css_class ("folded");
    }
  }
  
/**
 * Sets the widget currently visible on the album.
 *
 * @since 1.0
 */
 public void set_visible_child (Gtk.Widget? visible_child) {
 	var page = find_page_for_widget (visible_child);
  	stack.set_visible_child (page);
 }
 
 private He.AlbumPage find_page_for_widget (Gtk.Widget? widget) {
    He.AlbumPage page;
	foreach (var child in this.children) {
		page = (He.AlbumPage) child.get_child();

		if (page.child == widget)
			return page;
	}
	
	return null;
 }

  private void stackify() {

      this._box.unparent();
      this._stack.set_parent(this);

      foreach (var child in this.children) {
        var page = (He.AlbumPage) child.get_child();

        page.set_visible(true);


        child.unparent ();

        child.set_transition_type(Gtk.RevealerTransitionType.NONE);
        child.set_reveal_child(true);

        if (page.navigatable) {
          this._stack.add_child(child);
          this._stack.set_visible_child(child);
          ((Gtk.BoxLayout)page.get_layout_manager ()).homogeneous = true;
        }
      }

          _stack.set_transition_type(Gtk.StackTransitionType.OVER_LEFT_RIGHT);
  }
}
