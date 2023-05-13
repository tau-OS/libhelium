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

/**
* A struct that contains the color scheme of the app.
*/
public struct He.Scheme {
    public string neutral_background_hex;
    public string neutral_background_variant_hex;
    public string neutral_foreground_hex;
    public string neutral_foreground_variant_hex;
    public string inverse_neutral_background_hex;
    public string inverse_neutral_foreground_hex;
    public string primary_hex;
    public string on_primary_hex;
    public string primary_container_hex;
    public string on_primary_container_hex;
    public string inverse_primary_hex;
    public string error_hex;
    public string on_error_hex;
    public string secondary_hex;
    public string on_secondary_hex;
    public string secondary_container_hex;
    public string on_secondary_container_hex;
    public string tertiary_hex;
    public string on_tertiary_hex;
    public string tertiary_container_hex;
    public string on_tertiary_container_hex;
    public string outline_hex;
    public string outline_variant_hex;
    public string shadow_hex;
    public string scrim_hex;
}

/**
* A function that returns a color scheme from a given accent color and a boolean that indicates if dark mode is enabled.
*/
public delegate Scheme He.SchemeFactory (Color.CAM16Color accent, bool is_dark);
