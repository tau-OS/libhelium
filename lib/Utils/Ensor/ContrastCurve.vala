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
[CCode (gir_namespace = "He", gir_version = "1", cheader_filename = "libhelium-1.h")]
namespace He {
    public class ContrastCurve {
        private double target { get; set; }
        private double low { get; set; }
        private double normal { get; set; }
        private double medium { get; set; }
        private double high { get; set; }

        public ContrastCurve (double target, double low, double normal, double medium, double high) {
            this.target = target;
            this.low = low;
            this.normal = normal;
            this.medium = medium;
            this.high = high;
        }

        private double _contrast_level;
        public double contrast_level {
            get {
                if (target == 0.0) {
                    return this.low;
                } else if (target == 1.0) {
                    return this.normal;
                } else if (target == 2.0) {
                    return this.medium;
                } else if (target == 3.0) {
                    return this.high;
                } else {
                    return this.normal;
                }
            }
            set {
                _contrast_level = value;
            }
        }
    }
}