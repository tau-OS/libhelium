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
public class He.MonochromaticScheme : Object {
    /**
     * A theme with no colors
     */
    public DynamicScheme generate (HCTColor hct, bool is_dark, double contrast) {
        return new DynamicScheme (
                                  hct,
                                  SchemeVariant.MONOCHROME,
                                  is_dark,
                                  contrast,
                                  TonalPalette.from_hue_and_chroma (hct.h, 0.0),
                                  TonalPalette.from_hue_and_chroma (hct.h, 0.0),
                                  TonalPalette.from_hue_and_chroma (hct.h, 0.0),
                                  TonalPalette.from_hue_and_chroma (hct.h, 0.0),
                                  TonalPalette.from_hue_and_chroma (hct.h, 0.0),
                                  null,
                                  SchemePlatform.DESKTOP
        );
    }
}