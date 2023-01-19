/*
* Copyright (c) 2023 Fyra Labs
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
 * A SegmentedButton is a group of buttons that selects a setting
 * or chooses a view in a small space. Does not work with stacks
 * of less than 2 elements. The developer supplies the stack, and or
 * buttons as child for further coding in their app.
 */
 public class He.SegmentedButton : Gtk.Box {
    /**
     * Adds a widget to SegmentedButton, should only be used in the context of a UI or Blueprint file. There should be no need to use this method in code.
     *
     * @since 1.0
     */
    public void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
        if (type == "segment") {
            ((Gtk.Widget) child).set_parent (this);
        }
    }

    construct {
        this.add_css_class ("segmented-button");
        this.valign = Gtk.Align.CENTER;
    }
}
