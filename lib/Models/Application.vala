/*
 * Copyright (c) 2022-2025 Fyra Labs
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
 * An application.
 */
public class He.Application : Gtk.Application {
    private He.Desktop desktop = new He.Desktop ();
    private He.StyleManager style_manager = new He.StyleManager ();

    /**
     * A default accent color if the user has not set one.
     */
    private RGBColor? _default_accent_color = null;
    public RGBColor? default_accent_color {
        get { return _default_accent_color; }
        set { _default_accent_color = value; update_style_manager (); accent_color_changed (); }
    }

    /**
     * Whether to override the user's accent color choice. This requires default_accent_color to be set.
     */
    private bool _override_accent_color = false;
    public bool override_accent_color {
        get { return _override_accent_color; }
        set { _override_accent_color = value; update_style_manager (); accent_color_changed (); }
    }

    /**
     * Whether to override the user's dark style choice.
     */
    private bool _override_dark_style = false;
    public bool override_dark_style {
        get { return _override_dark_style; }
        set { _override_dark_style = value; update_style_manager (); }
    }

    /**
     * Whether to override the user's contrast choice.
     */
    private bool _override_contrast = false;
    public bool override_contrast {
        get { return _override_contrast; }
        set { _override_contrast = value; update_style_manager (); }
    }
    /**
     * The chosen contrast mode for the app. Useful if the app requires more/less/fixed contrast than the user choice.
     * Values are: -1.0 = low, 0.0 = default, 0.5 = medium, 1.0 = high.
     * Only works if override_contrast is TRUE.
     */
    private double _default_contrast = 0.0;
    public double default_contrast {
        get { return _default_contrast; }
        set { _default_contrast = value.clamp (-1.0, 1.0); update_style_manager (); }
    }

    /**
     * Sets the scheme variant to use for the application as Content.
     * This is especially useful for applications with their own color needs, such as media apps.
     */
    private bool _is_content = false;
    public bool is_content {
        get { return _is_content; }
        set { _is_content = value; update_style_manager (); accent_color_changed (); }
    }

    /**
     * Sets the scheme variant to use for the application as Monochrome.
     * This is especially useful for applications with their own color needs, such as image apps.
     */
    private bool _is_mono = false;
    public bool is_mono {
        get { return _is_mono; }
        set { _is_mono = value; update_style_manager (); }
    }

    /**
     * Signal emitted when the effective accent color changes.
     */
    public signal void accent_color_changed ();

    /**
     * Gets the effective accent color that should be used for content drawing.
     * When is_content is true and default_accent_color is set, returns the default_accent_color.
     * Otherwise returns the desktop accent color.
     */
    public RGBColor ? get_effective_accent_color () {
        if (is_content && default_accent_color != null) {
            return default_accent_color;
        }
        return desktop.accent_color;
    }

    private void update_style_manager () {
        if (default_accent_color != null && override_accent_color) {
            style_manager.accent_color = default_accent_color;
        } else if (default_accent_color != null && override_accent_color && is_content) {
            style_manager.accent_color = default_accent_color;
            desktop.accent_color = default_accent_color;
        } else if (desktop.accent_color != null) {
            style_manager.accent_color = desktop.accent_color;
        } else {
            style_manager.accent_color = default_accent_color;
        }

        if (is_content) {
            style_manager.scheme_variant = SchemeVariant.CONTENT;
        } else if (is_mono) {
            style_manager.scheme_variant = SchemeVariant.MONOCHROME;
        } else {
            style_manager.scheme_variant = desktop.ensor_scheme.to_variant ();
        }

        if (override_dark_style) {
            style_manager.is_dark = true;
        } else {
            style_manager.is_dark = desktop.prefers_color_scheme == Desktop.ColorScheme.DARK;
        }

        if (override_contrast) {
            style_manager.contrast = default_contrast;
        } else {
            style_manager.contrast = desktop.contrast;
        }

        style_manager.font_weight = desktop.font_weight;
        style_manager.roundness = desktop.roundness;
        style_manager.update ();
    }

    private void init_app_styles () {
        var base_path = get_resource_base_path ();
        if (base_path == null) {
            return;
        }

        string base_uri = "resource://" + base_path;
        File base_file = File.new_for_uri (base_uri);

        Misc.init_css_provider_from_file (style_manager.user_base, base_file.get_child ("style.css"));
        Misc.init_css_provider_from_file (style_manager.user_dark, base_file.get_child ("style-dark.css"));
    }

    protected override void startup () {
        He.init ();

        init_app_styles ();
        update_style_manager ();

        desktop.notify["accent-color"].connect (() => {
            update_style_manager ();
            accent_color_changed ();
        });
        desktop.notify["ensor-scheme"].connect (update_style_manager);
        desktop.notify["font-weight"].connect (update_style_manager);
        desktop.notify["prefers-color-scheme"].connect (update_style_manager);
        desktop.notify["contrast"].connect (update_style_manager);
        desktop.notify["roundness"].connect (update_style_manager);

        style_manager.register ();
        base.startup ();
    }

    /**
     * Creates a new application.
     *
     * @param application_id The application ID in reverse domain name notation
     * @param flags The application flags, as defined in GIO.ApplicationFlags
     */
    public Application (string? application_id, ApplicationFlags flags) {
        this.application_id = application_id;
        this.flags = flags;
    }
}
