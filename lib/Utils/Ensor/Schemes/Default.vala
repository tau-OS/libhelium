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
        double[] TERTIARY_HUES = { 0, 20, 71, 161, 333, 360 };
        double[] TERTIARY_ROTATIONS = { -40, 48, -32, 40, -32 };
        return new DynamicScheme (
                                  hct,
                                  SchemeVariant.DEFAULT,
                                  is_dark,
                                  contrast,
                                  TonalPalette.from_hue_and_chroma (hct.h, is_dark ? 26.0 : 32.0),
                                  TonalPalette.from_hue_and_chroma (hct.h, 16.0),
                                  TonalPalette.from_hue_and_chroma (get_rotated_hue (hct, TERTIARY_HUES, TERTIARY_ROTATIONS), 32.0),
                                  TonalPalette.from_hue_and_chroma (hct.h, 5.0),
                                  TonalPalette.from_hue_and_chroma (hct.h, (5.0 * 1.7)),
                                  null
        );
    }
}