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
public class Demo.Application : He.Application {
    private const GLib.ActionEntry APP_ENTRIES[] = {
        { "quit", quit },
    };

    public Application () {
        Object (application_id: Config.APP_ID);
    }

    public static int main (string[] args) {
        var app = new Demo.Application ();
        return app.run (args);
    }

    protected override void startup () {
        Gdk.RGBA accent_color = { 0 };
        accent_color.parse ("#007aff");
        default_accent_color = He.from_gdk_rgba (accent_color);
        override_accent_color = true;

        resource_base_path = "/com/fyralabs/Helium1/Demo";

        base.startup ();

        Bis.init ();

        typeof (Demo.BottomSheet).ensure ();
        typeof (Demo.ContentAwareBin).ensure ();
        typeof (Demo.OverlayButton).ensure ();
        typeof (Demo.Welcome).ensure ();

        add_action_entries (APP_ENTRIES, this);
    }

    protected override void activate () {
        var win = new MainWindow (this);
        win?.present ();
    }
}