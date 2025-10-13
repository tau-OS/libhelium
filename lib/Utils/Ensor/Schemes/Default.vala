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
     * The default theme - Ensor 2025
     */
    public DynamicScheme generate (HCTColor hct, bool is_dark, double contrast) {
        double primary_hue = hct.h;
        double secondary_hue = MathUtils.sanitize_degrees (primary_hue);

        double[] TERTIARY_HUES = { 0.0, 20.0, 71.0, 161.0, 333.0, 360.0 };
        double[] TERTIARY_ROTATIONS = { -40.0, 48.0, -32.0, 40.0, -32.0 };
        double tertiary_hue = MathUtils.sanitize_degrees (get_rotated_hue (hct, TERTIARY_HUES, TERTIARY_ROTATIONS));

        var scheme = new DynamicScheme (
                                        hct,
                                        SchemeVariant.DEFAULT,
                                        is_dark,
                                        contrast,
                                        TonalPalette.from_hue_and_chroma (primary_hue, is_dark ? 26.0 : 32.0),
                                        TonalPalette.from_hue_and_chroma (secondary_hue, 16.0),
                                        null,
                                        TonalPalette.from_hue_and_chroma (primary_hue, 5.0),
                                        TonalPalette.from_hue_and_chroma (primary_hue, 5.0 * 1.7),
                                        null
        );

        double tertiary_chroma = Math.fmax (hct.c * 1.2, is_dark ? 28.0 : 32.0);
        scheme.tertiary = TonalPalette.from_hue_and_chroma (tertiary_hue, tertiary_chroma);

        scheme.platform = SchemePlatform.DESKTOP;

        return scheme;
    }
}