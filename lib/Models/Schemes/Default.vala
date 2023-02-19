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
[CCode (gir_namespace = "He", gir_version = "1", cheader_filename = "libhelium-1.h")]
public class He.Schemes.Default : Object {
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

    public Default (Color.CAM16Color cam16_color, Desktop desktop) {
        // _  _ ____ _  _ ___ ____ ____ _    
        // |\ | |___ |  |  |  |__/ |__| |    
        // | \| |___ |__|  |  |  \ |  | |___
        neutral_background_hex = Color.hct_to_hex (cam16_color.h, 4.0, Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 10.0 : 99.0);
        neutral_background_variant_hex = Color.hct_to_hex (cam16_color.h, 4.0, Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 30.0 : 90.0);
        neutral_foreground_hex = Color.hct_to_hex (cam16_color.h, 4.0, Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 99.0 : 10.0);
        neutral_foreground_variant_hex = Color.hct_to_hex (cam16_color.h, 4.0, Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 80.0 : 30.0);
        inverse_neutral_background_hex = Color.hct_to_hex (cam16_color.h, 4.0, Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 90.0 : 20.0);
        inverse_neutral_foreground_hex = Color.hct_to_hex (cam16_color.h, 4.0, Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 20.0 : 95.0);
        // ___  ____ _ _  _ ____ ____ _   _ 
        // |__] |__/ | |\/| |__| |__/  \_/  
        // |    |  \ | |  | |  | |  \   | 
        primary_hex = Color.hct_to_hex (cam16_color.h, Math.fmax (cam16_color.C, 48.0), Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 80.0 : 40.0);
        on_primary_hex = Color.hct_to_hex (cam16_color.h, Math.fmax (cam16_color.C, 48.0), Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 20.0 : 100.0);
        primary_container_hex = Color.hct_to_hex (cam16_color.h, Math.fmax (cam16_color.C, 48.0), Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 30.0 : 90.0);
        on_primary_container_hex = Color.hct_to_hex (cam16_color.h, Math.fmax (cam16_color.C, 48.0), Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 90.0 : 10.0);
        inverse_primary_hex = Color.hct_to_hex (cam16_color.h, Math.fmax (cam16_color.C, 48.0), Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 40.0 : 80.0);
        // ____ ____ ____ ____ ____ 
        // |___ |__/ |__/ |  | |__/ 
        // |___ |  \ |  \ |__| |  \
        // Error is a special color, it never should change with hue.
        error_hex = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? "#ffb4ab" : "#ba1a1a";
        on_error_hex = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? "#690005" : "#ffffff";
        error_container_hex = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? "#93000a" : "#ffdad6";
        on_error_container_hex = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? "#ffdad6" : "#410002";
        // ____ ____ ____ ____ _  _ ___  ____ ____ _   _ 
        // [__  |___ |    |  | |\ | |  \ |__| |__/  \_/  
        // ___] |___ |___ |__| | \| |__/ |  | |  \   |
        secondary_hex = Color.hct_to_hex (cam16_color.h, 16.0, Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 80.0 : 40.0);
        on_secondary_hex = Color.hct_to_hex (cam16_color.h, 16.0, Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 20.0 : 100.0);
        secondary_container_hex = Color.hct_to_hex (cam16_color.h, 16.0, Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 30.0 : 90.0);
        on_secondary_container_hex = Color.hct_to_hex (cam16_color.h, 16.0, Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 90.0 : 10.0);
        // ___ ____ ____ ___ _ ____ ____ _   _ 
        //  |  |___ |__/  |  | |__| |__/  \_/  
        //  |  |___ |  \  |  | |  | |  \   |
        var tertiary_hue = (cam16_color.h + 60.0 >= 360) ? (cam16_color.h + 60.0) - 360 : (cam16_color.h + 60.0); // Fix tertiary hue going places it shouldn't.
        tertiary_hex = Color.hct_to_hex (tertiary_hue, 24.0, Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 80.0 : 40.0);
        on_tertiary_hex = Color.hct_to_hex (tertiary_hue, 24.0, Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 20.0 : 100.0);
        tertiary_container_hex = Color.hct_to_hex (tertiary_hue, 24.0, Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 30.0 : 90.0);
        on_tertiary_container_hex = Color.hct_to_hex (tertiary_hue, 24.0, Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 90.0 : 10.0);
        // ____ _  _ ___ _    _ _  _ ____ 
        // |  | |  |  |  |    | |\ | |___ 
        // |__| |__|  |  |___ | | \| |___
        outline_hex = Color.hct_to_hex (cam16_color.h, 8.0, Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 60.0 : 50.0);    
        outline_variant_hex = Color.hct_to_hex (cam16_color.h, 8.0, Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 30.0 : 80.0);

        // ____ _  _ ____ ___  ____ _ _ _ 
        // [__  |__| |__| |  \ |  | | | | 
        // ___] |  | |  | |__/ |__| |_|_|
        shadow_hex = Color.hct_to_hex (cam16_color.h, 4.0, Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 0.0 : 0.0);    
        scrim_hex = Color.hct_to_hex (cam16_color.h, 4.0, Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 0.0 : 0.0);
    }
}