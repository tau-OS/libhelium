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
 * A helper class to derive Buttons from.
 *
 * @since 1.0
 */
public abstract class He.Button : Gtk.Button, Gtk.Buildable {

    /**
     * The color of the button.
     * @since 1.0
     */
    public abstract He.Colors color { get; set; }

    /**
     * The icon of the Button.
     * @since 1.0
     */
    public string icon {
        set {
            set_icon_name (value);
        }

        owned get {
            return icon_name;
        }
    }
}
