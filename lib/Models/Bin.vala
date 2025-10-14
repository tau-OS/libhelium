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
 * A helper class for subclassing custom widgets.
 */
public class He.Bin : Gtk.Widget, Gtk.Buildable {
  private Gtk.Box box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
  private Gtk.CssProvider? color_provider = null;
  private string? cached_css = null;
  private He.Desktop desktop = new He.Desktop ();
  private He.Application? cached_app = null;
  private ulong app_accent_handler = 0;
  private const int COLOR_PROVIDER_PRIORITY = Gtk.STYLE_PROVIDER_PRIORITY_SETTINGS + 1;

  private bool _content_color_override = false;
  private RGBColor? _content_source_color = null;

  private Gtk.Widget? _child;
  public Gtk.Widget child {
    get {
      return _child;
    }
    set {
      if (value == _child) { return; }
      _child = value;

      value.set_parent (box);

      if (color_provider != null) {
        apply_color_provider_recursive (value, (!) color_provider);
      }
    }
  }

  /**
   * Add a child to the Bin, should only be used in the context of a UI or Blueprint file. There should be no need to use this method in code.
   */
  public virtual void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
    if (child is Gtk.Widget) {
      box.append ((Gtk.Widget) child);
      if (color_provider != null) {
        apply_color_provider_recursive ((Gtk.Widget) child, (!) color_provider);
      }
    } else {
      base.add_child (builder, child, type);
    }
  }

  /**
   * Create a new Bin.
   */
  public Bin () {
  }

  construct {
    box.set_parent (this);

    desktop.notify["accent-color"].connect (update_content_colors);
    desktop.notify["prefers-color-scheme"].connect (update_content_colors);
    desktop.notify["contrast"].connect (update_content_colors);

    notify["root"].connect (() => {
      handle_root_changed ();
      update_content_colors ();
    });

    // Monitor for hierarchy changes to catch dynamically added children
    notify["first-child"].connect (on_hierarchy_changed);
    notify["last-child"].connect (on_hierarchy_changed);

    handle_root_changed ();
    update_content_colors ();
  }

  /**
   * Enable or disable local content color overrides.
   */
  public bool content_color_override {
    get {
      return _content_color_override;
    }
    set {
      if (_content_color_override == value) {
        return;
      }

      _content_color_override = value;
      update_content_colors ();
    }
  }

  /**
   * Source color to apply when content_color_override is enabled.
   * This color will be used to generate the full color scheme including
   * secondary and tertiary palettes.
   */
  public RGBColor? content_source_color {
    get {
      return _content_source_color;
    }
    set {
      _content_source_color = value;

      if (_content_color_override) {
        update_content_colors ();
      }
    }
  }

  /**
   * Clears the content source color override and disables it.
   */
  public void clear_content_color_override () {
    _content_source_color = null;
    cached_css = null;
    content_color_override = false;
  }

  static construct {
    set_layout_manager_type (typeof (Gtk.BoxLayout));
  }

  private void update_content_colors () {
    if (!_content_color_override || _content_source_color == null) {
      remove_color_provider ();
      cached_css = null;
      return;
    }

    RGBColor source_argb = scale_to_argb ((RGBColor) _content_source_color);

    bool is_dark = get_is_dark_theme ();
    double contrast = get_contrast_level ();

    string css = build_content_css (source_argb, is_dark, contrast);

    if (css == "") {
      remove_color_provider ();
      cached_css = null;
      return;
    }

    if (cached_css != null && cached_css == css) {
      return;
    }

    ensure_color_provider ();
    load_provider_css ((!) color_provider, css);
    remove_color_provider_recursive (this, (!) color_provider);
    apply_color_provider_recursive (this, (!) color_provider);

    cached_css = css;
    queue_draw ();
  }

  private void handle_root_changed () {
    if (cached_app != null && app_accent_handler != 0) {
      GLib.SignalHandler.disconnect (cached_app, app_accent_handler);
      app_accent_handler = 0;
    }

    cached_app = get_he_application ();

    if (cached_app != null) {
      app_accent_handler = cached_app.accent_color_changed.connect (update_content_colors);
    }
  }

  private void on_hierarchy_changed () {
    // Re-apply color provider to catch any newly added children
    if (color_provider != null && _content_color_override) {
      apply_color_provider_recursive (this, (!) color_provider);
    }
  }

  private He.Application? get_he_application () {
    var root = get_root ();
    if (root is Gtk.Window) {
      var app = ((Gtk.Window) root).get_application ();
      if (app is He.Application) {
        return (He.Application) app;
      }
    }

    return null;
  }

  private void ensure_color_provider () {
    if (color_provider != null) {
      return;
    }

    color_provider = new Gtk.CssProvider ();
  }

  private void remove_color_provider () {
    if (color_provider == null) {
      return;
    }

    remove_color_provider_recursive (this, (!) color_provider);
    color_provider = null;
  }

  private string build_content_css (RGBColor source_color, bool is_dark, double contrast) {
    var source_hct = hct_from_int (rgb_to_argb_int (source_color));

    // Use ContentScheme to generate a full scheme from the source color
    var content_scheme = new ContentScheme ();
    var scheme = content_scheme.generate (source_hct, is_dark, contrast);

    var manager = new StyleManager ();
    string css = manager.style_refresh (scheme);
    return extract_content_color_definitions (css);
  }

  private string extract_content_color_definitions (string css) {
    var builder = new GLib.StringBuilder ();
    foreach (string line in css.split ("\n")) {
      if (!line.contains ("@define-color")) {
        continue;
      }

      // Include all color-related definitions from StyleManager
      if (line.contains ("accent") ||
          line.contains ("suggested") ||
          line.contains ("success") ||
          line.contains ("destructive") ||
          line.contains ("error") ||
          line.contains ("surface") ||
          line.contains ("window") ||
          line.contains ("view") ||
          line.contains ("headerbar") ||
          line.contains ("popover") ||
          line.contains ("card") ||
          line.contains ("outline") ||
          line.contains ("borders") ||
          line.contains ("shadow") ||
          line.contains ("scrim") ||
          line.contains ("osd")) {
        builder.append (line);
        builder.append ("\n");
      }
    }

    return builder.str;
  }

  private RGBColor scale_to_argb (RGBColor color) {
    RGBColor scaled = {
      MathUtils.clamp_double (0.0, 255.0, color.r * 255.0),
      MathUtils.clamp_double (0.0, 255.0, color.g * 255.0),
      MathUtils.clamp_double (0.0, 255.0, color.b * 255.0)
    };

    return scaled;
  }

  private void apply_color_provider_recursive (Gtk.Widget widget, Gtk.CssProvider provider) {
    widget.get_style_context ().add_provider (provider, COLOR_PROVIDER_PRIORITY);

    // Monitor this widget for child additions
    widget.notify["first-child"].connect (() => {
      if (_content_color_override && color_provider != null) {
        // Apply to all children when hierarchy changes
        for (var child = widget.get_first_child (); child != null; child = child.get_next_sibling ()) {
          apply_color_provider_recursive (child, (!) color_provider);
        }
      }
    });

    // Apply to all existing children
    for (var child = widget.get_first_child (); child != null; child = child.get_next_sibling ()) {
      apply_color_provider_recursive (child, provider);
    }
  }

  private void remove_color_provider_recursive (Gtk.Widget widget, Gtk.CssProvider provider) {
    widget.get_style_context ().remove_provider (provider);

    for (var child = widget.get_first_child (); child != null; child = child.get_next_sibling ()) {
      remove_color_provider_recursive (child, provider);
    }
  }

  private bool get_is_dark_theme () {
    return desktop.prefers_color_scheme == He.Desktop.ColorScheme.DARK;
  }

  private double get_contrast_level () {
    return desktop.contrast;
  }

#if !GTK4_IS_12
  [CCode (cname = "gtk_css_provider_load_from_data", cheader_filename = "gtk/gtk.h")]
  private extern void css_provider_load_from_data_fix (Gtk.CssProvider css_provider,
    [CCode (
            array_length_cname = "length",
            array_length_pos = 2.1,
            array_length_type = "gssize",
            type = "const char*"
     )]
    uint8[] data);

#endif

  private void load_provider_css (Gtk.CssProvider provider, string css) {
#if GTK4_IS_12
    provider.load_from_string (css);
#else
    css_provider_load_from_data_fix (provider, css.data);
#endif
  }

  ~Bin () {
    Gtk.Widget child;

    if (cached_app != null && app_accent_handler != 0) {
      GLib.SignalHandler.disconnect (cached_app, app_accent_handler);
      app_accent_handler = 0;
    }

    remove_color_provider ();

    while ((child = this.get_first_child ()) != null)
      child.unparent ();

    this.unparent ();
  }
}