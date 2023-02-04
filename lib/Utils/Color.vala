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
[CCode (gir_namespace = "He", gir_version = "1", cheader_filename = "libhelium-1.h")]
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
[CCode (gir_namespace = "He", gir_version = "1", cheader_filename = "libhelium-1.h")]
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

  public const double[] XYZ_TO_CAM16RGB = {
    0.401288, 0.650173, -0.051461,
    -0.250268, 1.204414, 0.045854,
    -0.002079, 0.048952, 0.953127,
  };
  public const double[] SRGB_TO_XYZ = {
    0.41233895, 0.35762064, 0.18051042,
    0.2126, 0.7152, 0.0722,
    0.01932141, 0.11916382, 0.95034478,
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
    public string hex; // Keep RGB rep as string on the struct for easy lookup
  }

  public struct HCTColor {
    public double h;
    public double c;
    public double t;
    public string a; // Keep RGB rep as string on the struct for easy lookup
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
    var hr = color.h * 6.283185307179586 / 360.0;
    LABColor result = {
      color.l,
      color.c * Math.cos(hr),
      color.c * Math.sin(hr)
    };

    return result;
  }

  public LCHColor lab_to_lch(LABColor color) {
    LCHColor result = {
      color.l,
      Math.hypot(color.a, color.b),
      Math.atan2(color.b,color.a) * 360.0 / 6.283185307179586
    };

    return result;
  }

  // Adapted from https://github.com/d3/d3-cam16/ until the next comment-less "//"
  public CAM16Color xyz_to_cam16 (XYZColor color) {
    // Make XYZ fit D65 by adjusting it
    double[] RGB = elem_mul(
      M16 (color.x, color.y, color.z),
      {1.0322048506322774, 0.9856436353674031, 0.9097575015921737}
    );
    var R_a = adapt(RGB[0]);
    var G_a = adapt(RGB[1]);
    var B_a = adapt(RGB[2]);

    var Aw = 3.49;
    var a = R_a + (-12*G_a + B_a) / 11;
    var b = (R_a + G_a - 2 * B_a) / 9;
    var hr = Math.atan2(b, a);
    var h = hr * 180/Math.PI;

    var e_t = 0.25 * (Math.cos(hr + 2) + 3.8);
    var A = 1 * (2 * R_a + G_a + 0.05 * B_a);
    var JR = Math.pow(A / Aw, 0.35 * 0.69 * 1.93);
    var J = 100 * JR * JR;
    var t = (5e4 / 13 * 1 * 1 * e_t * Math.sqrt(a*a + b*b) / (R_a + G_a + 1.05 * B_a + 0.305));
    var alpha = Math.pow(t, 0.9) * Math.pow(1.64 - Math.pow(0.29, 0.2), 0.73);

    var C = alpha * JR;

    var hex = hexcode (R_a, G_a, B_a);

    CAM16Color result = {
      J,
      a,
      b,
      C,
      h,
      hex
    };
    return result;
  }
  private double[] elem_mul(double[] v0, double[] v1) {
    double[] prod = {
      v0[0] * v1[0],
      v0[1] * v1[1],
      v0[2] * v1[2]
    };
    return prod;
  }
  private double adapt (double component) {
    var x = Math.pow(0.5848035714321961 * Math.fabs(component) * 0.01, 0.42);
    return sgn(component) * 400 * x / (x + 27.13);
  }
  private double[] M16 (double X, double Y, double Z) {
    var r =  0.401288*X + 0.650173*Y - 0.051461*Z;
    var g = -0.250268*X + 1.204414*Y + 0.045854*Z;
    var b = -0.002079*X + 0.048952*Y + 0.953127*Z;
    return {r, g, b};
  }
  private int sgn (double x) {
    return (int)(x > 0) - (int)(x < 0);
  }
  //

  public HCTColor cam16_and_lch_to_hct(CAM16Color color, LCHColor tone) {
    HCTColor result = {
      color.h,
      color.C + 18, // HCT Chroma is 0~150, instead of LCH's 0~132. Fix that.
      tone.l,
      color.hex
    };

    // Now, we're not just gonna accept what comes to us via CAM16 and LCH,
    // because it generates bad HCT colors. So we're gonna test the color and
    // fix it for UI usage.

    // Test color for bad props
    // A hue between 90 and 111 is body deject-colored so we can't use it.
    // A tone more than 70 is unsuitable for UI as it's too light.
    bool hueNotPass = Math.round(result.h) >= 90.0 && Math.round(result.h) <= 111.0;
    bool toneNotPass = Math.round(result.t) <= 70.0;

    if (result.h < 0) { result.h = result.h + 360.0; }
    if (result.c > 150) { result.c = result.c - 150.0; } // Make C = 0~150 always.

    if (hueNotPass && toneNotPass) {
      print("THIS IS YOUR HCT VALUES FIXED:\n%f / %f / %f\n".printf(result.h, result.c, 70.0));
      return {Math.round(result.h), Math.round(result.c), 70.0, result.a}; // Fix color for UI, based on Psychology
    } else {
      print("THIS IS YOUR HCT VALUES THAT PASSED:\n%f / %f / %f\n".printf(result.h, result.c, result.t));
      return {Math.round(result.h), Math.round(result.c), Math.round(result.t), result.a};
    }
  }
  public string hct_to_hex (HCTColor a) {
    return a.a;
  }
  public HCTColor hct_blend (HCTColor a, HCTColor b) {
    var diff_deg = diff_deg(a.h, b.h);
    var rot_deg = Math.fmin(diff_deg * 0.5, 15.0);
    var output = sanitize_degrees (a.h + rot_deg * rot_dir(a.h, b.h));
    return {output, a.c, a.t};
  }
  public double sanitize_degrees (double degrees) {
    degrees = degrees % 360.0;
    if (degrees < 0) {
      degrees = degrees + 360.0;
    }
    return degrees;
  }
  public double rot_dir(double from, double to) {
    var increasingDifference = sanitize_degrees (to - from);
    return increasingDifference <= 180.0 ? 1.0 : -1.0;
  }
  public double diff_deg(double a, double b) {
    return 180.0 - Math.fabs(Math.fabs(a - b) - 180.0);
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

    // D65 white point
    XYZColor result = {
      convert(x) * 0.95047,
      convert(y) * 1.00000,
      convert(z) * 1.08883
    };

    return result;
  }

  double convert(double value) {
    var epsilon = 6.0 / 29.0;
    var kappa = 108.0 / 841.0;
    var delta = 4.0 / 29.0;
    return value > epsilon ? Math.pow(value, 3) : (value - delta) * kappa;
  }

  public LCHColor hct_to_lch(HCTColor color) {
    LCHColor lch_color_derived = {
      color.t,
      color.c,
      color.h
    };
    return lch_color_derived;
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
