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
  /**
   * The child widget of the AlbumPage.
   */
  private Gtk.Widget _child;
  public Gtk.Widget child {
    get {
      return _child;
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
            if (this == album.visible_child) {
                album.set_visible_child (null);
            }
        }
    }
  }
  
  public AlbumPage () {
    navigatable = true;
  }
  
  ~AlbumPage () {
    child.unparent ();
    this.unparent ();
  }
}
