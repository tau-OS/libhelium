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
[GtkTemplate (ui = "/com/fyralabs/Helium1/Demo/banner.ui")]
public class Demo.Banner : He.Bin {
    [GtkChild]
    private unowned Gtk.Box banners_box;

    construct {
        // Info Banner
        var info_banner = new He.Banner ("Update Available", "A new version of the app is ready to install.");
        info_banner.style = He.Banner.Style.INFO;
        var info_action = new He.Button (null, "Update");
        info_action.is_tint = true;
        info_banner.add_action_button (info_action);
        banners_box.append (info_banner);

        // Warning Banner
        var warning_banner = new He.Banner ("Low Storage", "Your device is running low on storage space.");
        warning_banner.style = He.Banner.Style.WARNING;
        var warning_action = new He.Button (null, "Manage");
        warning_action.is_tint = true;
        warning_banner.add_action_button (warning_action);
        banners_box.append (warning_banner);

        // Error Banner
        var error_banner = new He.Banner ("Connection Lost", "Unable to connect to the server. Please check your network.");
        error_banner.style = He.Banner.Style.ERROR;
        var error_action = new He.Button (null, "Retry");
        error_action.is_tint = true;
        error_banner.add_action_button (error_action);
        banners_box.append (error_banner);

        // Simple banner without action
        var simple_banner = new He.Banner ("Welcome", "Thanks for trying out this demo application.");
        simple_banner.style = He.Banner.Style.INFO;
        banners_box.append (simple_banner);
    }
}
