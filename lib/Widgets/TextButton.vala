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
 * A TextButton is a button that displays text. It has a transparent background.
 */
public class He.TextButton : He.Button {
    private He.Colors _color;

    /**
     * The color of the button.
     */
    public override He.Colors color {
        set {
            if (_color != He.Colors.NONE) this.remove_css_class (_color.to_css_class ());
            if (value != He.Colors.NONE) this.add_css_class (value.to_css_class ());

            _color = value;
        }

        get {
            return _color;
        }
    }

    /**
     * Creates a new TextButton.
     * @param label The text to display on the button.
     */
    public TextButton (string label) {
        this.label = label;
    }

    /**
     * Creates a new TextButton from an icon.
     * @param icon The icon to display on the button.
     *
     * @since 1.0
     */
    public TextButton.from_icon (string icon) {
        this.icon = icon;
    }

    construct {
        this.add_css_class ("textual-button");
    }
}
