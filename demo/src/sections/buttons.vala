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
[GtkTemplate (ui = "/com/fyralabs/Helium1/Demo/buttons.ui")]
public class Demo.Buttons : He.Bin {
    [GtkChild]
    private unowned Gtk.FlowBox style_box;
    [GtkChild]
    private unowned Gtk.FlowBox color_box;
    [GtkChild]
    private unowned Gtk.FlowBox size_box;

    construct {
        // Button styles
        var fill_btn = new He.Button ("list-add-symbolic", "Fill");
        fill_btn.is_fill = true;
        style_box.append (fill_btn);

        var outline_btn = new He.Button ("list-add-symbolic", "Outline");
        outline_btn.is_outline = true;
        style_box.append (outline_btn);

        var tint_btn = new He.Button ("list-add-symbolic", "Tint");
        tint_btn.is_tint = true;
        style_box.append (tint_btn);

        var textual_btn = new He.Button ("list-add-symbolic", "Textual");
        textual_btn.is_textual = true;
        style_box.append (textual_btn);

        var pill_btn = new He.Button ("list-add-symbolic", "Pill");
        pill_btn.is_pill = true;
        style_box.append (pill_btn);

        var iconic_btn = new He.Button ("star-large-symbolic", "");
        iconic_btn.is_iconic = true;
        style_box.append (iconic_btn);

        var disclosure_btn = new He.Button ("go-next-symbolic", "");
        disclosure_btn.is_disclosure = true;
        style_box.append (disclosure_btn);

        var toggle_btn = new He.Button ("view-pin-symbolic", "Toggle");
        toggle_btn.is_tint = true;
        toggle_btn.toggle_mode = true;
        style_box.append (toggle_btn);

        // Button colors
        var primary_btn = new He.Button (null, "Primary");
        primary_btn.is_fill = true;
        primary_btn.color = He.ButtonColor.PRIMARY;
        color_box.append (primary_btn);

        var secondary_btn = new He.Button (null, "Secondary");
        secondary_btn.is_fill = true;
        secondary_btn.color = He.ButtonColor.SECONDARY;
        color_box.append (secondary_btn);

        var tertiary_btn = new He.Button (null, "Tertiary");
        tertiary_btn.is_fill = true;
        tertiary_btn.color = He.ButtonColor.TERTIARY;
        color_box.append (tertiary_btn);

        var surface_btn = new He.Button (null, "Surface");
        surface_btn.is_fill = true;
        surface_btn.color = He.ButtonColor.SURFACE;
        color_box.append (surface_btn);

        var red_btn = new He.Button (null, "Red");
        red_btn.is_fill = true;
        red_btn.custom_color = He.Colors.RED;
        color_box.append (red_btn);

        var green_btn = new He.Button (null, "Green");
        green_btn.is_fill = true;
        green_btn.custom_color = He.Colors.GREEN;
        color_box.append (green_btn);

        // Button sizes
        var xsmall_btn = new He.Button (null, "XSmall");
        xsmall_btn.is_fill = true;
        xsmall_btn.size = He.ButtonSize.XSMALL;
        xsmall_btn.valign = Gtk.Align.CENTER;
        size_box.append (xsmall_btn);

        var small_btn = new He.Button (null, "Small");
        small_btn.is_fill = true;
        small_btn.size = He.ButtonSize.SMALL;
        small_btn.valign = Gtk.Align.CENTER;
        size_box.append (small_btn);

        var medium_btn = new He.Button (null, "Medium");
        medium_btn.is_fill = true;
        medium_btn.size = He.ButtonSize.MEDIUM;
        medium_btn.valign = Gtk.Align.CENTER;
        size_box.append (medium_btn);

        var large_btn = new He.Button (null, "Large");
        large_btn.is_fill = true;
        large_btn.size = He.ButtonSize.LARGE;
        large_btn.valign = Gtk.Align.CENTER;
        size_box.append (large_btn);
    }
}
