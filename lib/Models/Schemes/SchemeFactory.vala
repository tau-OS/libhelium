/*
 * Copyright (c) 2023-2024 Fyra Labs
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

/**
 * A SchemeFactory is a class which implements a method to generate a
 * Scheme from an accent color and boolean representing whether the
 * scheme is dark or light.
 * Prior runs of the generate method should not affect the output
 * of future runs.
 */
public interface He.SchemeFactory : Object {
  public abstract Scheme generate (CAM16Color accent, bool is_dark, double contrast);
}