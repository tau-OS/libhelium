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
[CCode (gir_namespace = "He", gir_version = "1", cheader_filename = "libhelium-1.h")]
namespace He.Color {
    // Colors used for cards or elements atop the bg when Medium Dark Mode.
    private const RGBColor CARD_BLACK = {
        12,
        12,
        12
    };

    private const RGBColor CARD_WHITE = {
        255,
        255,
        255
    };

    private const RGBColor DEFAULT_DARK_ACCENT = {
        0.7450 * 255,
        0.6270 * 255,
        0.8590 * 255
    };

    private const RGBColor DEFAULT_LIGHT_ACCENT = {
        0.5490 * 255,
        0.3370 * 255,
        0.7490 * 255
    };

    private const double LSTAR = 49.6;
}
