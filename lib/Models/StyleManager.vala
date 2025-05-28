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
 * A class that manages the style of the application in conjunction with the provided preferences.
 * This is a low-level class that should not be used directly. Instead, let the `He.Application` class manage this for you.
 */
public class He.StyleManager : Object {
    /**
     * The preferred accent color. If null, a default accent color will be chosen based on the color scheme.
     */
    public RGBColor? accent_color = null;

    /**
     * The preferred font weight.
     */
    public double font_weight = 1.0;

    /**
     * The preferred UI roundness.
     */
    public double roundness = 1.0;

    /**
     * Whether to apply styles for dark mode.
     */
    public bool is_dark = false;

    /**
     * Whether to apply styles for contrast modes.
     * -1.0 = low, 0.0 = default, 0.5 = medium, 1.0 = high
     */
    public double contrast = 0.0;

    /**
     * A function that returns a color scheme from a given accent color and whether dark mode is enabled.
     */
    public SchemeVariant? scheme_variant = null;

    /**
     * Whether the style manager has been registered. Unregistered style managers will not apply their styles.
     */
    public bool is_registered { get; private set; default = false; }

    private const int STYLE_PROVIDER_PRIORITY_PLATFORM = Gtk.STYLE_PROVIDER_PRIORITY_THEME;
    private const int STYLE_PROVIDER_PRIORITY_ACCENT = Gtk.STYLE_PROVIDER_PRIORITY_SETTINGS;
    private const int STYLE_PROVIDER_PRIORITY_USER_BASE = Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION;
    private const int STYLE_PROVIDER_PRIORITY_USER_DARK = Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION + 1;

    private Gtk.CssProvider light = new Gtk.CssProvider ();
    private Gtk.CssProvider dark = new Gtk.CssProvider ();
    private Gtk.CssProvider accent = new Gtk.CssProvider ();

    /**
     * The base style provider for application provided styles. In this case user refers to the application, not the user of the application.
     */
    public Gtk.CssProvider user_base { get; default = new Gtk.CssProvider (); }
    /**
     * The dark style provider for application provided styles. This will be applied in addition to the base style provider when dark mode is enabled.
     */
    public Gtk.CssProvider user_dark { get; default = new Gtk.CssProvider (); }

    /**
     * Runs all the necessary updates to apply the current style. If is_registered is false, this will do nothing.
     */
    public void update () {
        if (!is_registered)
            return;

        RGBColor rgb_color = accent_color != null ? accent_color : is_dark ? He.DEFAULT_DARK_ACCENT : He.DEFAULT_LIGHT_ACCENT;

        string css = "";
        if (scheme_variant == SchemeVariant.DEFAULT) {
            RGBColor accent_color = { rgb_color.r* 255, rgb_color.g* 255, rgb_color.b* 255 };
            var hct = hct_from_int (rgb_to_argb_int (accent_color));

            var scheme_factory = new DefaultScheme ();
            css += style_refresh (scheme_factory.generate (hct, is_dark, contrast));
        } else if (scheme_variant == SchemeVariant.MONOCHROME) {
            RGBColor accent_color = { accent_color.r* 255, accent_color.g* 255, accent_color.b* 255 };
            var hct = hct_from_int (rgb_to_argb_int (accent_color));

            var scheme_factory = new MonochromaticScheme ();
            css += style_refresh (scheme_factory.generate (hct, is_dark, contrast));
        } else if (scheme_variant == SchemeVariant.MUTED) {
            RGBColor accent_color = { accent_color.r* 255, accent_color.g* 255, accent_color.b* 255 };
            var hct = hct_from_int (rgb_to_argb_int (accent_color));

            var scheme_factory = new MutedScheme ();
            css += style_refresh (scheme_factory.generate (hct, is_dark, contrast));
        } else if (scheme_variant == SchemeVariant.SALAD) {
            RGBColor accent_color = { accent_color.r* 255, accent_color.g* 255, accent_color.b* 255 };
            var hct = hct_from_int (rgb_to_argb_int (accent_color));

            var scheme_factory = new SaladScheme ();
            css += style_refresh (scheme_factory.generate (hct, is_dark, contrast));
        } else if (scheme_variant == SchemeVariant.VIBRANT) {
            RGBColor accent_color = { accent_color.r* 255, accent_color.g* 255, accent_color.b* 255 };
            var hct = hct_from_int (rgb_to_argb_int (accent_color));

            var scheme_factory = new VibrantScheme ();
            css += style_refresh (scheme_factory.generate (hct, is_dark, contrast));
        } else if (scheme_variant == SchemeVariant.CONTENT) {
            var hct = hct_from_int (rgb_to_argb_int (rgb_color));

            var scheme_factory = new ContentScheme ();
            css += style_refresh (scheme_factory.generate (hct, is_dark, contrast));
        }

        css += weight_refresh (font_weight);
        css += roundness_refresh (roundness);

        Misc.init_css_provider_from_string (accent, css);
        Misc.toggle_style_provider (light, !is_dark, STYLE_PROVIDER_PRIORITY_PLATFORM);
        Misc.toggle_style_provider (dark, is_dark, STYLE_PROVIDER_PRIORITY_PLATFORM);
        Misc.toggle_style_provider (user_dark, is_dark, STYLE_PROVIDER_PRIORITY_USER_DARK);

        var settings = Gtk.Settings.get_default ();
        settings.gtk_application_prefer_dark_theme = is_dark;
    }

    public string style_refresh (DynamicScheme scheme_factory) {
        string css = "";
        css += @"
    @define-color accent_color $(scheme_factory.get_primary());
    @define-color accent_bg_color $(scheme_factory.get_primary());
    @define-color accent_fg_color $(scheme_factory.get_on_primary());
    @define-color accent_container_color $(scheme_factory.get_primary_container());
    @define-color accent_container_bg_color $(scheme_factory.get_primary_container());
    @define-color accent_container_fg_color $(scheme_factory.get_on_primary_container());

    @define-color window_bg_color $(scheme_factory.get_surface());
    @define-color view_bg_color $(scheme_factory.get_surface());
    @define-color headerbar_bg_color $(scheme_factory.get_surface_variant());
    @define-color popover_bg_color $(scheme_factory.get_surface_container_high());
    @define-color card_bg_color $(scheme_factory.get_surface_container());
    @define-color window_fg_color $(scheme_factory.get_on_surface());
    @define-color view_fg_color $(scheme_factory.get_on_surface_variant());
    @define-color headerbar_fg_color $(scheme_factory.get_on_surface_variant());
    @define-color popover_fg_color $(scheme_factory.get_on_surface());
    @define-color card_fg_color $(scheme_factory.get_on_surface());

    @define-color surface_bright_bg_color $(scheme_factory.get_surface_bright());
    @define-color surface_bg_color $(scheme_factory.get_surface());
    @define-color surface_dim_bg_color $(scheme_factory.get_surface_dim());
    @define-color surface_container_lowest_bg_color $(scheme_factory.get_surface_container_lowest());
    @define-color surface_container_low_bg_color $(scheme_factory.get_surface_container_low());
    @define-color surface_container_bg_color $(scheme_factory.get_surface_container());
    @define-color surface_container_high_bg_color $(scheme_factory.get_surface_container_high());
    @define-color surface_container_highest_bg_color $(scheme_factory.get_surface_container_highest());
    ";

        css += @"
    @define-color destructive_bg_color $(scheme_factory.get_error());
    @define-color destructive_fg_color $(scheme_factory.get_on_error());
    @define-color destructive_color $(scheme_factory.get_error());
    @define-color destructive_container_color $(scheme_factory.get_on_error_container());
    @define-color destructive_container_bg_color $(scheme_factory.get_error_container());
    @define-color destructive_container_fg_color $(scheme_factory.get_on_error_container());

    @define-color suggested_bg_color $(scheme_factory.get_secondary());
    @define-color suggested_fg_color $(scheme_factory.get_on_secondary());
    @define-color suggested_color $(scheme_factory.get_secondary());
    @define-color suggested_container_color $(scheme_factory.get_secondary_container());
    @define-color suggested_container_bg_color $(scheme_factory.get_secondary_container());
    @define-color suggested_container_fg_color $(scheme_factory.get_on_secondary_container());

    @define-color error_bg_color $(scheme_factory.get_error());
    @define-color error_fg_color $(scheme_factory.get_on_error());
    @define-color error_color $(scheme_factory.get_error());
    @define-color error_container_color $(scheme_factory.get_on_error_container());
    @define-color error_container_bg_color $(scheme_factory.get_error_container());
    @define-color error_container_fg_color $(scheme_factory.get_on_error_container());

    @define-color success_bg_color $(scheme_factory.get_tertiary());
    @define-color success_fg_color $(scheme_factory.get_on_tertiary());
    @define-color success_color $(scheme_factory.get_tertiary());
    @define-color success_container_color $(scheme_factory.get_tertiary_container());
    @define-color success_container_bg_color $(scheme_factory.get_tertiary_container());
    @define-color success_container_fg_color $(scheme_factory.get_on_tertiary_container());

    @define-color outline $(scheme_factory.get_outline());
    @define-color borders $(scheme_factory.get_outline_variant());
    @define-color shadow $(scheme_factory.get_shadow());
    @define-color scrim $(scheme_factory.get_scrim());
    @define-color osd_bg_color $(scheme_factory.get_inverse_surface());
    @define-color osd_fg_color $(scheme_factory.get_inverse_on_surface());
    @define-color osd_accent_color $(scheme_factory.get_inverse_primary());
    ";

        return css;
    }

    public string weight_refresh (double font_weight) {
        var thin_weight = 200 * font_weight;
        var light_weight = 300 * font_weight;
        var base_weight = 400 * font_weight;
        var medium_weight = 500 * font_weight;
        var heavy_weight = 600 * font_weight;
        var black_weight = 700 * font_weight;

        string css = "";
        css += @"
    label,
    .big-display,
    .view-subtitle,
    .cb-subtitle,
    .body,
    .navigation-rail-button label,
    .navigation-section-button label,
    .navigation-section-list row .mini-content-block label,
    .text-field .placeholder,
    .calendar button label {
      font-weight: $base_weight;
    }
    .thin-body {
        font-weight: $thin_weight;
    }
    .large-title,
    .display,
    .appbar .text-field text,
    .flat-appbar .text-field text,
    .view-switcher button.toggle label {
      font-weight: $light_weight;
    }
    .view-title,
    .view-switcher button.toggle:checked label,
    .view-switcher button.toggle:active label {
        font-weight: $medium_weight;
    }
    .title-1,
    .title-2,
    .title-3,
    .title-4,
    .heading,
    .header,
    .caption,
    .caption-heading,
    .cb-title,
    button label,
    .toast-box button label,
    .navigation-section-list row .mini-content-block label.cb-title,
    .mini-content-block .cb-title,
    .badge label,
    .badge-info label,
    .tint-badge label,
    .modifier-badge label,
    .navigation-rail-button:checked label,
    .navigation-section-button:checked label,
    .calendar button.textual-button label,
    .calendar button.day label {
      font-weight: $heavy_weight;
    }
    .black-text {
      color: $black_weight;
    }
    ";

        return css;
    }

    private string roundness_refresh (double roundness) {
        var base_roundness = roundness != 0 ? 4 * roundness : 0;
        var small_roundness = (0.5 * base_roundness).to_string () + "px";
        var medium_roundness = (1 * base_roundness).to_string () + "px";
        var large_roundness = (2 * base_roundness).to_string () + "px";
        var x_large_roundness = (3 * base_roundness).to_string () + "px";
        var xx_large_roundness = (6 * base_roundness).to_string () + "px";
        var circle_roundness = (12.5 * base_roundness).to_string () + "px";

        string css = "";
        css += @"
    .small-radius {
      border-radius: $small_roundness;
    }
    .medium-radius {
      border-radius: $medium_roundness;
    }
    .large-radius {
      border-radius: $large_roundness;
    }
    .x-large-radius {
      border-radius: $x_large_roundness;
    }
    .circle-radius {
      border-radius: $circle_roundness;
    }

    .view-switcher button.toggle,
    .bottom-bar.docked {
      border-radius: 0px;
    }
    .badge,
    .badge-info,
    .tint-badge {
      border-radius: $small_roundness;
    }
    button,
    .toast-box,
    .text-view,
    popover > contents,
    check {
      border-radius: $medium_roundness;
    }
    .text-field,
    .navigation-section-button,
    scale > trough,
    scale > trough > slider {
      border-radius: $large_roundness;
    }
    .content-block,
    .mini-content-block,
    .dialog-content,
    .switchbar,
    .bottom-bar.floating,
    .navigation-section-list row .mini-content-block,
    window.csd {
      border-radius: $x_large_roundness;
    }
    window.csd.dialog.message,
    window.csd.dialog-content,
    .dialog-sheet {
      border-radius: $xx_large_roundness;
    }
    .bottom-sheet {
        border-top-left-radius: $xx_large_roundness;
        border-bottom-left-radius: 0;
        border-top-right-radius: $xx_large_roundness;
        border-bottom-right-radius: 0;
    }
    .disclosure-button,
    .disclosure-button .toggle,
    .overlay-button,
    .iconic-button,
    .text-field.search,
    .switch,
    .switch > slider,
    .modifier-badge,
    .circular,
    .pill-button,
    .navigation-rail-button image,
    switch,
    switch > slider,
    radio,
    window.csd.dialog-content windowcontrols > button > image,
    window.csd.dialog-content .fill-button,
    window.csd.dialog-content .pill-button,
    window.csd.dialog-content .tint-button,
    window.csd.dialog-content .textual-button,
    window.csd.dialog-content .outline-button,
    windowcontrols > button > image {
      border-radius: $circle_roundness;
    }
    .content-list row:first-child .mini-content-block {
      border-top-left-radius: $xx_large_roundness;
	    border-top-right-radius: $xx_large_roundness;
      border-bottom-left-radius: $large_roundness;
      border-bottom-right-radius: $large_roundness;
    }
    .content-list row:first-child:last-child .mini-content-block {
      border-top-left-radius: $large_roundness;
	    border-top-right-radius: $large_roundness;
      border-bottom-left-radius: $large_roundness;
      border-bottom-right-radius: $large_roundness;
    }
    .content-list row:last-child .mini-content-block {
      border-top-left-radius: $large_roundness;
	    border-top-right-radius: $large_roundness;
      border-bottom-left-radius: $xx_large_roundness;
      border-bottom-right-radius: $xx_large_roundness;
    }
    .segmented-button > button:not(:first-child),
    .segmented-button > button:not(:last-child) {
        border-top-left-radius: $x_large_roundness;
        border-bottom-left-radius: $x_large_roundness;
        border-top-right-radius: $x_large_roundness;
        border-bottom-right-radius: $x_large_roundness;
    }
    .segmented-button > button:not(:first-child):checked,
    .segmented-button > button:not(:last-child):checked,
    .segmented-button > button:first-child:checked,
    .segmented-button > button:last-child:checked {
        border-top-left-radius: $circle_roundness;
        border-bottom-left-radius: $circle_roundness;
        border-top-right-radius: $circle_roundness;
        border-bottom-right-radius: $circle_roundness;
    }
    .segmented-button button:first-child {
        border-top-left-radius: $circle_roundness;
        border-bottom-left-radius: $circle_roundness;
        border-top-right-radius: $x_large_roundness;
        border-bottom-right-radius: $x_large_roundness;
    }
    .segmented-button button:first-child:dir(rtl) {
        border-top-right-radius: $circle_roundness;
        border-bottom-right-radius: $circle_roundness;
        border-top-left-radius: $x_large_roundness;
        border-bottom-left-radius: $x_large_roundness;
    }
    .segmented-button button:last-child {
        border-top-right-radius: $circle_roundness;
        border-bottom-right-radius: $circle_roundness;
        border-top-left-radius: $x_large_roundness;
        border-bottom-left-radius: $x_large_roundness;
    }
    .segmented-button button:last-child:dir(rtl) {
        border-top-left-radius: $circle_roundness;
        border-bottom-left-radius: $circle_roundness;
        border-top-right-radius: $x_large_roundness;
        border-bottom-right-radius: $x_large_roundness;
    }
    .vertical.segmented-button > button:not(:first-child),
    .vertical.segmented-button > button:not(:last-child) {
        border-top-left-radius: $x_large_roundness;
        border-bottom-left-radius: $x_large_roundness;
        border-top-right-radius: $x_large_roundness;
        border-bottom-right-radius: $x_large_roundness;
    }
    .vertical.segmented-button > button:not(:first-child):checked,
    .vertical.segmented-button > button:not(:last-child):checked,
    .vertical.segmented-button > button:first-child:checked,
    .vertical.segmented-button > button:last-child:checked {
        border-top-left-radius: $circle_roundness;
        border-bottom-left-radius: $circle_roundness;
        border-top-right-radius: $circle_roundness;
        border-bottom-right-radius: $circle_roundness;
    }
    .vertical.segmented-button button:first-child {
      border-top-left-radius: $circle_roundness;
      border-top-right-radius: $circle_roundness;
      border-bottom-left-radius: $x_large_roundness;
      border-bottom-right-radius: $x_large_roundness;
    }
    .vertical.segmented-button button:last-child {
      border-bottom-left-radius: $circle_roundness;
      border-bottom-right-radius: $circle_roundness;
      border-top-left-radius: $x_large_roundness;
      border-top-right-radius: $x_large_roundness;
    }
    progressbar > trough > progress {
      border-radius: $large_roundness;
    }
    progressbar > trough > progress.left {
      border-top-left-radius: $large_roundness;
      border-bottom-left-radius: $large_roundness;
    }
    progressbar > trough > progress.right {
      border-top-right-radius: $large_roundness;
      border-bottom-right-radius: $large_roundness;
    }
    progressbar > trough > progress.top {
      border-top-right-radius: $large_roundness;
      border-top-left-radius: $large_roundness;
    }
    progressbar > trough > progress.bottom {
      border-bottom-right-radius: $large_roundness;
      border-bottom-left-radius: $large_roundness;
    }
    ";

        return css;
    }

    /**
     * Register the style manager with GTK. This will also call update.
     */
    public void register () {
#if BUNDLED_STYLESHEET
        debug ("Loading bundled Helium stylesheet");
        light.load_from_resource ("/com/fyralabs/Helium/gtk.css");
        dark.load_from_resource ("/com/fyralabs/Helium/gtk-dark.css");
#else
        debug ("Loading system Helium stylesheet (this may fail if Helium is not installed)");
        light.load_named ("Helium", null);
        dark.load_named ("Helium", "dark");
#endif

        Misc.toggle_style_provider (accent, true, STYLE_PROVIDER_PRIORITY_ACCENT);
        Misc.toggle_style_provider (user_base, true, STYLE_PROVIDER_PRIORITY_USER_BASE);

        // Setup the platform gtk theme and default icon theme.
        var settings = Gtk.Settings.get_default ();
        settings.gtk_theme_name = "Helium-empty";
        settings.gtk_icon_theme_name = "Hydrogen";

        is_registered = true;

        update ();
    }

    /**
     * Unregister the style manager with GTK.
     */
    public void unregister () {
        Misc.toggle_style_provider (accent, false, STYLE_PROVIDER_PRIORITY_ACCENT);
        Misc.toggle_style_provider (light, false, STYLE_PROVIDER_PRIORITY_PLATFORM);
        Misc.toggle_style_provider (dark, false, STYLE_PROVIDER_PRIORITY_PLATFORM);
        Misc.toggle_style_provider (user_base, false, STYLE_PROVIDER_PRIORITY_USER_BASE);
        Misc.toggle_style_provider (user_dark, false, STYLE_PROVIDER_PRIORITY_USER_DARK);

        is_registered = false;
    }

    ~StyleManager () {
        unregister ();
    }
}
