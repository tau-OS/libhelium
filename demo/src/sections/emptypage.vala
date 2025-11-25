/*
 * Copyright (c) 2024 Fyra Labs
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA
 *
 */
[GtkTemplate (ui = "/com/fyralabs/Helium1/Demo/emptypage.ui")]
public class Demo.EmptyPage : He.Bin {
    [GtkChild]
    private unowned Gtk.Box empty_box;
    [GtkChild]
    private unowned He.Button show_btn;
    [GtkChild]
    private unowned He.Button hide_btn;

    private He.EmptyPage empty_page;

    construct {
        // Empty Page with action button
        empty_page = new He.EmptyPage ();
        empty_page.icon = "folder-symbolic";
        empty_page.title = "No Files Found";
        empty_page.description = "This folder is empty. Add some files to get started.";
        empty_page.button = "Add Files";
        empty_page.visible = true;
        empty_page.action_button.clicked.connect (() => {
            empty_page.title = "Action Triggered!";
            empty_page.description = "You clicked the action button. In a real app, this would open a file picker.";
        });
        empty_box.append (empty_page);

        // Show/hide controls
        show_btn.clicked.connect (() => {
            empty_page.visible = true;
            empty_page.title = "No Files Found";
            empty_page.description = "This folder is empty. Add some files to get started.";
        });

        hide_btn.clicked.connect (() => {
            empty_page.visible = false;
        });
    }
}
