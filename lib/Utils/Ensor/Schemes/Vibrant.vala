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
public class He.VibrantScheme : DynamicScheme {
    /**
     * A theme with ALL the color
     */
    public VibrantScheme (HCTColor hct, bool is_dark, double contrast) {
        double[] HUES = { 0, 41, 61, 101, 131, 181, 251, 301, 360 };
        double[] SECONDARY_ROTATIONS = { 18, 15, 10, 12, 15, 18, 15, 12, 12 };
        double[] TERTIARY_ROTATIONS = { 35, 30, 20, 25, 30, 35, 30, 25, 25 };
        base (
              hct,
              SchemeVariant.VIBRANT,
              is_dark,
              contrast,
              TonalPalette.from_hue_and_chroma (hct.h, 200.0),
              TonalPalette.from_hue_and_chroma (get_rotated_hue (hct.h, HUES, SECONDARY_ROTATIONS), 24.0),
              TonalPalette.from_hue_and_chroma (get_rotated_hue (hct.h, HUES, TERTIARY_ROTATIONS), 32.0),
              TonalPalette.from_hue_and_chroma (hct.h, 10.0),
              TonalPalette.from_hue_and_chroma (hct.h, 12.0),
              null
        );
    }
}
