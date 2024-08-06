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
    public class TemperatureCache : Object {
        public He.Color.HCTColor input { get; set; }
        private Gee.HashMap<He.Color.HCTColor?, double?> temps_by_hct_cache = new Gee.HashMap<He.Color.HCTColor?, double?> ();
        private double input_relative_temperature_cache = -1.0;

        public TemperatureCache(He.Color.HCTColor input) {
            this.input = input;
        }

        public List<He.Color.HCTColor?> get_hcts_by_temp() {
            List<He.Color.HCTColor?> hcts = get_hcts_by_hue();
            hcts.append(input);
            hcts.sort_with_data((a, b) => diff_temps(a, b));

            return hcts;
        }

        public int diff_temps(He.Color.HCTColor a, He.Color.HCTColor b) {
            return (int) get_temp(a) - (int) get_temp(b);
        }

        public He.Color.HCTColor get_warmest() {
            return get_hcts_by_temp().last().data;
        }

        public He.Color.HCTColor get_coldest() {
            return get_hcts_by_temp().first().data;
        }

        public He.Color.HCTColor get_complement() {
            double complement_hue = (input.h + 180.0) % 360.0;
            return Color.from_params(complement_hue, input.c, input.t);
        }

        public List<He.Color.HCTColor?> analogous(int count = 5, int divisions = 12) {
            List<He.Color.HCTColor?> all_colors = get_hcts_by_hue();
            double step = 360.0 / divisions;
            List<He.Color.HCTColor?> analogous_colors = new List<He.Color.HCTColor?> ();

            for (int i = 0; i < count; i++) {
                double hue = (input.h + i * step) % 360.0;
                // Find the closest hue from all_colors
                He.Color.HCTColor? closest_hct = null;
                double min_diff = 360.0;
                foreach (He.Color.HCTColor hct in all_colors) {
                    double diff = Math.fabs(hct.h - hue);
                    if (diff < min_diff) {
                        min_diff = diff;
                        closest_hct = hct;
                    }
                }
                analogous_colors.append(closest_hct);
            }

            return analogous_colors;
        }

        public double get_input_relative_temperature() {
            if (input_relative_temperature_cache < 0.0) {
                input_relative_temperature_cache = relative_temperature(input);
            }
            return input_relative_temperature_cache;
        }

        private double relative_temperature(He.Color.HCTColor hct) {
            double coldest_temp = get_temp(get_coldest());
            double warmest_temp = get_temp(get_warmest());
            double range = warmest_temp - coldest_temp;
            return (get_temp(hct) - coldest_temp) / range;
        }

        public double get_temp(He.Color.HCTColor hct) {
            if (!temps_by_hct_cache.has_key(hct)) {
                temps_by_hct_cache.set(hct, calculate_temp(hct));
            }
            return temps_by_hct_cache.get(hct);
        }

        private List<He.Color.HCTColor?> get_hcts_by_hue() {
            List<He.Color.HCTColor?> hcts = new List<He.Color.HCTColor?> ();
            for (int hue = 0; hue < 360; hue++) {
                hcts.append(Color.from_params(hue, input.c, input.t));
            }
            return hcts;
        }

        private double calculate_temp(He.Color.HCTColor hct) {
            He.Color.LABColor lab = Color.lab_from_argb(hct.a);
            double hue = Math.atan2(lab.a, lab.l) * 180.0 / Math.PI;
            double chroma = Math.sqrt((lab.l * lab.l) + (lab.a * lab.a));
            return -0.5 + 0.02 * Math.pow(chroma, 1.07) * Math.cos((hue - 50.0) * Math.PI / 180.0);
        }
    }
}
