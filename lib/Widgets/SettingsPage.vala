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
 */

/**
 * Auxilary Class for handling the contents of Settings Windows
 */
public class He.SettingsPage : He.Bin, Gtk.Buildable {
    private Gtk.Box box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

    /**
     * The title of this Settings Page. This is used to determine the name shown in the View Switcher.
     */
    public string title {
        get { return _name; }
        set { _name = value; }
    }
    private string _name = null;

    /**
     * Add a child to this page, should only be used in the context of a UI or Blueprint file.
     * There should be no need to use this method in code.
     */
    public override void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
        box.append ((Gtk.Widget) child);
    }

    /**
     * Add a Settings List to this page
     */
    public void add_list (He.SettingsList list) {
        box.append (list);
    }

    /**
     * Create a new Settings Page.
     *
     * @since 1.0
     */
    public SettingsPage (string title) {
        base ();
        this.title = title;
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BoxLayout));
    }

    construct {
        box.set_parent (this);
    }
}