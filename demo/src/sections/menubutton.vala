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
[GtkTemplate (ui = "/com/fyralabs/Helium1/Demo/menubutton.ui")]
public class Demo.MenuButton : He.Bin {
    [GtkChild]
    private unowned He.MenuButton default_menu;
    [GtkChild]
    private unowned He.MenuButton bubble_menu;
    [GtkChild]
    private unowned He.MenuButton vibrant_menu;

    construct {
        // Setup default style menu
        default_menu.set_layout({
            new He.Section(null, {
                new He.Item("New Document", "app.new", "document-new-symbolic", "Ctrl+N"),
                new He.Item("Open...", "app.open", "document-open-symbolic", "Ctrl+O"),
                new He.Item("Save", "app.save", "document-save-symbolic", "Ctrl+S")
            }),
            new He.Section("Recent Files", {
                new He.Item.detail("project.vala", "~/Projects/demo", null, "text-x-generic-symbolic"),
                new He.Item.detail("notes.txt", "~/Documents", null, "text-x-generic-symbolic")
            }),
            new He.Section(null, {
                new He.Item("Preferences", "app.preferences", "preferences-system-symbolic"),
                new He.Item("About", "app.about", "help-about-symbolic")
            })
        });

        // Setup bubble style menu
        bubble_menu.menu_style = He.MenuStyle.BUBBLE;
        bubble_menu.set_layout({
            new He.Section("Edit", {
                new He.Item("Cut", "app.cut", "edit-cut-symbolic", "Ctrl+X"),
                new He.Item("Copy", "app.copy", "edit-copy-symbolic", "Ctrl+C"),
                new He.Item("Paste", "app.paste", "edit-paste-symbolic", "Ctrl+V")
            }),
            new He.Section("Format", {
                new He.Item("Bold", "app.bold", "format-text-bold-symbolic", "Ctrl+B"),
                new He.Item("Italic", "app.italic", "format-text-italic-symbolic", "Ctrl+I"),
                new He.Item("Underline", "app.underline", "format-text-underline-symbolic", "Ctrl+U")
            })
        });

        // Setup vibrant style menu
        vibrant_menu.visual_style = He.MenuVisual.VIBRANT;
        vibrant_menu.set_layout({
            new He.Section(null, {
                new He.Item("Share", "app.share", "emblem-shared-symbolic"),
                new He.Item("Export", "app.export", "document-export-symbolic"),
                new He.Item("Print", "app.print", "printer-symbolic", "Ctrl+P")
            })
        });
    }
}
