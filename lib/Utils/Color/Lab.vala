namespace He.Color {
    /**
    * Miscellaneous constants for the Lab colorspace
    */
    // Corresponds roughly to RGB brighter/darker
    public const double Kn = 18.0;
    // D65 standard referent
    public const double Xn = 0.9570855264;
    public const double Yn = 1.0114135331;
    public const double Zn = 1.1190554598;
    public const double t0 = 0.1379310345;  // 4 / 29
    public const double t1 = 0.2068965523;  // 6 / 29
    public const double t2 = 0.1284185508;  // 3  * t1 * t1
    public const double t3 = 0.0088564521;  // t1 * t1 * t1

    public struct LABColor {
        public double l;
        public double a;
        public double b;
    }

    public double xyz_value_to_lab (double v) {
        if (v > He.Color.t3) return Math.pow (v, 1d / 3d);
        return v / He.Color.t2 + He.Color.t0;
    }

    public LABColor xyz_to_lab (XYZColor color) {
        var l = xyz_value_to_lab (color.x);
        var a = xyz_value_to_lab (color.y);
        var b = xyz_value_to_lab (color.z);

        LABColor result = {
          l,
          a,
          b
        };

        return result;
    }

    public LABColor lch_to_lab (LCHColor color) {
        var hr = color.h * 6.283185307179586 / 360.0;
        LABColor result = {
          color.l,
          color.c * Math.cos (hr),
          color.c * Math.sin (hr)
        };

        return result;
    }

    public LABColor rgb_to_lab (RGBColor color) {
        var xyz_color = rgb_to_xyz (color);
        var l = 116d * xyz_color.y - 16d;

        LABColor result = {
          l < 0 ? 0 : l,
          500d * (xyz_color.x - xyz_color.y),
          200d * (xyz_color.y - xyz_color.z)
        };

        return result;
    }

    public double lab_distance (LABColor color1, LABColor color2) {
        var l = color1.l - color2.l;
        var a = color1.a - color2.a;
        var b = color1.b - color2.b;

        return Math.sqrt (l * l + a * a + b * b);
    }
}
