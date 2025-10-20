namespace He {
  public static int rgb_from_linrgb (int red, int green, int blue) {
    return (255 << 24) | ((red & 255) << 16) | ((green & 255) << 8) | (blue & 255);
  }

  public static int argb_from_linrgb (double[] linrgb) {
    int r = MathUtils.delinearized (linrgb[0]);
    int g = MathUtils.delinearized (linrgb[1]);
    int b = MathUtils.delinearized (linrgb[2]);

    return argb_from_rgb_int (r, g, b);
  }

  public int from_solved (double h, double c, double lstar) {
    // If color is mono…
    if (c < 0.0001 || lstar < 0.0001 || lstar > 99.9999) {
      return MathUtils.argb_from_lstar (lstar);
      // Else…
    } else {
      h = MathUtils.sanitize_degrees (h);
      double hr = h * Math.PI / 180.0;
      double y = MathUtils.y_from_lstar (lstar);
      int exact_answer = find_result_by_j (hr, c, y);

      if (exact_answer != 0) {
        return exact_answer;
      }

      double[] linrgb = MathUtils.bisect_to_limit (y, hr);
      return argb_from_linrgb (linrgb);
    }
  }

  public int find_result_by_j (double hr, double c, double y) {
    // Initial estimate of j.
    y = Math.fmax (0.0, y);
    double j = Math.sqrt (y) * 11.0;
    ViewingConditions vc = ViewingConditions.with_lstar (lab_to_xyz ({ 50.0, 0.0, 0.0 }).y* 100.0);

    // Protect against negative base in power operation
    double base_tr = Math.fmax (0.0, 1.64 - Math.pow (0.29, vc.n));
    double tr = 1.0 / Math.pow (base_tr, 0.73);
    double e_hue = 0.25 * (Math.cos (hr + 2.0) + 3.8);
    double p1 = e_hue * (50000.0 / 13.0) * vc.nc * vc.ncb;
    double h_sine = Math.sin (hr);
    double h_cosine = Math.cos (hr);

    for (int round = 0; round < 5; round++) {
      double jr = j / 100.0;
      jr = Math.fmax (1e-10, jr);
      double alpha = (c == 0.0 || j == 0.0) ? 0.0 : c / Math.sqrt (jr);
      double t = Math.pow (Math.fmax (0.0, alpha * tr), 1.0 / 0.9);
      double ac = vc.aw * Math.pow (Math.fmax (0.0, jr), 1.0 / vc.c / vc.z);
      double p2 = ac / Math.fmax (1e-10, vc.nbb);
      double gamma = 23.0 * (p2 + 0.305) * t / (23.0 * p1 + 11.0 * t * h_cosine + 108.0 * t * h_sine);
      double a = gamma * h_cosine;
      double b = gamma * h_sine;
      double r_a = (460.0 * p2 + 451.0 * a + 288.0 * b) / 1403.0;
      double g_a = (460.0 * p2 - 891.0 * a - 261.0 * b) / 1403.0;
      double b_a = (460.0 * p2 - 220.0 * a - 6300.0 * b) / 1403.0;
      double r_c_scaled = MathUtils.inverse_chromatic_adaptation (r_a);
      double g_c_scaled = MathUtils.inverse_chromatic_adaptation (g_a);
      double b_c_scaled = MathUtils.inverse_chromatic_adaptation (b_a);
      double[] linrgb = MathUtils.elem_mul (
                                            { r_c_scaled, g_c_scaled, b_c_scaled },
                                            MathUtils.LINRGB_FROM_SCALED_DISCOUNT
      );

      if (linrgb[0] < 0.0 || linrgb[1] < 0.0 || linrgb[2] < 0.0) {
        return 0;
      }

      double k_r = 0.2126;
      double k_g = 0.7152;
      double k_b = 0.0722;
      double fnj = k_r * linrgb[0] + k_g * linrgb[1] + k_b * linrgb[2];

      if (fnj <= 0.0) {
        return 0;
      }

      if (round == 4 || Math.fabs (fnj - y) < 0.002) {
        if (linrgb[0] > 100.01 || linrgb[1] > 100.01 || linrgb[2] > 100.01) {
          return 0;
        }
        return argb_from_linrgb (linrgb);
      }

      // Iterates with Newton method,
      // Using 2 * fn(j) / j as the approximation of fn'(j)
      // Protect against division by zero
      double denominator = Math.fmax (1e-10, 2.0 * fnj);
      double step = (fnj - y) * j / denominator;
      j = j - step;

      // Clamp j to reasonable bounds to prevent divergence
      j = MathUtils.clamp_double (0.1, 200.0, j);
    }
    return 0;
  }
}