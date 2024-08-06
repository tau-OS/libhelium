/*
 * Copyright (c) 2022 Fyra Labs
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
  private He.Color.RGBColor? _default_accent_color = null;
  public He.Color.RGBColor? default_accent_color {
    get { return _default_accent_color; }
    set { _default_accent_color = value; update_style_manager (); }
  }

  /**
   * Whether to override the user's accent color choice. This requires default_accent_color to be set.
   */
  private bool _override_accent_color = false;
  public bool override_accent_color {
    get { return _override_accent_color; }
    set { _override_accent_color = value; update_style_manager (); }
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
   * Values are: 1.0 = low, 2.0 = default, 3.0 = medium, 4.0 = high.
   * Only works if override_contrast is TRUE.
   */
  private double _default_contrast = 2.0;
  public double default_contrast {
    get { return _default_contrast; }
    set { _default_contrast = value.clamp(1.0, 4.0); update_style_manager (); }
  }

  /**
   * A scheme factory to use for the application. If not set, the user's preferred scheme will be used.
   * This is especially useful for applications with their own color needs, such as media applications using the Content factory.
   */
  private SchemeFactory? _scheme_factory = null;
  public SchemeFactory? scheme_factory {
    get { return _scheme_factory; }
    set { _scheme_factory = value; update_style_manager (); }
  }

  private void update_style_manager () {
    if (default_accent_color != null && override_accent_color) {
      style_manager.accent_color = default_accent_color;
    } else if (desktop.accent_color != null) {
      style_manager.accent_color = desktop.accent_color;
    } else {
      style_manager.accent_color = default_accent_color;
    }

    if (scheme_factory != null) {
      style_manager.scheme_factory = scheme_factory;
    } else if (scheme_factory != null && override_accent_color) {
      style_manager.scheme_factory = new ContentScheme ();
    } else {
      style_manager.scheme_factory = desktop.ensor_scheme.to_factory ();
    }

    if (override_dark_style) {
      style_manager.is_dark = true;
    } else {
      style_manager.is_dark = desktop.prefers_color_scheme == Desktop.ColorScheme.DARK;
    }

    if (override_contrast && default_contrast != 0.0) {
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

    desktop.notify["accent-color"].connect (update_style_manager);
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