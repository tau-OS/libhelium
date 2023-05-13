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
  public He.Color.RGBColor? default_accent_color {
    get { return _default_accent_color; }
    set { _default_accent_color = value; update_style_manager (); }
  }
  private He.Color.RGBColor? _default_accent_color = null;

  /**
  * Whether to override the user's accent color choice. This requires default_accent_color to be set.
  */
  public bool override_accent_color {
    get { return _override_accent_color; }
    set { _override_accent_color = value; update_style_manager ();}
  }
  private bool _override_accent_color = false;

  /**
  * A scheme factory to use for the application. If not set, the user's preferred scheme will be used.
  * This is especially useful for applications with their own color needs, such as media applications using the He.new_content_scheme factory.
  */
  public SchemeFactory? scheme_factory {
    get { return _scheme_factory; }
    set { _scheme_factory = value; update_style_manager (); }
  }
  private SchemeFactory? _scheme_factory = null;

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
    } else {
      style_manager.scheme_factory = desktop.ensor_scheme.to_factory ();
    }

    style_manager.is_dark = desktop.prefers_color_scheme == Desktop.ColorScheme.DARK;
    style_manager.dark_mode_strength = desktop.dark_mode_strength;
    style_manager.font_weight = desktop.font_weight;

    style_manager.update ();
  }

  protected override void startup () {
    base.startup ();
    He.init ();

    update_style_manager ();

    desktop.notify["prefers-color-scheme"].connect (update_style_manager);
    desktop.notify["dark-mode-strength"].connect (update_style_manager);
    desktop.notify["ensor-scheme"].connect (update_style_manager);
    desktop.notify["font-weight"].connect (update_style_manager);

    style_manager.register ();
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
