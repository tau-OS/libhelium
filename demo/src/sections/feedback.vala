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
[GtkTemplate (ui = "/com/fyralabs/Helium1/Demo/feedback.ui")]
public class Demo.Feedback : He.Bin {
    [GtkChild]
    private unowned He.Button toast_btn;
    [GtkChild]
    private unowned He.Button toast_action_btn;
    [GtkChild]
    private unowned He.Button dialog_btn;
    [GtkChild]
    private unowned He.Toast toast;
    [GtkChild]
    private unowned He.Toast toast_with_action;

    construct {
        // Simple toast
        toast.label = "This is a simple toast message";

        toast_btn.clicked.connect (() => {
            toast.send_notification ();
        });

        // Toast with action
        toast_with_action.label = "Message sent successfully";
        toast_with_action.default_action = "Undo";
        toast_with_action.action.connect (() => {
            toast.label = "Action undone!";
            toast.send_notification ();
        });

        toast_action_btn.clicked.connect (() => {
            toast_with_action.send_notification ();
        });

        // Dialog
        dialog_btn.clicked.connect (() => {
            var window = (Gtk.Window) this.get_root ();
            var primary = new He.Button (null, "Confirm");
            var secondary = new He.Button (null, "Learn More");

            var dialog = new He.Dialog (
                window,
                "Delete this file?",
                "This action cannot be undone. The file will be permanently removed from your system.",
                "user-trash-symbolic",
                primary,
                secondary
            );

            primary.clicked.connect (() => {
                dialog.hide_dialog ();
                toast.label = "File deleted";
                toast.send_notification ();
            });

            secondary.clicked.connect (() => {
                toast.label = "Opening help...";
                toast.send_notification ();
            });

            dialog.present ();
        });
    }
}
