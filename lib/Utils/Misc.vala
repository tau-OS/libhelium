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
 * Miscellaneous functions
 */
[CCode (gir_namespace = "He", gir_version = "1", cheader_filename = "libhelium-1.h")]
namespace He.Misc {
  /**
   * An useful method for finding an ancestor of a given widget.
   * @param widget The widget to find the ancestor of.
   */
  public T find_ancestor_of_type<T> (Gtk.Widget? widget) {
    while ((widget = widget.get_parent ()) != null) {
      if (widget.get_type ().is_a (typeof (T)))
        return (T) widget;
    }

    return null;
  }

  /**
   * Gives the contrast ratio between two colors.
   *
   * @param red The red component of the background color.
   * @param green The green component of the background color.
   * @param blue The blue component of the background color.
   *
   * @param red2 The red component of the foreground color.
   * @param green2 The green component of the foreground color.
   * @param blue2 The blue component of the foreground color.
   *
   * @since 1.0
   */
  public double contrast_ratio (double red, double green, double blue, double red2, double green2, double blue2) {
      // From WCAG 2.0 https://www.w3.org/TR/WCAG20/#contrast-ratiodef
      var bg_luminance = get_luminance (red, green, blue);
      var fg_luminance = get_luminance (red2, green2, blue2);

      if (bg_luminance > fg_luminance) {
          return (bg_luminance + 0.05) / (fg_luminance + 0.05);
      }

      return (fg_luminance + 0.05) / (bg_luminance + 0.05);
  }

  private double get_luminance (double red, double green, double blue) {
      // Values from WCAG 2.0 https://www.w3.org/TR/WCAG20/#relativeluminancedef
      var r = sanitize_color (red) * 0.2126;
      var g = sanitize_color (green) * 0.7152;
      var b = sanitize_color (blue) * 0.0722;

      return r + g + b;
  }
  private double sanitize_color (double color) {
      // From WCAG 2.0 https://www.w3.org/TR/WCAG20/#relativeluminancedef
      if (color <= 0.03928) {
          return (color) / 12.92;
      }

      return Math.pow ((color + 0.055) / 1.055, 2.4);
  }

  // Adapted from https://github.com/gka/chroma.js
  private double[] interpolate (double red, double green, double blue, double red2, double green2, double blue2) {
    var r = Math.round (red + 0.5 * (red2 - red));
    var g = Math.round (green + 0.5 * (green2 - green));
    var b = Math.round (blue + 0.5 * (blue2 - blue));
    double[] interp_color = {r, g, b};

    return interp_color;
  }

  // Adapted from https://github.com/gka/chroma.js
  private double[] adjust_luminance (double red, double green, double blue, double target) {
    var cur_lum = get_luminance (red, green, blue);
    double[] black = {0, 0, 0};
    double[] white = {1, 1, 1};
    double[] color = {red, green, blue};

    return cur_lum > target ? test (black, color, target) : test (color, white, target);
  }

  private double[] test (double[] low, double[] high, double target) {
    var eps = 1e-7;
    var mid = interpolate (low[0], low[1], low[2], high[0], high[1], high[2]);
    var lm = get_luminance (mid[0], mid[1], mid[2]);

    if (MathUtils.abs (target - lm) < eps) {
      // close enough
      return mid;
    }

    return lm > target ? test (low, mid, target) : test (mid, high, target);
  }

  /**
   * Gives a contrasting foreground color for a given background color.
   *
   * @param red The red component of the background color.
   * @param green The green component of the background color.
   * @param blue The blue component of the background color.
   *
   * @param red2 The red component of the foreground color.
   * @param green2 The green component of the foreground color.
   * @param blue2 The blue component of the foreground color.
   *
   * @since 1.0
   */
  public double[] fix_fg_contrast (double red, double green, double blue, double red2, double green2, double blue2) {
    var bg_luminance = get_luminance (red, green, blue);
    var fg_luminance = get_luminance (red2, green2, blue2);

    var ratio = contrast_ratio (red, green, blue, red2, green2, blue2);
    double[] color = {red2, green2, blue2};

    if (ratio >= 7) {
      return color;
    }

    if (fg_luminance > bg_luminance) {
      var denominator = bg_luminance + 0.05;
      var target_luminance = 7 * denominator - 0.05;

      return adjust_luminance (color[0], color[1], color[2], target_luminance);
    } else {
      var numerator = bg_luminance + 0.05;
      var target_luminance = numerator / 7 - 0.05;

      return adjust_luminance (color[0], color[1], color[2], target_luminance);
    }
  }

  private class Pair<T, U> {
    public T key;
    public U value;

    public Pair (T key, U value) {
      this.key = key;
      this.value = value;
    }
  }

  /**
   * Converts a {@link Gtk.accelerator_parse} style accel string to a human-readable string.
   *
   * @param accel an accelerator label like “<Control>a” or “<Super>Right”
   *
   * @return a human-readable string like "Ctrl + A" or "⯁ + →"
   */
  public static string accel_label (string? accel) {
    if (accel == null) {
        return "";
    }

    // We need to make sure that the library is up
    He.init ();

    uint accel_key;
    Gdk.ModifierType accel_mods;
    Gtk.accelerator_parse (accel, out accel_key, out accel_mods);

    string[] arr = {};
    if (Gdk.ModifierType.SUPER_MASK in accel_mods) {
        arr += "⯁";
    }

    if (Gdk.ModifierType.SHIFT_MASK in accel_mods) {
        arr += _("Shift");
    }

    if (Gdk.ModifierType.CONTROL_MASK in accel_mods) {
        arr += _("Ctrl");
    }

    if (Gdk.ModifierType.ALT_MASK in accel_mods) {
        arr += _("Alt");
    }

    switch (accel_key) {
        case Gdk.Key.Up:
            arr += "↑";
            break;
        case Gdk.Key.Down:
            arr += "↓";
            break;
        case Gdk.Key.Left:
            arr += "←";
            break;
        case Gdk.Key.Right:
            arr += "→";
            break;
        case Gdk.Key.Alt_L:
            ///TRANSLATORS: The Alt key on the left side of the keyboard
            arr += _("Left Alt");
            break;
        case Gdk.Key.Alt_R:
            ///TRANSLATORS: The Alt key on the right side of the keyboard
            arr += _("Right Alt");
            break;
        case Gdk.Key.backslash:
            arr += "\\";
            break;
        case Gdk.Key.Control_R:
            ///TRANSLATORS: The Ctrl key on the right side of the keyboard
            arr += _("Right Ctrl");
            break;
        case Gdk.Key.Control_L:
            ///TRANSLATORS: The Ctrl key on the left side of the keyboard
            arr += _("Left Ctrl");
            break;
        case Gdk.Key.minus:
        case Gdk.Key.KP_Subtract:
            ///TRANSLATORS: This is a non-symbol representation of the "-" key
            arr += _("Minus");
            break;
        case Gdk.Key.KP_Add:
        case Gdk.Key.plus:
            ///TRANSLATORS: This is a non-symbol representation of the "+" key
            arr += _("Plus");
            break;
        case Gdk.Key.KP_Equal:
        case Gdk.Key.equal:
            ///TRANSLATORS: This is a non-symbol representation of the "=" key
            arr += _("Equals");
            break;
        case Gdk.Key.Return:
            arr += _("Enter");
            break;
        case Gdk.Key.Shift_L:
            ///TRANSLATORS: The Shift key on the left side of the keyboard
            arr += _("Left Shift");
            break;
        case Gdk.Key.Shift_R:
            ///TRANSLATORS: The Shift key on the right side of the keyboard
            arr += _("Right Shift");
            break;
        default:
            // If a specified accelarator contains only modifiers e.g. "<Control><Shift>",
            // we don't get anything from accelerator_get_label method, so skip that case
            string accel_label = Gtk.accelerator_get_label (accel_key, 0);
            if (accel_label != "") {
                arr += accel_label;
            }
            break;
    }

    if (accel_mods != 0) {
        return string.joinv (" + ", arr);
    }

    return arr[0];
  }

  /**
   * Pango markup to use for secondary text in a {@link Gtk.Tooltip}, such as for accelerators, extended descriptions, etc.
   */
  private const string TOOLTIP_SECONDARY_TEXT_MARKUP = """<span weight="600" size="12px" alpha="66%">%s</span>""";

  /**
   * Takes a description and an array of accels and returns {@link Pango} markup for use in a {@link Gtk.Tooltip}. This method uses {@link Granite.accel_to_string}.
   *
   * Example:
   *
   * Description
   * Shortcut 1, Shortcut 2
   *
   * @param accels string array of accelerator labels like {"<Control>a", "<Super>Right"}
   *
   * @param description a standard tooltip text string
   *
   * @return {@link Pango} markup with the description label on one line and a list of human-readable accels on a new line
   */
  public static string accel_string (string[]? accels, string? description = null) {
    string[] parts = {};
    if (description != null && description != "") {
        parts += description;
    }

    if (accels != null && accels.length > 0) {
        string[] unique_accels = {};

        // We need to make sure that the translation domain is correctly setup
        He.init ();

        for (int i = 0; i < accels.length; i++) {
            if (accels[i] == "") {
                continue;
            }

            var accel_string = accel_label (accels[i]);
            if (!(accel_string in unique_accels)) {
                unique_accels += accel_string;
            }
        }

        if (unique_accels.length > 0) {
            ///TRANSLATORS: This is a delimiter that separates two keyboard shortcut labels like "⌘ + →, Control + A"
            var accel_label = string.joinv (_(", "), unique_accels);

            var accel_markup = TOOLTIP_SECONDARY_TEXT_MARKUP.printf (accel_label);

            parts += accel_markup;
        }
    }

    return string.joinv ("\n", parts);
  }

  private void toggle_style_provider (Gtk.StyleProvider provider, bool enabled, int priority) {
    Gdk.Display display = Gdk.Display.get_default ();

    if (display == null)
    return;

    if (enabled) {
      Gtk.StyleContext.add_provider_for_display (display, provider, priority);
    } else {
      Gtk.StyleContext.remove_provider_for_display (display, provider);
    }
  }

  private void init_css_provider_from_file (Gtk.CssProvider provider, File file) {
    if (file.query_exists (null)) {
      provider.load_from_file (file);
    }
  }
}
