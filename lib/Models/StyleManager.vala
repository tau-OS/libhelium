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
   * The preferred secondary color. If null, secondary will be derived from accent color.
   */
  public RGBColor? secondary_color = null;

  /**
   * The preferred tertiary color. If null, tertiary will be derived from accent color.
   */
  public RGBColor? tertiary_color = null;

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

  /**
   * The UI density preference.
   * 0 = compact, 1 = normal, 2 = comfortable
   */
  private uint _density = 0;
  public uint density {
    get {
      return _density;
    }
    set {
      if (value > 2) {
        _density = 0;
      } else {
        _density = value;
      }
    }
  }

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

    // Check if we have custom secondary/tertiary colors
    if (secondary_color != null || tertiary_color != null) {
      // Create custom DynamicScheme with overridden colors
      RGBColor accent_rgb = { rgb_color.r* 255, rgb_color.g* 255, rgb_color.b* 255 };
      HCTColor accent_hct = hct_from_int (rgb_to_argb_int (accent_rgb));

      // Create palettes
      TonalPalette primary_palette = TonalPalette.from_hct (accent_hct);

      TonalPalette secondary_palette;
      if (secondary_color != null) {
        RGBColor secondary_rgb = { secondary_color.r* 255, secondary_color.g* 255, secondary_color.b* 255 };
        HCTColor secondary_hct = hct_from_int (rgb_to_argb_int (secondary_rgb));
        secondary_palette = TonalPalette.from_hct (secondary_hct);
      } else {
        // Use default secondary derivation
        secondary_palette = TonalPalette.from_hue_and_chroma (
                                                              accent_hct.h,
                                                              MathUtils.max (accent_hct.c - 32.0, 16.0)
        );
      }

      TonalPalette tertiary_palette;
      if (tertiary_color != null) {
        RGBColor tertiary_rgb = { tertiary_color.r* 255, tertiary_color.g* 255, tertiary_color.b* 255 };
        HCTColor tertiary_hct = hct_from_int (rgb_to_argb_int (tertiary_rgb));
        tertiary_palette = TonalPalette.from_hct (tertiary_hct);
      } else {
        // Use default tertiary derivation
        tertiary_palette = TonalPalette.from_hue_and_chroma (
                                                             MathUtils.sanitize_degrees (accent_hct.h + 60.0),
                                                             MathUtils.max (accent_hct.c * 0.5, 24.0)
        );
      }

      // Create neutral palettes
      TonalPalette neutral_palette = TonalPalette.from_hue_and_chroma (accent_hct.h, 4.0);
      TonalPalette neutral_variant_palette = TonalPalette.from_hue_and_chroma (accent_hct.h, 8.0);

      // Determine scheme variant for custom scheme
      SchemeVariant variant = scheme_variant ?? SchemeVariant.DEFAULT;

      // Create custom dynamic scheme
      DynamicScheme custom_scheme = new DynamicScheme (
                                                       accent_hct,
                                                       variant,
                                                       is_dark,
                                                       contrast,
                                                       primary_palette,
                                                       secondary_palette,
                                                       tertiary_palette,
                                                       neutral_palette,
                                                       neutral_variant_palette,
                                                       null
      );

      css += style_refresh (custom_scheme);
    } else {
      // Use existing scheme factory logic
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
    }

    css += weight_refresh (font_weight);
    css += roundness_refresh (roundness);
    css += density_refresh (density);

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

    css += @"
    @define-color accent_fixed_bg_color $(scheme_factory.get_primary_fixed());
    @define-color accent_fixed_dim_bg_color $(scheme_factory.get_primary_fixed_dim());
    @define-color accent_fixed_fg_color $(scheme_factory.get_on_primary_fixed());
    @define-color accent_fixed_variant_fg_color $(scheme_factory.get_on_primary_fixed_variant());

    @define-color suggested_fixed_bg_color $(scheme_factory.get_secondary_fixed());
    @define-color suggested_fixed_dim_bg_color $(scheme_factory.get_secondary_fixed_dim());
    @define-color suggested_fixed_fg_color $(scheme_factory.get_on_secondary_fixed());
    @define-color suggested_fixed_variant_fg_color $(scheme_factory.get_on_secondary_fixed_variant());

    @define-color success_fixed_bg_color $(scheme_factory.get_tertiary_fixed());
    @define-color success_fixed_dim_bg_color $(scheme_factory.get_tertiary_fixed_dim());
    @define-color success_fixed_fg_color $(scheme_factory.get_on_tertiary_fixed());
    @define-color success_fixed_variant_fg_color $(scheme_factory.get_on_tertiary_fixed_variant());
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
      font-weight: $black_weight;
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
    var xx_large_roundness = (4 * base_roundness).to_string () + "px";
    var extra_large_roundness = (7 * base_roundness).to_string () + "px";
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
    .xx-large-radius {
      border-radius: $xx_large_roundness;
    }
    .extra-large-radius {
      border-radius: $extra_large_roundness;
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
    .switchbar,
    .navigation-section-list row .mini-content-block {
      border-radius: $x_large_roundness;
    }
    window.csd {
      border-radius: $xx_large_roundness;
    }
    window.csd.dialog.message,
    window.csd.dialog-content,
    .dialog-content,
    .dialog-sheet {
      border-radius: $extra_large_roundness;
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
    .bottom-bar.floating,
    .navigation-rail-button image,
    .navigation-rail.expanded .navigation-rail-button,
    switch,
    switch > slider,
    radio,
    window.csd.dialog-content windowcontrols > button > image,
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
    ";

    css += @"
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
    .grouped-button.small box button.inactive {
        border-radius: $x_large_roundness;
    }
    .grouped-button.medium box button.inactive {
        border-radius: $xx_large_roundness;
    }
    .grouped-button.large box button.inactive {
        border-radius: $extra_large_roundness;
    }
    .grouped-button.xlarge box button.inactive {
        border-radius: $extra_large_roundness;
    }
    .grouped-button.small box button.active {
        border-radius: $circle_roundness;
    }
    .grouped-button.medium box button.active {
        border-radius: $circle_roundness;
    }
    .grouped-button.large box button.active {
        border-radius: $circle_roundness;
    }
    .grouped-button.xlarge box button.active {
        border-radius: $circle_roundness;
    }
    ";

    return css;
  }

  private string density_refresh (uint density) {
    uint button_height;
    uint button_xsmall_height;
    uint button_small_height;
    uint button_medium_height;
    uint button_large_height;
    uint button_xlarge_height;
    uint card_mini_height;
    uint card_content_height;
    uint check_radio_size;
    uint textfield_height;

    switch (density) {
    case 0:
      button_height = 40;
      button_xsmall_height = 32;
      button_small_height = 40;
      button_medium_height = 56;
      button_large_height = 96;
      button_xlarge_height = 136;
      card_mini_height = 40;
      card_content_height = 80;
      check_radio_size = 15;
      textfield_height = 44;
      break;
    case 1:
      button_height = 56;
      button_xsmall_height = 44;
      button_small_height = 56;
      button_medium_height = 72;
      button_large_height = 112;
      button_xlarge_height = 152;
      card_mini_height = 80;
      card_content_height = 100;
      check_radio_size = 18;
      textfield_height = 56;
      break;
    case 2:
      button_height = 64;
      button_xsmall_height = 52;
      button_small_height = 64;
      button_medium_height = 80;
      button_large_height = 120;
      button_xlarge_height = 160;
      card_mini_height = 132;
      card_content_height = 200;
      check_radio_size = 24;
      textfield_height = 68;
      break;
    default:
      button_height = 40;
      button_xsmall_height = 32;
      button_small_height = 40;
      button_medium_height = 56;
      button_large_height = 96;
      button_xlarge_height = 136;
      card_mini_height = 40;
      card_content_height = 80;
      check_radio_size = 15;
      textfield_height = 44;
      break;
    }

    var button_height_px = button_height.to_string () + "px";
    var button_xsmall_height_px = button_xsmall_height.to_string () + "px";
    var button_small_height_px = button_small_height.to_string () + "px";
    var button_medium_height_px = button_medium_height.to_string () + "px";
    var button_large_height_px = button_large_height.to_string () + "px";
    var button_xlarge_height_px = button_xlarge_height.to_string () + "px";
    var card_mini_height_px = card_mini_height.to_string () + "px";
    var card_content_height_px = card_content_height.to_string () + "px";
    var check_radio_size_px = check_radio_size.to_string () + "px";
    var textfield_height_px = textfield_height.to_string () + "px";

    string css = "";
    css += @"
    .fill-button:not(.xsmall):not(.small):not(.medium):not(.large):not(.xlarge),
    .outline-button:not(.xsmall):not(.small):not(.medium):not(.large):not(.xlarge),
    .textual-button:not(.xsmall):not(.small):not(.medium):not(.large):not(.xlarge),
    .tint-button:not(.xsmall):not(.small):not(.medium):not(.large):not(.xlarge),
    .pill-button:not(.xsmall):not(.small):not(.medium):not(.large):not(.xlarge),
    .segmented-button > button:not(.xsmall):not(.small):not(.medium):not(.large):not(.xlarge),
    .chip:not(.xsmall):not(.small):not(.medium):not(.large):not(.xlarge) {
      min-height: $button_height_px;
    }
    .fill-button.xsmall,
    .outline-button.xsmall,
    .textual-button.xsmall,
    .tint-button.xsmall,
    .pill-button.xsmall,
    .segmented-button > button.xsmall,
    .chip.xsmall {
      min-height: $button_xsmall_height_px;
    }
    .fill-button.small,
    .outline-button.small,
    .textual-button.small,
    .tint-button.small,
    .pill-button.small,
    .segmented-button > button.small,
    .chip.small {
      min-height: $button_small_height_px;
    }
    .fill-button.medium,
    .outline-button.medium,
    .textual-button.medium,
    .tint-button.medium,
    .pill-button.medium,
    .segmented-button > button.medium,
    .chip.medium {
      min-height: $button_medium_height_px;
    }
    .fill-button.large,
    .outline-button.large,
    .textual-button.large,
    .tint-button.large,
    .pill-button.large,
    .segmented-button > button.large,
    .chip.large {
      min-height: $button_large_height_px;
    }
    .fill-button.xlarge,
    .outline-button.xlarge,
    .textual-button.xlarge,
    .tint-button.xlarge,
    .pill-button.xlarge,
    .segmented-button > button.xlarge,
    .chip.xlarge {
      min-height: $button_xlarge_height_px;
    }
    .mini-content-block,
    .content-block.mini-content-block {
      min-height: $card_mini_height_px;
    }
    .content-block {
      min-height: $card_content_height_px;
    }
    check,
    radio {
      min-width: $check_radio_size_px;
      min-height: $check_radio_size_px;
    }
    .text-field {
      min-height: $textfield_height_px;
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