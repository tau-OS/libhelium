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
    public MainWindow (He.Application application) {
        GLib.Object (
            application: application,
            icon_name: Config.APP_ID
        );
    }

    construct {
        var theme = Gtk.IconTheme.get_for_display (Gdk.Display.get_default ());
        theme.add_resource_path ("/co/tauos/Helium1/Demo/");

        this.set_size_request (360, 360);
        this.show ();
    }
}
