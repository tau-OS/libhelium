/*
 * Copyright (c) 2023 Fyra Labs
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
public class He.ContentScheme : DynamicScheme {
    /**
     * A theme in which the primary color does not shift.
     * Useful for content such as Album Art, Images, etc. suppling color for UI.
     */
    public ContentScheme (HCTColor hct, bool is_dark, double contrast) {
        base (
              hct,
              SchemeVariant.CONTENT,
              is_dark,
              contrast,
              TonalPalette.from_hue_and_chroma (hct.h, hct.c),
              TonalPalette.from_hue_and_chroma (hct.h, Math.fmax (hct.c - 32.0, hct.c * 0.5)),
              TonalPalette.from_hct (fix_disliked (new TemperatureCache (hct).analogous (3, 6).nth_data (2))),
              TonalPalette.from_hue_and_chroma (hct.h, hct.c / 8.0),
              TonalPalette.from_hue_and_chroma (hct.h, (hct.c / 8.0) + 4.0),
              null
        );
    }
}
