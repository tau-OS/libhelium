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
[GtkTemplate (ui = "/com/fyralabs/Helium1/Demo/badges.ui")]
public class Demo.Badges : He.Bin {
    [GtkChild]
    private unowned Gtk.Box badge_box;
    [GtkChild]
    private unowned Gtk.FlowBox modifier_badge_box;

    construct {
        // Badge with dot indicator (no label)
        var badge_dot = new He.Badge ();
        badge_dot.child = new Gtk.Image.from_icon_name ("mail-unread-symbolic") {
            pixel_size = 32
        };
        badge_box.append (badge_dot);

        // Badge with count
        var badge_count = new He.Badge ();
        badge_count.label = "5";
        badge_count.child = new Gtk.Image.from_icon_name ("chat-symbolic") {
            pixel_size = 32
        };
        badge_box.append (badge_count);

        // Badge with larger count
        var badge_large = new He.Badge ();
        badge_large.label = "99+";
        badge_large.child = new Gtk.Image.from_icon_name ("bell-symbolic") {
            pixel_size = 32
        };
        badge_box.append (badge_large);

        // Modifier badges with different colors
        var modifier_red = new He.ModifierBadge ("Error");
        modifier_red.color = He.Colors.RED;
        modifier_badge_box.append (modifier_red);

        var modifier_orange = new He.ModifierBadge ("Warning");
        modifier_orange.color = He.Colors.ORANGE;
        modifier_badge_box.append (modifier_orange);

        var modifier_yellow = new He.ModifierBadge ("Pending");
        modifier_yellow.color = He.Colors.YELLOW;
        modifier_badge_box.append (modifier_yellow);

        var modifier_green = new He.ModifierBadge ("Success");
        modifier_green.color = He.Colors.GREEN;
        modifier_badge_box.append (modifier_green);

        var modifier_blue = new He.ModifierBadge ("Info");
        modifier_blue.color = He.Colors.BLUE;
        modifier_badge_box.append (modifier_blue);

        var modifier_purple = new He.ModifierBadge ("New");
        modifier_purple.color = He.Colors.PURPLE;
        modifier_badge_box.append (modifier_purple);

        // Tinted modifier badges
        var tint_red = new He.ModifierBadge ("Tinted");
        tint_red.color = He.Colors.RED;
        tint_red.tinted = true;
        modifier_badge_box.append (tint_red);

        var tint_green = new He.ModifierBadge ("Tinted");
        tint_green.color = He.Colors.GREEN;
        tint_green.tinted = true;
        modifier_badge_box.append (tint_green);

        var tint_blue = new He.ModifierBadge ("Tinted");
        tint_blue.color = He.Colors.BLUE;
        tint_blue.tinted = true;
        modifier_badge_box.append (tint_blue);
    }
}
