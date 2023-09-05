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
    public string surface_bg_hex;
    public string surface_bg_variant_hex;
    public string surface_fg_hex;
    public string surface_fg_variant_hex;

    public string inverse_surface_bg_hex;
    public string inverse_surface_fg_hex;

    public string surface_bright_bg_hex;
    public string surface_dim_bg_hex;

    public string surface_container_lowest_bg_hex;
    public string surface_container_low_bg_hex;
    public string surface_container_bg_hex;
    public string surface_container_high_bg_hex;
    public string surface_container_highest_bg_hex;

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
