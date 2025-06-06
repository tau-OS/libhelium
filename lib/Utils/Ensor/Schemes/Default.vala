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
        // Use exact baseline relationships regardless of input hue
        double primary_hue = hct.h;
        double secondary_hue = MathUtils.sanitize_degrees (primary_hue - 15.73);
        double tertiary_hue = MathUtils.sanitize_degrees (primary_hue + 28.76);

        var scheme = new DynamicScheme (
                                        hct,
                                        SchemeVariant.DEFAULT,
                                        is_dark,
                                        contrast,
                                        // Primary: Use input chroma, or boost to baseline level
                                        TonalPalette.from_hue_and_chroma (primary_hue, Math.fmax (hct.c, 39.97)),
                                        // Secondary: Fixed chroma for consistency
                                        TonalPalette.from_hue_and_chroma (secondary_hue, 15.96),
                                        null,
                                        // Neutral: Very low chroma
                                        TonalPalette.from_hue_and_chroma (primary_hue, 5.0),
                                        // Neutral Variant: Low chroma
                                        TonalPalette.from_hue_and_chroma (primary_hue, 8.5),
                                        null
        );

        // Tertiary: Relationship-based chroma
        double tertiary_chroma = Math.fmax (hct.c * 1.2, 47.97);
        scheme.tertiary = TonalPalette.from_hue_and_chroma (tertiary_hue, tertiary_chroma);

        return scheme;
    }
}