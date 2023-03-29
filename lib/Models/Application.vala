/*
* Copyright (c) 2022 Fyra Labs
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

/**
* An application.
*/
public class He.Application : Gtk.Application {
  private int STYLE_PROVIDER_PRIORITY_PLATFORM = Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION + 1;
  private int STYLE_PROVIDER_PRIORITY_ACCENT = Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION + 2;
  private int STYLE_PROVIDER_PRIORITY_USER_BASE = Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION + 3;
  private int STYLE_PROVIDER_PRIORITY_USER_DARK = Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION + 4;

  private He.Color.RGBColor default_dark_accent = {
    0.7450 * 255,
    0.6270 * 255,
    0.8590 * 255
  };

  private He.Color.RGBColor default_light_accent = {
    0.5490 * 255,
    0.3370 * 255,
    0.7490 * 255
  };

  /**
  * A default accent color if the user has not set one.
  */
  public He.Color.RGBColor? default_accent_color { get; set; }
  private He.Color.RGBColor? derived_card_bg { get; set; }

  public double default_font_weight { get; set; }

  private Gtk.CssProvider light = new Gtk.CssProvider ();
  private Gtk.CssProvider dark = new Gtk.CssProvider ();
  private Gtk.CssProvider accent = new Gtk.CssProvider ();
  private Gtk.CssProvider user_base = new Gtk.CssProvider ();
  private Gtk.CssProvider user_dark = new Gtk.CssProvider ();
  private He.Desktop desktop = new He.Desktop ();

  /**
  * The applied accent color.
  */
  private He.Color.RGBColor? _accent_color;
  public He.Color.RGBColor accent_color {
    get {
      return _accent_color;
    }
    private set {
      _accent_color = value;
    }
  }

  /**
  * The foreground color that pairs well with the accent color.
  *
  * @since 1.0
  */
  private He.Color.RGBColor? _foreground;
  public He.Color.RGBColor foreground {
    get {
      return _foreground;
    }
    private set {
      _foreground = value;
    }
  }

  /**
  * The foreground accent color, used for text.
  *
  * @since 1.0
  */
  private He.Color.RGBColor? _accent_foreground;
  public He.Color.RGBColor accent_foreground {
    get {
      return _accent_foreground;
    }
    private set {
      _accent_foreground = value;
    }
  }

  private void update_accent_color () {
    He.Color.RGBColor rgb_color;
    double weight;

    if (desktop.accent_color == null) {
      if (default_accent_color != null) {
        rgb_color = default_accent_color;
      } else {
        rgb_color = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? default_dark_accent : default_light_accent;
      }
    } else {
      rgb_color = desktop.accent_color;
    }

    if (desktop.font_weight == 0.0) {
      if (default_font_weight != 0.0) {
        weight = 400 * default_font_weight;
      } else {
        weight = 400 * 1.0;
      }
    } else {
      weight = (400 * desktop.font_weight);
    }

    var cam16_color = He.Color.xyz_to_cam16 (He.Color.rgb_to_xyz (rgb_color));

    if (Desktop.DarkModeStrength.MEDIUM == desktop.dark_mode_strength) {
      derived_card_bg = He.Color.CARD_BLACK;
    } else if (Desktop.DarkModeStrength.SOFT == desktop.dark_mode_strength) {
      derived_card_bg = He.Color.SOFT_CARD_BLACK;
    } else if (Desktop.DarkModeStrength.HARSH == desktop.dark_mode_strength) {
      derived_card_bg = He.Color.HARSH_CARD_BLACK;
    }
    var background_hex = Color.hexcode (derived_card_bg.r, derived_card_bg.g, derived_card_bg.b);

    var chosen_scheme = new He.Scheme (cam16_color, desktop);
    if (Desktop.EnsorScheme.DEFAULT == desktop.ensor_scheme) {
      chosen_scheme = new He.Schemes.Default (cam16_color, desktop);
    } else if (Desktop.EnsorScheme.VIBRANT == desktop.ensor_scheme) {
      chosen_scheme = new He.Schemes.Vibrant (cam16_color, desktop);
    } else if (Desktop.EnsorScheme.MUTED == desktop.ensor_scheme) {
      chosen_scheme = new He.Schemes.Muted (cam16_color, desktop);
    } else if (Desktop.EnsorScheme.MONOCHROMATIC == desktop.ensor_scheme) {
      chosen_scheme = new He.Schemes.Monochrome (cam16_color, desktop);
    } else {
      chosen_scheme = new He.Schemes.Default (cam16_color, desktop);
    }

    var error_hex = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? "#F2B8B5" : "#B3261E";
    var on_error_hex = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? "#601410" : "#FFFFFF";
    var error_container_hex = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? "#8C1D18" : "#F9DEDC";
    var on_error_container_hex = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? "#F9DEDC" : "#410E0B";

    // HCT Color blendin'
    var meson_red_hct = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ?
    Color.hct_blend (Color.from_params (8.0, 85.0, 80.0), Color.from_params (cam16_color.h, cam16_color.C, 80.0)) :
    Color.hct_blend (Color.from_params (2.0, 49.0, 40.0), Color.from_params (cam16_color.h, cam16_color.C, 40.0)) ;
    var meson_red_hex = Color.hct_to_hex (meson_red_hct.h, meson_red_hct.c, meson_red_hct.t);

    var lepton_orange_hct = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ?
    Color.hct_blend (Color.from_params (55.0, 29.0, 80.0), Color.from_params (cam16_color.h, cam16_color.C, 80.0)) :
    Color.hct_blend (Color.from_params (50.0, 61.0, 40.0), Color.from_params (cam16_color.h, cam16_color.C, 40.0)) ;
    var lepton_orange_hex = Color.hct_to_hex (lepton_orange_hct.h, lepton_orange_hct.c, lepton_orange_hct.t);

    var electron_yellow_hct = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ?
    Color.hct_blend (Color.from_params (89.0, 37.0, 80.0), Color.from_params (cam16_color.h, cam16_color.C, 80.0)) :
    Color.hct_blend (Color.from_params (81.0, 55.0, 40.0), Color.from_params (cam16_color.h, cam16_color.C, 40.0)) ;
    var electron_yellow_hex = Color.hct_to_hex (electron_yellow_hct.h, electron_yellow_hct.c, electron_yellow_hct.t);

    var muon_green_hct = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ?
    Color.hct_blend (Color.from_params (152.0, 43.0, 80.0), Color.from_params (cam16_color.h, cam16_color.C, 80.0)) :
    Color.hct_blend (Color.from_params (147.0, 71.0, 40.0), Color.from_params (cam16_color.h, cam16_color.C, 40.0)) ;
    var muon_green_hex = Color.hct_to_hex (muon_green_hct.h, muon_green_hct.c, muon_green_hct.t);

    var baryon_mint_hct = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ?
    Color.hct_blend (Color.from_params (182.0, 25.0, 80.0), Color.from_params (cam16_color.h, cam16_color.C, 80.0)) :
    Color.hct_blend (Color.from_params (177.0, 42.0, 40.0), Color.from_params (cam16_color.h, cam16_color.C, 40.0)) ;
    var baryon_mint_hex = Color.hct_to_hex (baryon_mint_hct.h, baryon_mint_hct.c, baryon_mint_hct.t);

    var proton_blue_hct = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ?
    Color.hct_blend (Color.from_params (233.0, 34.0, 80.0), Color.from_params (cam16_color.h, cam16_color.C, 80.0)) :
    Color.hct_blend (Color.from_params (240.0, 53.0, 40.0), Color.from_params (cam16_color.h, cam16_color.C, 40.0)) ;
    var proton_blue_hex = Color.hct_to_hex (proton_blue_hct.h, proton_blue_hct.c, proton_blue_hct.t);

    var photon_indigo_hct = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ?
    Color.hct_blend (Color.from_params (291.0, 67.0, 80.0), Color.from_params (cam16_color.h, cam16_color.C, 80.0)) :
    Color.hct_blend (Color.from_params (288.0, 84.0, 40.0), Color.from_params (cam16_color.h, cam16_color.C, 40.0)) ;
    var photon_indigo_hex = Color.hct_to_hex (photon_indigo_hct.h, photon_indigo_hct.c, photon_indigo_hct.t);

    var tau_purple_hct = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ?
    Color.hct_blend (Color.from_params (309.0, 34.0, 80.0), Color.from_params (cam16_color.h, cam16_color.C, 80.0)) :
    Color.hct_blend (Color.from_params (311.0, 57.0, 40.0), Color.from_params (cam16_color.h, cam16_color.C, 40.0));
    var tau_purple_hex = Color.hct_to_hex (tau_purple_hct.h, tau_purple_hct.c, tau_purple_hct.t);

    var fermion_pink_hct = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ?
    Color.hct_blend (Color.from_params (337.0, 34.0, 80.0), Color.from_params (cam16_color.h, cam16_color.C, 80.0)) :
    Color.hct_blend (Color.from_params (340.0, 60.0, 40.0), Color.from_params (cam16_color.h, cam16_color.C, 40.0));
    var fermion_pink_hex = Color.hct_to_hex (fermion_pink_hct.h, fermion_pink_hct.c, fermion_pink_hct.t);

    var gluon_brown_hct = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ?
    Color.hct_blend (Color.from_params (66.0, 12.0, 80.0), Color.from_params (cam16_color.h, cam16_color.C, 80.0)) :
    Color.hct_blend (Color.from_params (61.0, 30.0, 40.0), Color.from_params (cam16_color.h, cam16_color.C, 40.0));
    var gluon_brown_hex = Color.hct_to_hex (gluon_brown_hct.h, gluon_brown_hct.c, gluon_brown_hct.t);

    string css = "";
    if (desktop.prefers_color_scheme == Desktop.ColorScheme.DARK) {
      css = @"
      @define-color accent_color $(chosen_scheme.primary_hex);
      @define-color accent_bg_color $(chosen_scheme.primary_hex);
      @define-color accent_fg_color $(chosen_scheme.on_primary_hex);

      @define-color accent_container_color $(chosen_scheme.primary_container_hex);
      @define-color accent_container_bg_color $(chosen_scheme.primary_container_hex);
      @define-color accent_container_fg_color $(chosen_scheme.on_primary_container_hex);

      @define-color window_bg_color mix($(chosen_scheme.neutral_background_hex), $background_hex, 0.5);
      @define-color view_bg_color mix($(chosen_scheme.neutral_background_hex), $background_hex, 0.5);
      @define-color headerbar_bg_color mix($(chosen_scheme.neutral_background_variant_hex), $background_hex, 0.5);
      @define-color popover_bg_color mix($(chosen_scheme.neutral_background_hex), $background_hex, 0.5);
      @define-color card_bg_color mix($(chosen_scheme.neutral_background_hex), $background_hex, 0.5);

      @define-color window_fg_color $(chosen_scheme.neutral_foreground_hex);
      @define-color view_fg_color $(chosen_scheme.neutral_foreground_hex);
      @define-color headerbar_fg_color $(chosen_scheme.neutral_foreground_variant_hex);
      @define-color popover_fg_color $(chosen_scheme.neutral_foreground_hex);
      @define-color card_fg_color $(chosen_scheme.neutral_foreground_hex);

      @define-color destructive_bg_color $error_hex;
      @define-color destructive_fg_color $on_error_hex;
      @define-color destructive_color $error_hex;

      @define-color destructive_container_color $on_error_container_hex;
      @define-color destructive_container_bg_color $error_container_hex;
      @define-color destructive_container_fg_color $on_error_container_hex;

      @define-color suggested_bg_color $(chosen_scheme.secondary_hex);
      @define-color suggested_fg_color $(chosen_scheme.on_secondary_hex);
      @define-color suggested_color $(chosen_scheme.secondary_hex);

      @define-color suggested_container_color $(chosen_scheme.secondary_container_hex);
      @define-color suggested_container_bg_color $(chosen_scheme.secondary_container_hex);
      @define-color suggested_container_fg_color $(chosen_scheme.on_secondary_container_hex);

      @define-color error_bg_color $error_hex;
      @define-color error_fg_color $on_error_hex;
      @define-color error_color $error_hex;

      @define-color error_container_color $on_error_container_hex;
      @define-color error_container_bg_color $error_container_hex;
      @define-color error_container_fg_color $error_container_hex;

      @define-color success_bg_color $(chosen_scheme.tertiary_hex);
      @define-color success_fg_color $(chosen_scheme.on_tertiary_hex);
      @define-color success_color $(chosen_scheme.tertiary_hex);

      @define-color success_container_color $(chosen_scheme.tertiary_container_hex);
      @define-color success_container_bg_color $(chosen_scheme.tertiary_container_hex);
      @define-color success_container_fg_color $(chosen_scheme.on_tertiary_container_hex);

      @define-color outline $(chosen_scheme.outline_hex);
      @define-color borders $(chosen_scheme.outline_variant_hex);

      @define-color shadow $(chosen_scheme.shadow_hex);
      @define-color scrim $(chosen_scheme.scrim_hex);
      ";

      css += @"
      @define-color osd_bg_color $(chosen_scheme.inverse_neutral_background_hex);
      @define-color osd_fg_color $(chosen_scheme.inverse_neutral_foreground_hex);
      @define-color osd_accent_color $(chosen_scheme.inverse_primary_hex);
      ";
    } else {
      css = @"
      @define-color accent_color $(chosen_scheme.primary_hex);
      @define-color accent_bg_color $(chosen_scheme.primary_hex);
      @define-color accent_fg_color $(chosen_scheme.on_primary_hex);

      @define-color accent_container_color $(chosen_scheme.primary_container_hex);
      @define-color accent_container_bg_color $(chosen_scheme.primary_container_hex);
      @define-color accent_container_fg_color $(chosen_scheme.on_primary_container_hex);

      @define-color window_bg_color $(chosen_scheme.neutral_background_hex);
      @define-color view_bg_color $(chosen_scheme.neutral_background_hex);
      @define-color headerbar_bg_color $(chosen_scheme.neutral_background_variant_hex);
      @define-color popover_bg_color $(chosen_scheme.neutral_background_hex);
      @define-color card_bg_color $(chosen_scheme.neutral_background_hex);

      @define-color window_fg_color $(chosen_scheme.neutral_foreground_hex);
      @define-color view_fg_color $(chosen_scheme.neutral_foreground_hex);
      @define-color headerbar_fg_color $(chosen_scheme.neutral_foreground_variant_hex);
      @define-color popover_fg_color $(chosen_scheme.neutral_foreground_hex);
      @define-color card_fg_color $(chosen_scheme.neutral_foreground_hex);

      @define-color destructive_bg_color $error_hex;
      @define-color destructive_fg_color $on_error_hex;
      @define-color destructive_color $error_hex;

      @define-color destructive_container_color $on_error_container_hex;
      @define-color destructive_container_bg_color $error_container_hex;
      @define-color destructive_container_fg_color $on_error_container_hex;

      @define-color suggested_bg_color $(chosen_scheme.secondary_hex);
      @define-color suggested_fg_color $(chosen_scheme.on_secondary_hex);
      @define-color suggested_color $(chosen_scheme.secondary_hex);

      @define-color suggested_container_color $(chosen_scheme.secondary_container_hex);
      @define-color suggested_container_bg_color $(chosen_scheme.secondary_container_hex);
      @define-color suggested_container_fg_color $(chosen_scheme.on_secondary_container_hex);

      @define-color error_bg_color $error_hex;
      @define-color error_fg_color $on_error_hex;
      @define-color error_color $error_hex;

      @define-color error_container_color $on_error_container_hex;
      @define-color error_container_bg_color $error_container_hex;
      @define-color error_container_fg_color $error_container_hex;

      @define-color success_bg_color $(chosen_scheme.tertiary_hex);
      @define-color success_fg_color $(chosen_scheme.on_tertiary_hex);
      @define-color success_color $(chosen_scheme.tertiary_hex);

      @define-color success_container_color $(chosen_scheme.tertiary_container_hex);
      @define-color success_container_bg_color $(chosen_scheme.tertiary_container_hex);
      @define-color success_container_fg_color $(chosen_scheme.on_tertiary_container_hex);

      @define-color outline $(chosen_scheme.outline_hex);
      @define-color borders $(chosen_scheme.outline_variant_hex);

      @define-color shadow $(chosen_scheme.shadow_hex);
      @define-color scrim $(chosen_scheme.scrim_hex);
      ";

      css += @"
      @define-color osd_bg_color $(chosen_scheme.inverse_neutral_background_hex);
      @define-color osd_fg_color $(chosen_scheme.inverse_neutral_foreground_hex);
      @define-color osd_accent_color $(chosen_scheme.inverse_primary_hex);
      ";
    }

    css += @"
      @define-color meson_red $meson_red_hex;
      @define-color lepton_orange $lepton_orange_hex;
      @define-color electron_yellow $electron_yellow_hex;
      @define-color muon_green $muon_green_hex;
      @define-color baryon_mint $baryon_mint_hex;
      @define-color proton_blue $proton_blue_hex;
      @define-color photon_indigo $photon_indigo_hex;
      @define-color tau_purple $tau_purple_hex;
      @define-color fermion_pink $fermion_pink_hex;
      @define-color gluon_brown $gluon_brown_hex;
    ";

    if (desktop.font_weight == 0.0) {
      double light_weight = 300;
      double heavy_weight = 700;

      css += @"
      label {
        font-weight: $weight;
      }
      button label {
        font-weight: $heavy_weight;
      }
      .view-switcher button label {
        font-weight: $weight;
      }
      .big-display {
        font-weight: $weight;
      }
      .display {
        font-weight: $light_weight;
      }
      .view-title {
        font-weight: $light_weight;
      }
      .view-subtitle {
        font-weight: $weight;
      }
      .cb-title {
        font-weight: $heavy_weight;
      }
      .cb-subtitle {
        font-weight: $weight;
      }
      .header {
        font-weight: $heavy_weight;
      }
      .body {
        font-weight: $weight;
      }
      .caption {
        font-weight: $heavy_weight;
      }
      .large-title {
        font-weight: $light_weight;
      }
      .title-1 {
        font-weight: $heavy_weight;
      }
      .title-2 {
        font-weight: $heavy_weight;
      }
      .title-3 {
        font-weight: $heavy_weight;
      }
      .title-4 {
        font-weight: $heavy_weight;
      }
      .heading {
        font-weight: $heavy_weight;
      }
      .caption-heading {
        font-weight: $heavy_weight;
      }
      ";
    } else {
      double light_weight = (300 * desktop.font_weight);
      double heavy_weight = (700 * desktop.font_weight);

      css += @"
      label {
        font-weight: $weight;
      }
      button label {
        font-weight: $heavy_weight;
      }
      .view-switcher button label {
        font-weight: $weight;
      }
      .big-display {
        font-weight: $weight;
      }
      .display {
        font-weight: $light_weight;
      }
      .view-title {
        font-weight: $light_weight;
      }
      .view-subtitle {
        font-weight: $weight;
      }
      .cb-title {
        font-weight: $heavy_weight;
      }
      .cb-subtitle {
        font-weight: $weight;
      }
      .header {
        font-weight: $heavy_weight;
      }
      .body {
        font-weight: $weight;
      }
      .caption {
        font-weight: $heavy_weight;
      }
      .large-title {
        font-weight: $light_weight;
      }
      .title-1 {
        font-weight: $heavy_weight;
      }
      .title-2 {
        font-weight: $heavy_weight;
      }
      .title-3 {
        font-weight: $heavy_weight;
      }
      .title-4 {
        font-weight: $heavy_weight;
      }
      .heading {
        font-weight: $heavy_weight;
      }
      .caption-heading {
        font-weight: $heavy_weight;
      }
      ";
    }

    accent.load_from_data (css.data);
  }

  private void init_style_providers () {
    // Setup the dark preference theme loading
    light.load_from_resource ("/com/fyralabs/helium/gtk.css");
    dark.load_from_resource ("/com/fyralabs/helium/gtk-dark.css");

    style_provider_set_enabled (light, desktop.prefers_color_scheme != He.Desktop.ColorScheme.DARK, STYLE_PROVIDER_PRIORITY_PLATFORM);
    style_provider_set_enabled (dark, desktop.prefers_color_scheme == He.Desktop.ColorScheme.DARK, STYLE_PROVIDER_PRIORITY_PLATFORM);

    style_provider_set_enabled (accent, true, STYLE_PROVIDER_PRIORITY_ACCENT);

    style_provider_set_enabled (user_base, true, STYLE_PROVIDER_PRIORITY_USER_BASE);
    style_provider_set_enabled (user_dark, desktop.prefers_color_scheme == He.Desktop.ColorScheme.DARK, STYLE_PROVIDER_PRIORITY_USER_DARK);

    desktop.notify["prefers-color-scheme"].connect (() => {
      update_accent_color();

      style_provider_set_enabled (light, desktop.prefers_color_scheme != He.Desktop.ColorScheme.DARK, STYLE_PROVIDER_PRIORITY_PLATFORM);
      style_provider_set_enabled (dark, desktop.prefers_color_scheme == He.Desktop.ColorScheme.DARK, STYLE_PROVIDER_PRIORITY_PLATFORM);
      style_provider_set_enabled (user_dark, desktop.prefers_color_scheme == He.Desktop.ColorScheme.DARK, STYLE_PROVIDER_PRIORITY_USER_DARK);
    });

    desktop.notify["dark-mode-strength"].connect (() => {
      update_accent_color ();

      style_provider_set_enabled (light, desktop.prefers_color_scheme != He.Desktop.ColorScheme.DARK, STYLE_PROVIDER_PRIORITY_PLATFORM);
      style_provider_set_enabled (dark, desktop.prefers_color_scheme == He.Desktop.ColorScheme.DARK, STYLE_PROVIDER_PRIORITY_PLATFORM);
      style_provider_set_enabled (user_dark, desktop.prefers_color_scheme == He.Desktop.ColorScheme.DARK, STYLE_PROVIDER_PRIORITY_USER_DARK);
    });

    desktop.notify["ensor-scheme"].connect (() => {
      update_accent_color ();

      style_provider_set_enabled (light, desktop.prefers_color_scheme != He.Desktop.ColorScheme.DARK, STYLE_PROVIDER_PRIORITY_PLATFORM);
      style_provider_set_enabled (dark, desktop.prefers_color_scheme == He.Desktop.ColorScheme.DARK, STYLE_PROVIDER_PRIORITY_PLATFORM);
      style_provider_set_enabled (user_dark, desktop.prefers_color_scheme == He.Desktop.ColorScheme.DARK, STYLE_PROVIDER_PRIORITY_USER_DARK);
    });

    desktop.notify["font-weight"].connect (() => {
      update_accent_color ();

      style_provider_set_enabled (light, desktop.prefers_color_scheme != He.Desktop.ColorScheme.DARK, STYLE_PROVIDER_PRIORITY_PLATFORM);
      style_provider_set_enabled (dark, desktop.prefers_color_scheme == He.Desktop.ColorScheme.DARK, STYLE_PROVIDER_PRIORITY_PLATFORM);
      style_provider_set_enabled (user_dark, desktop.prefers_color_scheme == He.Desktop.ColorScheme.DARK, STYLE_PROVIDER_PRIORITY_USER_DARK);
    });
  }

  private void init_app_providers () {
    /**
    * Load the custom css of the application (if any.)
    *
    * This is useful for overriding the base theme. For example,
    * to override the default theme of the He.Application, you
    * can create a file called style.css (or style-dark.css) in the
    * application's data folder, and gresource it. This file will
    * be loaded by the application. The file name is based on the
    * color scheme preference. For example, if the user prefers the
    * dark color scheme, the file name is style-dark.css.
    *
    * @since 1.0
    */
    var base_path = get_resource_base_path ();
    if (base_path == null) {
      return;
    }

    string base_uri = "resource://" + base_path;
    File base_file = File.new_for_uri (base_uri);

    init_provider_from_file (user_base, base_file.get_child ("style.css"));
    init_provider_from_file (user_dark, base_file.get_child ("style-dark.css"));
  }

  private void init_accent_color () {
    update_accent_color();

    desktop.notify["accent-color"].connect (() => {
      update_accent_color();
    });

    desktop.notify["dark-mode-strength"].connect (() => {
      update_accent_color();
    });

    desktop.notify["ensor-scheme"].connect (() => {
      update_accent_color();
    });

    desktop.notify["font-weight"].connect (() => {
      update_accent_color();
    });

    this.notify["default-accent-color"].connect(() => {
      update_accent_color();
    });
  }

  private void style_provider_set_enabled (Gtk.CssProvider provider, bool enabled, int priority) {
    Gdk.Display display = Gdk.Display.get_default ();

    if (display == null)
    return;

    if (enabled) {
      Gtk.StyleContext.add_provider_for_display (display, provider, priority);
    } else {
      Gtk.StyleContext.remove_provider_for_display (display, provider);
    }
  }

  private void init_provider_from_file (Gtk.CssProvider provider, File file) {
    if (file.query_exists (null)) {
      provider.load_from_file (file);
    }
  }

  protected override void startup () {
    base.startup ();
    He.init ();

    init_accent_color ();
    init_app_providers ();
    init_style_providers ();
  }

  public Application(string? application_id, ApplicationFlags flags) {
    this.application_id = application_id;
    this.flags = flags;
  }
}
