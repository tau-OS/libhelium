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
 * An AlbumPage is a widget that holds a single view, for use in an Album.
 */
public class He.AlbumPage : Object {
  public Gtk.Requisition nat;
  public Gtk.Requisition min;
  public Gtk.Allocation alloc;
  public bool visible;
  public Gtk.Widget last_focus;
  public string name;

  /**
   * The child widget of the AlbumPage.
   */
  private Gtk.Widget _child;
  public Gtk.Widget child {
    get {
      return _child;
    }
    set {
      _child = value;
    }
  }

  /**
   * Whether the AlbumPage is navigatable.
   */
  private bool _navigatable;
  public bool navigatable {
    get {
      return _navigatable;
    }
    set {
        if (value == _navigatable)
            return;

        _navigatable = value;
        if (child != null && child.get_parent () != null) {
            He.Album album = ((He.Album) child.get_parent ());
            album.visible_child = null;
        }
    }
  }

  public AlbumPage () {
    navigatable = true;
  }
}

public class He.AlbumPages : Object, GLib.ListModel, Gtk.SelectionModel {
	public He.Album album;

	public uint get_n_items () {
		return album.children.length ();
	}

	public Object? get_item (uint position) {
		Gtk.Widget page;

		page = album.children.nth_data (position).child;

		if (page == null)
		    return null;

		return page;
	}

 	public AlbumPages (He.Album? album) {
 		this.album = album;
 	}

 	public bool is_selected (uint position) {
		He.AlbumPage page;

		page = album.children.nth_data (position);

		return page != null && page == album.visible_child;
 	}

 	public bool select_item (uint position, bool exclusive) {
		He.AlbumPage page;

		page = album.children.nth_data (position);

		album.visible_child = page;

		return true;
 	}

 	public GLib.Type get_item_type () { return typeof(He.AlbumPage); }
 	public Gtk.Bitset get_selection_in_range (uint start, uint end) { return (Gtk.Bitset)null; }
 	public bool select_all () { return false; }
 	public bool select_range (uint start, uint end, bool exclusive) { return false; }
 	public bool set_selection (Gtk.Bitset a, Gtk.Bitset b) { return false; }
 	public bool unselect_all () { return false; }
 	public bool unselect_item (uint position) { return false; }
 	public bool unselect_range (uint start, uint end) { return false; }
}

public enum He.FoldThresholdPolicy {
  MINIMUM,
  NATURAL,
}

/**
* An Album is a helper widget to making an app responsive.
*/
public class He.Album : Gtk.Widget, Gtk.Buildable {
    // for ltr
    public unowned GLib.List<He.AlbumPage> children;
    // For rtl
    public unowned GLib.List<He.AlbumPage> children_reversed;

    private He.AlbumPage _visible_child;
    public He.AlbumPage visible_child {
        get { return _visible_child; }
        set {
            Gtk.Root root;
            Gtk.Widget focus;
            bool contains_focus = false;
            uint old_pos = 0;
            uint new_pos = 0;
            unowned GLib.List<He.AlbumPage> l;

            if (this.in_destruction ())
                return;

            if (value != null) {
                for (l = children; l != null; l = l.next) {
                  He.AlbumPage p = l.data;

                  if (this.get_visible ()) {
                    _visible_child = p;
                    break;
                  }
                }
            }

            if (_visible_child == value)
                return;

            if (pages != null) {
                uint position = 0;

                for (l = children, position = 0; l != null; l = l.next, position++) {
                  He.AlbumPage p = l.data;
                  if (p == value) {
                    old_pos = position;
                  } else if (p == value) {
                    new_pos = position;
                  }
                }
            }

            root = this.get_root ();
            if (root != null) {
                focus = root.get_focus ();
            } else {
                focus = null;
            }

            if (focus != null &&
                value != null &&
                value.child != null &&
                focus.is_ancestor (value.child)) {
                contains_focus = true;
            }

            if (value != null && value.child != null) {
                if (this.is_visible ()) {
                  last_visible_child = value;
                } else {
                  value.child.set_child_visible (!folded);
                }
            }

            _visible_child = value;

            if (value != null) {
                value.child.set_child_visible (true);

                if (contains_focus) {
                  if (value.last_focus != null) {
                    _visible_child.last_focus.grab_focus ();
                  } else {
                    _visible_child.child.child_focus (Gtk.DirectionType.TAB_FORWARD);
                  }
                }
            }

            if (folded) {
                if (homogeneous) {
                  this.queue_allocate ();
                } else {
                  this.queue_resize ();
                }
            }

            if (pages != null) {
                if (old_pos == 0 && new_pos == 0) {
                } else if (old_pos == 0) {
                  pages.selection_changed (new_pos, 1);
                } else if (new_pos == 0) {
                  pages.selection_changed (old_pos, 1);
                } else {
                  pages.selection_changed (uint.min (old_pos, new_pos), uint.max (old_pos, new_pos) - uint.min (old_pos, new_pos) + 1);
                }
            }
        }
    }

    private string _visible_child_name;
    public string visible_child_name {
        get { return _visible_child_name; }
        set {
            He.AlbumPage page;
            bool contains_child;

            page = find_page_for_name (name);
            contains_child = page != null;

            this.visible_child = page;
        }
    }

    public He.AlbumPage last_visible_child;
    public He.AlbumPages pages;
    public He.Animation anime;
    
    private He.FoldThresholdPolicy _fold_threshold_policy;
    public He.FoldThresholdPolicy fold_threshold_policy {
        get { return _fold_threshold_policy; }
        set {
            if (_fold_threshold_policy == value)
                return;

            _fold_threshold_policy = value;

            this.queue_allocate ();
        }
    }

    private bool _folded;
    public bool folded {
        get {
            return _folded;
        }
        set {
            start_mode_transition (folded ? 0.0 : 1.0);

            if (value) {
                this.add_css_class ("folded");
                this.remove_css_class ("unfolded");
                _folded = value;
            } else {
                this.remove_css_class ("folded");
                this.add_css_class ("unfolded");
                _folded = value;
            }
        }
    }

    public bool homogeneous;
    public Gtk.Orientation orientation;
    public He.AnimationTarget target;

    struct ModeTransition {
        public uint duration;

        public double current_pos;
        public double start_progress;
        public double end_progress;

        public He.TimedAnimation animation;
    }

    ModeTransition mode_transition = ModeTransition() {
        duration = 250,
        current_pos = 1.0
    };

    /**
     * The stack of album pages.
     */
    private Gtk.Stack _stack = new Gtk.Stack ();
    public Gtk.Stack stack {
        get { return _stack; }
    }

    /**
     * Whether the album can unfold.
     */
    private bool _can_unfold;
    public bool can_unfold {
        get { return _can_unfold; }
        set {
            if (_can_unfold == value)
                return;

            this.queue_allocate ();
            _can_unfold = value;
        }
    }

    /**
     * Add a child to the album, should only be used in the context of a UI or Blueprint file. There should be no need to use this method in code.
     *
     * @since 1.0
     */
    public new void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
        add_page (((He.AlbumPage) child), children != null ? children.last ().data : null);
    }

    public Album () {
        this.set_overflow (Gtk.Overflow.HIDDEN);
        this.add_css_class ("unfolded");
    }

    construct {
        can_unfold = true;
        homogeneous = true;

        pages = new He.AlbumPages (this);

        target = new He.CallbackAnimationTarget (mode_transition_cb);
		mode_transition.animation = new He.TimedAnimation (this, 0, 1, mode_transition.duration, target);

        fold_threshold_policy = MINIMUM;
        overflow = Gtk.Overflow.HIDDEN;
    }

    public void mode_transition_cb (double value) {
      mode_transition.current_pos = value;

      if (homogeneous) {
        this.queue_allocate ();
      } else {
        this.queue_resize ();
      }
    }

    public void start_mode_transition (double target) {
        mode_transition.animation.skip ();
        mode_transition.animation.from = mode_transition.current_pos;
        mode_transition.animation.to = target;

        if (can_unfold)
            mode_transition.animation.play ();
        else
            mode_transition.animation.skip ();
    }

    public Gtk.PanDirection get_pan_direction (bool new_child_first) {
        if (orientation == Gtk.Orientation.HORIZONTAL) {
            if (this.get_direction () == Gtk.TextDirection.RTL) {
                return new_child_first ? Gtk.PanDirection.LEFT : Gtk.PanDirection.RIGHT;
            } else {
                return new_child_first ? Gtk.PanDirection.RIGHT : Gtk.PanDirection.LEFT;
            }
        } else {
            return new_child_first ? Gtk.PanDirection.DOWN : Gtk.PanDirection.UP;
        }
    }


    public int get_page_size (He.AlbumPage page, Gtk.Orientation orientation) {
        Gtk.Requisition req;

        if (this.fold_threshold_policy == MINIMUM)
            req = page.min;
        else
            req = page.nat;

        return orientation == Gtk.Orientation.HORIZONTAL ? req.width : req.height;
    }

    public int get_child_window_x (He.AlbumPage page, int width) {
        if (page == visible_child)
          return width;

        if (page == last_visible_child)
          return -width;

        return 0;
    }

    public int get_child_window_y (He.AlbumPage page, int height) {
        if (page == visible_child)
          return height;

        if (page == last_visible_child)
          return -height;

        return 0;
    }

    public void update_child_visible (He.AlbumPage page) {
        bool enabled;

        enabled = page.child.get_visible ();

        if (visible_child == null && enabled)
            visible_child = page;
        else if (visible_child == page && !enabled)
            visible_child = null;

        if (page == last_visible_child) {
            last_visible_child.child.set_child_visible (false);
            last_visible_child = null;
        }
    }

    public unowned GLib.List<He.AlbumPage> get_directed_children () {
        return orientation == Gtk.Orientation.HORIZONTAL && this.get_direction () == Gtk.TextDirection.RTL ? children_reversed : children;
    }


    public void size_allocate_folded (int width, int height) {
          unowned GLib.List<He.AlbumPage> directed_children, children;
          He.AlbumPage page, visible_child;
          int start_size, end_size, visible_size;
          int remaining_start_size, remaining_end_size, remaining_size;
          int current_pad;
          int start_position = 0, end_position = 0;
          bool under;
          Gtk.TextDirection direction;

          directed_children = get_directed_children ();
          visible_child = this.visible_child;

          if (visible_child == null)
            return;

          for (children = directed_children; children != null; children = children.next) {
            page = children.data;

            if (page.child == null)
              continue;

            if (page.child == visible_child.child)
              continue;

            if (this.last_visible_child != null &&
                page.child == this.last_visible_child.child)
              continue;

            page.visible = false;
          }

          if (visible_child.child == null)
            return;

          visible_child.visible = true;

          if (this.mode_transition.current_pos <= 0.0) {
            for (children = directed_children; children != null; children = children.next) {
              page = children.data;

              if (page != visible_child &&
                  page != this.last_visible_child) {
                page.visible = false;

                continue;
              }

              page.alloc.x = get_child_window_x (page, width);
              page.alloc.y = get_child_window_y (page, height);
              page.alloc.width = width;
              page.alloc.height = height;
              page.visible = true;
            }

            return;
          }

          visible_size = orientation == Gtk.Orientation.HORIZONTAL ?
            int.min (width,  int.max (get_page_size (visible_child, orientation), (int) (width * (1.0 - this.mode_transition.current_pos)))) :
            int.min (height, int.max (get_page_size (visible_child, orientation), (int) (height * (1.0 - this.mode_transition.current_pos))));

          start_size = 0;
          for (children = directed_children; children != null; children = children.next) {
            page = children.data;

            if (page == visible_child)
              break;

            start_size += get_page_size (page, orientation);
          }

          end_size = 0;
          for (children = directed_children.last (); children != null; children = children.prev) {
            page = children.data;

            if (page == visible_child)
              break;

            end_size += get_page_size (page, orientation);
          }

          remaining_size = orientation == Gtk.Orientation.HORIZONTAL ?
            width - visible_size :
            height - visible_size;
          remaining_start_size = (int) (remaining_size * ((double) start_size / (double) (start_size + end_size)));
          remaining_end_size = remaining_size - remaining_start_size;

          switch (orientation) {
            case Gtk.Orientation.HORIZONTAL:
                direction = this.get_direction ();
                under = (direction == Gtk.TextDirection.RTL) || (direction == Gtk.TextDirection.LTR);
                start_position = under ? 0 : remaining_start_size - start_size;
                mode_transition.start_progress = under ? (double) remaining_size / start_size : 1;
                end_position = under ? width - end_size : remaining_start_size + visible_size;
                mode_transition.end_progress = under ? (double) remaining_end_size / end_size : 1;
                break;
            case Gtk.Orientation.VERTICAL:
                direction = this.get_direction ();
                under = (direction == Gtk.TextDirection.RTL) || (direction == Gtk.TextDirection.LTR);
                start_position = under ? 0 : remaining_start_size - start_size;
                mode_transition.start_progress = under ? (double) remaining_size / start_size : 1;
                end_position = remaining_start_size + visible_size;
                mode_transition.end_progress = under ? (double) remaining_end_size / end_size : 1;
                break;
          }

          if (orientation == Gtk.Orientation.HORIZONTAL) {
            visible_child.alloc.width = visible_size;
            visible_child.alloc.height = height;
            visible_child.alloc.x = remaining_start_size;
            visible_child.alloc.y = 0;
            visible_child.visible = true;
          } else {
            visible_child.alloc.width = width;
            visible_child.alloc.height = visible_size;
            visible_child.alloc.x = 0;
            visible_child.alloc.y = remaining_start_size;
            visible_child.visible = true;
          }

          current_pad = start_position;

          for (children = directed_children; children != null; children = children.next) {
            page = children.data;

            if (page == visible_child)
              break;

            if (orientation == Gtk.Orientation.HORIZONTAL) {
              page.alloc.width = get_page_size (page, orientation);
              page.alloc.height = height;
              page.alloc.x = current_pad;
              page.alloc.y = 0;
              page.visible = page.alloc.x + page.alloc.width > 0;

              current_pad += page.alloc.width;
            }
            else {
              page.alloc.width = width;
              page.alloc.height = get_page_size (page, orientation);
              page.alloc.x = 0;
              page.alloc.y = current_pad;
              page.visible = page.alloc.y + page.alloc.height > 0;

              current_pad += page.alloc.height;
            }
          }

          current_pad = end_position;

          for (children = children.next; children != null; children = children.next) {
            page = children.data;

            if (orientation == Gtk.Orientation.HORIZONTAL) {
              page.alloc.width = get_page_size (page, orientation);
              page.alloc.height = height;
              page.alloc.x = current_pad;
              page.alloc.y = 0;
              page.visible = page.alloc.x < width;

              current_pad += page.alloc.width;
            }
            else {
              page.alloc.width = width;
              page.alloc.height = get_page_size (page, orientation);
              page.alloc.x = 0;
              page.alloc.y = current_pad;
              page.visible = page.alloc.y < height;

              current_pad += page.alloc.height;
            }
          }
    }

    public void size_allocate_unfolded (int width, int height) {
          unowned GLib.List<He.AlbumPage> directed_children, children;
          He.AlbumPage page, visible_child;
          int min_size, extra_size;
          int per_child_extra = 0, n_extra_widgets = 0;
          int n_visible_children, n_expand_children;
          int start_pad = 0, end_pad = 0;
          int i = 0, position = 0;
          bool under;
          Gtk.TextDirection direction;

          visible_child = this.visible_child;

          if (visible_child == null)
            return;

          directed_children = get_directed_children ();

          n_visible_children = n_expand_children = 0;
          for (children = directed_children; children != null; children = children.next) {
            page = children.data;

            page.visible = page.child != null && page.child.get_visible ();

            if (page.visible) {
              n_visible_children++;
              if (page.child.compute_expand (orientation))
                n_expand_children++;
            }
            else {
              page.min.width = page.min.height = 0;
              page.nat.width = page.nat.height = 0;
            }
          }

          Gtk.RequestedSize[] sizes = new Gtk.RequestedSize[n_visible_children];

          min_size = 0;
          if (orientation == Gtk.Orientation.HORIZONTAL) {
            for (children = directed_children; children != null; children = children.next) {
              page = children.data;

              if (!page.visible)
                continue;

              min_size += page.min.width;

              sizes[i].minimum_size = page.min.width;
              sizes[i].natural_size = page.nat.width;
              i++;
            }

            extra_size = int.max (min_size, width);
          } else {
            for (children = directed_children; children != null; children = children.next) {
              page = children.data;

              if (!page.visible)
                continue;

              min_size += page.min.height;

              sizes[i].minimum_size = page.min.height;
              sizes[i].natural_size = page.nat.height;
              i++;
            }

            extra_size = int.max (min_size, height);
          }

          if (extra_size >= 0) {
            extra_size -= min_size;
            extra_size = int.max (0, extra_size);
            extra_size = Gtk.distribute_natural_allocation (extra_size, sizes);
          }

          if (n_expand_children > 0) {
            per_child_extra = extra_size / n_expand_children;
            n_extra_widgets = extra_size % n_expand_children;
          }

          i = 0;
          for (children = directed_children; children != null; children = children.next) {
            int allocated_size;

            page = children.data;

            if (!page.visible)
              continue;

            allocated_size = sizes[i].minimum_size;

            if (page.child.compute_expand (orientation)) {
              allocated_size += per_child_extra;

              if (n_extra_widgets > 0) {
                allocated_size++;
                n_extra_widgets--;
              }
            }

            if (orientation == Gtk.Orientation.HORIZONTAL) {
              page.alloc.x = position;
              page.alloc.y = 0;
              page.alloc.width = allocated_size;
              page.alloc.height = height;
            } else {
              page.alloc.x = 0;
              page.alloc.y = position;
              page.alloc.width = width;
              page.alloc.height = allocated_size;
            }

            position += allocated_size;
            i++;
          }

        if (orientation == Gtk.Orientation.HORIZONTAL) {
            start_pad = (int) ((this.visible_child.alloc.x) * (1.0 - mode_transition.current_pos));
            end_pad = (int) ((width - (this.visible_child.alloc.x + this.visible_child.alloc.width)) * (1.0 - mode_transition.current_pos));
        } else {
            start_pad = (int) ((this.visible_child.alloc.y) * (1.0 - mode_transition.current_pos));
            end_pad = (int) ((height - (this.visible_child.alloc.y + this.visible_child.alloc.height)) * (1.0 - mode_transition.current_pos));
        }

        direction = this.get_direction ();
        under = ((direction == Gtk.TextDirection.LTR) || (direction == Gtk.TextDirection.RTL));

        for (children = directed_children; children != null; children = children.next) {
            page = children.data;

            if (page == visible_child)
              break;

            if (!page.visible)
              continue;

            if (under)
              continue;

            if (orientation == Gtk.Orientation.HORIZONTAL)
              page.alloc.x -= start_pad;
            else
              page.alloc.y -= start_pad;
        }

        mode_transition.start_progress = under ? mode_transition.current_pos : 1;

        under = ((direction == Gtk.TextDirection.LTR) || (direction == Gtk.TextDirection.RTL));

          for (children = directed_children.last(); children != null; children = children.prev) {
            page = children.data;

            if (page == visible_child)
              break;

            if (!page.visible)
              continue;

            if (orientation == Gtk.Orientation.HORIZONTAL)
              page.alloc.x += end_pad;
            else
              page.alloc.y += end_pad;
          }

          visible_child.alloc.x -= start_pad;
          visible_child.alloc.width += start_pad + end_pad;
    }
    public override void measure (Gtk.Orientation orientation, int for_size, out int minimum, out int natural, out int minimum_baseline, out int natural_baseline) {
        int visible_children;
        int child_min, max_min, visible_min, last_visible_min;
        int child_nat, max_nat, sum_nat;
        He.AlbumPage page;
        unowned GLib.List<He.AlbumPage> l;

        visible_children = 0;
        child_min = max_min = visible_min = last_visible_min = 0;
        child_nat = max_nat = sum_nat = 0;
        for (l = children; l != null; l = l.next) {
            page = l.data;
            visible_children++;

            page.child.measure (orientation, for_size, out child_min, out child_nat, null, null);

            max_min = int.max (max_min, child_min);
            max_nat = int.max (max_nat, child_nat);
            sum_nat += child_nat;
        }

        if (visible_child != null)
            visible_child.child.measure (orientation, for_size, out visible_min, null, null, null);
        if (last_visible_child != null)
            visible_child.child.measure (orientation, for_size, out last_visible_min, null, null, null);

        if (minimum != -1) {
            if (homogeneous) {
              minimum = max_min;
            } else {
              minimum = int.parse ("%f".printf(anime.lerp (last_visible_min, visible_min, mode_transition.current_pos)));
              minimum = int.parse ("%f".printf(anime.lerp (minimum, max_min, mode_transition.current_pos)));
            }
        }

        if (natural != -1) {
            if (can_unfold) {
              natural = sum_nat;
            } else {
              natural = max_nat;
            }
        }

        if (minimum_baseline != -1)
            minimum_baseline = -1;
        if (natural_baseline != -1)
            natural_baseline = -1;
    }

    public override void size_allocate (int width, int height, int baseline) {
        He.AlbumPage page;
        unowned GLib.List<He.AlbumPage> l;

        for (l = children; l != null; l = l.next) {
            page = l.data;
            page.child.get_preferred_size (out page.min, out page.nat);
            page.visible = false;
        }

        if (can_unfold) {
            int nat_box_size = 0,
                nat_max_size = 0,
                min_box_size = 0,
                min_max_size = 0,
                visible_children = 0;

            for (l = children; l != null; l = l.next) {
                page = l.data;

                if (page.nat.width <= 0)
                  continue;

                nat_box_size += page.nat.width;
                min_box_size += page.min.width;
                nat_max_size = int.max (nat_max_size, page.nat.width);
                min_max_size = int.max (min_max_size, page.min.width);
                visible_children++;
            }

            if (this.fold_threshold_policy == NATURAL)
                folded = visible_children > 1 && width < nat_box_size;
            else
                folded = visible_children > 1 && width < min_box_size;
        } else {
            folded = true;
        }

        /* Allocate size to the children. */
        if (folded) {
            size_allocate_folded (width, height);
        } else {
            size_allocate_unfolded (width, height);
        }

        /* Apply visibility and allocation. */
        for (l = children; l != null; l = l.next) {
            page = l.data;
            page.child.set_child_visible (page.visible);
            page.child.size_allocate (page.alloc.x, page.alloc.y, baseline);
            page.child.show ();
        }
    }

    public He.AlbumPage get_top_overlap_child () {
        if (last_visible_child == null)
            return visible_child;

 		var direction = this.get_direction ();
 		bool is_rtl = direction == Gtk.TextDirection.RTL;
        bool start = is_rtl;
        return start ? last_visible_child : visible_child;
    }

    public override void snapshot (Gtk.Snapshot snapshot) {
        Gdk.Rectangle shadow_rect = Gdk.Rectangle ();
        bool is_vertical = this.orientation == Gtk.Orientation.VERTICAL;
        bool is_rtl = this.get_direction () == Gtk.TextDirection.RTL;
        He.AlbumPage overlap_child = get_top_overlap_child ();
        He.AlbumPage page;
        unowned GLib.List<He.AlbumPage> l;

        shadow_rect.x = 0;
        shadow_rect.y = 0;
        shadow_rect.width = this.get_width ();
        shadow_rect.height = this.get_height ();

        if (is_vertical) {
            shadow_rect.height = overlap_child.alloc.y;
        } else {
            if (is_rtl) {
              shadow_rect.x = overlap_child.alloc.x + overlap_child.alloc.width;
              shadow_rect.width -= shadow_rect.x;
            } else {
              shadow_rect.width = overlap_child.alloc.x;
            }
        }

        snapshot.push_clip (Graphene.Rect ().init (shadow_rect.x,
                                                   shadow_rect.y,
                                                   shadow_rect.width,
                                                   shadow_rect.height));

        for (l = children; l != null; l = l.next) {
            page = l.data;
            if (page == overlap_child) {
                snapshot.pop ();

                if (is_vertical) {
                    shadow_rect.y = overlap_child.alloc.y;
                    shadow_rect.height = this.get_height () - shadow_rect.y;
                } else {
                    if (is_rtl) {
                      shadow_rect.width = shadow_rect.x;
                      shadow_rect.x = 0;
                    } else {
                      shadow_rect.x = overlap_child.alloc.x;
                      shadow_rect.width = this.get_width () - shadow_rect.x;
                    }
                }

                snapshot.push_clip (Graphene.Rect ().init (shadow_rect.x,
                                                           shadow_rect.y,
                                                           shadow_rect.width,
                                                           shadow_rect.height));
            }
            this.snapshot_child (page.child, snapshot);
        }

        snapshot.pop ();
    }

    public void add_page (He.AlbumPage? page, He.AlbumPage? sibling_page) {
        if (sibling_page == null) {
            children.prepend (page);
            children_reversed.append (page);
        } else {
            int sibling_pos = children.index (sibling_page);
            uint length = children.length ();

            children.insert (page, sibling_pos + 1);
            children_reversed.insert (page, ((int)length) - sibling_pos - 1);
        }

        page.child.insert_after (this, sibling_page.child);

        if (pages != null) {
            int position = children.index (page);

            pages.items_changed (position, 0, 1);
        }

        page.child.notify["visible"].connect (child_visibility_notify_cb);

        if (visible_child == null && page.child.get_visible ())
            this.visible_child = page;

        if (!folded || homogeneous || visible_child == page)
            this.queue_resize ();
    }

    public void child_visibility_notify_cb (Object obj, ParamSpec pspec) {
        He.AlbumPage page;
        Gtk.Widget child = ((Gtk.Widget) obj);
        page = find_page_for_widget (child);
        update_child_visible (page);
    }

    public He.AlbumPage find_page_for_widget (Gtk.Widget? widget) {
        He.AlbumPage page;
        unowned GLib.List<He.AlbumPage> l;

        for (l = children; l != null; l = l.next) {
            page = l.data;

            if (page.child == widget)
                return page;
        }

        return (He.AlbumPage)null;
    }

     public He.AlbumPage find_page_for_name (string? name) {
        He.AlbumPage page;
        unowned GLib.List<He.AlbumPage> l;

        for (l = children; l != null; l = l.next) {
            page = l.data;

            if (GLib.strcmp (page.name, name) == 0)
                return page;
        }

        return (He.AlbumPage)null;
    }

}
