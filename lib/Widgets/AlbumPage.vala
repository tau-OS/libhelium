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

public interface He.AlbumPageInterface : Gtk.Widget {
  public abstract int min_width { get; set; }
  public abstract bool navigatable { get; set; }
}

/**
 * An AlbumPage is a widget that holds a single view, for use in an Album.
 */
public class He.AlbumPage : Gtk.Widget, Gtk.Buildable, He.AlbumPageInterface {

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
        _child.compute_expand (Gtk.Orientation.HORIZONTAL);
        _child.hexpand = true;
        ((Gtk.BoxLayout)this.get_layout_manager ()).homogeneous = true;
      } else {
        _child.hexpand = false;
        ((Gtk.BoxLayout)this.get_layout_manager ()).homogeneous = false;
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
   *
     * @since 1.0
     */
  public AlbumPage (Gtk.Widget child, int min_width, bool navigatable) {
    this.child = child;
    this.min_width = min_width;
    this.navigatable = navigatable;
  }

  static construct {
    set_layout_manager_type (typeof (Gtk.BoxLayout));
  }
}
