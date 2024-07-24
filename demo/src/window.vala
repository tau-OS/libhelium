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
    delegate void HookFunc ();
    public signal void clicked ();

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
    [GtkChild]
    private unowned He.FillButton toast_button;
    [GtkChild]
    private unowned He.Toast toast;
    [GtkChild]
    private unowned He.FillButton dialog_button;
    [GtkChild]
    private unowned He.TintButton action;
    [GtkChild]
    private unowned He.Banner banner;
    [GtkChild]
    private unowned He.TintButton action3;
    [GtkChild]
    private unowned He.Banner banner2;
    [GtkChild]
    private unowned He.FillButton ws_button;
    [GtkChild]
    private unowned Gtk.Box extra_box;
    [GtkChild]
    private unowned He.ProgressBar pb;
    [GtkChild]
    private unowned He.Slider sl;
    [GtkChild]
    private unowned He.FillButton bottom_sheet_button;
    [GtkChild]
    private unowned He.BottomSheet sheet;

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

        var theme = Gtk.IconTheme.get_for_display (Gdk.Display.get_default ());
        theme.add_resource_path ("/com/fyralabs/Helium1/Demo/");

        var builder = new Gtk.Builder.from_resource ("/com/fyralabs/Helium1/Demo/menu.ui");
        main_menu.menu_model = (MenuModel)builder.get_object ("menu");

        toast_button.clicked.connect (() => {
            toast.send_notification ();
        });

        sheet.show_sheet = false;
        bottom_sheet_button.clicked.connect (() => {
            sheet.show_sheet = true;
        });

        dialog_button.clicked.connect (() => {
            var p_button = new He.FillButton ("Do It!");
            var s_button = new He.TintButton ("Don't Do It!");

            var dialog = new He.Dialog (
                                true,
                                this,
                                "Title",
                                "An example of info to provide.",
                                "",
                                "dialog-information-symbolic",
                                p_button,
                                s_button
                            );
            dialog.show ();
        });

        action.clicked.connect (() => {
            banner.unparent ();
            banner.destroy ();
        });
        action3.clicked.connect (() => {
            banner2.unparent ();
            banner2.destroy ();
        });

        ws_button.clicked.connect (() => {
            var ws = new He.Window ();
            ws.has_title = true;
            ws.modal = true;
            ws.parent = this;
            ws.resizable = false;
            ws.has_back_button = false;

            var ws_welcome = new He.WelcomeScreen ("Helium Demo", "This is a welcome screen.");

            var button1 = new He.TextButton ("Do thing");
            ((Gtk.Label)button1.get_child ()).xalign = 0;
            var button2 = new He.TextButton ("Don't do thing");
            ((Gtk.Label)button2.get_child ()).xalign = 0;
            var button3 = new He.PillButton ("Open");
            button3.icon = "document-open-symbolic";
            var button4 = new He.PillButton ("New");
            button4.icon = "list-add-symbolic";

            ws_welcome.add_child (builder, ((Gtk.Widget) button1), "action");
            ws_welcome.add_child (builder, ((Gtk.Widget) button2), "action");
            ws_welcome.add_child (builder, ((Gtk.Widget) button3), "action-button");
            ws_welcome.add_child (builder, ((Gtk.Widget) button4), "action-button");
            ws.set_child (ws_welcome);

            ws.present ();
        });

        var switcher = new He.TabSwitcher ();
        switcher.hexpand = true;
        switcher.insert_tab (new He.Tab ("Tab 1", new He.FillButton ("Tab 1")), 0);
        switcher.insert_tab (new He.Tab ("Tab 2", new He.FillButton ("Tab 2")), 1);
        switcher.insert_tab (new He.Tab ("Tab 3", new He.FillButton ("Tab 3")), 2);
        extra_box.append (switcher);

        switcher.new_tab_requested.connect (on_new_tab_requested);

        pb.progressbar.set_fraction (0.25);

        var adj = new Gtk.Adjustment (-1, 0.0, 100.0, 0.1, 0, 0);
        sl.scale.set_adjustment (adj);
        sl.add_mark (25.0, null);
        sl.add_mark (50.0, null);
        sl.add_mark (75.0, null);
    }

    private void on_new_tab_requested () {
        new_tab (Environment.get_home_dir ());
    }

    private He.Tab new_tab (string label) {
        var view = new He.ViewMono ();
        var tab = new He.Tab (label, view);
        return tab;
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
