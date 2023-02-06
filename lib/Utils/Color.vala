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

  public const double[,] XYZ_TO_CAM16RGB = {
    {0.401288, 0.650173, -0.051461},
    {-0.250268, 1.204414, 0.045854},
    {-0.002079, 0.048952, 0.953127}
  };
  public const double[,] CAM16RGB_TO_XYZ = {
    {1.8620678, -1.0112547, 0.14918678},
    {0.38752654, 0.62144744, -0.00897398},
    {-0.01584150, -0.03412294, 1.0499644}
  };
  public const double[,] SCALED_DISCOUNT_FROM_LINRGB = {
    {
      0.001200833568784504, 0.002389694492170889, 0.0002795742885861124,
    },
    {
      0.0005891086651375999, 0.0029785502573438758, 0.0003270666104008398,
    },
    {
      0.00010146692491640572, 0.0005364214359186694, 0.0032979401770712076,
    },
  };
  public const double[,] LINRGB_FROM_SCALED_DISCOUNT = {
    {
      1373.2198709594231, -1100.4251190754821, -7.278681089101213,
    },
    {
      -271.815969077903, 559.6580465940733, -32.46047482791194,
    },
    {
      1.9622899599665666, -57.173814538844006, 308.7233197812385,
    },
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
    public string a; // Keep hexcode rep as string on the struct for easy lookup
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

  public RGBColor xyz_to_rgb (XYZColor color) {
    RGBColor rgb = {};

    rgb.r = (color.x *  3.240479) + (color.y * -1.537150) + (color.z * -0.498535);
    rgb.g = (color.x * -0.969256) + (color.y *  1.875992) + (color.z *  0.041556);
    rgb.b = (color.x *  0.055648) + (color.y * -0.204043) + (color.z *  1.057311);

    if (rgb.r > 0.0031308) {
        rgb.r = (1.055 * Math.pow(rgb.r, (1.0/2.4))) - 0.055;
    } else {
        rgb.r = rgb.r * 12.92;
    }

    if (rgb.g > 0.0031308) {
        rgb.g = (1.055 * Math.pow(rgb.g, (1.0/2.4))) - 0.055;
    } else {
        rgb.g = rgb.g * 12.92;
    }

    if (rgb.b > 0.0031308) {
        rgb.b = (1.055 * Math.pow(rgb.b, (1.0/2.4))) - 0.055;
    } else {
        rgb.b = rgb.b * 12.92;
    }

    rgb.r = rgb.r * 255.0;
    rgb.g = rgb.g * 255.0;
    rgb.b = rgb.b * 255.0;

    return rgb;
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
    var result = lab_to_lch (lab_color);

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

  public CAM16Color xyz_to_cam16 (XYZColor color) {
    var rC =  0.401288 * color.x + 0.650173 * color.y - 0.051461 * color.z;
    var gC = -0.250268 * color.x + 1.204414 * color.y + 0.045854 * color.z;
    var bC = -0.002079 * color.x + 0.048952 * color.y + 0.953127 * color.z;

    double[] xyz = {95.047, 100.0, 108.883}; // D65
    var rW = xyz[0] *  0.401288 + xyz[1] * 0.650173 + xyz[2] * -0.051461;
    var gW = xyz[0] * -0.250268 + xyz[1] * 1.204414 + xyz[2] *  0.045854;
    var bW = xyz[0] * -0.002079 + xyz[1] * 0.048952 + xyz[2] *  0.953127;

    double[] rgbD = {
      0.9 * (100.0 / rW) + 1.0 - 0.9,
      0.9 * (100.0 / gW) + 1.0 - 0.9,
      0.9 * (100.0 / bW) + 1.0 - 0.9,
    };

    // Discount illuminant
    var rD = rgbD[0] * rC;
    var gD = rgbD[1] * gC;
    var bD = rgbD[2] * bC;

    var rAF = Math.pow(0.5848035714321961 * Math.fabs(rD) / 100.0, 0.42);
    var gAF = Math.pow(0.5848035714321961 * Math.fabs(gD) / 100.0, 0.42);
    var bAF = Math.pow(0.5848035714321961 * Math.fabs(bD) / 100.0, 0.42);
    var rA = signum(rD) * 400.0 * rAF / (rAF + 27.13);
    var gA = signum(gD) * 400.0 * gAF / (gAF + 27.13);
    var bA = signum(bD) * 400.0 * bAF / (bAF + 27.13);

    // redness-greenness
    var a = (11.0 * rA + -12.0 * gA + bA) / 11.0;
    // yellowness-blueness
    var b = (rA + gA - 2.0 * bA + 0.011) / 9.0;

    // auxiliary components
    var u = (20.0 * rA + 20.0 * gA + 21.0 * bA) / 20.0;
    var p2 = (40.0 * rA + 20.0 * gA + bA) / 20.0;

    // hue
    var hr = Math.atan2(b, a);
    var atanDegrees = hr * 180.0 / Math.PI;
    var h = atanDegrees < 0.0 ? atanDegrees + 360.0 : atanDegrees >= 360.0 ? atanDegrees - 360.0 : atanDegrees;

    // achromatic response to color
    var ac = p2 * 1.0003040045593807;

    // CAM16 lightness and brightness
    var J = 100.0 * Math.pow(ac / 34.866244046768664, 0.69 * 1.9272135954999579);

    var e_t = (h < 20.14) ? h + 360 : h;
    var eh = 0.25 * (Math.cos(e_t * Math.PI / 180.0 + 2.0) + 3.8);
    var p1 = 50000.0 / 13.0 * eh * 1 * 1.0003040045593807;
    var t = p1 * Math.sqrt(a * a + b * b) / (u + 0.3050);
    var alpha = Math.pow(t, 0.9) * Math.pow(1.64 - Math.pow(0.29, 0.2), 0.73);

    // CAM16 chroma
    var C = alpha * Math.pow(ac / 34.866244046768664, 0.5 * 0.69 * 1.9272135954999579);

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

    if (hueNotPass || toneNotPass) {
      print("\nTHIS IS YOUR HCT VALUES FIXED:\nH %f / C %f / T %f\n".printf(result.h, result.c, 70.0));
      return {result.h, result.c, 70.0, result.a}; // Fix color for UI, based on Psychology
    } else {
      print("\nTHIS IS YOUR HCT VALUES THAT PASSED:\nH %f / C %f / T %f\n".printf(result.h, result.c, result.t));
      return {result.h, result.c, result.t, result.a};
    }
  }
  public string hct_to_hex (HCTColor color) {
    // If color is mono
    if (color.c < 1.0001 || color.t < 0.0001 || color.t > 99.9999) {
      double y = 100.0 * lab_invf((color.t + 16.0) / 116.0);
      double normalized = y / 100.0;
      double delinearized = 0.0;
      if (normalized <= 0.0031308) {
        delinearized = normalized * 12.92;
      } else {
        delinearized = 1.055 * Math.pow(normalized, 1.0 / 2.4) - 0.055;
      }
      int component = (int)Math.round(delinearized * 255.0).clamp(0, 255);
      return hexcode (component, component, component);
    }

    // Else...
    color.h = sanitize_degrees (color.h);
    double hr = color.h / 180 * Math.PI;
    double y = 100.0 * lab_invf((color.t + 16.0) / 116.0);
    string exactAnswer = find_result_by_j(hr, color.c, y);
    if (exactAnswer != "#000000") {
      return exactAnswer;
    }
    double[] linrgb = bisect_to_limit(y, hr);
    return argbFromLinrgb(linrgb);
  }
  public static int rgbFromLRgb(int red, int green, int blue) {
    return (255 << 24) | ((red & 255) << 16) | ((green & 255) << 8) | (blue & 255);
  }
  public static string argbFromLinrgb(double[] linrgb) {
    int r = delinearized(linrgb[0]);
    int g = delinearized(linrgb[1]);
    int b = delinearized(linrgb[2]);

    RGBColor rgb = { (double)r, (double)g, (double)b };

    return hexcode (rgb.r, rgb.g, rgb.b);
  }
  public static int delinearized(double rgbComponent) {
    double normalized = rgbComponent / 100.0;
    double delinearized = 0.0;
    if (normalized <= 0.0031308) {
      delinearized = normalized * 12.92;
    } else {
      delinearized = 1.055 * Math.pow(normalized, 1.0 / 2.4) - 0.055;
    }
    return (int) Math.round(delinearized * 255.0).clamp(0, 255);
  }
  static double inverse_chromatic_adaptation(double adapted) {
    double adaptedAbs = Math.fabs(adapted);
    double b = Math.fmax(0, 27.13 * adaptedAbs / (400.0 - adaptedAbs));
    return signum(adapted) * Math.pow(b, 1.0 / 0.42);
  }
  static string find_result_by_j(double hr, double c, double y) {
    // Initial estimate of j.
    double j = Math.sqrt(y) * 11.0;
    double tInnerCoeff = 1 / Math.pow(1.64 - Math.pow(0.29, 0.2), 0.73);
    double eHue = 0.25 * (Math.cos(hr + 2.0) + 3.8);
    double p1 = eHue * (50000.0 / 13.0) * 0.69 * 1.0003040045593807;
    double hSin = Math.sin(hr);
    double hCos = Math.cos(hr);
    for (int iterationRound = 0; iterationRound < 5; iterationRound++) {
      double jNormalized = j / 100.0;
      double alpha = c == 0.0 || j == 0.0 ? 0.0 : c / Math.sqrt(jNormalized);
      double t = Math.pow(alpha * tInnerCoeff, 1.0 / 0.9);
      double ac = 34.866244046768664 * Math.pow(jNormalized, 1.0 / 0.69 / 1.9272135954999579);
      double p2 = ac / 1.0003040045593807;
      double gamma = 23.0 * (p2 + 0.305) * t / (23.0 * p1 + 11 * t * hCos + 108.0 * t * hSin);
      double a = gamma * hCos;
      double b = gamma * hSin;
      double rA = (460.0 * p2 + 451.0 * a + 288.0 * b) / 1403.0;
      double gA = (460.0 * p2 - 891.0 * a - 261.0 * b) / 1403.0;
      double bA = (460.0 * p2 - 220.0 * a - 6300.0 * b) / 1403.0;
      double rCScaled = inverse_chromatic_adaptation (rA);
      double gCScaled = inverse_chromatic_adaptation (gA);
      double bCScaled = inverse_chromatic_adaptation (bA);
      double[] linrgb = elem_mul({rCScaled, gCScaled, bCScaled}, LINRGB_FROM_SCALED_DISCOUNT);
      if (linrgb[0] < 0 || linrgb[1] < 0 || linrgb[2] < 0) {
        return "#000000";
      }
      double kR = 0.2126;
      double kG = 0.7152;
      double kB = 0.0722;
      double fnj = kR * linrgb[0] + kG * linrgb[1] + kB * linrgb[2];
      if (fnj <= 0) {
        return "#000000";
      }
      if (iterationRound == 4 || Math.fabs(fnj - y) < 0.002) {
        if (linrgb[0] > 100.01 || linrgb[1] > 100.01 || linrgb[2] > 100.01) {
          return "#000000";
        }
        return argbFromLinrgb(linrgb);
      }
      // Iterates with Newton method,
      // Using 2 * fn(j) / j as the approximation of fn'(j)
      j = j - (fnj - y) * j / (2 * fnj);
    }
    return "#000000";
  }
  static double[] bisect_to_segment (double y, double targetHue) {
    double[] left = {-1.0, -1.0, -1.0};
    double[] right = left;
    double leftHue = 0.0;
    double rightHue = 0.0;
    bool initialized = false;
    bool uncut = true;
    for (int n = 0; n < 12; n++) {
      double[] mid = nth_vertex(y, n);
      if (mid[0] < 0) {
        continue;
      }
      double midHue = hue_of(mid);
      if (!initialized) {
        left = mid;
        right = mid;
        leftHue = midHue;
        rightHue = midHue;
        initialized = true;
        continue;
      }
      if (uncut || areInCyclicOrder(leftHue, midHue, rightHue)) {
        uncut = false;
        if (areInCyclicOrder(leftHue, targetHue, midHue)) {
          right = mid;
          rightHue = midHue;
        } else {
          left = mid;
          leftHue = midHue;
        }
      }
    }
    return new double[] {left[0], left[1], left[2], right[0], right[1], right[2]};
  }
  static int critical_plane_below(double x) {
    return (int) Math.floor(x - 0.5);
  }

  static int critical_plane_above(double x) {
    return (int) Math.ceil(x - 0.5);
  }
  static double[] midpoint(double[] a, double[] b) {
    return new double[] {
      (a[0] + b[0]) / 2, (a[1] + b[1]) / 2, (a[2] + b[2]) / 2,
    };
  }
  static double intercept(double source, double mid, double target) {
    return (mid - source) / (target - source);
  }

  static double[] lerpPoint(double[] source, double t, double[] target) {
    return new double[] {
      source[0] + (target[0] - source[0]) * t,
      source[1] + (target[1] - source[1]) * t,
      source[2] + (target[2] - source[2]) * t,
    };
  }
  static double[] bisect_to_limit(double y, double targetHue) {
    double[] segment = bisect_to_segment(y, targetHue);
    double[] left = {segment[0], segment[1], segment[2]};
    double leftHue = hue_of(left);
    double[] right = {segment[3], segment[4], segment[5]};;
    for (int axis = 0; axis < 3; axis++) {
      if (left[axis] != right[axis]) {
        int lPlane = -1;
        int rPlane = 255;
        if (left[axis] < right[axis]) {
          lPlane = critical_plane_below(real_delinearized(left[axis]));
          rPlane = critical_plane_above(real_delinearized(right[axis]));
        } else {
          lPlane = critical_plane_above(real_delinearized(left[axis]));
          rPlane = critical_plane_below(real_delinearized(right[axis]));
        }
        for (int i = 0; i < 8; i++) {
          if (Math.fabs(rPlane - lPlane) <= 1) {
            break;
          } else {
            int mPlane = (int) Math.floor((lPlane + rPlane) / 2.0);
            double midPlaneCoordinate = CRITICAL_PLANES[mPlane];
            double[] mid = set_coordinate(left, midPlaneCoordinate, right, axis);
            double midHue = hue_of(mid);
            if (areInCyclicOrder(leftHue, targetHue, midHue)) {
              right = mid;
              rPlane = mPlane;
            } else {
              left = mid;
              leftHue = midHue;
              lPlane = mPlane;
            }
          }
        }
      }
    }
    return midpoint(left, right);
  }
  static bool areInCyclicOrder(double a, double b, double c) {
    double deltaAB = sanitizeRadians(b - a);
    double deltaAC = sanitizeRadians(c - a);
    return deltaAB < deltaAC;
  }
  static double sanitizeRadians(double angle) {
    return (angle + Math.PI * 8) % (Math.PI * 2);
  }
  static double chromatic_adaptation(double component) {
    double af = Math.pow(Math.fabs(component), 0.42);
    return signum(component) * 400.0 * af / (af + 27.13);
  }
  static double hue_of(double[] linrgb) {
    double[] scaled_discount = elem_mul(linrgb, SCALED_DISCOUNT_FROM_LINRGB);
    double rA = chromatic_adaptation(scaled_discount[0]);
    double gA = chromatic_adaptation(scaled_discount[1]);
    double bA = chromatic_adaptation(scaled_discount[2]);
    // redness-greenness
    double a = (11.0 * rA + -12.0 * gA + bA) / 11.0;
    // yellowness-blueness
    double b = (rA + gA - 2.0 * bA) / 9.0;
    return Math.atan2(b, a);
  }
  static double[] nth_vertex(double y, int n) {
    double kR = 0.2126;
    double kG = 0.7152;
    double kB = 0.0722;
    double coordA = n % 4 <= 1 ? 0.0 : 100.0;
    double coordB = n % 2 == 0 ? 0.0 : 100.0;
    if (n < 4) {
      double g = coordA;
      double b = coordB;
      double r = (y - g * kG - b * kB) / kR;
      if (is_bounded(r)) {
        return new double[] {r, g, b};
      } else {
        return new double[] {-1.0, -1.0, -1.0};
      }
    } else if (n < 8) {
      double b = coordA;
      double r = coordB;
      double g = (y - r * kR - b * kB) / kG;
      if (is_bounded(g)) {
        return new double[] {r, g, b};
      } else {
        return new double[] {-1.0, -1.0, -1.0};
      }
    } else {
      double r = coordA;
      double g = coordB;
      double b = (y - r * kR - g * kG) / kB;
      if (is_bounded(b)) {
        return new double[] {r, g, b};
      } else {
        return new double[] {-1.0, -1.0, -1.0};
      }
    }
  }
  static double[] set_coordinate(double[] source, double coordinate, double[] target, int axis) {
    double t = intercept(source[axis], coordinate, target[axis]);
    return lerpPoint(source, t, target);
  }

  static bool is_bounded (double x) {
    return 0.0 <= x && x <= 100.0;
  }
  static double real_delinearized (double rgbc) {
    double normalized = rgbc / 100.0;
    double delinearized = 0.0;
    if (normalized <= 0.0031308) {
      delinearized = normalized * 12.92;
    } else {
      delinearized = 1.055 * Math.pow(normalized, 1.0 / 2.4) - 0.055;
    }
    return delinearized * 255.0;
  }
  private double[] elem_mul(double[] row, double[,] matrix) {
    double[] prod = {
      row[0] * matrix[0,0] + row[1] * matrix[0,1] + row[2] * matrix[0,2],
      row[0] * matrix[1,0] + row[1] * matrix[1,1] + row[2] * matrix[1,2],
      row[0] * matrix[2,0] + row[1] * matrix[2,1] + row[2] * matrix[2,2]
    };
    return prod;
  }
  private static double lab_invf(double ft) {
    double e = 216.0 / 24389.0;
    double kappa = 24389.0 / 27.0;
    double ft3 = ft * ft * ft;
    if (ft3 > e) {
      return ft3;
    } else {
      return (116 * ft - 16) / kappa;
    }
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

  public RGBColor lab_to_rgb(LABColor color) {
    var xyz_lab = lab_to_xyz(color);
    var result = xyz_to_rgb (xyz_lab);

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
  
  public RGBColor lch_to_rgb (LCHColor color) {
    var lab = lch_to_lab(color);
    var rgb = lab_to_rgb(lab);

    RGBColor result = rgb;
    
    return result;
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

  public string hexcode_argb (int color) {
    string c = "%x".printf(color);
    string result = "#" + c.substring(2, 6);
    return result;
  }

  private const double[] CRITICAL_PLANES = {
    0.015176349177441876,
    0.045529047532325624,
    0.07588174588720938,
    0.10623444424209313,
    0.13658714259697685,
    0.16693984095186062,
    0.19729253930674434,
    0.2276452376616281,
    0.2579979360165119,
    0.28835063437139563,
    0.3188300904430532,
    0.350925934958123,
    0.3848314933096426,
    0.42057480301049466,
    0.458183274052838,
    0.4976837250274023,
    0.5391024159806381,
    0.5824650784040898,
    0.6277969426914107,
    0.6751227633498623,
    0.7244668422128921,
    0.775853049866786,
    0.829304845476233,
    0.8848452951698498,
    0.942497089126609,
    1.0022825574869039,
    1.0642236851973577,
    1.1283421258858297,
    1.1946592148522128,
    1.2631959812511864,
    1.3339731595349034,
    1.407011200216447,
    1.4823302800086415,
    1.5599503113873272,
    1.6398909516233677,
    1.7221716113234105,
    1.8068114625156377,
    1.8938294463134073,
    1.9832442801866852,
    2.075074464868551,
    2.1693382909216234,
    2.2660538449872063,
    2.36523901573795,
    2.4669114995532007,
    2.5710888059345764,
    2.6777882626779785,
    2.7870270208169257,
    2.898822059350997,
    3.0131901897720907,
    3.1301480604002863,
    3.2497121605402226,
    3.3718988244681087,
    3.4967242352587946,
    3.624204428461639,
    3.754355295633311,
    3.887192587735158,
    4.022731918402185,
    4.160988767090289,
    4.301978482107941,
    4.445716283538092,
    4.592217266055746,
    4.741496401646282,
    4.893568542229298,
    5.048448422192488,
    5.20615066083972,
    5.3666897647573375,
    5.5300801301023865,
    5.696336044816294,
    5.865471690767354,
    6.037501145825082,
    6.212438385869475,
    6.390297286737924,
    6.571091626112461,
    6.7548350853498045,
    6.941541251256611,
    7.131223617812143,
    7.323895587840543,
    7.5195704746346665,
    7.7182615035334345,
    7.919981813454504,
    8.124744458384042,
    8.332562408825165,
    8.543448553206703,
    8.757415699253682,
    8.974476575321063,
    9.194643831691977,
    9.417930041841839,
    9.644347703669503,
    9.873909240696694,
    10.106627003236781,
    10.342513269534024,
    10.58158024687427,
    10.8238400726681,
    11.069304815507364,
    11.317986476196008,
    11.569896988756009,
    11.825048221409341,
    12.083451977536606,
    12.345119996613247,
    12.610063955123938,
    12.878295467455942,
    13.149826086772048,
    13.42466730586372,
    13.702830557985108,
    13.984327217668513,
    14.269168601521828,
    14.55736596900856,
    14.848930523210871,
    15.143873411576273,
    15.44220572664832,
    15.743938506781891,
    16.04908273684337,
    16.35764934889634,
    16.66964922287304,
    16.985093187232053,
    17.30399201960269,
    17.62635644741625,
    17.95219714852476,
    18.281524751807332,
    18.614349837764564,
    18.95068293910138,
    19.290534541298456,
    19.633915083172692,
    19.98083495742689,
    20.331304511189067,
    20.685334046541502,
    21.042933821039977,
    21.404114048223256,
    21.76888489811322,
    22.137256497705877,
    22.50923893145328,
    22.884842241736916,
    23.264076429332462,
    23.6469514538663,
    24.033477234264016,
    24.42366364919083,
    24.817520537484558,
    25.21505769858089,
    25.61628489293138,
    26.021211842414342,
    26.429848230738664,
    26.842203703840827,
    27.258287870275353,
    27.678110301598522,
    28.10168053274597,
    28.529008062403893,
    28.96010235337422,
    29.39497283293396,
    29.83362889318845,
    30.276079891419332,
    30.722335150426627,
    31.172403958865512,
    31.62629557157785,
    32.08401920991837,
    32.54558406207592,
    33.010999283389665,
    33.4802739966603,
    33.953417292456834,
    34.430438229418264,
    34.911345834551085,
    35.39614910352207,
    35.88485700094671,
    36.37747846067349,
    36.87402238606382,
    37.37449765026789,
    37.87891309649659,
    38.38727753828926,
    38.89959975977785,
    39.41588851594697,
    39.93615253289054,
    40.460400508064545,
    40.98864111053629,
    41.520882981230194,
    42.05713473317016,
    42.597404951718396,
    43.141702194811224,
    43.6900349931913,
    44.24241185063697,
    44.798841244188324,
    45.35933162437017,
    45.92389141541209,
    46.49252901546552,
    47.065252796817916,
    47.64207110610409,
    48.22299226451468,
    48.808024568002054,
    49.3971762874833,
    49.9904556690408,
    50.587870934119984,
    51.189430279724725,
    51.79514187861014,
    52.40501387947288,
    53.0190544071392,
    53.637271562750364,
    54.259673423945976,
    54.88626804504493,
    55.517063457223934,
    56.15206766869424,
    56.79128866487574,
    57.43473440856916,
    58.08241284012621,
    58.734331877617365,
    59.39049941699807,
    60.05092333227251,
    60.715611475655585,
    61.38457167773311,
    62.057811747619894,
    62.7353394731159,
    63.417162620860914,
    64.10328893648692,
    64.79372614476921,
    65.48848194977529,
    66.18756403501224,
    66.89098006357258,
    67.59873767827808,
    68.31084450182222,
    69.02730813691093,
    69.74813616640164,
    70.47333615344107,
    71.20291564160104,
    71.93688215501312,
    72.67524319850172,
    73.41800625771542,
    74.16517879925733,
    74.9167682708136,
    75.67278210128072,
    76.43322770089146,
    77.1981124613393,
    77.96744375590167,
    78.74122893956174,
    79.51947534912904,
    80.30219030335869,
    81.08938110306934,
    81.88105503125999,
    82.67721935322541,
    83.4778813166706,
    84.28304815182372,
    85.09272707154808,
    85.90692527145302,
    86.72564993000343,
    87.54890820862819,
    88.3767072518277,
    89.2090541872801,
    90.04595612594655,
    90.88742016217518,
    91.73345337380438,
    92.58406282226491,
    93.43925555268066,
    94.29903859396902,
    95.16341895893969,
    96.03240364439274,
    96.9059996312159,
    97.78421388448044,
    98.6670533535366,
    99.55452497210776,
  };
}
