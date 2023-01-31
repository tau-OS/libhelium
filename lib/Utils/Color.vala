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
    public const double Xn = 0.9570855264;
    public const double Yn = 1.0114135331;
    public const double Zn = 1.1190554598;

    public const double t0 = 0.1379310345;  // 4 / 29
    public const double t1 = 0.2068965523;  // 6 / 29
    public const double t2 = 0.1284185508;  // 3  * t1 * t1
    public const double t3 = 0.0088564521;  // t1 * t1 * t1
}

/**
 * Miscellaneous color related functions
 */
namespace He.Color {
  public const RGBColor BLACK = {
      0.0,
      0.0,
      0.0
  };

  public const RGBColor WHITE = {
      255.0,
      255.0,
      255.0
  };
  
  // Colors used for cards or elements atop the bg when Harsh Dark Mode.
  public const RGBColor HARSH_CARD_BLACK = {
      0.0,
      0.0,
      0.0
  };

  // Colors used for cards or elements atop the bg when Medium Dark Mode.
  public const RGBColor CARD_BLACK = {
      18.0,
      18.0,
      18.0
  };
  
  // Colors used for cards or elements atop the bg when Soft Dark Mode.
  public const RGBColor SOFT_CARD_BLACK = {
      36.0,
      36.0,
      36.0
  };

  public const RGBColor CARD_WHITE = {
      255.0,
      255.0,
      255.0
  };

  public const double[] LINRGB_FROM_SCALED_DISCOUNT = {
    1373.2198709594231, -1100.4251190754821, -7.278681089101213,
    -271.815969077903, 559.6580465940733, -32.46047482791194,
    1.9622899599665666, -57.173814538844006, 308.7233197812385
  };
  public const double[] Y_FROM_LINRGB = {
    0.2126,
    0.7152,
    0.0722
  };

  public struct RGBColor {
    public double r;
    public double g;
    public double b;
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

  public struct CAM16Color {
    public double J;
    public double a;
    public double b;
    public double C;
    public double h;
  }

  public struct HCTColor {
    public double h;
    public double c;
    public double t;
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

  public LABColor xyz_to_lab (XYZColor color) {
    var l = xyz_value_to_lab(color.x);
    var a = xyz_value_to_lab(color.y);
    var b = xyz_value_to_lab(color.z);

    LABColor result = {
      l,
      a,
      b
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

  public LCHColor lab_to_lch(LABColor color) {
    LCHColor result = {
      color.l,
      color.a,
      color.b
    };

    return result;
  }

  // Adapted from https://github.com/d3/d3-cam16/ until the next comment-less "//"
  public CAM16Color rgb_to_cam16 (RGBColor color) {
    Gdk.RGBA adapted_color = {
      (float)(color.r / 255.0),
      (float)(color.g / 255.0),
      (float)(color.b / 255.0),
      (float)(1.0)
    };

    var a = adapted_color.red - (12.0 * adapted_color.green / 11.0) + (adapted_color.blue / 11.0);
    var b = (adapted_color.red + adapted_color.green - 2.0 * adapted_color.blue) / 9.0;
    var h = ((180.0 / Math.PI) * Math.atan2(b, a)); if (h < 0) h += 360; else if (h > 360) h -= 360;
    var J = 100.0 * Math.pow((2.0 * adapted_color.red + adapted_color.green + 0.05 * adapted_color.blue - 0.3) * 0.37, 1.47);
    var C = 1525.0 * Math.sqrt(J / 100.0) * 0.75;
    
    CAM16Color result = {
      J,
      a,
      b,
      C,
      h
    };

    return result;
  }

  public LCHColor cam16_to_lch(CAM16Color color) {
    var A =  25.5 * Math.pow(color.J/100.0, 11.11);

    RGBColor result = {
      (20/61 * A + 0.32 * color.a + 0.21 * color.b) * 255,
      (20/61 * A - 0.635 * color.a - 0.19 * color.b) * 255,
      (20/61 * A - 0.157 * color.a - 4.50 * color.b) * 255
    };

    return lab_to_lch(rgb_to_lab(result));
  }
  //

  public HCTColor cam16_and_lch_to_hct(CAM16Color color, LCHColor tone) {
    HCTColor result = {
      color.h,
      color.C,
      tone.l
    };

    return result;
  }

  public RGBColor hct_to_rgb(HCTColor color) {
    var j = Math.sqrt(50.0) * 11.0;
    int rd = 0;
    while (rd <= 5) {
      var jn = j / 100.0;
      var t = Math.pow((color.c / jn) / Math.pow(1.64 - Math.pow(0.29, 0.5), 0.73), 1.0 / 0.9);
      var h_rad =  (Math.PI / 180) * color.h;

      var ac = 25.436  * Math.pow(jn, 1.0 / 0.69 / 2.0);
      var p1 = 0.25 * ((Math.cos(h_rad + 2.0) + 3.8) * 385.0);
      var p2 = ac;

      var h_sin = Math.sin(h_rad);
      var h_cos = Math.cos(h_rad);
      var gamma = 23.0 * (p2 + 0.305) * t / (23.0 * p1 + 11.0 * t * h_cos + 108.0 * t * h_sin);
      var a = gamma * h_cos;
      var b = gamma * h_sin;
      var r_a = (460.0 * p2 + 451.0 * a + 288.0 * b) / 1403.0;
      var g_a = (460.0 * p2 - 891.0 * a - 261.0 * b) / 1403.0;
      var b_a = (460.0 * p2 - 220.0 * a - 6300.0 * b) / 1403.0;

      var r_cbase = ((27.13 * Math.fabs(r_a)) / Math.fmax(400.0 - Math.fabs(r_a), 0.0));
      var r_c = signum(r_a) * (100.0 / 1) * Math.pow(r_cbase, 1.0 / 0.42);
      var g_cbase = ((27.13 * Math.fabs(g_a)) / Math.fmax(400.0 - Math.fabs(g_a), 0.0));
      var g_c = signum(g_a) * (100.0 / 1) * Math.pow(g_cbase, 1.0 / 0.42);
      var b_cbase = ((27.13 * Math.fabs(b_a)) / Math.fmax(400.0 - Math.fabs(b_a), 0.0));
      var b_c = signum(b_a) * (100.0 / 1) * Math.pow(b_cbase, 1.0 / 0.42);

      var linrgb = matrix_multiply(
        {r_c, g_c, b_c},
        LINRGB_FROM_SCALED_DISCOUNT
      );

      if (linrgb[0] < 0.0 || linrgb[1] < 0.0 || linrgb[2] < 0.0) {
        return {0, 0, 0};
      }

      var k_r = Y_FROM_LINRGB[0];
      var k_g = Y_FROM_LINRGB[1];
      var k_b = Y_FROM_LINRGB[2];

      var fnj = k_r * linrgb[0] + k_g * linrgb[1] + k_b * linrgb[2];
      if (fnj <= 0.0) {
        return {0, 0, 0};
      }

      if (rd == 4 || Math.fabs(fnj - color.t) < 0.002) {
        if (linrgb[0] > 100.01 || linrgb[1] > 100.01 || linrgb[2] > 100.01) {
          return {0, 0, 0};
        }
  
        var r = delinearized(linrgb[0]);
        var g = delinearized(linrgb[1]);
        var bt = delinearized(linrgb[2]);
  
        RGBColor result = {
          r,
          g,
          bt
        };

        return result;
      }

      rd++;
      j = j - (fnj - color.t) * j / (2.0 * fnj);
    }

    return {0, 0, 0};
  }
  int delinearized(double rgb_comp) {
    var normalized = rgb_comp / 100.0;
    var delinearized = 0.0;
    if (normalized <= 0.0031308) {
        normalized * 12.92;
    } else {
        1.055 * Math.pow(normalized, 1.0 / 2.4) - 0.055;
    };
    return ((int)Math.round(delinearized * 255.0)).clamp(0, 255);
  }
  int signum (double s) {
    if (s < 0) { return -1; }
    else if (s > 0) { return 1; }
    else if (s == 0) { return 0; }
    else { return 0; }
  }
  private double[] matrix_multiply (double[] row, double[] matrix) {
    var a = row[0] * matrix[0] + row[1] * matrix[1] + row[2] * matrix[2];
    var b = row[0] * matrix[3] + row[1] * matrix[4] + row[2] * matrix[5];
    var c = row[0] * matrix[6] + row[1] * matrix[7] + row[2] * matrix[8];

    return {a,b,c};
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

  public LCHColor derive_contrasting_color(HCTColor color, LCHColor derived, double? contrast, bool? lighten) {
    LCHColor lch_color_derived = {
      color.t,
      ((derived.c/132)*150), // Make Chroma follow HCT's
      derived.h
    };

    if (contrast != null) {
      var min = lighten == true ? lch_color_derived.l : 0;
      var max = lighten == null || lighten == true ? 100 : lch_color_derived.l;

      var l = min;
      var r = max;

      for (var i = 0; i <= 100; i++) {
        var cur_guess_lightness = (l + r) / 2.0;
        lch_color_derived.l = cur_guess_lightness;
        var cur_contrast = contrast_ratio_for_lch(derived, lch_color_derived);
        var move_away = contrast > cur_contrast;
        var is_darker = color.t < lch_color_derived.l;
        if (approx_float_eq((float) contrast, (float) cur_contrast, 4)) {
          break;
        } else if (is_darker && move_away || !is_darker && !move_away) {
            l = cur_guess_lightness;
        } else {
            r = cur_guess_lightness;
        }
      }

      // TODO CLAMP
      return lch_color_derived;
    } else {
      if (color.t > 50.0) {
        return rgb_to_lch(BLACK);
      } else {
        return rgb_to_lch(WHITE);
      }
    }
  }

  private string hexcode (double r, double g, double b) {
    return "#" + "%02x%02x%02x".printf (
        (uint)r,
        (uint)g,
        (uint)b
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
      color.red * 255,
      color.green * 255,
      color.blue * 255,
    };

    return result;
  }

  public RGBColor from_hex (string color) {
    RGBColor result = {
      uint.parse(color.substring(1, 2), 16),
      uint.parse(color.substring(3, 2), 16),
      uint.parse(color.substring(5, 2), 16),
    };

    return result;
  }
}
