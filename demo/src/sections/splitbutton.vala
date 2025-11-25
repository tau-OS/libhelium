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
[GtkTemplate (ui = "/com/fyralabs/Helium1/Demo/splitbutton.ui")]
public class Demo.SplitButton : He.Bin {
    [GtkChild]
    private unowned Gtk.Box split_box;
    [GtkChild]
    private unowned Gtk.Label action_label;

    construct {
        // Basic SplitButton
        var split_basic = new He.SplitButton ();
        split_basic.icon_name = "document-save-symbolic";
        split_basic.label = "Save";
        split_basic.tooltip_text = "Save document";
        split_basic.menu_tooltip_text = "More save options";
        split_basic.add_menu_item ("Save As...", () => {
            action_label.label = "Action: Save As";
        }, "document-save-as-symbolic");
        split_basic.add_menu_item ("Save a Copy...", () => {
            action_label.label = "Action: Save Copy";
        }, "edit-copy-symbolic");
        split_basic.add_menu_separator ();
        split_basic.add_menu_item ("Export...", () => {
            action_label.label = "Action: Export";
        }, "document-export-symbolic");
        split_basic.clicked.connect (() => {
            action_label.label = "Action: Save";
        });
        split_box.append (split_basic);

        // Medium size SplitButton
        var split_medium = new He.SplitButton.with_config (
            "mail-send-symbolic",
            "Send message",
            "More options",
            He.SplitButtonSize.MEDIUM
        );
        split_medium.label = "Send";
        split_medium.add_menu_item ("Send Later", () => {
            action_label.label = "Action: Send Later";
        });
        split_medium.add_menu_item ("Schedule Send", () => {
            action_label.label = "Action: Schedule";
        });
        split_medium.clicked.connect (() => {
            action_label.label = "Action: Send";
        });
        split_box.append (split_medium);

        // Suggested action SplitButton
        var split_suggested = new He.SplitButton ();
        split_suggested.icon_name = "list-add-symbolic";
        split_suggested.label = "Create";
        split_suggested.set_suggested_action (true);
        split_suggested.add_menu_item ("New File", () => {
            action_label.label = "Action: New File";
        }, "document-new-symbolic");
        split_suggested.add_menu_item ("New Folder", () => {
            action_label.label = "Action: New Folder";
        }, "folder-new-symbolic");
        split_suggested.clicked.connect (() => {
            action_label.label = "Action: Create";
        });
        split_box.append (split_suggested);

        // Destructive action SplitButton
        var split_destructive = new He.SplitButton ();
        split_destructive.icon_name = "user-trash-symbolic";
        split_destructive.label = "Delete";
        split_destructive.set_destructive_action (true);
        split_destructive.add_menu_item ("Move to Trash", () => {
            action_label.label = "Action: Move to Trash";
        });
        split_destructive.add_menu_item ("Delete Permanently", () => {
            action_label.label = "Action: Delete Permanently";
        });
        split_destructive.clicked.connect (() => {
            action_label.label = "Action: Delete";
        });
        split_box.append (split_destructive);
    }
}
