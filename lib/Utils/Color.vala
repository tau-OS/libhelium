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
// Taken from https://github.com/gka/chroma.js/blob/75ea5d8a5480c90ef1c7830003ac63c2d3a15c03/src/io/lab/lab-constants.js

/**
 * Miscellaneous constants for the Lab colorspace
 */
namespace He.Color.LabConstants {
    // Corresponds roughly to RGB brighter/darker
    public const double Kn = 18;

    // D65 standard referent
    public const double Xn = 0.950470;
    public const double Yn = 1;
    public const double Zn = 1.088830;

    public const double t0 = 0.137931034;  // 4 / 29
    public const double t1 = 0.206896552;  // 6 / 29
    public const double t2 = 0.128418550;   // 3 * t1 * t1
    public const double t3 = 0.008856452;  // t1 * t1 * t1
}

/**
 * Miscellaneous color related functions
 */
namespace He.Color {
  // True Black for Harsh Dark Mode.
  public const RGBColor HARSH_BLACK = {
      0,
      0,
      0
  };

  // Medium black for Medium Dark Mode.
  public const RGBColor BLACK = {
      45,
      45,
      45
  };
  
  // Softer black for Soft Dark Mode
  public const RGBColor SOFT_BLACK = {
      61,
      61,
      61
  };

  // Not true white because it's too harsh.
  public const RGBColor WHITE = {
      240,
      240,
      240
  };
  
  // Colors used for cards or elements atop the bg when Harsh Dark Mode.
  public const RGBColor HARSH_CARD_BLACK = {
      30,
      30,
      30
  };

  // Colors used for cards or elements atop the bg when Medium Dark Mode.
  public const RGBColor CARD_BLACK = {
      61,
      61,
      61
  };
  
  // Colors used for cards or elements atop the bg when Soft Dark Mode.
  public const RGBColor SOFT_CARD_BLACK = {
      90,
      90,
      90
  };

  public const RGBColor CARD_WHITE = {
      250,
      250,
      250
  };

  public struct RGBColor {
    public int r;
    public int g;
    public int b;
  }

  public struct XYZColor {
    public double x;
    public double y;
    public double z;
  }

  public struct LABColor {
    public double l;
    public double a;
    public double b;
  }

  public struct LCHColor {
    public double l;
    public double c;
    public double h;
  }

  // The following is adapted from:
  // https://github.com/gka/chroma.js/blob/75ea5d8a5480c90ef1c7830003ac63c2d3a15c03/src/io/lab/rgb2lab.js
  // https://github.com/gka/chroma.js/blob/75ea5d8a5480c90ef1c7830003ac63c2d3a15c03/src/io/lab/lab-constants.js
  // https://cs.github.com/gka/chroma.js/blob/cd1b3c0926c7a85cbdc3b1453b3a94006de91a92/src/io/lab/lab2rgb.js#L10

  public double rgb_value_to_xyz(double v) {
    if ((v /= 255) <= 0.04045) return v / 12.92000;
    return Math.pow((v + 0.05500) / 1.05500, 2.40000);
  }

  public double xyz_value_to_lab(double v) {
    if (v > He.Color.LabConstants.t3) return Math.pow(v, 1d / 3d);
    return v / He.Color.LabConstants.t2 + He.Color.LabConstants.t0;
  }

  public XYZColor rgb_to_xyz(RGBColor color) {
    var r = rgb_value_to_xyz(color.r);
    var g = rgb_value_to_xyz(color.g);
    var b = rgb_value_to_xyz(color.b);

    var x = xyz_value_to_lab((0.4124564 * r + 0.3575761 * g + 0.1804375 * b) / He.Color.LabConstants.Xn);
    var y = xyz_value_to_lab((0.2126729 * r + 0.7151522 * g + 0.0721750 * b) / He.Color.LabConstants.Yn);
    var z = xyz_value_to_lab((0.0193339 * r + 0.1191920 * g + 0.9503041 * b) / He.Color.LabConstants.Zn);

    XYZColor result = {
      x,
      y,
      z
    };
    
    return result;
  }

  public LABColor rgb_to_lab(RGBColor color) {
    var xyz_color = rgb_to_xyz(color);
    var l = 116d * xyz_color.y - 16d;

    LABColor result = {
      l < 0 ? 0 : l,
      500d * (xyz_color.x - xyz_color.y),
      200d * (xyz_color.y - xyz_color.z)
    };

    return result;
  }

  public LCHColor rgb_to_lch(RGBColor color) {
    var lab_color = rgb_to_lab(color);
    
    LCHColor result = {
      lab_color.l,
      lab_color.a,
      lab_color.b
    };

    return result;
  }

  public LABColor lch_to_lab(LCHColor color) {
    LABColor result = {
      color.l,
      color.c,
      color.h
    };

    return result;
  }

  int xyz_value_to_rgb_value(double value) {
    return (int) (255 * (value <= 0.00304 ? 12.92 * value : 1.05500 * Math.pow(value, 1 / 2.4) - 0.05500));
  }

  double lab_value_to_xyz_value(double value) {
    return value > He.Color.LabConstants.t1 ? value * value * value : He.Color.LabConstants.t2 * (value - He.Color.LabConstants.t0);
  }

  public RGBColor lab_to_rgb(LABColor color) {
    var y = (color.l + 16) / 116;
    var x = (bool) Math.isnan(color.a) ? y : y + color.a / 500;
    var z = (bool) Math.isnan(color.b) ? y : y - color.b / 200;

    y = He.Color.LabConstants.Yn * lab_value_to_xyz_value(y);
    x = He.Color.LabConstants.Xn * lab_value_to_xyz_value(x);
    z = He.Color.LabConstants.Zn * lab_value_to_xyz_value(z);

    var r = xyz_value_to_rgb_value(3.2404542 * x - 1.5371385 * y - 0.4985314 * z);  // D65 -> sRGB
    var g = xyz_value_to_rgb_value(-0.9692660 * x + 1.8760108 * y + 0.0415560 * z);
    var b = xyz_value_to_rgb_value(0.0556434 * x - 0.2040259 * y + 1.0572252 * z);

    RGBColor result = {
      r.clamp(0, 255),
      g.clamp(0, 255),
      b.clamp(0, 255)
    };

    return result;
  }

  // Adapted from https://cs.github.com/Ogeon/palette/blob/d4cae1e2510205f7626e880389e5e18b45913bd4/palette/src/xyz.rs#L259
  public XYZColor lab_to_xyz(LABColor color) {
        // Recip call shows performance benefits in benchmarks for this function
        var y = (color.l + 16.0) * (1 / 116.0);
        var x = y + (color.a * 1 / 500.0);
        var z = y - (color.b * 1 / 200.0);

        var epsilon = 6.0 / 29.0;
        var kappa = 108.0 / 841.0;
        var delta = 4.0 / 29.0;

        double convert(double value) {
          return value > epsilon ? Math.pow(value, 3) : (value - delta) * kappa;
        }

        // D65 white point
        XYZColor result = {
          convert(x) * 0.95047,
          convert(y) * 1.00000,
          convert(z) * 1.08883
        };

        return result;
  }

  // Adapted from https://github.com/Ogeon/palette/blob/94e30738539465f14f373146b1ae948ee551faed/palette/src/relative_contrast.rs#L106

  public double contrast_ratio(double luma1, double luma2) {
    return luma1 > luma2 ? (luma1 + 0.05) / (luma2 + 0.05) : (luma2 + 0.05) / (luma1 + 0.05);
  }

  // Adapted from https://cs.github.com/Ogeon/palette/blob/d4cae1e2510205f7626e880389e5e18b45913bd4/palette/src/lch.rs#L377

  public double contrast_ratio_for_lch(LCHColor color1, LCHColor color2) {
    var xyz1 = lab_to_xyz(lch_to_lab(color1));
    var xyz2 = lab_to_xyz(lch_to_lab(color2));

    return contrast_ratio(xyz1.y, xyz2.y);
  }


  // Adpated from https://github.com/mikedilger/float-cmp/blob/418c5d9d339268f355363ea7cf6c546e69d63b7b/src/eq.rs#L89
  
  private bool approx_float_eq(float first, float second, int? ulps = 4, float? epsilon = float.EPSILON) {
    if (first == second) return true;
    if ((first - second).abs() <= epsilon) return true;

    var ai32 = (int32) first;
    var bi32 = (int32) second;
    var diff = ai32 - bi32;

    return (diff < 0 ? uint32.MAX : diff) <= ulps;
  }

  // Adapted from https://github.com/wash2/hue-chroma-accent

  public LCHColor derive_contasting_color(LCHColor color, double? contrast, bool? lighten) {
    LCHColor lch_color_derived = {
      color.l,
      color.c,
      color.h
    };

    if (contrast != null) {
      var min = lighten == true ? lch_color_derived.l : 0;
      var max = lighten == null || lighten == true ? 100 : lch_color_derived.l;

      var l = min;
      var r = max;

      for (var i = 0; i < 100; i++) {
        var cur_guess_lightness = (l + r) / 2.0;
        lch_color_derived.l = cur_guess_lightness;
        var cur_contrast = contrast_ratio_for_lch(color, lch_color_derived);
        var move_away = contrast > cur_contrast;
        var is_darker = color.l < lch_color_derived.l;
        if (approx_float_eq((float) contrast, (float) cur_contrast, 4)) {
            break;
        } else if (is_darker && move_away || !is_darker && !move_away) {
            l = cur_guess_lightness;
        } else {
            r = cur_guess_lightness;
        }
      }

      // TODO CLAMP

      var actual_contrast = contrast_ratio_for_lch(lch_color_derived, color);

      if (!approx_float_eq((float) contrast, (float) actual_contrast, 4)) {
        error ("Failed to derive color with contrast " + contrast.to_string());
      }

      return lch_color_derived;
    } else {
      if (color.l > 50.0) {
        return rgb_to_lch(BLACK);
      } else {
        return rgb_to_lch(WHITE);
      }
    }
  }

  private string hexcode (double r, double g, double b) {
    return "#" + "%02x%02x%02x".printf (
        (int)r,
        (int)g,
        (int)b
    );
  }

  public Gdk.RGBA to_gdk_rgba (RGBColor color) {
    Gdk.RGBA result = {
      (float)color.r / 255.0f,
      (float)color.g / 255.0f,
      (float)color.b / 255.0f,
      1.0f
    };

    return result;
  }

  public RGBColor from_gdk_rgba (Gdk.RGBA color) {
    RGBColor result = {
      (int)(color.red * 255),
      (int)(color.green * 255),
      (int)(color.blue * 255),
    };

    return result;
  }
}
