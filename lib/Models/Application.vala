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
    (int) (0.7450 * 255),
    (int) (0.6270 * 255),
    (int) (0.8590 * 255)
  };

  private He.Color.RGBColor default_light_accent = {
    (int) (0.5490 * 255),
    (int) (0.3370 * 255),
    (int) (0.7490 * 255)
  };

  /**
  * A default accent color if the user has not set one.
  */
  public He.Color.RGBColor? default_accent_color { get; set; }

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

    var lch_color = He.Color.rgb_to_lch (rgb_color);
    lch_color.l = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 0 : 109.0;

    if (dark_mode_strength = Desktop.DarkModeStrength.MEDIUM) {
      var derived_fg = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? He.Color.WHITE : He.Color.BLACK;
      var derived_bg = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? He.Color.BLACK : He.Color.WHITE;

      var derived_card_fg = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? He.Color.CARD_BLACK : He.Color.CARD_WHITE;
      var derived_card_bg = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? He.Color.CARD_BLACK : He.Color.CARD_WHITE;
    } else if (dark_mode_strength = Desktop.DarkModeStrength.SOFT) {
      var derived_fg = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? He.Color.WHITE : He.Color.SOFT_BLACK;
      var derived_bg = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? He.Color.SOFT_BLACK : He.Color.WHITE;

      var derived_card_fg = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? He.Color.SOFT_CARD_BLACK : He.Color.CARD_WHITE;
      var derived_card_bg = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? He.Color.SOFT_CARD_BLACK : He.Color.CARD_WHITE;
    } else if (dark_mode_strength = Desktop.DarkModeStrength.HARSH) {
      var derived_fg = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? He.Color.WHITE : He.Color.HARSH_BLACK;
      var derived_bg = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? He.Color.HARSH_BLACK : He.Color.WHITE;

      var derived_card_fg = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? He.Color.HARSH_CARD_BLACK : He.Color.CARD_WHITE;
      var derived_card_bg = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? He.Color.HARSH_CARD_BLACK : He.Color.CARD_WHITE;
    } else {
      var derived_fg = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? He.Color.WHITE : He.Color.BLACK;
      var derived_bg = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? He.Color.BLACK : He.Color.WHITE;

      var derived_card_fg = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? He.Color.CARD_BLACK : He.Color.CARD_WHITE;
      var derived_card_bg = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? He.Color.CARD_BLACK : He.Color.CARD_WHITE;
    }

    var fg_contrast = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 12.0 : 7.0;
    var bg_contrast = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 10.0 : 9.0;

    var derived_accent_as_fg = He.Color.derive_contasting_color(lch_color, fg_contrast, null);
    var derived_bg_c = He.Color.derive_contasting_color(lch_color, bg_contrast, null);
    if (dark_mode_strength = Desktop.DarkModeStrength.MEDIUM) {
      var derived_accent_fg = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? He.Color.BLACK : He.Color.WHITE;
    } else if (dark_mode_strength = Desktop.DarkModeStrength.SOFT) {
      var derived_accent_fg = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? He.Color.SOFT_BLACK : He.Color.WHITE;
    } else if (dark_mode_strength = Desktop.DarkModeStrength.HARSH) {
      var derived_accent_fg = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? He.Color.HARSH_BLACK : He.Color.WHITE;
    } else {
      var derived_accent_fg = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? He.Color.BLACK : He.Color.WHITE;
    }
    var derived_accent_as_rgb_bg = He.Color.lab_to_rgb (He.Color.lch_to_lab(derived_bg_c));
    var derived_accent_as_rgb_fg = He.Color.lab_to_rgb (He.Color.lch_to_lab(derived_accent_as_fg));

    this.accent_color = derived_accent_as_rgb_bg;
    this.foreground = derived_fg;
    this.accent_foreground = derived_accent_as_rgb_fg;

    var base_foreground_hex = Color.hexcode ((double) derived_fg.r, (double) derived_fg.g, (double) derived_fg.b);
    var base_background_hex = Color.hexcode ((double) derived_bg.r, (double) derived_bg.g, (double) derived_bg.b);

    var card_foreground_hex = Color.hexcode ((double) derived_card_fg.r, (double) derived_card_fg.g, (double) derived_card_fg.b);
    var card_background_hex = Color.hexcode ((double) derived_card_bg.r, (double) derived_card_bg.g, (double) derived_card_bg.b);

    var accent_color_hex = Color.hexcode ((double) derived_accent_as_rgb_bg.r, (double) derived_accent_as_rgb_bg.g, (double) derived_accent_as_rgb_bg.b);
    var accent_foreground_hex = Color.hexcode ((double) derived_accent_fg.r, (double) derived_accent_fg.g, (double) derived_accent_fg.b);
    var accent_color_foreground_hex = Color.hexcode ((double) derived_accent_as_rgb_fg.r, (double) derived_accent_as_rgb_fg.g, (double) derived_accent_as_rgb_fg.b);

    var css = @"
      @define-color accent_color $accent_color_foreground_hex;
      @define-color accent_bg_color $accent_color_hex;
      @define-color accent_fg_color $accent_foreground_hex;

      @define-color window_bg_color $base_background_hex;
      @define-color view_bg_color $card_background_hex;
      @define-color headerbar_bg_color shade($base_background_hex, 0.96);
      @define-color popover_bg_color $base_background_hex;
      @define-color card_bg_color $card_background_hex;

      @define-color window_fg_color $base_foreground_hex;
      @define-color view_fg_color $base_foreground_hex;
      @define-color headerbar_fg_color $base_foreground_hex;
      @define-color popover_fg_color $base_foreground_hex;
      @define-color card_fg_color $card_foreground_hex;
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
