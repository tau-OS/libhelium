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
[GtkTemplate (ui = "/com/fyralabs/Helium1/Demo/textfields.ui")]
public class Demo.TextFields : He.Bin {
    [GtkChild]
    private unowned He.TextField default_field;
    [GtkChild]
    private unowned He.TextField search_field;
    [GtkChild]
    private unowned He.TextField outline_field;
    [GtkChild]
    private unowned He.TextField validated_field;
    [GtkChild]
    private unowned He.TextField password_field;

    construct {
        // Default text field
        default_field.placeholder_text = "Enter your name";
        default_field.support_text = "This is helper text";

        // Search field
        search_field.is_search = true;
        search_field.placeholder_text = "Search...";

        // Outline styled field
        outline_field.is_outline = true;
        outline_field.placeholder_text = "Outline style";
        outline_field.prefix_icon = "mail-unread-symbolic";

        // Validated email field
        try {
            var email_regex = new Regex ("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$");
            validated_field.regex = email_regex;
        } catch (Error e) {
            warning ("Failed to create regex: %s", e.message);
        }
        validated_field.needs_validation = true;
        validated_field.min_length = 5;
        validated_field.placeholder_text = "Enter email address";
        validated_field.support_text = "Must be a valid email";

        // Password field
        password_field.placeholder_text = "Enter password";
        password_field.visibility = false;
        password_field.support_text = "Your password is hidden";
    }
}
