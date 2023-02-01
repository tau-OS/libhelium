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

  private void update_accent_color() {
    He.Color.RGBColor rgb_color;

    if (desktop.accent_color == null) {
      if (default_accent_color != null) {
        rgb_color = default_accent_color;
      } else {
        rgb_color = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? default_dark_accent : default_light_accent;
      }
    } else {
      rgb_color = desktop.accent_color;
    }

    var cam16_color = He.Color.xyz_to_cam16 (He.Color.rgb_to_xyz (rgb_color));
    var lch_color = He.Color.rgb_to_lch (rgb_color);
    lch_color.l = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 0 : 100.0;
    var hct_color = He.Color.cam16_and_lch_to_hct (cam16_color, lch_color);

    if (Desktop.DarkModeStrength.MEDIUM == desktop.dark_mode_strength) {
      derived_card_bg = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? He.Color.CARD_BLACK : He.Color.CARD_WHITE;
    } else if (Desktop.DarkModeStrength.SOFT == desktop.dark_mode_strength) {
      derived_card_bg = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? He.Color.SOFT_CARD_BLACK : He.Color.CARD_WHITE;
    } else if (Desktop.DarkModeStrength.HARSH == desktop.dark_mode_strength) {
      derived_card_bg = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? He.Color.HARSH_CARD_BLACK : He.Color.CARD_WHITE;
    } else {
      derived_card_bg = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? He.Color.CARD_BLACK : He.Color.CARD_WHITE;
    }
    var card_background_hex = Color.hexcode (derived_card_bg.r, derived_card_bg.g, derived_card_bg.b);

    // _  _ ____ _  _ ___ ____ ____ _    
    // |\ | |___ |  |  |  |__/ |__| |    
    // | \| |___ |__|  |  |  \ |  | |___
    var derived_card_background = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ?
                                        He.Color.derive_contrasting_color({hct_color.h, Math.fmin(hct_color.c / 12.0, 4.0), 10.0}, lch_color, 0, null) :
                                        He.Color.derive_contrasting_color({hct_color.h, Math.fmin(hct_color.c / 12.0, 4.0), 99.0}, lch_color, 0, null);
    var derived_card_background_rgb = He.Color.lab_to_rgb (He.Color.lch_to_lab(derived_card_background));
    var card_neutral_background_hex = Color.hexcode (derived_card_background_rgb.r, derived_card_background_rgb.g, derived_card_background_rgb.b);

    var derived_background_variant = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ?
                                     He.Color.derive_contrasting_color({hct_color.h, Math.fmin(hct_color.c / 12.0, 4.0), 30.0}, lch_color, 0, null) :
                                     He.Color.derive_contrasting_color({hct_color.h, Math.fmin(hct_color.c / 12.0, 4.0), 90.0}, lch_color, 0, null);
    var derived_background_variant_rgb = He.Color.lab_to_rgb (He.Color.lch_to_lab(derived_background_variant));
    var card_neutral_background_variant_hex = Color.hexcode (derived_background_variant_rgb.r, derived_background_variant_rgb.g, derived_background_variant_rgb.b);

    var derived_card_foreground = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ?
                                        He.Color.derive_contrasting_color({hct_color.h, Math.fmin(hct_color.c / 12.0, 4.0), 99.0}, lch_color, 0, null) :
                                        He.Color.derive_contrasting_color({hct_color.h, Math.fmin(hct_color.c / 12.0, 4.0), 10.0}, lch_color, 0, null);
    var derived_card_foreground_rgb = He.Color.lab_to_rgb (He.Color.lch_to_lab(derived_card_foreground));
    var card_neutral_foreground_hex = Color.hexcode (derived_card_foreground_rgb.r, derived_card_foreground_rgb.g, derived_card_foreground_rgb.b);

    // ___  ____ _ _  _ ____ ____ _   _ 
    // |__] |__/ | |\/| |__| |__/  \_/  
    // |    |  \ | |  | |  | |  \   | 
    var derived_primary = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ?
                             He.Color.derive_contrasting_color({hct_color.h, hct_color.c, 80.0}, lch_color, 0, null) :
                             He.Color.derive_contrasting_color({hct_color.h, hct_color.c, 40.0}, lch_color, 0, null);
    var derived_primary_rgb = He.Color.lab_to_rgb (He.Color.lch_to_lab(derived_primary));
    var primary_hex = Color.hexcode (derived_primary_rgb.r, derived_primary_rgb.g, derived_primary_rgb.b);

    var derived_on_primary = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ?
                                He.Color.derive_contrasting_color({hct_color.h, hct_color.c, 20.0}, lch_color, 0, null) :
                                He.Color.derive_contrasting_color({hct_color.h, hct_color.c, 100.0}, lch_color, 0, null);
    var derived_on_primary_rgb = He.Color.lab_to_rgb (He.Color.lch_to_lab(derived_on_primary));
    var on_primary_hex = Color.hexcode (derived_on_primary_rgb.r, derived_on_primary_rgb.g, derived_on_primary_rgb.b);

    var derived_primary_container = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ?
                                       He.Color.derive_contrasting_color({hct_color.h, hct_color.c, 30.0}, lch_color, 0, null) :
                                       He.Color.derive_contrasting_color({hct_color.h, hct_color.c, 90.0}, lch_color, 0, null);
    var derived_primary_container_rgb = He.Color.lab_to_rgb (He.Color.lch_to_lab(derived_primary_container));
    var primary_container_hex = Color.hexcode (derived_primary_container_rgb.r, derived_primary_container_rgb.g, derived_primary_container_rgb.b);

    var derived_on_primary_container = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ?
                                          He.Color.derive_contrasting_color({hct_color.h, hct_color.c, 90.0}, lch_color, 0, null) :
                                          He.Color.derive_contrasting_color({hct_color.h, hct_color.c, 10.0}, lch_color, 0, null);
    var derived_on_primary_container_rgb = He.Color.lab_to_rgb (He.Color.lch_to_lab(derived_on_primary_container));
    var on_primary_container_hex = Color.hexcode (derived_on_primary_container_rgb.r, derived_on_primary_container_rgb.g, derived_on_primary_container_rgb.b);

    // ____ ____ ____ ____ ____ 
    // |___ |__/ |__/ |  | |__/ 
    // |___ |  \ |  \ |__| |  \
    var derived_error = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ?
                           He.Color.derive_contrasting_color({25 * 0.0175, 84.0, 80.0}, lch_color, 0, null) :
                           He.Color.derive_contrasting_color({25 * 0.0175, 84.0, 40.0}, lch_color, 0, null);
    var derived_error_rgb = He.Color.lab_to_rgb (He.Color.lch_to_lab(derived_error));
    var error_hex = Color.hexcode (derived_error_rgb.r, derived_error_rgb.g, derived_error_rgb.b);

    var derived_on_error = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ?
                              He.Color.derive_contrasting_color({25 * 0.0175, 84.0, 20.0}, lch_color, 0, null) :
                              He.Color.derive_contrasting_color({25 * 0.0175, 84.0, 100.0}, lch_color, 0, null);
    var derived_on_error_rgb = He.Color.lab_to_rgb (He.Color.lch_to_lab(derived_on_error));
    var on_error_hex = Color.hexcode (derived_on_error_rgb.r, derived_on_error_rgb.g, derived_on_error_rgb.b);

    var derived_error_container_fg = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ?
                           He.Color.derive_contrasting_color({25 * 0.0175, 84.0, 80.0}, lch_color, 0, null) :
                           He.Color.derive_contrasting_color({25 * 0.0175, 84.0, 40.0}, lch_color, 0, null);
    var derived_error_container_rgb = He.Color.lab_to_rgb (He.Color.lch_to_lab(derived_error_container_fg));
    var error_container_hex = Color.hexcode (derived_error_container_rgb.r, derived_error_container_rgb.g, derived_error_container_rgb.b);

    var derived_on_error_container_fg = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ?
                              He.Color.derive_contrasting_color({25 * 0.0175, 84.0, 20.0}, lch_color, 0, null) :
                              He.Color.derive_contrasting_color({25 * 0.0175, 84.0, 100.0}, lch_color, 0, null);
    var derived_on_error_container_rgb = He.Color.lab_to_rgb (He.Color.lch_to_lab(derived_on_error_container_fg));
    var on_error_container_hex = Color.hexcode (derived_on_error_container_rgb.r, derived_on_error_container_rgb.g, derived_on_error_container_rgb.b);

    // ____ ____ ____ ____ _  _ ___  ____ ____ _   _ 
    // [__  |___ |    |  | |\ | |  \ |__| |__/  \_/  
    // ___] |___ |___ |__| | \| |__/ |  | |  \   |
    var derived_secondary = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ?
                               He.Color.derive_contrasting_color({hct_color.h, hct_color.c / 3.0, 80.0}, lch_color, 0, null) :
                               He.Color.derive_contrasting_color({hct_color.h, hct_color.c / 3.0, 40.0}, lch_color, 0, null);
    var derived_secondary_rgb = He.Color.lab_to_rgb (He.Color.lch_to_lab(derived_secondary));
    var secondary_hex = Color.hexcode (derived_secondary_rgb.r, derived_secondary_rgb.g, derived_secondary_rgb.b);

    var derived_on_secondary = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ?
                                  He.Color.derive_contrasting_color({hct_color.h, hct_color.c / 3.0, 20.0}, lch_color, 0, null) :
                                  He.Color.derive_contrasting_color({hct_color.h, hct_color.c / 3.0, 100.0}, lch_color, 0, null);
    var derived_on_secondary_rgb = He.Color.lab_to_rgb (He.Color.lch_to_lab(derived_on_secondary));
    var on_secondary_hex = Color.hexcode (derived_on_secondary_rgb.r, derived_on_secondary_rgb.g, derived_on_secondary_rgb.b);

    var derived_secondary_container = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ?
                               He.Color.derive_contrasting_color({hct_color.h, hct_color.c / 3.0, 30.0}, lch_color, 0, null) :
                               He.Color.derive_contrasting_color({hct_color.h, hct_color.c / 3.0, 90.0}, lch_color, 0, null);
    var derived_secondary_container_rgb = He.Color.lab_to_rgb (He.Color.lch_to_lab(derived_secondary_container));
    var secondary_container_hex = Color.hexcode (derived_secondary_container_rgb.r, derived_secondary_container_rgb.g, derived_secondary_container_rgb.b);

    var derived_on_secondary_container = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ?
                                  He.Color.derive_contrasting_color({hct_color.h, hct_color.c / 3.0, 90.0}, lch_color, 0, null) :
                                  He.Color.derive_contrasting_color({hct_color.h, hct_color.c / 3.0, 10.0}, lch_color, 0, null);
    var derived_on_secondary_container_rgb = He.Color.lab_to_rgb (He.Color.lch_to_lab(derived_on_secondary_container));
    var on_secondary_container_hex = Color.hexcode (derived_on_secondary_container_rgb.r, derived_on_secondary_container_rgb.g, derived_on_secondary_container_rgb.b);


    // ___ ____ ____ ___ _ ____ ____ _   _ 
    //  |  |___ |__/  |  | |__| |__/  \_/  
    //  |  |___ |  \  |  | |  | |  \   |
    var derived_tertiary = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ?
                              He.Color.derive_contrasting_color({hct_color.h + 60.0 * 0.0175, hct_color.c / 2.0, 80.0}, lch_color, 0, null) :
                              He.Color.derive_contrasting_color({hct_color.h + 60.0 * 0.0175, hct_color.c / 2.0, 40.0}, lch_color, 0, null);
    var derived_tertiary_rgb = He.Color.lab_to_rgb (He.Color.lch_to_lab(derived_tertiary));
    var tertiary_hex = Color.hexcode (derived_tertiary_rgb.r, derived_tertiary_rgb.g, derived_tertiary_rgb.b);

    var derived_on_tertiary = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ?
                                 He.Color.derive_contrasting_color({hct_color.h + 60.0 * 0.0175, hct_color.c / 2.0, 20.0}, lch_color, 0, null) :
                                 He.Color.derive_contrasting_color({hct_color.h + 60.0 * 0.0175, hct_color.c / 2.0, 100.0}, lch_color, 0, null);
    var derived_on_tertiary_rgb = He.Color.lab_to_rgb (He.Color.lch_to_lab(derived_on_tertiary));
    var on_tertiary_hex = Color.hexcode (derived_on_tertiary_rgb.r, derived_on_tertiary_rgb.g, derived_on_tertiary_rgb.b);

    var derived_tertiary_container = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ?
                               He.Color.derive_contrasting_color({hct_color.h + 60.0 * 0.0175, hct_color.c / 2.0, 30.0}, lch_color, 0, null) :
                               He.Color.derive_contrasting_color({hct_color.h + 60.0 * 0.0175, hct_color.c / 2.0, 90.0}, lch_color, 0, null);
    var derived_tertiary_container_rgb = He.Color.lab_to_rgb (He.Color.lch_to_lab(derived_tertiary_container));
    var tertiary_container_hex = Color.hexcode (derived_tertiary_container_rgb.r, derived_tertiary_container_rgb.g, derived_tertiary_container_rgb.b);

    var derived_on_tertiary_container = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ?
                                  He.Color.derive_contrasting_color({hct_color.h + 60.0 * 0.0175, hct_color.c / 2.0, 90.0}, lch_color, 0, null) :
                                  He.Color.derive_contrasting_color({hct_color.h + 60.0 * 0.0175, hct_color.c / 2.0, 10.0}, lch_color, 0, null);
    var derived_on_tertiary_container_rgb = He.Color.lab_to_rgb (He.Color.lch_to_lab(derived_on_tertiary_container));
    var on_tertiary_container_hex = Color.hexcode (derived_on_tertiary_container_rgb.r, derived_on_tertiary_container_rgb.g, derived_on_tertiary_container_rgb.b);

    // ____ _  _ ___ _    _ _  _ ____ 
    // |  | |  |  |  |    | |\ | |___ 
    // |__| |__|  |  |___ | | \| |___
    var derived_border = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ?
                               He.Color.derive_contrasting_color({hct_color.h, Math.fmin(hct_color.c / 6.0, 8.0), 60.0}, lch_color, 0, null) :
                               He.Color.derive_contrasting_color({hct_color.h, Math.fmin(hct_color.c / 6.0, 8.0), 50.0}, lch_color, 0, null);
    var derived_border_rgb = He.Color.lab_to_rgb (He.Color.lch_to_lab(derived_border));
    var border_hex = Color.hexcode (derived_border_rgb.r, derived_border_rgb.g, derived_border_rgb.b);

    this.foreground = derived_on_primary_rgb;
    this.accent_color = derived_primary_rgb;
    this.accent_foreground = derived_primary_rgb;

    var css = @"
      @define-color accent_color $primary_hex;
      @define-color accent_bg_color $primary_hex;
      @define-color accent_fg_color $on_primary_hex;

      @define-color accent_container_color $primary_container_hex;
      @define-color accent_container_bg_color $primary_container_hex;
      @define-color accent_container_fg_color $on_primary_container_hex;

      @define-color window_bg_color mix($card_neutral_background_hex, $card_background_hex, 0.8);
      @define-color view_bg_color mix($card_neutral_background_hex, $card_background_hex, 0.8);
      @define-color headerbar_bg_color mix($card_neutral_background_variant_hex, $card_background_hex, 0.8);
      @define-color popover_bg_color mix($card_neutral_background_variant_hex, $card_background_hex, 0.8);
      @define-color card_bg_color mix($card_neutral_background_variant_hex, $card_background_hex, 0.8);

      @define-color window_fg_color $card_neutral_foreground_hex;
      @define-color view_fg_color $card_neutral_foreground_hex;
      @define-color headerbar_fg_color $card_neutral_foreground_hex;
      @define-color popover_fg_color $card_neutral_foreground_hex;
      @define-color card_fg_color $card_neutral_foreground_hex;

      @define-color destructive_bg_color $error_hex;
      @define-color destructive_fg_color $on_error_hex;
      @define-color destructive_color $error_hex;

      @define-color destructive_container_color $error_container_hex;
      @define-color destructive_container_bg_color $error_container_hex;
      @define-color destructive_container_fg_color $on_error_container_hex;

      @define-color suggested_bg_color $secondary_hex;
      @define-color suggested_fg_color $on_secondary_hex;
      @define-color suggested_color $secondary_hex;

      @define-color suggested_container_color $secondary_container_hex;
      @define-color suggested_container_bg_color $secondary_container_hex;
      @define-color suggested_container_fg_color $on_secondary_container_hex;

      @define-color error_bg_color $error_hex;
      @define-color error_color $on_error_hex;
      @define-color error_color $error_hex;

      @define-color error_container_color $error_container_hex;
      @define-color error_container_bg_color $error_container_hex;
      @define-color error_container_fg_color $on_error_container_hex;

      @define-color success_bg_color $tertiary_hex;
      @define-color success_fg_color $on_tertiary_hex;
      @define-color success_color $tertiary_hex;

      @define-color success_container_color $tertiary_container_hex;
      @define-color success_container_bg_color $tertiary_container_hex;
      @define-color success_container_fg_color $on_tertiary_container_hex;

      @define-color borders $border_hex;
    ";
    accent.load_from_data (css.data);
}
  
  private void init_style_providers () {
    // Setup the dark preference theme loading
    light.load_from_resource ("/co/tauos/helium/gtk.css");
    dark.load_from_resource ("/co/tauos/helium/gtk-dark.css");

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
        update_accent_color();
        
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
