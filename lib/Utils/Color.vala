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
    // Colors used for cards or elements atop the bg when Harsh Dark Mode.
    private const RGBColor HARSH_CARD_BLACK = {
        0,
        0,
        0
    };

    // Colors used for cards or elements atop the bg when Medium Dark Mode.
    private const RGBColor CARD_BLACK = {
        12,
        12,
        12
    };

    // Colors used for cards or elements atop the bg when Soft Dark Mode.
    private const RGBColor SOFT_CARD_BLACK = {
        24,
        24,
        24
    };

    private const RGBColor CARD_WHITE = {
        255,
        255,
        255
    };

    private const double LSTAR = 49.6;
}
