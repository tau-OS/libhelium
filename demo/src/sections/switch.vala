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
[GtkTemplate (ui = "/com/fyralabs/Helium1/Demo/switch.ui")]
public class Demo.Switch : He.Bin {
    [GtkChild]
    private unowned Gtk.Box switch_box;
    [GtkChild]
    private unowned Gtk.Label status_label;

    construct {
        // Primary switch with day/night icons
        var switch_primary = new He.Switch ();
        switch_primary.color = He.SwitchColor.PRIMARY;
        switch_primary.left_icon = "weather-clear-night-symbolic";
        switch_primary.right_icon = "weather-clear-symbolic";
        switch_primary.iswitch.notify["active"].connect (() => {
            update_status (switch_primary.iswitch.active ? "Primary: On" : "Primary: Off");
        });
        switch_box.append (switch_primary);

        // Secondary switch (active by default)
        var switch_secondary = new He.Switch ();
        switch_secondary.color = He.SwitchColor.SECONDARY;
        switch_secondary.iswitch.active = true;
        switch_secondary.iswitch.notify["active"].connect (() => {
            update_status (switch_secondary.iswitch.active ? "Secondary: On" : "Secondary: Off");
        });
        switch_box.append (switch_secondary);

        // Tertiary switch
        var switch_tertiary = new He.Switch ();
        switch_tertiary.color = He.SwitchColor.TERTIARY;
        switch_tertiary.left_icon = "microphone-disabled-symbolic";
        switch_tertiary.right_icon = "microphone-sensitivity-high-symbolic";
        switch_tertiary.iswitch.notify["active"].connect (() => {
            update_status (switch_tertiary.iswitch.active ? "Tertiary: On" : "Tertiary: Off");
        });
        switch_box.append (switch_tertiary);

        // Surface switch (active by default)
        var switch_surface = new He.Switch ();
        switch_surface.color = He.SwitchColor.SURFACE;
        switch_surface.iswitch.active = true;
        switch_surface.left_icon = "notifications-disabled-symbolic";
        switch_surface.right_icon = "preferences-system-notifications-symbolic";
        switch_surface.iswitch.notify["active"].connect (() => {
            update_status (switch_surface.iswitch.active ? "Surface: On" : "Surface: Off");
        });
        switch_box.append (switch_surface);
    }

    private void update_status (string status) {
        status_label.label = status;
    }
}
