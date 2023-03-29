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
*/

/**
 * Auxilary Class for handling the contents of Tabs
 */
 public class He.TabPage : He.Bin {
    /**
     * The Tab this page is associated with
     */
    public unowned Tab tab {
        get { return _tab; }
        set { _tab = value; }
    }

    private unowned Tab _tab = null;

    He.TabSwitcher tab_switcher {
        get { return (get_parent () as Gtk.Notebook)?.get_parent () as He.TabSwitcher; }
    }

    /**
     * Create a new Tab Page. This should be handled automatically by the Tab generation code.
     *
     * @since 1.0
     */
    public TabPage (Tab tab) {
        Object (
            tab: tab
        );
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BoxLayout));
    }

    ~TabPage () {
        this.get_first_child ().unparent ();
    }
}
