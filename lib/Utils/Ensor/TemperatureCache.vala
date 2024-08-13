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
        public HCTColor input { get; set; }
        private Gee.HashMap<HCTColor?, double?> temps_by_hct_cache = new Gee.HashMap<HCTColor?, double?> ();
        private double input_relative_temperature_cache = -1.0;

        public TemperatureCache(HCTColor input) {
            this.input = input;
        }

        public List<HCTColor?> get_hcts_by_temp() {
            List<HCTColor?> hcts = get_hcts_by_hue();
            hcts.append(input);
            hcts.sort_with_data((a, b) => diff_temps(a, b));

            return hcts;
        }

        public int diff_temps(HCTColor a, HCTColor b) {
            return (int) get_temp(a) - (int) get_temp(b);
        }

        public HCTColor get_warmest() {
            return get_hcts_by_temp().last().data;
        }

        public HCTColor get_coldest() {
            return get_hcts_by_temp().first().data;
        }

        public HCTColor get_complement() {
            double complement_hue = (input.h + 180.0) % 360.0;
            return from_params(complement_hue, input.c, input.t);
        }

        public List<HCTColor?> analogous(int count = 5, int divisions = 12) {
            List<HCTColor?> analogous_colors = new List<HCTColor?> ();
            double step = 360.0 / divisions;

            for (int i = 0; i < count; i++) {
                double hue = (input.h + i * step) % 360.0;
                HCTColor? closest_hct = get_closest_hct(hue);
                analogous_colors.append(closest_hct);
            }

            return analogous_colors;
        }
        private HCTColor? get_closest_hct(double hue) {
            HCTColor? closest_hct = null;
            double min_diff = 360.0;

            foreach (HCTColor hct in get_hcts_by_hue()) {
                double diff = Math.fabs(hct.h - hue);
                if (diff < min_diff) {
                    min_diff = diff;
                    closest_hct = hct;
                }
            }

            return closest_hct;
        }

        public double get_input_relative_temperature() {
            if (input_relative_temperature_cache < 0.0) {
                input_relative_temperature_cache = relative_temperature(input);
            }
            return input_relative_temperature_cache;
        }

        private double relative_temperature(HCTColor hct) {
            double coldest_temp = get_temp(get_coldest());
            double warmest_temp = get_temp(get_warmest());
            double range = warmest_temp - coldest_temp;
            return (get_temp(hct) - coldest_temp) / range;
        }

        public double get_temp(HCTColor hct) {
            if (!temps_by_hct_cache.has_key(hct)) {
                temps_by_hct_cache.set(hct, calculate_temp(hct));
            }
            return temps_by_hct_cache.get(hct);
        }

        private List<HCTColor?> get_hcts_by_hue() {
            List<HCTColor?> hcts = new List<HCTColor?> ();
            for (int hue = 0; hue < 360; hue++) {
                hcts.append(from_params(hue, input.c, input.t));
            }
            return hcts;
        }

        private double calculate_temp(HCTColor hct) {
            LABColor lab = lab_from_argb(hct.a);
            double hue = Math.atan2(lab.a, lab.l) * 180.0 / Math.PI;
            double chroma = Math.sqrt((lab.l * lab.l) + (lab.a * lab.a));
            return -0.5 + 0.02 * Math.pow(chroma, 1.07) * Math.cos((hue - 50.0) * Math.PI / 180.0);
        }
    }
}