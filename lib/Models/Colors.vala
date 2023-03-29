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
 * An enum that maps colors to internal CSS classes as per HIG.
 */
public enum He.Colors {
    NONE = 0,
    RED = 1,
    ORANGE = 2,
    YELLOW = 3,
    GREEN = 4,
    BLUE = 5,
    INDIGO = 6,
    PURPLE = 7,
    PINK = 8,
    MINT = 9,
    BROWN = 10,
    LIGHT = 11,
    DARK = 12;

    /**
     * Returns the CSS class name for the color.
     */
    public string to_css_class () {
        switch (this) {
            case RED:
                return "meson-red";

            case ORANGE:
                return "lepton-orange";

            case YELLOW:
                return "electron-yellow";

            case GREEN:
                return "muon-green";

            case BLUE:
                return "proton-blue";

            case INDIGO:
                return "photon-indigo";

            case PURPLE:
                return "tau-purple";

            case PINK:
                return "fermion-pink";

            case MINT:
                return "baryon-mint";

            case BROWN:
                return "gluon-brown";

            case LIGHT:
                return "neutron-light";

            case DARK:
                return "graviton-dark";

            case NONE:
            default:
                return "";
        }
    }

    /**
     * Returns the color name.
     *
     * @since 1.0
     */
    public string to_string () {
        return this.to_css_class ();
    }
}
