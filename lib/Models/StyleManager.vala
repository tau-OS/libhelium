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
  public Color.RGBColor? accent_color = null;

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
  * Whether to apply styles for high contrast mode.
  */
  public bool is_contrast = false;

  /**
  * A function that returns a color scheme from a given accent color and whether dark mode is enabled.
  */
  public SchemeFactory scheme_factory = new DefaultScheme ();

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

    var rgb_color = accent_color != null ? accent_color : is_dark ? He.Color.DEFAULT_DARK_ACCENT : He.Color.DEFAULT_LIGHT_ACCENT;
    var base_weight = 400 * font_weight;
    var base_roundness = roundness != 0 ? 4 * roundness : 0;
    var cam16_color = He.Color.xyz_to_cam16 (He.Color.rgb_to_xyz (rgb_color));
    var chosen_scheme = scheme_factory.generate (cam16_color, is_dark, is_contrast);

    // HCT Color blendin'
    var error_hct = is_dark ?
    Color.hct_blend (Color.from_params (20.0, 25.0, is_contrast ? 90.0 : 80.0), Color.from_params (cam16_color.h, cam16_color.c, is_contrast ? 90.0 : 80.0)) :
    Color.hct_blend (Color.from_params (25.0, 75.0, is_contrast ? 20.0 : 40.0), Color.from_params (cam16_color.h, cam16_color.c, is_contrast ? 20.0 : 40.0)) ;
    var error_hex = Color.hct_to_hex (error_hct.h, error_hct.c, error_hct.t);

    var on_error_hct = is_dark ?
    Color.hct_blend (Color.from_params (25.0, 50.0, 20.0), Color.from_params (cam16_color.h, cam16_color.c, 20.0)) :
    Color.hct_blend (Color.from_params (0.0, 0.0, 100.0), Color.from_params (cam16_color.h, cam16_color.c, 100.0)) ;
    var on_error_hex = Color.hct_to_hex (on_error_hct.h, on_error_hct.c, on_error_hct.t);

    var error_container_hct = is_dark ?
    Color.hct_blend (Color.from_params (25.0, 35.0, is_contrast ? 40.0 : 30.0), Color.from_params (cam16_color.h, cam16_color.c, is_contrast ? 90.0 : 80.0)) :
    Color.hct_blend (Color.from_params (20.0, 10.0, is_contrast ? 70.0 : 90.0), Color.from_params (cam16_color.h, cam16_color.c, is_contrast ? 20.0 : 40.0)) ;
    var error_container_hex = Color.hct_to_hex (error_container_hct.h, error_container_hct.c, error_container_hct.t);

    var on_error_container_hct = is_dark ?
    Color.hct_blend (Color.from_params (20.0, 10.0, 90.0), Color.from_params (cam16_color.h, cam16_color.c, 90.0)) :
    Color.hct_blend (Color.from_params (25.0, 65.0, 30.0), Color.from_params (cam16_color.h, cam16_color.c, 10.0)) ;
    var on_error_container_hex = Color.hct_to_hex (on_error_container_hct.h, on_error_container_hct.c, on_error_container_hct.t);

    var meson_red_hct = is_dark ?
    Color.hct_blend (Color.from_params (8.0, 85.0, is_contrast ? 90.0 : 80.0), Color.from_params (cam16_color.h, cam16_color.c, is_contrast ? 90.0 : 80.0)) :
    Color.hct_blend (Color.from_params (2.0, 49.0, is_contrast ? 20.0 : 40.0), Color.from_params (cam16_color.h, cam16_color.c, is_contrast ? 20.0 : 40.0)) ;
    var meson_red_hex = Color.hct_to_hex (meson_red_hct.h, meson_red_hct.c, meson_red_hct.t);

    var lepton_orange_hct = is_dark ?
    Color.hct_blend (Color.from_params (55.0, 29.0, is_contrast ? 90.0 : 80.0), Color.from_params (cam16_color.h, cam16_color.c, is_contrast ? 90.0 : 80.0)) :
    Color.hct_blend (Color.from_params (50.0, 61.0, is_contrast ? 20.0 : 40.0), Color.from_params (cam16_color.h, cam16_color.c, is_contrast ? 20.0 : 40.0)) ;
    var lepton_orange_hex = Color.hct_to_hex (lepton_orange_hct.h, lepton_orange_hct.c, lepton_orange_hct.t);

    var electron_yellow_hct = is_dark ?
    Color.hct_blend (Color.from_params (89.0, 37.0, is_contrast ? 90.0 : 80.0), Color.from_params (cam16_color.h, cam16_color.c, is_contrast ? 90.0 : 80.0)) :
    Color.hct_blend (Color.from_params (81.0, 55.0, is_contrast ? 20.0 : 40.0), Color.from_params (cam16_color.h, cam16_color.c, is_contrast ? 20.0 : 40.0)) ;
    var electron_yellow_hex = Color.hct_to_hex (electron_yellow_hct.h, electron_yellow_hct.c, electron_yellow_hct.t);

    var muon_green_hct = is_dark ?
    Color.hct_blend (Color.from_params (152.0, 43.0, is_contrast ? 90.0 : 80.0), Color.from_params (cam16_color.h, cam16_color.c, is_contrast ? 90.0 : 80.0)) :
    Color.hct_blend (Color.from_params (147.0, 71.0, is_contrast ? 20.0 : 40.0), Color.from_params (cam16_color.h, cam16_color.c, is_contrast ? 20.0 : 40.0)) ;
    var muon_green_hex = Color.hct_to_hex (muon_green_hct.h, muon_green_hct.c, muon_green_hct.t);

    var baryon_mint_hct = is_dark ?
    Color.hct_blend (Color.from_params (182.0, 25.0, is_contrast ? 90.0 : 80.0), Color.from_params (cam16_color.h, cam16_color.c, is_contrast ? 90.0 : 80.0)) :
    Color.hct_blend (Color.from_params (177.0, 42.0, is_contrast ? 20.0 : 40.0), Color.from_params (cam16_color.h, cam16_color.c, is_contrast ? 20.0 : 40.0)) ;
    var baryon_mint_hex = Color.hct_to_hex (baryon_mint_hct.h, baryon_mint_hct.c, baryon_mint_hct.t);

    var proton_blue_hct = is_dark ?
    Color.hct_blend (Color.from_params (233.0, 34.0, is_contrast ? 90.0 : 80.0), Color.from_params (cam16_color.h, cam16_color.c, is_contrast ? 90.0 : 80.0)) :
    Color.hct_blend (Color.from_params (240.0, 53.0, is_contrast ? 20.0 : 40.0), Color.from_params (cam16_color.h, cam16_color.c, is_contrast ? 20.0 : 40.0)) ;
    var proton_blue_hex = Color.hct_to_hex (proton_blue_hct.h, proton_blue_hct.c, proton_blue_hct.t);

    var photon_indigo_hct = is_dark ?
    Color.hct_blend (Color.from_params (291.0, 67.0, is_contrast ? 90.0 : 80.0), Color.from_params (cam16_color.h, cam16_color.c, is_contrast ? 90.0 : 80.0)) :
    Color.hct_blend (Color.from_params (288.0, 84.0, is_contrast ? 20.0 : 40.0), Color.from_params (cam16_color.h, cam16_color.c, is_contrast ? 20.0 : 40.0)) ;
    var photon_indigo_hex = Color.hct_to_hex (photon_indigo_hct.h, photon_indigo_hct.c, photon_indigo_hct.t);

    var tau_purple_hct = is_dark ?
    Color.hct_blend (Color.from_params (309.0, 34.0, is_contrast ? 90.0 : 80.0), Color.from_params (cam16_color.h, cam16_color.c, is_contrast ? 90.0 : 80.0)) :
    Color.hct_blend (Color.from_params (311.0, 57.0, is_contrast ? 20.0 : 40.0), Color.from_params (cam16_color.h, cam16_color.c, is_contrast ? 20.0 : 40.0)) ;
    var tau_purple_hex = Color.hct_to_hex (tau_purple_hct.h, tau_purple_hct.c, tau_purple_hct.t);

    var fermion_pink_hct = is_dark ?
    Color.hct_blend (Color.from_params (337.0, 34.0, is_contrast ? 90.0 : 80.0), Color.from_params (cam16_color.h, cam16_color.c, is_contrast ? 90.0 : 80.0)) :
    Color.hct_blend (Color.from_params (340.0, 60.0, is_contrast ? 20.0 : 40.0), Color.from_params (cam16_color.h, cam16_color.c, is_contrast ? 20.0 : 40.0)) ;
    var fermion_pink_hex = Color.hct_to_hex (fermion_pink_hct.h, fermion_pink_hct.c, fermion_pink_hct.t);

    var gluon_brown_hct = is_dark ?
    Color.hct_blend (Color.from_params (66.0, 12.0, is_contrast ? 90.0 : 80.0), Color.from_params (cam16_color.h, cam16_color.c, is_contrast ? 90.0 : 80.0)) :
    Color.hct_blend (Color.from_params (61.0, 30.0, is_contrast ? 20.0 : 40.0), Color.from_params (cam16_color.h, cam16_color.c, is_contrast ? 20.0 : 40.0)) ;
    var gluon_brown_hex = Color.hct_to_hex (gluon_brown_hct.h, gluon_brown_hct.c, gluon_brown_hct.t);

    string css = "";
    css = @"
    @define-color accent_color $(chosen_scheme.primary_hex);
    @define-color accent_bg_color $(chosen_scheme.primary_hex);
    @define-color accent_fg_color $(chosen_scheme.on_primary_hex);
    @define-color accent_container_color $(chosen_scheme.primary_container_hex);
    @define-color accent_container_bg_color $(chosen_scheme.primary_container_hex);
    @define-color accent_container_fg_color $(chosen_scheme.on_primary_container_hex);

    @define-color window_bg_color $(chosen_scheme.surface_bg_hex);
    @define-color view_bg_color $(chosen_scheme.surface_bg_hex);
    @define-color headerbar_bg_color $(chosen_scheme.surface_bg_variant_hex);
    @define-color popover_bg_color $(chosen_scheme.surface_container_high_bg_hex);
    @define-color card_bg_color $(chosen_scheme.surface_container_bg_hex);
    @define-color window_fg_color $(chosen_scheme.surface_fg_hex);
    @define-color view_fg_color $(chosen_scheme.surface_fg_variant_hex);
    @define-color headerbar_fg_color $(chosen_scheme.surface_fg_variant_hex);
    @define-color popover_fg_color $(chosen_scheme.surface_fg_hex);
    @define-color card_fg_color $(chosen_scheme.surface_fg_hex);

    @define-color surface_bright_bg_color $(chosen_scheme.surface_bright_bg_hex);
    @define-color surface_bg_color $(chosen_scheme.surface_bg_hex);
    @define-color surface_dim_bg_color $(chosen_scheme.surface_dim_bg_hex);
    @define-color surface_container_lowest_bg_color $(chosen_scheme.surface_container_lowest_bg_hex);
    @define-color surface_container_low_bg_color $(chosen_scheme.surface_container_low_bg_hex);
    @define-color surface_container_bg_color $(chosen_scheme.surface_container_bg_hex);
    @define-color surface_container_high_bg_color $(chosen_scheme.surface_container_high_bg_hex);
    @define-color surface_container_highest_bg_color $(chosen_scheme.surface_container_highest_bg_hex);
    ";

    css += @"
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
    @define-color error_container_color $error_container_hex;
    @define-color error_container_bg_color $error_container_hex;
    @define-color error_container_fg_color $on_error_container_hex;

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
    @define-color osd_bg_color $(chosen_scheme.inverse_surface_bg_hex);
    @define-color osd_fg_color $(chosen_scheme.inverse_surface_fg_hex);
    @define-color osd_accent_color $(chosen_scheme.inverse_primary_hex);
    ";

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

    var light_weight = (300 * font_weight);
    var heavy_weight = (700 * font_weight);

    css += @"
    label,
    .view-switcher button label,
    .big-display,
    .view-subtitle,
    .cb-subtitle,
    .body {
      font-weight: $base_weight;
    }
    .large-title,
    .display,
    .view-title {
      font-weight: $light_weight;
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
    .badge label,
    .badge-info label,
    .tint-badge label,
    .modifier-badge label {
      font-weight: $heavy_weight;
    }
    ";

    var small_roundness = (0.5 * base_roundness).to_string () + "px";
    var medium_roundness = (1 * base_roundness).to_string () + "px";
    var large_roundness = (2 * base_roundness).to_string () + "px";
    var x_large_roundness = (3 * base_roundness).to_string () + "px";
    var circle_roundness = (12.5 * base_roundness).to_string () + "px";

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

    .view-switcher button.toggle {
      border-radius: 0px;
    }
    .badge,
    .badge-info,
    .tint-badge,
    .modifier-badge {
      border-radius: $small_roundness;
    }
    button,
    .toast-box,
    .text-view,
    windowcontrols > button > image,
    popover > contents,
    check {
      border-radius: $medium_roundness;
    }
    .text-field,
    .navigation-section-button,
    scale > trough,
    scale > trough > slider,
    window.csd {
      border-radius: $large_roundness;
    }
    .content-block,
    .mini-content-block,
    .bottom-bar,
    .dialog-content,
    .switchbar,
    .navigation-section-list row .mini-content-block,
    window.csd.dialog.message,
    window.csd.dialog-content {
      border-radius: $x_large_roundness;
    }
    .disclosure-button,
    .disclosure-button .toggle,
    .overlay-button,
    .iconic-button,
    .text-field.search,
    switch,
    switch > slider,
    radio {
      border-radius: $circle_roundness;
    }
    .content-list row:first-child .mini-content-block {
      border-top-left-radius: $x_large_roundness;
	    border-top-right-radius: $x_large_roundness;
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
      border-bottom-left-radius: $x_large_roundness;
      border-bottom-right-radius: $x_large_roundness;
    }
    .segmented-button > button:not(:first-child),
    .segmented-button > button:not(:last-child) {
        border-top-left-radius: 0;
        border-bottom-left-radius: 0;
        border-top-right-radius: 0;
        border-bottom-right-radius: 0;
    }
    .segmented-button button:first-child {
        border-top-left-radius: $x_large_roundness;
        border-bottom-left-radius: $x_large_roundness;
    }
    .segmented-button button:first-child:dir(rtl) {
        border-top-right-radius: $x_large_roundness;
        border-bottom-right-radius: $x_large_roundness;
    }
    .segmented-button button:last-child {
        border-top-right-radius: $x_large_roundness;
        border-bottom-right-radius: $x_large_roundness;
    }
    .segmented-button button:last-child:dir(rtl) {
        border-top-left-radius: $x_large_roundness;
        border-bottom-left-radius: $x_large_roundness;
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

    Misc.init_css_provider_from_string (accent, css);
    Misc.toggle_style_provider (light, !is_dark, STYLE_PROVIDER_PRIORITY_PLATFORM);
    Misc.toggle_style_provider (dark, is_dark, STYLE_PROVIDER_PRIORITY_PLATFORM);
    Misc.toggle_style_provider (user_dark, is_dark, STYLE_PROVIDER_PRIORITY_USER_DARK);

    var settings = Gtk.Settings.get_default ();
    settings.gtk_application_prefer_dark_theme = is_dark;
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
