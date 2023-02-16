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
  
  private void update_accent_color () {
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
    
    if (Desktop.DarkModeStrength.MEDIUM == desktop.dark_mode_strength) {
      derived_card_bg = He.Color.CARD_BLACK;
    } else if (Desktop.DarkModeStrength.SOFT == desktop.dark_mode_strength) {
      derived_card_bg = He.Color.SOFT_CARD_BLACK;
    } else if (Desktop.DarkModeStrength.HARSH == desktop.dark_mode_strength) {
      derived_card_bg = He.Color.HARSH_CARD_BLACK;
    }
    var background_hex = Color.hexcode (derived_card_bg.r, derived_card_bg.g, derived_card_bg.b);
    
    var scheme_default = new He.Schemes.Default (cam16_color, desktop);
    
    string css = "";
    if (desktop.prefers_color_scheme == Desktop.ColorScheme.DARK) {
      css = @"
      @define-color accent_color $(scheme_default.primary_hex);
      @define-color accent_bg_color $(scheme_default.primary_hex);
      @define-color accent_fg_color $(scheme_default.on_primary_hex);
      
      @define-color accent_container_color $(scheme_default.primary_container_hex);
      @define-color accent_container_bg_color $(scheme_default.primary_container_hex);
      @define-color accent_container_fg_color $(scheme_default.on_primary_container_hex);
      
      @define-color window_bg_color mix($(scheme_default.neutral_background_hex), $background_hex, 0.5);
      @define-color view_bg_color mix($(scheme_default.neutral_background_hex), $background_hex, 0.5);
      @define-color headerbar_bg_color mix($(scheme_default.neutral_background_variant_hex), $background_hex, 0.5);
      @define-color popover_bg_color mix($(scheme_default.neutral_background_hex), $background_hex, 0.5);
      @define-color card_bg_color mix($(scheme_default.neutral_background_hex), $background_hex, 0.5);
      
      @define-color window_fg_color $(scheme_default.neutral_foreground_hex);
      @define-color view_fg_color $(scheme_default.neutral_foreground_hex);
      @define-color headerbar_fg_color $(scheme_default.neutral_foreground_hex);
      @define-color popover_fg_color $(scheme_default.neutral_foreground_hex);
      @define-color card_fg_color $(scheme_default.neutral_foreground_hex);
      
      @define-color destructive_bg_color $(scheme_default.error_hex);
      @define-color destructive_fg_color $(scheme_default.on_error_hex);
      @define-color destructive_color $(scheme_default.error_hex);
      
      @define-color destructive_container_color $(scheme_default.on_error_container_hex);
      @define-color destructive_container_bg_color $(scheme_default.error_container_hex);
      @define-color destructive_container_fg_color $(scheme_default.on_error_container_hex);
      
      @define-color suggested_bg_color $(scheme_default.secondary_hex);
      @define-color suggested_fg_color $(scheme_default.on_secondary_hex);
      @define-color suggested_color $(scheme_default.secondary_hex);
      
      @define-color suggested_container_color $(scheme_default.secondary_container_hex);
      @define-color suggested_container_bg_color $(scheme_default.secondary_container_hex);
      @define-color suggested_container_fg_color $(scheme_default.on_secondary_container_hex);
      
      @define-color error_bg_color $(scheme_default.error_hex);
      @define-color error_fg_color $(scheme_default.on_error_hex);
      @define-color error_color $(scheme_default.error_hex);
      
      @define-color error_container_color $(scheme_default.on_error_container_hex);
      @define-color error_container_bg_color $(scheme_default.error_container_hex);
      @define-color error_container_fg_color $(scheme_default.error_container_hex);
      
      @define-color success_bg_color $(scheme_default.tertiary_hex);
      @define-color success_fg_color $(scheme_default.on_tertiary_hex);
      @define-color success_color $(scheme_default.tertiary_hex);
      
      @define-color success_container_color $(scheme_default.tertiary_container_hex);
      @define-color success_container_bg_color $(scheme_default.tertiary_container_hex);
      @define-color success_container_fg_color $(scheme_default.on_tertiary_container_hex);
      
      @define-color outline $(scheme_default.outline_hex);
      @define-color borders $(scheme_default.outline_variant_hex);
      
      @define-color shadow $(scheme_default.shadow_hex);
      @define-color scrim $(scheme_default.scrim_hex);
      
      @define-color osd_bg_color $(scheme_default.inverse_neutral_background_hex);
      @define-color osd_fg_color $(scheme_default.inverse_neutral_foreground_hex);
      @define-color osd_accent_color $(scheme_default.inverse_primary_hex);
      ";
    } else {
      css = @"
      @define-color accent_color $(scheme_default.primary_hex);
      @define-color accent_bg_color $(scheme_default.primary_hex);
      @define-color accent_fg_color $(scheme_default.on_primary_hex);
      
      @define-color accent_container_color $(scheme_default.primary_container_hex);
      @define-color accent_container_bg_color $(scheme_default.primary_container_hex);
      @define-color accent_container_fg_color $(scheme_default.on_primary_container_hex);
      
      @define-color window_bg_color $(scheme_default.neutral_background_hex);
      @define-color view_bg_color $(scheme_default.neutral_background_hex);
      @define-color headerbar_bg_color $(scheme_default.neutral_background_variant_hex);
      @define-color popover_bg_color $(scheme_default.neutral_background_hex);
      @define-color card_bg_color $(scheme_default.neutral_background_hex);
      
      @define-color window_fg_color $(scheme_default.neutral_foreground_hex);
      @define-color view_fg_color $(scheme_default.neutral_foreground_hex);
      @define-color headerbar_fg_color $(scheme_default.neutral_foreground_hex);
      @define-color popover_fg_color $(scheme_default.neutral_foreground_hex);
      @define-color card_fg_color $(scheme_default.neutral_foreground_hex);
      
      @define-color destructive_bg_color $(scheme_default.error_hex);
      @define-color destructive_fg_color $(scheme_default.on_error_hex);
      @define-color destructive_color $(scheme_default.error_hex);
      
      @define-color destructive_container_color $(scheme_default.on_error_container_hex);
      @define-color destructive_container_bg_color $(scheme_default.error_container_hex);
      @define-color destructive_container_fg_color $(scheme_default.on_error_container_hex);
      
      @define-color suggested_bg_color $(scheme_default.secondary_hex);
      @define-color suggested_fg_color $(scheme_default.on_secondary_hex);
      @define-color suggested_color $(scheme_default.secondary_hex);
      
      @define-color suggested_container_color $(scheme_default.secondary_container_hex);
      @define-color suggested_container_bg_color $(scheme_default.secondary_container_hex);
      @define-color suggested_container_fg_color $(scheme_default.on_secondary_container_hex);
      
      @define-color error_bg_color $(scheme_default.error_hex);
      @define-color error_fg_color $(scheme_default.on_error_hex);
      @define-color error_color $(scheme_default.error_hex);
      
      @define-color error_container_color $(scheme_default.on_error_container_hex);
      @define-color error_container_bg_color $(scheme_default.error_container_hex);
      @define-color error_container_fg_color $(scheme_default.error_container_hex);
      
      @define-color success_bg_color $(scheme_default.tertiary_hex);
      @define-color success_fg_color $(scheme_default.on_tertiary_hex);
      @define-color success_color $(scheme_default.tertiary_hex);
      
      @define-color success_container_color $(scheme_default.tertiary_container_hex);
      @define-color success_container_bg_color $(scheme_default.tertiary_container_hex);
      @define-color success_container_fg_color $(scheme_default.on_tertiary_container_hex);
      
      @define-color outline $(scheme_default.outline_hex);
      @define-color borders $(scheme_default.outline_variant_hex);
      
      @define-color shadow $(scheme_default.shadow_hex);
      @define-color scrim $(scheme_default.scrim_hex);
      
      @define-color osd_bg_color $(scheme_default.inverse_neutral_background_hex);
      @define-color osd_fg_color $(scheme_default.inverse_neutral_foreground_hex);
      @define-color osd_accent_color $(scheme_default.inverse_primary_hex);
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
