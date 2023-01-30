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
    public double Q;
    public double M;
    public double s;
    public double ha;
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

  public RGBColor xyz_sharpened_rgb (XYZColor color) {
    // Apply the M16 matrix to XYZ color channels to get sharpened RGB
    RGBColor result = { 
        0.401288 * color.x + 0.650173 * color.y - 0.051461 * color.z,
        -0.250268 * color.x + 1.204414 * color.y + 0.045854 * color.z,
        -0.002079 * color.x + 0.048952 * color.y + 0.953127 * color.z
    };
  
    return result;
  }

  // Adapted from https://github.com/d3/d3-cam16/ until the next comment-less "//"
  public double nonlinear_adaptation (double cr, double fl) {
    var c = 400;
    if (cr < 0) {
      fl = fl * -1;
      c = -400;
    }
    var p = Math.pow( (fl * cr) / 100.0, 0.42 );
  
    return ((c * p) / (27.13 + p)) + 0.1;
  }

  public double sign(double x) {
    if (x == 0) return 0;
    else if (x < 0) return -1;
    else return 1;
  }

  public double inverse_nonlinear_adaptation(double cr, double fl) {
    return (sign(cr - 0.1) * (100.0 / fl) * Math.pow((27.13 * Math.fabs(cr - 0.1)) * (400.0 - Math.fabs(cr - 0.1)), 1.0 / 0.42));
  }

  public double compute_eccentricity(double hue_angle) {
    return 0.25 * (Math.cos((hue_angle * Math.PI) / 180.0 + 2.0) + 3.8);
  }

  public CAM16Color xyz_to_cam16(XYZColor color) {
    // Step 1: Make a sharp RGB color from source XYZ.
    var rgb_color = xyz_sharpened_rgb (color);

    // Step 2: Apply best white point to sharpened RGB
    RGBColor xyz_w_color = {
      rgb_color.r * He.Color.LabConstants.Xn,
      rgb_color.g * He.Color.LabConstants.Yn,
      rgb_color.b * He.Color.LabConstants.Zn
    };

    // Step 3: Apply nonlinear responses
    var LA = (64.0 / Math.PI) / 5.0;
    var k = 1.0 / ((5.0 * LA) + 1.0);
    var FL = (0.2 * Math.pow(k, 4.0) * (5.0 * LA)) + 0.1 * Math.pow(1.0 - Math.pow(k, 4.0), 2.0) * Math.pow(5.0 * LA, 1.0/3.0);

    RGBColor rgbnla_color = {
      nonlinear_adaptation(xyz_w_color.r, FL),
      nonlinear_adaptation(xyz_w_color.g, FL),
      nonlinear_adaptation(xyz_w_color.b, FL)
    };

    // Step 4: convert to preliminary cartesian a, b AND compute hue *angle*
    var a = rgbnla_color.r - (12.0 * rgbnla_color.g / 11.0) + (rgbnla_color.b / 11.0);
    var b = (rgbnla_color.r + rgbnla_color.g - 2.0 * rgbnla_color.b) / 9.0;
    var hue_angle = ((180.0 / Math.PI) * Math.atan2(b, a));
    if (hue_angle < 0) hue_angle += 360;

    // Step 5: compute hue quadratrue, eccentricity, and hue composition
    var e_t = compute_eccentricity(hue_angle);

    // Step 6: Compute achromatic response for input
    var n = 20.0 / 100.0;
    var nbb = 0.725 * Math.pow(1.0 / n, 0.2);
    var A = (2.0 * rgbnla_color.r + rgbnla_color.g + 0.05 * rgbnla_color.b - 0.305) * nbb;

    // Step 7: Compute Lightness
    var AW = (2.0 * 255.0 + 255.0 + 0.05 * 255.0 - 0.305) * nbb;
    var J = 100.0 * Math.pow(A / AW, 0.69 * 1.48 + Math.sqrt(n));

    // Step 8: Compute brightness
    var Q = (4.0 / 0.69) * Math.sqrt(J / 100.0) * (AW + 4.0) * Math.pow(FL, 0.25);

    // Step 9: Compute chroma
    var ncb = 0.725 * Math.pow(1.0 / n, 0.2);
    var t = (50000.0 / 13.0) * 1.0 * ncb * e_t * Math.sqrt(a*a + b*b) * (rgbnla_color.r + rgbnla_color.g + (21.0/20.0) * rgbnla_color.b);
    var C = Math.pow(t, 0.9) * Math.sqrt(J / 100.0) * Math.pow(1.64 - Math.pow(0.29, n), 0.73);

    // Step 10: Compute colorfulness
    var M = C * Math.pow(FL, 0.25);

    // Step 11: Compute saturation
    var s = 100.0 * Math.sqrt(M / Q);

    J = 1.7 * J / (1 + 0.007 * J);
    M = Math.log(1 + 0.0228 * M) / 0.0228;
    a = M * Math.cos((hue_angle * Math.PI) / 180.0);
    b = M * Math.sin((hue_angle * Math.PI) / 180.0);
    
    CAM16Color result = {
      J,
      a,
      b,
      C,
      Q,
      M,
      s,
      hue_angle
    };

    return result;
  }

  public LCHColor cam16_to_lch(CAM16Color color) {
    // Step 1: Compute the achromatic transformed sharpened RGB values
    var n = 20.0 / 100.0;
    var nbb = 0.725 * Math.pow(1.0 / n, 0.2);
    var AW = (2.0 * 255.0 + 255.0 + 0.05 * 255.0 - 0.305) * nbb;
    var z = 1.48 + Math.sqrt(n);
    var A = AW * Math.pow(color.J/100.0, 1 / (0.69 * z));
    var p_2 = A / nbb + 0.305;
    var LA = (64.0 / Math.PI) / 5.0;
    var k = 1.0 / ((5.0 * LA) + 1.0);
    var FL = (0.2 * Math.pow(k, 4.0) * (5.0 * LA)) + 0.1 * Math.pow(1.0 - Math.pow(k, 4.0), 2.0) * Math.pow(5.0 * LA, 1.0/3.0);
  
    RGBColor rgba_color = {
      (460/1403) * p_2 + (451/1403) * color.a + (288/1403) * color.b,
      (460/1403) * p_2 - (891/1403) * color.a - (261/1403) * color.b,
      (460/1403) * p_2 - (220/1403) * color.a - (6300/1403) * color.b
    };
  
    // Step 2: Reverse nonlinear compression
    RGBColor rgbc_color = {
      inverse_nonlinear_adaptation(rgba_color.r, FL),
      inverse_nonlinear_adaptation(rgba_color.g, FL),
      inverse_nonlinear_adaptation(rgba_color.b, FL)
    };
  
    // Step 3: Undo the degree of adaptation to obtain sharpened RGB values
    var D = 1.0 * (1.0 - (1.0 / 3.6) * Math.exp((-LA - 42.0) / 92.0));
    if (D > 1.0) D = 1.0; else if (D < 0.0) D = 0.0;

    RGBColor rgbd_color = {
      rgbc_color.r / (((100.0 * D)) + (1.0 - D)),
      rgbc_color.g / (((100.0 * D)) + (1.0 - D)),
      rgbc_color.b / (((100.0 * D)) + (1.0 - D)),
    };

    RGBColor result = {
      (rgbc_color.r / rgbd_color.r) * 255,
      (rgbc_color.g / rgbd_color.g) * 255,
      (rgbc_color.b / rgbd_color.b) * 255
    };
  
    return rgb_to_lch(result);
  }
  //

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

  public LCHColor derive_contrasting_color(LCHColor color, double? contrast, bool? lighten) {
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
