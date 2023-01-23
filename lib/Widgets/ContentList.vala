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
 * A Content List is a list of content blocks with an optional title and description.
 */
public class He.ContentList : He.Bin, Gtk.Buildable {
    private Gtk.Box text_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);
    private Gtk.ListBox list = new Gtk.ListBox ();
    private Gtk.Label title_label = new Gtk.Label (null);
    private Gtk.Label description_label = new Gtk.Label (null);

    /**
     * A List of all the children of the content list.
     */
     public List<Gtk.Widget> children = new List<Gtk.Widget> ();

    /**
     * The title of the content list.
     */
    public string? title {
        get { return title_label.get_text (); }
        set {
            title_label.set_text (value);
            title_label.set_visible (value != null);
            if (value != null) {
                this.margin_top = 18;
            } else {
                this.margin_top = 0;
            }
        }
    }

    /**
     * The description of the content list.
     */
    public string? description {
        get { return description_label.get_text (); }
        set { 
            description_label.set_text (value); 
            description_label.set_visible (value != null);
        }
    }

    /**
     * Adds a new item to the content list, should only be used in the context of a UI or Blueprint file. There should be no need to use this method in code.
     */
    public new void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
        if (((Gtk.Widget) child).get_type () == typeof (He.ContentBlock)) {
            children.append ((Gtk.Widget) child);
        } else if (((Gtk.Widget) child).get_type () == typeof (He.MiniContentBlock)) {
            children.append ((Gtk.Widget) child);
        } else {
            ((Gtk.Widget) child).set_parent (this);
        }
    }

    /**
     * Adds a new item to the content list.
     * @param child The item to add.
     */
    public void add (Gtk.Widget child) {
        if (child.get_type () == typeof (He.ContentBlock)) {
            children.append (child);
        } else if (child.get_type () == typeof (He.MiniContentBlock)) {
            children.append (child);
        } else {
            child.set_parent (this);
        }
    }

    /**
     * Removes an item from the content list.
     * @param child The item to remove.
     *
     * @since 1.0
     */
    public void remove (Gtk.Widget child) {
        if (child.get_parent () == this) {
            child.unparent ();
        } else if (child.get_parent ().get_parent () == list) {
            children.remove (child);
        }
    }
    
    public ContentList () {
    	base ();
    }

    construct {
        this.title_label.set_visible (false);
        this.description_label.set_visible (false);

        this.title_label.add_css_class ("header");
        this.title_label.xalign = 0;
        this.description_label.add_css_class ("body");
        this.description_label.xalign = 0;

        var layout = new Gtk.BoxLayout (Gtk.Orientation.VERTICAL) {
            spacing = 6,
        };
        this.layout_manager = layout;

        this.text_box.append (title_label);
        this.text_box.append (description_label);

        list.set_selection_mode (Gtk.SelectionMode.NONE);
        list.add_css_class ("content-list");

        Timeout.add(1, () => {
            foreach (var child in this.children) {
                list.append (child);
            }
        });

        text_box.set_parent (this);
        list.set_parent (this);
    }
}
