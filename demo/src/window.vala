/*
* Copyright (c) 2022 Fyra Labs
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
[GtkTemplate (ui = "/com/fyralabs/Helium1/Demo/window.ui")]
public class Demo.MainWindow : He.ApplicationWindow {
    public SimpleActionGroup actions { get; construct; }
    public const string ACTION_PREFIX = "win.";
    public const string ACTION_ABOUT = "action_about";
    public const string ACTION_SETTINGS = "action_settings";
    public static Gee.MultiMap<string, string> action_accelerators = new Gee.HashMultiMap<string, string> ();

    private const GLib.ActionEntry[] ACTION_ENTRIES = {
          {ACTION_ABOUT, action_about },
          {ACTION_SETTINGS, action_settings },
    };

    [GtkChild]
    private unowned Gtk.MenuButton main_menu;

    public He.Application app { get; construct; }
    public MainWindow (He.Application application) {
        GLib.Object (
            application: application,
            app: application,
            icon_name: "com.fyralabs.Helium1.Demo"
        );
    }

    construct {
        // Actions
        actions = new SimpleActionGroup ();
        actions.add_action_entries (ACTION_ENTRIES, this);
        insert_action_group ("win", actions);

        foreach (var action in action_accelerators.get_keys ()) {
            var accels_array = action_accelerators[action].to_array ();
            accels_array += null;

            app.set_accels_for_action (ACTION_PREFIX + action, accels_array);
        }
        app.set_accels_for_action ("app.quit", {"<Ctrl>q"});

        main_menu.get_popover ().has_arrow = false;
    }

    public void action_about () {
        var about = new He.AboutWindow (
            this,
            "Helium Demo",
            "com.fyralabs.Helium1.Demo",
            Config.VERSION,
            "com.fyralabs.Helium1.Demo",
            "https://fyralabs.com",
            "https://fyralabs.com",
            "https://fyralabs.com",
            {"Lains", "Lea"},
            {"Lains", "Lea"},
            2023,
            He.AboutWindow.Licenses.GPLV3,
            He.Colors.NONE
        );
        about.present ();
    }

    public void action_settings () {
        var settings = new Demo.SettingsWindow (this);
        settings.present ();
    }
}
