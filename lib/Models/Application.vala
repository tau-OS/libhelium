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
  private He.Desktop desktop = new He.Desktop ();


  /**
  * The applied accent color.
  */
  private string? _accent_color;
  public string accent_color {
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
  private string? _foreground;
  public string foreground {
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
  private string? _accent_foreground;
  public string accent_foreground {
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
    lch_color.l = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 0 : 108.8840;

    var derived_fg = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? He.Color.BLACK : He.Color.WHITE;
    var fg_contrast = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 8.0 : 7.0;
    var bg_contrast = Desktop.ColorScheme.DARK == desktop.prefers_color_scheme ? 10.0 : 9.0;

    var derived_accent_as_fg = He.Color.derive_contasting_color(lch_color, fg_contrast, null);
    var derived_bg = He.Color.derive_contasting_color(lch_color, bg_contrast, null);

    var derived_accent_as_rgb_bg = He.Color.lab_to_rgb (He.Color.lch_to_lab(derived_bg));
    var derived_accent_as_rgb_fg = He.Color.lab_to_rgb (He.Color.lch_to_lab(derived_accent_as_fg));

    accent_color = Color.hexcode ((double) derived_accent_as_rgb_bg.r, (double) derived_accent_as_rgb_bg.g, (double) derived_accent_as_rgb_bg.b);
    accent_foreground = Color.hexcode ((double) derived_accent_as_rgb_fg.r, (double) derived_accent_as_rgb_fg.g, (double) derived_accent_as_rgb_fg.b);
    foreground = Color.hexcode ((double) derived_fg.r, (double) derived_fg.g, (double) derived_fg.b);

    warning ("accent color is %s", accent_color);
    warning ("accent foreground is %s", accent_foreground);
    warning ("foreground is %s", foreground);

    var css = @"
      @define-color accent_bg_color $accent_color;
      @define-color accent_fg_color $foreground;
      @define-color accent_color $accent_foreground;
    ";
    accent.load_from_data (css.data);
}
  
  private void init_style_providers () {
    // Setup the dark preference theme loading
    light.load_from_resource ("/co/tauos/helium/gtk.css");
    dark.load_from_resource ("/co/tauos/helium/gtk-dark.css");

    if (desktop.prefers_color_scheme == He.Desktop.ColorScheme.DARK) {
      style_provider_set_enabled (dark, true);
      style_provider_set_enabled (light, false);
    } else {
      style_provider_set_enabled (light, true);
      style_provider_set_enabled (dark, false);
    }

    style_provider_set_enabled (accent, true);

    desktop.notify["prefers-color-scheme"].connect (() => {
      if (desktop.prefers_color_scheme == He.Desktop.ColorScheme.DARK) {
        update_accent_color();
        style_provider_set_enabled (dark, true);
        style_provider_set_enabled (light, false);
      } else {
        update_accent_color();
        style_provider_set_enabled (light, true);
        style_provider_set_enabled (dark, false);
      }
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
    Gtk.CssProvider base_provider = new Gtk.CssProvider ();
    
    if (base_file.get_child ("style-dark.css").query_exists (null)) {
        if (desktop.prefers_color_scheme == He.Desktop.ColorScheme.DARK) {
            init_provider_from_file (base_provider, base_file.get_child ("style-dark.css"));
        } else {
            init_provider_from_file (base_provider, base_file.get_child ("style.css"));
        }
    } else {
        warning ("Dark Styling not found. Proceeding anyway.");
    }
    
    if (base_provider != null) {
        style_provider_set_enabled (base_provider, true);
    }
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
  
  private void style_provider_set_enabled (Gtk.CssProvider provider, bool enabled) {
    Gdk.Display display = Gdk.Display.get_default ();

    if (display == null)
      return;

    if (enabled) {
      Gtk.StyleContext.add_provider_for_display (display, provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
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
    init_style_providers ();
    init_app_providers ();
  }

  public Application(string? application_id, ApplicationFlags flags) {
    this.application_id = application_id;
    this.flags = flags;
  }
}
