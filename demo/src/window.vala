/*
* Copyright (c) 2022 Fyra Labs
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
*/
[GtkTemplate (ui = "/co/tauos/Helium1/Demo/window.ui")]
public class Demo.MainWindow : Gtk.ApplicationWindow {
    delegate void HookFunc ();
    public signal void clicked ();

    public SimpleActionGroup actions { get; construct; }
    public const string ACTION_PREFIX = "win.";
    public const string ACTION_ABOUT = "action_about";
    public static Gee.MultiMap<string, string> action_accelerators = new Gee.HashMultiMap<string, string> ();

    private const GLib.ActionEntry[] ACTION_ENTRIES = {
          {ACTION_ABOUT, action_about },
    };

    [GtkChild]
    private unowned Gtk.MenuButton main_menu;

    public He.Application app { get; construct; }
    public MainWindow (He.Application application) {
        GLib.Object (
            application: application,
            app: application,
            icon_name: "libhelium"
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
        app.set_accels_for_action("app.quit", {"<Ctrl>q"});

        var theme = Gtk.IconTheme.get_for_display (Gdk.Display.get_default ());
        theme.add_resource_path ("/co/tauos/Helium1/Demo/");

        var builder = new Gtk.Builder.from_resource ("/co/tauos/Helium1/Demo/menu.ui");
        main_menu.menu_model = (MenuModel)builder.get_object ("menu");

        this.set_size_request (360, 360);
        this.show ();
    }

    public void action_about () {
        const string COPYRIGHT = "Copyright \xc2\xa9 2022 Fyra Labs\n";

        const string? AUTHORS[] = {
            "Lains",
            "Lea",
            null
        };

        Gtk.show_about_dialog (
           this,
           "program-name", "Helium Demo",
           "logo-icon-name", "libhelium",
           "version", Config.VERSION,
           "comments", _("A demo of the tauOS Application Framework."),
           "copyright", COPYRIGHT,
           "authors", AUTHORS,
           "artists", null,
           "license-type", Gtk.License.GPL_3_0,
           "wrap-license", false,
           // TRANSLATORS: 'Name <email@domain.com>' or 'Name https://website.example'
           "translator-credits", _("translator-credits"),
           null
        );
    }
}
