/*
 * Copyright (c) 2024 Fyra Labs
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
[CCode(gir_namespace = "He", gir_version = "1", cheader_filename = "libhelium-1.h")]
namespace He {
    /**
     * Optimized temperature cache that avoids creating 360 HCT colors.
     * Uses direct mathematical calculations for temperature-based operations.
     */
    public class TemperatureCache : Object {
        public HCTColor input { get; set; }

        // Cached values for performance
        private double _input_temp = double.NAN;

        // Temperature formula constants
        // temp = -0.5 + 0.02 * pow(chroma, 1.07) * cos((hue - 50.0) * PI / 180.0)
        // Warmest: hue where cos is max (1.0) -> hue = 50
        // Coldest: hue where cos is min (-1.0) -> hue = 230
        private const double WARMEST_HUE = 50.0;
        private const double COLDEST_HUE = 230.0;

        public TemperatureCache (HCTColor input) {
            this.input = input;
        }

        /**
         * Get analogous colors by dividing the color wheel.
         * Optimized to directly calculate hues without creating 360 HCT colors.
         */
        public List<HCTColor?> analogous (int count = 5, int divisions = 12) {
            List<HCTColor?> analogous_colors = new List<HCTColor?> ();

            if (divisions <= 0) {
                divisions = 12;
            }
            if (count <= 0) {
                count = 5;
            }

            double step = 360.0 / divisions;

            for (int i = 0; i < count; i++) {
                double hue = MathUtils.sanitize_degrees (input.h + i * step);
                // Create HCT directly with the calculated hue, preserving chroma and tone
                HCTColor hct = from_params (hue, input.c, input.t);
                analogous_colors.append (hct);
            }

            return analogous_colors;
        }

        /**
         * Get the complement color (180 degrees opposite on the color wheel).
         */
        public HCTColor get_complement () {
            double complement_hue = MathUtils.sanitize_degrees (input.h + 180.0);
            return from_params (complement_hue, input.c, input.t);
        }

        /**
         * Get the warmest color (hue = 50 degrees gives maximum temperature).
         * Optimized to calculate directly without iteration.
         */
        public HCTColor get_warmest () {
            return from_params (WARMEST_HUE, input.c, input.t);
        }

        /**
         * Get the coldest color (hue = 230 degrees gives minimum temperature).
         * Optimized to calculate directly without iteration.
         */
        public HCTColor get_coldest () {
            return from_params (COLDEST_HUE, input.c, input.t);
        }

        /**
         * Get the temperature of a color.
         * Temperature is calculated from LAB color space.
         */
        public double get_temp (HCTColor hct) {
            return calculate_temp (hct);
        }

        /**
         * Get the input color's relative temperature (0.0 = coldest, 1.0 = warmest).
         */
        public double get_input_relative_temperature () {
            if (_input_temp.is_nan ()) {
                _input_temp = relative_temperature (input);
            }
            return _input_temp;
        }

        /**
         * Calculate relative temperature (0.0 to 1.0 range).
         * Optimized to use direct calculation instead of iterating all hues.
         */
        private double relative_temperature (HCTColor hct) {
            // For a given chroma, the temperature range is determined by the cosine term
            // temp = -0.5 + k * cos(hue_rad)  where k = 0.02 * pow(chroma, 1.07)
            // The range is [-0.5 - k, -0.5 + k]

            double chroma = Math.fmax (0.0, hct.c);
            double k = 0.02 * Math.pow (chroma, 1.07);

            // Avoid division by zero when chroma is 0
            if (k < 1e-10) {
                return 0.5;
            }

            double coldest_temp = -0.5 - k;  // when cos = -1
            double warmest_temp = -0.5 + k;  // when cos = 1
            double range = warmest_temp - coldest_temp;  // = 2k

            double current_temp = calculate_temp (hct);
            return (current_temp - coldest_temp) / range;
        }

        /**
         * Calculate temperature from HCT color using LAB color space.
         */
        private double calculate_temp (HCTColor hct) {
            LABColor lab = lab_from_argb (hct.a);
            double hue = Math.atan2 (lab.b, lab.a) * 180.0 / Math.PI;
            double chroma = Math.sqrt ((lab.a * lab.a) + (lab.b * lab.b));
            chroma = Math.fmax (0.0, chroma);
            return -0.5 + 0.02 * Math.pow (chroma, 1.07) * Math.cos ((hue - 50.0) * Math.PI / 180.0);
        }

        /**
         * Compare temperatures of two colors.
         */
        public int diff_temps (HCTColor a, HCTColor b) {
            return (int) Math.floor (get_temp (a) - get_temp (b));
        }

        /**
         * Get HCT colors sorted by temperature.
         * Note: This is kept for API compatibility but should be avoided for performance.
         * Returns a small set of representative colors instead of all 360.
         */
        public List<HCTColor?> get_hcts_by_temp () {
            List<HCTColor?> hcts = new List<HCTColor?> ();

            // Instead of 360 colors, return a representative set:
            // coldest, input, and warmest (sorted by temperature)
            HCTColor coldest = get_coldest ();
            HCTColor warmest = get_warmest ();

            double input_temp = get_temp (input);
            double coldest_temp = get_temp (coldest);
            double warmest_temp = get_temp (warmest);

            // Sort: coldest first, then input (if between), then warmest
            if (coldest_temp <= warmest_temp) {
                hcts.append (coldest);
                if (input_temp > coldest_temp && input_temp < warmest_temp) {
                    hcts.append (input);
                }
                hcts.append (warmest);
            } else {
                hcts.append (warmest);
                if (input_temp > warmest_temp && input_temp < coldest_temp) {
                    hcts.append (input);
                }
                hcts.append (coldest);
            }

            return hcts;
        }
    }
}
