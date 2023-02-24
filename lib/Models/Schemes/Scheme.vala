/*
* Copyright (c) 2023 Fyra Labs
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/
public class He.Scheme : Object {
    private string _neutral_background_hex = "";
    public string neutral_background_hex {
        get { return _neutral_background_hex; }
        set { _neutral_background_hex = value; }
    }
    private string _neutral_background_variant_hex = "";
    public string neutral_background_variant_hex {
        get { return _neutral_background_variant_hex; }
        set { _neutral_background_variant_hex = value; }
    }
    private string _neutral_foreground_hex = "";
    public string neutral_foreground_hex {
        get { return _neutral_foreground_hex; }
        set { _neutral_foreground_hex = value; }
    }
    private string _neutral_foreground_variant_hex = "";
    public string neutral_foreground_variant_hex {
        get { return _neutral_foreground_variant_hex; }
        set { _neutral_foreground_variant_hex = value; }
    }
    private string _inverse_neutral_background_hex = "";
    public string inverse_neutral_background_hex {
        get { return _inverse_neutral_background_hex; }
        set { _inverse_neutral_background_hex = value; }
    }
    private string _inverse_neutral_foreground_hex = "";
    public string inverse_neutral_foreground_hex {
        get { return _inverse_neutral_foreground_hex; }
        set { _inverse_neutral_foreground_hex = value; }
    }

    private string _primary_hex = "";
    public string primary_hex {
        get { return _primary_hex; }
        set { _primary_hex = value; }
    }
    private string _on_primary_hex = "";
    public string on_primary_hex {
        get { return _on_primary_hex; }
        set { _on_primary_hex = value; }
    }
    private string _primary_container_hex = "";
    public string primary_container_hex {
        get { return _primary_container_hex; }
        set { _primary_container_hex = value; }
    }
    private string _on_primary_container_hex = "";
    public string on_primary_container_hex {
        get { return _on_primary_container_hex; }
        set { _on_primary_container_hex = value; }
    }
    private string _inverse_primary_hex = "";
    public string inverse_primary_hex {
        get { return _inverse_primary_hex; }
        set { _inverse_primary_hex = value; }
    }

    private string _error_hex = "";
    public string error_hex {
        get { return _error_hex; }
        set { _error_hex = value; }
    }
    private string _on_error_hex = "";
    public string on_error_hex {
        get { return _on_error_hex; }
        set { _on_error_hex = value; }
    }
    private string _error_container_hex = "";
    public string error_container_hex {
        get { return _error_container_hex; }
        set { _error_container_hex = value; }
    }
    private string _on_error_container_hex = "";
    public string on_error_container_hex {
        get { return _on_error_container_hex; }
        set { _on_error_container_hex = value; }
    }

    private string _secondary_hex = "";
    public string secondary_hex {
        get { return _secondary_hex; }
        set { _secondary_hex = value; }
    }
    private string _on_secondary_hex = "";
    public string on_secondary_hex {
        get { return _on_secondary_hex; }
        set { _on_secondary_hex = value; }
    }
    private string _secondary_container_hex = "";
    public string secondary_container_hex {
        get { return _secondary_container_hex; }
        set { _secondary_container_hex = value; }
    }
    private string _on_secondary_container_hex = "";
    public string on_secondary_container_hex {
        get { return _on_secondary_container_hex; }
        set { _on_secondary_container_hex = value; }
    }

    private string _tertiary_hex = "";
    public string tertiary_hex {
        get { return _tertiary_hex; }
        set { _tertiary_hex = value; }
    }
    private string _on_tertiary_hex = "";
    public string on_tertiary_hex {
        get { return _on_tertiary_hex; }
        set { _on_tertiary_hex = value; }
    }
    private string _tertiary_container_hex = "";
    public string tertiary_container_hex {
        get { return _tertiary_container_hex; }
        set { _tertiary_container_hex = value; }
    }
    private string _on_tertiary_container_hex = "";
    public string on_tertiary_container_hex {
        get { return _on_tertiary_container_hex; }
        set { _on_tertiary_container_hex = value; }
    }

    private string _outline_hex = "";
    public string outline_hex {
        get { return _outline_hex; }
        set { _outline_hex = value; }
    }
    private string _outline_variant_hex = "";
    public string outline_variant_hex {
        get { return _outline_variant_hex; }
        set { _outline_variant_hex = value; }
    }

    private string _shadow_hex = "";
    public string shadow_hex {
        get { return _shadow_hex; }
        set { _shadow_hex = value; }
    }
    private string _scrim_hex = "";
    public string scrim_hex {
        get { return _scrim_hex; }
        set { _scrim_hex = value; }
    }

    public static double hue = 0.0;
    public static double chroma = 0.0;

    public Scheme (Color.CAM16Color cam16_color, Desktop desktop) {
        hue = cam16_color.h;
        chroma = cam16_color.C;
    }
}