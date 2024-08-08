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
        private double low { get; set; }
        private double normal { get; set; }
        private double medium { get; set; }
        private double high { get; set; }

        public ContrastCurve (double low, double normal, double medium, double high) {
            this.low = low;
            this.normal = normal;
            this.medium = medium;
            this.high = high;
        }

        public double get (double contrast) {
            if (contrast <= 1.0) {
                return this.low;
            } else if (contrast < 2.0) {
                return MathUtils.lerp(this.low, this.normal, (contrast - 1.0) / 1.0);
            } else if (contrast < 3.0) {
                return MathUtils.lerp(this.normal, this.medium, (contrast - 2.0) / 1.0);
            } else if (contrast < 4.0) {
                return MathUtils.lerp(this.medium, this.high, (contrast - 3.0) / 1.0);
            } else {
                return this.high;
            }
        }
    }
}