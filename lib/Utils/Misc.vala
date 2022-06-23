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
 * Miscellaneous functions
 */
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

  private double contrast_ratio (double red, double green, double blue, double red2, double green2, double blue2) {
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
    var r = Math.round(red + 0.5 * (red2 - red));
    var g = Math.round(green + 0.5 * (green2 - green));
    var b = Math.round(blue + 0.5 * (blue2 - blue));
    double[] interp_color = {r, g, b};

    return interp_color;
  }

  // Adapted from https://github.com/gka/chroma.js
  private double[] adjust_luminance (double red, double green, double blue, double target) {
    var cur_lum = get_luminance(red, green, blue);
    double[] black = {0, 0, 0};
    double[] white = {1, 1, 1};
    double[] color = {red, green, blue};

    return cur_lum > target ? test(black, color, target) : test(color, white, target);
  }

  private double[] test (double[] low, double[] high, double target) {
    var EPS = 1e-7;
    var mid = interpolate(low[0], low[1], low[2], high[0], high[1], high[2]);
    var lm = get_luminance(mid[0], mid[1], mid[2]);

    if (Math.fabs(target - lm) < EPS) {
      // close enough
      return mid;
    }

    return lm > target ? test(low, mid, target) : test(mid, high, target);
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

      return adjust_luminance(color[0], color[1], color[2], target_luminance);
    } else {
      var numerator = bg_luminance + 0.05;
      var target_luminance = numerator / 7 - 0.05;

      return adjust_luminance(color[0], color[1], color[2], target_luminance);
    }
  }
}