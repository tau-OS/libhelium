namespace He.Color {
    public static int rgb_from_linrgb (int red, int green, int blue) {
        return (255 << 24) | ((red & 255) << 16) | ((green & 255) << 8) | (blue & 255);
      }
      public static string argb_from_linrgb (double[] linrgb) {
        int r = He.MathUtils.delinearized (linrgb[0]);
        int g = He.MathUtils.delinearized (linrgb[1]);
        int b = He.MathUtils.delinearized (linrgb[2]);
    
        RGBColor rgb = { (double)r, (double)g, (double)b };
    
        return hexcode (rgb.r, rgb.g, rgb.b);
    }
    public string find_result_by_j(double hr, double c, double y) {
        // Initial estimate of j.
        double j = Math.sqrt(y) * 11.0;
        He.ViewingConditions vc = He.ViewingConditions.DEFAULT;
        double tInner_coeff = 1 / Math.pow (1.64 - Math.pow (0.29, vc.n), 0.73);
        double e_hue = 0.25 * (Math.cos(hr + 2.0) + 3.8);
        double p1 = e_hue * (5e4 / 13.0) * vc.nc * vc.ncb;
        double h_sine = Math.sin (hr);
        double h_cosine = Math.cos (hr);
        for (int round = 0; round < 5; round++) {
          double jNormalized = j / 100.0;
          double alpha = c == 0.0 || j == 0.0 ? 0.0 : c / Math.sqrt (jNormalized);
          double t = Math.pow (alpha * tInner_coeff, 1.0 / 0.9);
          double ac = vc.aw * Math.pow (jNormalized, 1.0 / vc.c / vc.z);
          double p2 = ac / vc.nbb;
          double gamma = 23.0 * (p2 + 0.305) * t / (23.0 * p1 + 11 * t * h_cosine + 108.0 * t * h_sine);
          double a = gamma * h_cosine;
          double b = gamma * h_sine;
          double r_a = (460.0 * p2 + 451.0 * a + 288.0 * b) / 1403.0;
          double g_a = (460.0 * p2 - 891.0 * a - 261.0 * b) / 1403.0;
          double b_a = (460.0 * p2 - 220.0 * a - 6300.0 * b) / 1403.0;
          double r_c_scaled = He.MathUtils.inverse_chromatic_adaptation (r_a);
          double g_c_scaled = He.MathUtils.inverse_chromatic_adaptation (g_a);
          double b_c_scaled = He.MathUtils.inverse_chromatic_adaptation (b_a);
          double[] linrgb = He.MathUtils.elem_mul({r_c_scaled, g_c_scaled, b_c_scaled}, He.MathUtils.LINRGB_FROM_SCALED_DISCOUNT);
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
          if (round == 4 || Math.fabs(fnj - y) < 0.002) {
            if (linrgb[0] > 100.01 || linrgb[1] > 100.01 || linrgb[2] > 100.01) {
              return "#000000";
            }
            return argb_from_linrgb (linrgb);
          }
          // Iterates with Newton method,
          // Using 2 * fn(j) / j as the approximation of fn'(j)
          j = j - (fnj - y) * j / (2 * fnj);
        }
        return "#000000";
    }
}