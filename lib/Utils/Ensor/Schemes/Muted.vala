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
public class He.MutedScheme : Object {
    /**
     * A theme with just a tiny amount of color
     */
    public DynamicScheme generate (HCTColor hct, bool is_dark, double contrast) {
        double[] TERTIARY_HUES = { 0, 38, 105, 161, 204, 278, 333, 360 };
        double[] TERTIARY_ROTATIONS = { -32, 26, 10, -39, 24, -15, -32 };
        return new DynamicScheme (
                                  hct,
                                  SchemeVariant.MUTED,
                                  is_dark,
                                  contrast,
                                  TonalPalette.from_hue_and_chroma (hct.h, hue_is_blue (hct.h) ? 12.0 : 8.0),
                                  TonalPalette.from_hue_and_chroma (hct.h, hue_is_blue (hct.h) ? 6.0 : 4.0),
                                  TonalPalette.from_hue_and_chroma (get_rotated_hue (hct, TERTIARY_HUES, TERTIARY_ROTATIONS), 20.0),
                                  TonalPalette.from_hue_and_chroma (hct.h, 1.4),
                                  TonalPalette.from_hue_and_chroma (hct.h, (1.4 * 2.2)),
                                  null
        );
    }
}