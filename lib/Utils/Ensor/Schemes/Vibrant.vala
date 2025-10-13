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
public class He.VibrantScheme : Object {
    /**
     * A theme with ALL the color
     */
    public DynamicScheme generate (HCTColor hct, bool is_dark, double contrast) {
        double[] SECONDARY_HUES = { 0, 105, 140, 204, 253, 278, 300, 333, 360 };
        double[] TERTIARY_HUES = { 0, 105, 140, 204, 253, 278, 300, 333, 360 };
        double[] NEUTRAL_HUES = { 0, 71, 124, 253, 278, 300, 360 };
        double[] SECONDARY_ROTATIONS = { -160, 155, -100, 96, -96, -156, -165, -160 };
        double[] TERTIARY_ROTATIONS = { -165, 160, -105, 101, -101, -160, -170, -165 };
        double[] NEUTRAL_ROTATIONS = { 10, 0, 10, 0, 10, 0 };
        return new DynamicScheme (
                                  hct,
                                  SchemeVariant.VIBRANT,
                                  is_dark,
                                  contrast,
                                  TonalPalette.from_hue_and_chroma (hct.h, is_dark ? 36.0 : 48.0),
                                  TonalPalette.from_hue_and_chroma (get_rotated_hue (hct, SECONDARY_HUES, SECONDARY_ROTATIONS), is_dark ? 16.0 : 24.0),
                                  TonalPalette.from_hue_and_chroma (get_rotated_hue (hct, TERTIARY_HUES, TERTIARY_ROTATIONS), 48.0),
                                  TonalPalette.from_hue_and_chroma (get_rotated_hue (hct, NEUTRAL_HUES, NEUTRAL_ROTATIONS), is_dark ? (HCTColor.hue_is_yellow (hct.h) ? 6.0 : 14.0) : 18.0),
                                  TonalPalette.from_hue_and_chroma (hct.h, hct.h >= 105 && hct.h < 125 ? 1.6 * 10.0 : 2.3 * 10.0),
                                  null,
                                  SchemePlatform.DESKTOP
        );
    }
}