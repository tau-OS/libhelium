public class He.ViewingConditions : Object {
    public static ViewingConditions DEFAULT = ViewingConditions.with_lstar (50);
    public double[] rgbD = {};

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

    public static double lerp(double start, double stop, double amount) {
        return (1.0 - amount) * start + amount * stop;
    }

    public static ViewingConditions make (
        double[] whitePoint,
        double adaptingLuminance,
        double backgroundLstar,
        double surround,
        bool discountingIlluminant) {

      backgroundLstar = Math.fmax(0.1, backgroundLstar);
      double[,] matrix = Color.XYZ_TO_CAM16RGB;
      double[] xyz = whitePoint;
      double rW = (xyz[0] * matrix[0,0]) + (xyz[1] * matrix[0,1]) + (xyz[2] * matrix[0,2]);
      double gW = (xyz[0] * matrix[1,0]) + (xyz[1] * matrix[1,1]) + (xyz[2] * matrix[1,2]);
      double bW = (xyz[0] * matrix[2,0]) + (xyz[1] * matrix[2,1]) + (xyz[2] * matrix[2,2]);
      double f = 0.8 + (surround / 10.0);
      double c =
          (f >= 0.9)
              ? lerp(0.59, 0.69, ((f - 0.9) * 10.0))
              : lerp(0.525, 0.59, ((f - 0.8) * 10.0));
      double d =
          discountingIlluminant
              ? 1.0
              : f * (1.0 - ((1.0 / 3.6) * Math.exp((-adaptingLuminance - 42.0) / 92.0)));
      d = d.clamp(0.0, 1.0);
      double nc = f;
      double[] rgbD = {
        d * (100.0 / rW) + 1.0 - d, d * (100.0 / gW) + 1.0 - d, d * (100.0 / bW) + 1.0 - d
      };
      double k = 1.0 / (5.0 * adaptingLuminance + 1.0);
      double k4 = k * k * k * k;
      double k4F = 1.0 - k4;
      double fl = (k4 * adaptingLuminance) + (0.1 * k4F * k4F * Math.cbrt(5.0 * adaptingLuminance));
      double n = (100.0 * Color.lab_invf((backgroundLstar + 16.0) / 116.0) / whitePoint[1]);
      double z = 1.48 + Math.sqrt(n);
      double nbb = 0.725 / Math.pow(n, 0.2);
      double ncb = nbb;
      double[] rgbAFactors =
          new double[] {
            Math.pow(fl * rgbD[0] * rW / 100.0, 0.42),
            Math.pow(fl * rgbD[1] * gW / 100.0, 0.42),
            Math.pow(fl * rgbD[2] * bW / 100.0, 0.42)
          };
  
      double[] rgbA =
          new double[] {
            (400.0 * rgbAFactors[0]) / (rgbAFactors[0] + 27.13),
            (400.0 * rgbAFactors[1]) / (rgbAFactors[1] + 27.13),
            (400.0 * rgbAFactors[2]) / (rgbAFactors[2] + 27.13)
          };
  
      double aw = ((2.0 * rgbA[0]) + rgbA[1] + (0.05 * rgbA[2])) * nbb;
      return new ViewingConditions(n, aw, nbb, ncb, c, nc, rgbD, fl, Math.pow(fl, 0.25), z);
    }

    public static ViewingConditions with_lstar (double lstar) {
        return ViewingConditions.make(
            {95.047, 100.0, 108.883},
            (200.0 / Math.PI * 100.0 * Color.lab_invf((50 + 16.0) / 116.0) / 100),
            lstar,
            2.0,
            true
        );
    }

    private ViewingConditions(
        double n,
        double aw,
        double nbb,
        double ncb,
        double c,
        double nc,
        double[] rgbD,
        double fl,
        double fl_root,
        double z) {
      this.n = n;
      this.aw = aw;
      this.nbb = nbb;
      this.ncb = ncb;
      this.c = c;
      this.nc = nc;
      this.rgbD = rgbD;
      this.fl = fl;
      this.fl_root = fl_root;
      this.z = z;
    }
}