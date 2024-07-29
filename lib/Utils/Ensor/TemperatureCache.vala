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
        private He.Color.HCTColor input_color;

        private He.Color.HCTColor? cached_complement;
        private He.Color.HCTColor[] ? cached_hcts_by_temp;
        private double[] cached_temps_by_hct;

        public TemperatureCache(He.Color.HCTColor input_color) {
            this.input_color = input_color;
        }

        public He.Color.HCTColor get_complement() {
            if (cached_complement != null) {
                return cached_complement;
            }

            double coldest_hue = get_hcts_by_temp()[get_coldest_color()].h;
            double coldest_temp = get_temps_by_hct()[get_coldest_color()];

            double warmest_hue = get_hcts_by_temp()[get_warmest_color()].h;
            double warmest_temp = get_temps_by_hct()[get_warmest_color()];
            double temperature_range = warmest_temp - coldest_temp;
            bool is_input_hue_between = is_hue_between(input_color.h, coldest_hue, warmest_hue);
            double start_hue = is_input_hue_between ? warmest_hue : coldest_hue;
            double end_hue = is_input_hue_between ? coldest_hue : warmest_hue;
            double rotation_direction = 1.0;
            double smallest_error = 1000.0;
            int complement_color = (int) Math.round(input_color.h);

            double complement_relative_temp = 1.0 - get_relative_temp(input_color);

            for (double hue_offset = 0.0; hue_offset <= 360.0; hue_offset += 1.0) {
                double current_hue = He.MathUtils.sanitize_degrees(start_hue + rotation_direction * hue_offset);
                if (!is_hue_between(current_hue, start_hue, end_hue)) {
                    continue;
                }
                int candidate_color = (int) Math.round(current_hue);
                double candidate_relative_temp = (get_temps_by_hct()[candidate_color] - coldest_temp) / temperature_range;
                double error = Math.fabs(complement_relative_temp - candidate_relative_temp);
                if (error < smallest_error) {
                    smallest_error = error;
                    complement_color = candidate_color;
                }
            }
            cached_complement = get_hcts_by_temp()[complement_color];
            return cached_complement;
        }

        public He.Color.HCTColor[] get_analogous_colors_simple() {
            return get_analogous_colors(5, 12);
        }

        public He.Color.HCTColor[] get_analogous_colors(int count, int divisions) {
            int initial_hue = (int) Math.round(input_color.h);
            He.Color.HCTColor initial_color = get_hcts_by_hue()[initial_hue];
            double last_temp = get_relative_temp(initial_color);

            He.Color.HCTColor[] all_colors = {};
            all_colors += initial_color;

            double total_temp_variation = 0.0;
            for (int i = 0; i < 360; i++) {
                int current_hue = He.MathUtils.sanitize_degrees_int(initial_hue + i);
                He.Color.HCTColor current_color = get_hcts_by_hue()[current_hue];
                double current_temp = get_relative_temp(current_color);
                double temp_difference = Math.fabs(current_temp - last_temp);
                last_temp = current_temp;
                total_temp_variation += temp_difference;
            }

            int hue_increment = 1;
            double temp_step = total_temp_variation / (double) divisions;
            double accumulated_temp_variation = 0.0;
            last_temp = get_relative_temp(initial_color);
            while (all_colors.length < divisions) {
                int current_hue = He.MathUtils.sanitize_degrees_int(initial_hue + hue_increment);
                He.Color.HCTColor current_color = get_hcts_by_hue()[current_hue];
                double current_temp = get_relative_temp(current_color);
                double temp_difference = Math.fabs(current_temp - last_temp);
                accumulated_temp_variation += temp_difference;

                double required_temp_variation_for_index = all_colors.length * temp_step;
                bool is_index_satisfied = accumulated_temp_variation >= required_temp_variation_for_index;
                int index_increment = 1;

                while (is_index_satisfied && all_colors.length < divisions) {
                    all_colors += current_color;
                    required_temp_variation_for_index = (all_colors.length + index_increment) * temp_step;
                    is_index_satisfied = accumulated_temp_variation >= required_temp_variation_for_index;
                    index_increment++;
                }
                last_temp = current_temp;
                hue_increment++;

                if (hue_increment > 360) {
                    while (all_colors.length < divisions) {
                        all_colors += current_color;
                    }
                    break;
                }
            }

            He.Color.HCTColor[] answers = {};
            answers += input_color;

            int ccw_count = (int) Math.floor((count - 1.0) / 2.0);
            for (int i = 1; i <= ccw_count; i++) {
                int index = -i;
                while (index < 0) {
                    index = all_colors.length + index;
                }
                if (index >= all_colors.length) {
                    index = index % all_colors.length;
                }
                answers += all_colors[index];
            }

            int cw_count = count - ccw_count - 1;
            for (int i = 1; i <= cw_count; i++) {
                int index = i;
                while (index < 0) {
                    index = all_colors.length + index;
                }
                if (index >= all_colors.length) {
                    index = index % all_colors.length;
                }
                answers += all_colors[index];
            }

            return answers;
        }

        public double get_relative_temp(He.Color.HCTColor color) {
            var color_index = (int) Math.round(color.h);
            double temperature_range = get_temps_by_hct()[get_warmest_color()] - get_temps_by_hct()[get_coldest_color()];
            double temp_difference_from_coldest = get_temps_by_hct()[color_index] - get_temps_by_hct()[get_coldest_color()];

            if (temperature_range == 0.0) {
                return 0.5;
            }
            return temp_difference_from_coldest / temperature_range;
        }

        public static double raw_temp(He.Color.HCTColor color) {
            He.Color.LABColor lab = He.Color.lab_from_argb(color.a);
            double hue = He.MathUtils.sanitize_degrees(He.MathUtils.to_degrees(Math.atan2(lab.b, lab.a)));
            double chroma = Math.hypot(lab.a, lab.b);
            return -0.5 + 0.02 * Math.pow(chroma, 1.07) * Math.cos(He.MathUtils.to_radians(He.MathUtils.sanitize_degrees(hue - 50.0)));
        }

        private int get_coldest_color() {
            return 0;
        }

        private int get_warmest_color() {
            return get_hcts_by_temp().length - 1;
        }

        private static bool is_hue_between(double angle, double lower_bound, double upper_bound) {
            if (lower_bound < upper_bound) {
                return lower_bound <= angle && angle <= upper_bound;
            }
            return lower_bound <= angle || angle <= upper_bound;
        }

        private He.Color.HCTColor[] get_hcts_by_hue() {
            He.Color.HCTColor[] hcts = {};
            for (double hue = 0.0; hue <= 360.0; hue += 1.0) {
                He.Color.HCTColor color_at_hue = { hue, input_color.c, input_color.t };
                hcts += (color_at_hue);
            }
            return hcts;
        }

        private He.Color.HCTColor[] get_hcts_by_temp() {
            if (cached_hcts_by_temp != null) {
                return cached_hcts_by_temp;
            }

            He.Color.HCTColor[] hcts = {};
            for (double hue = 0.0; hue <= 360.0; hue += 1.0) {
                He.Color.HCTColor color_at_hue = { hue, input_color.c, input_color.t };
                hcts += color_at_hue;
            }
            sort_hcts(hcts, true);
            hcts += input_color;

            cached_hcts_by_temp = hcts;
            return cached_hcts_by_temp;
        }

        private double[] get_temps_by_hct() {
            if (cached_temps_by_hct != null) {
                return cached_temps_by_hct;
            }

            double[] temps_by_hct = {};
            var hcts = get_hcts_by_hue();
            foreach (var color in hcts) {
                temps_by_hct += raw_temp(color);
            }
            sort(temps_by_hct, true);
            cached_temps_by_hct = temps_by_hct;
            return cached_temps_by_hct;
        }

        private double[] sort(double[] array, bool ascending) {
            double temp;
            bool swapped;

            for (int i = 0; i < array.length - 1; i++) {
                swapped = false;

                for (int j = 0; j < array.length - i - 1; j++) {
                    if (ascending) {
                        if (array[j] > array[j + 1]) {
                            // Swap array[j] and array[j + 1]
                            temp = array[j];
                            array[j] = array[j + 1];
                            array[j + 1] = temp;
                            swapped = true;
                        }
                    } else {
                        if (array[j] < array[j + 1]) {
                            // Swap array[j] and array[j + 1]
                            temp = array[j];
                            array[j] = array[j + 1];
                            array[j + 1] = temp;
                            swapped = true;
                        }
                    }
                }

                // If no two elements were swapped in the inner loop, then the array is already sorted
                if (!swapped) {
                    break;
                }
            }

            return array;
        }

        private He.Color.HCTColor[] sort_hcts(He.Color.HCTColor[] array, bool ascending) {
            double temp;
            bool swapped;

            for (int i = 0; i < array.length - 1; i++) {
                swapped = false;

                for (int j = 0; j < array.length - i - 1; j++) {
                    if (ascending) {
                        if (array[j].h > array[j + 1].h) {
                            // Swap array[j] and array[j + 1]
                            temp = array[j].h;
                            array[j].h = array[j + 1].h;
                            array[j + 1].h = temp;
                            swapped = true;
                        }
                    } else {
                        if (array[j].h < array[j + 1].h) {
                            // Swap array[j] and array[j + 1]
                            temp = array[j].h;
                            array[j].h = array[j + 1].h;
                            array[j + 1].h = temp;
                            swapped = true;
                        }
                    }
                }

                // If no two elements were swapped in the inner loop, then the array is already sorted
                if (!swapped) {
                    break;
                }
            }

            return array;
        }
    }
}