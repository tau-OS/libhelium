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
* An Outline button is a transparent FillButton with a border.
*/
public class He.OutlineButton : He.Button {
    private He.Colors _color;

    /**
     * The color of the outline button.
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
    * Creates a new OutlineButton.
    * @param label The label of the button.
    *
     * @since 1.0
     */
    public OutlineButton (string label) {
        this.label = label;
    }

    construct {
        this.add_css_class ("outline-button");
    }
}
