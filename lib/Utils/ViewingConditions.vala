// Adapted from the Java implementation of material-color-utilities licensed under the Apache License, Version 2.0
// Copyright (c) 2021 Google LLC

public class He.ViewingConditions : Object {
    public static ViewingConditions default_conditions = ViewingConditions.with_lstar (LSTAR);
    public double[] rgb_d = {};

    private double _aw;
    public double aw {
        get { return _aw; }
        set { _aw = value; }
    }

    private double _nbb;
    public double nbb {
        get { return _nbb; }
        set { _nbb = value; }
    }

    private double _ncb;
    public double ncb {
        get { return _ncb; }
        set { _ncb = value; }
    }

    private double _c;
    public double c {
        get { return _c; }
        set { _c = value; }
    }

    private double _nc;
    public double nc {
        get { return _nc; }
        set { _nc = value; }
    }

    private double _n;
    public double n {
        get { return _n; }
        set { _n = value; }
    }

    private double _fl;
    public double fl {
        get { return _fl; }
        set { _fl = value; }
    }

    private double _fl_root;
    public double fl_root {
        get { return _fl_root; }
        set { _fl_root = value; }
    }

    private double _z;
    public double z {
        get { return _z; }
        set { _z = value; }
    }

    public static double lerp (double start, double stop, double amount) {
        return (1.0 - amount) * start + amount * stop;
    }

    public static ViewingConditions make (double[] white_point = { 95.047, 100, 108.883 },
                                          double adapting_luminance = (200.0 / Math.PI * He.MathUtils.y_from_lstar (50.0) / 100.0),
                                          double bg_lstar = 50.0,
                                          double surround = 2.0,
                                          bool discount_illuminant = false) {
        bg_lstar = Math.fmax (0.1, bg_lstar);
        double[,] matrix = XYZ_TO_CAM16RGB;
        double[] xyz = white_point;
        double r_white = (xyz[0] * matrix[0, 0]) + (xyz[1] * matrix[0, 1]) + (xyz[2] * matrix[0, 2]);
        double g_white = (xyz[0] * matrix[1, 0]) + (xyz[1] * matrix[1, 1]) + (xyz[2] * matrix[1, 2]);
        double b_white = (xyz[0] * matrix[2, 0]) + (xyz[1] * matrix[2, 1]) + (xyz[2] * matrix[2, 2]);
        double f = 0.8 + (surround / 10.0);
        double c =
            (f >= 0.9)
              ? lerp (0.59, 0.69, ((f - 0.9) * 10.0))
              : lerp (0.525, 0.59, ((f - 0.8) * 10.0));
        double d =
            discount_illuminant
              ? 1.0
              : f * (1.0 - ((1.0 / 3.6) * Math.exp ((-adapting_luminance - 42.0) / 92.0)));
        d = MathUtils.clamp_double (0.0, 1.0, d);
        double nc = f;
        double[] rgb_d = {
            d* (100.0 / r_white) + 1.0 - d,
            d * (100.0 / g_white) + 1.0 - d,
            d * (100.0 / b_white) + 1.0 - d
        };
        double k = 1.0 / (5.0 * adapting_luminance + 1.0);
        double k4 = k * k * k * k;
        double k4_f = 1.0 - k4;
        double fl = (k4 * adapting_luminance) + (0.1 * k4_f * k4_f * Math.cbrt (5.0 * adapting_luminance));
        double n = (MathUtils.y_from_lstar (bg_lstar) / white_point[1]);
        double z = 1.48 + Math.sqrt (n);
        double nbb = 0.725 / Math.pow (n, 0.2);
        double ncb = nbb;
        double[] rgb_a_factors =
            new double[] {
            Math.pow (fl * rgb_d[0] * r_white / 100.0, 0.42),
            Math.pow (fl * rgb_d[1] * g_white / 100.0, 0.42),
            Math.pow (fl * rgb_d[2] * b_white / 100.0, 0.42)
        };

        double[] rgba =
            new double[] {
            (400.0 * rgb_a_factors[0]) / (rgb_a_factors[0] + 27.13),
            (400.0 * rgb_a_factors[1]) / (rgb_a_factors[1] + 27.13),
            (400.0 * rgb_a_factors[2]) / (rgb_a_factors[2] + 27.13)
        };

        double aw = ((2.0 * rgba[0]) + rgba[1] + (0.05 * rgba[2])) * nbb;
        return new ViewingConditions (n, aw, nbb, ncb, c, nc, rgb_d, fl, Math.pow (fl, 0.25), z);
    }

    public static ViewingConditions with_lstar (double lstar) {
        double adapting_luminance = -1;
        lstar = Math.fmax (0.1, lstar);
        return ViewingConditions.make (
                                       { 95.047, 100, 108.883 },
                                       (adapting_luminance > 0.0) ? adapting_luminance : (200.0 / Math.PI * MathUtils.y_from_lstar (lstar) / 100.0),
                                       lstar,
                                       2.0,
                                       false
        );
    }

    private ViewingConditions (double n,
        double aw,
        double nbb,
        double ncb,
        double c,
        double nc,
        double[] rgb_d,
        double fl,
        double fl_root,
        double z) {
        this.n = n;
        this.aw = aw;
        this.nbb = nbb;
        this.ncb = ncb;
        this.c = c;
        this.nc = nc;
        this.rgb_d = rgb_d;
        this.fl = fl;
        this.fl_root = fl_root;
        this.z = z;
    }
}