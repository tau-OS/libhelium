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
public class He.DefaultScheme : Object {
    /**
     * The default theme
     */
    public DynamicScheme generate (HCTColor hct, bool is_dark, double contrast) {
        return new DynamicScheme (
                                  hct,
                                  SchemeVariant.DEFAULT,
                                  is_dark,
                                  contrast,
                                  TonalPalette.from_hue_and_chroma (hct.h, 36.0),
                                  TonalPalette.from_hue_and_chroma (hct.h, 16.0),
                                  TonalPalette.from_hue_and_chroma (MathUtils.sanitize_degrees (hct.h + 60.0), 24.0),
                                  TonalPalette.from_hue_and_chroma (hct.h, 6.0),
                                  TonalPalette.from_hue_and_chroma (hct.h, 8.0),
                                  null
        );
    }
}