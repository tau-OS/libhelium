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
 * A helper class for subclassing custom widgets.
 */
public class He.Bin : Gtk.Widget, Gtk.Buildable {
    private Gtk.Box box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

    private Gtk.Widget? _child;
    public Gtk.Widget child {
      get {
        return _child;
      }
      set {
        if (value == _child) {return;}
        _child = value;

        value.set_parent (box);
      }
    }

    /**
    * Add a child to the Bin, should only be used in the context of a UI or Blueprint file. There should be no need to use this method in code.
    */
    public virtual void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
        if (child is Gtk.Widget) {
          box.append ((Gtk.Widget) child);
        } else {
          base.add_child (builder, child, type);
        }
    }

    /**
    * Create a new Bin.
    */
    public Bin () {
    }

    construct {
        box.set_parent (this);
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BoxLayout));
    }

    ~Bin () {
      Gtk.Widget child;

      while ((child = this.get_first_child ()) != null)
        child.unparent ();

      this.unparent ();
    }
}
