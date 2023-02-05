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
    public const double Kn = 18.0;

    // D65 standard referent
    public const double Xn = 0.95708552640;
    public const double Yn = 1.01141353310;
    public const double Zn = 1.11905545980;

    public const double t0 = 0.13793103450;  // 4 / 29
    public const double t1 = 0.20689655230;  // 6 / 29
    public const double t2 = 0.12841855080;  // 3  * t1 * t1
    public const double t3 = 0.00885645210;  // t1 * t1 * t1
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
     0.4012880, 0.6501730, -0.0514610,
    -0.2502680, 1.2044140,  0.0458540,
    -0.0020790, 0.0489520,  0.9531270,
  };
  public const double[] SRGB_TO_XYZ = {
    0.412338950, 0.357620640, 0.180510420,
    0.212600000, 0.715200000, 0.072200000,
    0.019321410, 0.119163820, 0.950344780,
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
    public string a; // Keep RGB rep as string on the struct for easy lookup
  }

  // The following is adapted from:
  // https://github.com/gka/chroma.js/blob/75ea5d8a5480c90ef1c7830003ac63c2d3a15c03/src/io/lab/rgb2lab.js
  // https://github.com/gka/chroma.js/blob/75ea5d8a5480c90ef1c7830003ac63c2d3a15c03/src/io/lab/lab-constants.js
  // https://cs.github.com/gka/chroma.js/blob/cd1b3c0926c7a85cbdc3b1453b3a94006de91a92/src/io/lab/lab2rgb.js#L10

  public double rgb_value_to_xyz(double v) {
    if ((v /= 255) <= 0.040450) return v / 12.92000;
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

    var x = xyz_value_to_lab((0.41245640 * r + 0.35757610 * g + 0.18043750 * b) / He.Color.LabConstants.Xn);
    var y = xyz_value_to_lab((0.21267290 * r + 0.71515220 * g + 0.07217500 * b) / He.Color.LabConstants.Yn);
    var z = xyz_value_to_lab((0.01933390 * r + 0.11919200 * g + 0.95030410 * b) / He.Color.LabConstants.Zn);

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
    var hr = color.h * 6.2831853071795860 / 360.0;
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
      Math.atan2(color.b,color.a) * 360.0 / 6.2831853071795860
    };

    return result;
  }

  public CAM16Color xyz_to_cam16 (XYZColor color) {
    var rC =  0.4012880 * color.x + 0.6501730 * color.y - 0.0514610 * color.z;
    var gC = -0.2502680 * color.x + 1.2044140 * color.y + 0.0458540 * color.z;
    var bC = -0.0020790 * color.x + 0.0489520 * color.y + 0.9531270 * color.z;

    double[] xyz = {95.047, 100.0, 108.883}; // D65
    var rW = xyz[0] *  0.4012880 + xyz[1] * 0.6501730 + xyz[2] * -0.0514610;
    var gW = xyz[0] * -0.2502680 + xyz[1] * 1.2044140 + xyz[2] *  0.0458540;
    var bW = xyz[0] * -0.0020790 + xyz[1] * 0.0489520 + xyz[2] *  0.9531270;

    double[] rgbD = {
      0.88607764889132490 * (100.0 / rW) + 1.0 - 0.88607764889132490,
      0.88607764889132490 * (100.0 / gW) + 1.0 - 0.88607764889132490,
      0.88607764889132490 * (100.0 / bW) + 1.0 - 0.88607764889132490,
    };

    // Discount illuminant
    var rD = rgbD[0] * rC;
    var gD = rgbD[1] * gC;
    var bD = rgbD[2] * bC;

    var rAF = Math.pow(0.58480357143219610 * Math.fabs(rD) / 100.0, 0.420);
    var gAF = Math.pow(0.58480357143219610 * Math.fabs(gD) / 100.0, 0.420);
    var bAF = Math.pow(0.58480357143219610 * Math.fabs(bD) / 100.0, 0.420);
    var rA = signum(rD) * 400.0 * rAF / (rAF + 27.130);
    var gA = signum(gD) * 400.0 * gAF / (gAF + 27.130);
    var bA = signum(bD) * 400.0 * bAF / (bAF + 27.130);

    // redness-greenness
    var a = (11.0 * rA + -12.0 * gA + bA) / 11.0;
    // yellowness-blueness
    var b = (rA + gA - 2.0 * bA) / 9.0;

    // auxiliary components
    var u = (20.0 * rA + 20.0 * gA + 21.0 * bA) / 20.0;
    var p2 = (40.0 * rA + 20.0 * gA + bA) / 20.0;

    // hue
    var hr = Math.atan2(b, a);
    var atanDegrees = hr * 180.0 / Math.PI;
    var h = atanDegrees < 0.0
        ? atanDegrees + 360.0
        : atanDegrees >= 360.0
            ? atanDegrees - 360.0
            : atanDegrees;

    // achromatic response to color
    var ac = p2 * 1.00030400455938070;

    // CAM16 lightness and brightness
    var J = 100.0 * Math.pow(ac / 34.8662440467686640, 0.69 * 1.92721359549995790);

    var huePrime = (h < 20.14) ? h + 360 : h;
    var eHue = (1.0 / 4.0) * (Math.cos(huePrime * Math.PI / 180.0 + 2.0) + 3.8);
    var p1 = 50000.0 / 13.0 * eHue * 1 * 1.00030400455938070;
    var t = p1 * Math.sqrt(a * a + b * b) / (u + 0.3050);
    var alpha = Math.pow(t, 0.90) *
        Math.pow(
            1.640 - Math.pow(0.290, 0.20),
            0.730);
    // CAM16 chroma
    var C = (alpha * Math.sqrt(J / 100.0));

    CAM16Color result = {
      J,
      a,
      b,
      C,
      h
    };
    return result;
  }
  private int signum (double x) {
    return (int)(x > 0) - (int)(x < 0);
  }
  //

  public HCTColor cam16_and_lch_to_hct(CAM16Color color, LCHColor tone) {
    HCTColor result = {
      color.h,
      color.C,
      tone.l
    };

    // Now, we're not just gonna accept what comes to us via CAM16 and LCH,
    // because it generates bad HCT colors. So we're gonna test the color and
    // fix it for UI usage.

    // Test color for bad props
    // A hue between 90.0 and 111.0 is body deject-colored so we can't use it.
    // A tone less than 70.0 is unsuitable for UI as it's too dark.
    bool hueNotPass = result.h >= 90.0 && result.h <= 111.0;
    bool toneNotPass = result.t < 70.0;

    if (hueNotPass && toneNotPass) {
      print("THIS IS YOUR HCT VALUES FIXED:\nH %f / C %f / T %f\n".printf(result.h, result.c, 70.0));
      return {result.h, result.c, 70.0, result.a}; // Fix color for UI, based on Psychology
    } else {
      print("THIS IS YOUR HCT VALUES THAT PASSED:\nH %f / C %f / T %f\n".printf(result.h, result.c, result.t));
      return {result.h, result.c, result.t, result.a};
    }
  }
  public string hct_to_hex (HCTColor a) {
    return a.a;
  }
  public HCTColor hct_blend (HCTColor a, HCTColor b) {
    var diff_deg = diff_deg(a.h, b.h);
    var rot_deg = Math.fmin(diff_deg * 0.50, 15.0);
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

  public RGBColor lab_to_rgb(LABColor color) {
    var y = (color.l + 16.0) / 116.0;
    var x = color.a / 500.0 + y;
    var z = y - color.b / 200.0;
    
    if (Math.pow(y, 3) > 0.0088560)  { y = Math.pow(y, 3); }
    else                             { y = (y - 16.0 / 116.0) / 7.7870; }
    if (Math.pow(x, 3) > 0.0088560)  { x = Math.pow(x, 3); }
    else                             { x = (x - 16.0 / 116.0) / 7.7870; }
    if (Math.pow(z, 3) > 0.0088560)  { z = Math.pow(z, 3); }
    else                             { z = (z - 16.0 / 116.0) / 7.7870; }

    // (Observer = 2°, Illuminant = D65)
    x =  95.0470 * x;
    y = 100.0000 * y;
    z = 108.8830 * z;
    x = x / 100.0 ;
    y = y / 100.0 ;
    z = z / 100.0 ;

    var r =  3.24045420 * x - 1.53713850 * y - 0.49853140 * z;  // D65 -> sRGB
    var g = -0.96926600 * x + 1.87601080 * y + 0.04155600 * z;
    var b =  0.05564340 * x - 0.20402590 * y + 1.05722520 * z;
    
    if (r > 0.00313080)  { r = 1.0550 * Math.pow(r, ( 1 / 2.40 )) - 0.0550; }
    else                 { r = 12.920 * r; }
    if (g > 0.00313080)  { g = 1.0550 * Math.pow(g, ( 1 / 2.40 )) - 0.0550; }
    else                 { g = 12.920 * g; }
    if (b > 0.00313080)  { b = 1.0550 * Math.pow(b, ( 1 / 2.40 )) - 0.0550; }
    else                 { b = 12.920 * b; }

    RGBColor result = {
      r * 255.0,
      g * 255.0,
      b * 255.0
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
      convert(x) * 0.950470,
      convert(y) * 1.000000,
      convert(z) * 1.088830
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
      color.red * 255.0,
      color.green * 255.0,
      color.blue * 255.0,
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
