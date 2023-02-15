namespace He.MathUtils {
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

    public static double clamp_double (double min, double max, double input) {
        if (input < min) {
          return min;
        } else if (input > max) {
          return max;
        }
    
        return input;
    }

    public int signum (double x) {
        return (int)(x > 0) - (int)(x < 0);
    }
    
    public double chromatic_adaptation (double component) {
        double af = Math.pow (Math.fabs (component), 0.42);
        return signum (component) * 400.0 * af / (af + 27.13);
    }

    public double inverse_chromatic_adaptation (double adapted) {
        double adaptedAbs = Math.fabs (adapted);
        double b = Math.fmax (0, 27.13 * adaptedAbs / (400.0 - adaptedAbs));
        return signum(adapted) * Math.pow (b, 1.0 / 0.42);
    }
    
    public double[] lerp_point (double[] source, double t, double[] target) {
        return new double[] {
            source[0] + (target[0] - source[0]) * t,
            source[1] + (target[1] - source[1]) * t,
            source[2] + (target[2] - source[2]) * t,
        };
    }

    public double sanitize_radians (double angle) {
        return (angle + Math.PI * 8) % (Math.PI * 2);
    }

    public bool is_bounded_rgb (double x) {
        return 0.0 <= x && x <= 100.0;
    }

    public double adapt (double color_channel) {
        if (color_channel > 0.0031308) {
            return (1.055 * Math.pow (color_channel, (1.0 / 2.4))) - 0.055;
        } else {
            return color_channel * 12.92;
        }
    }

    public double[] elem_mul (double[] row, double[,] matrix) {
        double[] prod = {
            row[0] * matrix[0,0] + row[1] * matrix[0,1] + row[2] * matrix[0,2],
            row[0] * matrix[1,0] + row[1] * matrix[1,1] + row[2] * matrix[1,2],
            row[0] * matrix[2,0] + row[1] * matrix[2,1] + row[2] * matrix[2,2]
        };
        return prod;
    }

    public double lab_inverse_fovea (double ft) {
        double e = 216.0 / 24389.0;
        double kappa = 24389.0 / 27.0;
        double ft3 = ft * ft * ft;
        if (ft3 > e) {
            return ft3;
        } else {
            return (116 * ft - 16) / kappa;
        }
    }

    public double lab_fovea (double t) {
        double e = 216.0 / 24389.0;
        double kappa = 24389.0 / 27.0;
        if (t > e) {
            return Math.pow (t, 1.0 / 3.0);
        } else {
            return (kappa * t + 16) / 116;
        }
    }

    public double sanitize_degrees (double degrees) {
        degrees = degrees % 360.0;
        if (degrees < 0) {
            degrees = degrees + 360.0;
        }
        return degrees;
    }

    public int sanitize_degrees_int (int degrees) {
        degrees = degrees % 360;
        if (degrees < 0) {
            degrees = degrees + 360;
        }
        return degrees;
    }

    public double rotate_direction (double from, double to) {
        var inc_diff = sanitize_degrees (to - from);
        return inc_diff <= 180.0 ? 1.0 : -1.0;
    }

    public double difference_degrees (double a, double b) {
        return 180.0 - Math.fabs (Math.fabs (a - b) - 180.0);
    }

    public double linearized (int rgb_component) {
        double normalized = rgb_component / 255.0;
        if (normalized <= 0.040449936) {
          return normalized / 12.92 * 100.0;
        } else {
          return Math.pow((normalized + 0.055) / 1.055, 2.4) * 100.0;
        }
    }

    public int delinearized (double rgb_component) {
        double normalized = rgb_component / 100.0;
        double delinearized = 0.0;
        if (normalized <= 0.0031308) {
            delinearized = normalized * 12.92;
        } else {
            delinearized = 1.055 * Math.pow (normalized, 1.0 / 2.4) - 0.055;
        }
        return (int) Math.round (delinearized * 255.0).clamp (0, 255);
    }

    public double double_delinearized (double rgb_component) {
        double normalized = rgb_component / 100.0;
        double delinearized = 0.0;
        if (normalized <= 0.0031308) {
            delinearized = normalized * 12.92;
        } else {
            delinearized = 1.055 * Math.pow (normalized, 1.0 / 2.4) - 0.055;
        }
        return delinearized * 255.0;
    }

    public double[] midpoint (double[] a, double[] b) {
        return new double[] {
            (a[0] + b[0]) / 2, (a[1] + b[1]) / 2, (a[2] + b[2]) / 2,
        };
    }

    public double intercept (double source, double mid, double target) {
        return (mid - source) / (target - source);
    }

    public double hue_of (double[] linrgb) {
        double[] scaled_discount = elem_mul (linrgb, SCALED_DISCOUNT_FROM_LINRGB);
        double r_a = chromatic_adaptation (scaled_discount[0]);
        double g_a = chromatic_adaptation (scaled_discount[1]);
        double b_a = chromatic_adaptation (scaled_discount[2]);
        // redness-greenness
        double a = (11.0 * r_a + -12.0 * g_a + b_a) / 11.0;
        // yellowness-blueness
        double b = (r_a + g_a - 2.0 * b_a) / 9.0;
        return Math.atan2 (b, a);
    }

    public double[] nth_vertex (double y, int n) {
        double k_r = 0.2126;
        double k_g = 0.7152;
        double k_b = 0.0722;
        double coord_a = n % 4 <= 1 ? 0.0 : 100.0;
        double coord_b = n % 2 == 0 ? 0.0 : 100.0;
        if (n < 4) {
            double g = coord_a;
            double b = coord_b;
            double r = (y - g * k_g - b * k_b) / k_r;
            if (is_bounded_rgb (r)) {
                return new double[] {r, g, b};
            } else {
                return new double[] {-1.0, -1.0, -1.0};
            }
        } else if (n < 8) {
            double b = coord_a;
            double r = coord_b;
            double g = (y - r * k_r - b * k_b) / k_g;
            if (is_bounded_rgb (g)) {
                return new double[] {r, g, b};
            } else {
                return new double[] {-1.0, -1.0, -1.0};
            }
        } else {
            double r = coord_a;
            double g = coord_b;
            double b = (y - r * k_r - g * k_g) / k_b;
            if (is_bounded_rgb (b)) {
                return new double[] {r, g, b};
            } else {
                return new double[] {-1.0, -1.0, -1.0};
            }
        }
    }

    public bool are_in_cyclic_order (double a, double b, double c) {
        double delta_ab = sanitize_radians (b - a);
        double delta_ac = sanitize_radians (c - a);
        return delta_ab < delta_ac;
    }

    public double[] set_coordinate (double[] source, double coordinate, double[] target, int axis) {
        double t = intercept (source[axis], coordinate, target[axis]);
        return lerp_point (source, t, target);
    }

    public double convert (double value) {
        var epsilon = 6.0 / 29.0;
        var kappa = 108.0 / 841.0;
        var delta = 4.0 / 29.0;
        return value > epsilon ? Math.pow (value, 3) : (value - delta) * kappa;
    }

    public double[] bisect_to_segment (double y, double target_hue) {
        double[] left = {-1.0, -1.0, -1.0};
        double[] right = left;
        double left_hue = 0.0;
        double right_hue = 0.0;
        bool initialized = false;
        bool uncut = true;
        for (int n = 0; n < 12; n++) {
            double[] mid = nth_vertex(y, n);
            if (mid[0] < 0) {
                continue;
            }
            double mid_hue = hue_of (mid);
            if (!initialized) {
                left = mid;
                right = mid;
                left_hue = mid_hue;
                right_hue = mid_hue;
                initialized = true;
                continue;
            }
            if (uncut || are_in_cyclic_order (left_hue, mid_hue, right_hue)) {
                uncut = false;
                if (are_in_cyclic_order (left_hue, target_hue, mid_hue)) {
                    right = mid;
                    right_hue = mid_hue;
                } else {
                    left = mid;
                    left_hue = mid_hue;
                }
            }
        }
        return new double[] {left[0], left[1], left[2], right[0], right[1], right[2]};
    }

    public double[] bisect_to_limit (double y, double target_hue) {
        double[] segment = bisect_to_segment (y, target_hue);
        double[] left = {segment[0], segment[1], segment[2]};
        double left_hue = hue_of (left);
        double[] right = {segment[3], segment[4], segment[5]};;
        for (int axis = 0; axis < 3; axis++) {
            if (left[axis] != right[axis]) {
                int l_plane = -1;
                int r_plane = 255;
                if (left[axis] < right[axis]) {
                    l_plane = He.Color.critical_plane_below (double_delinearized (left[axis]));
                    r_plane = He.Color.critical_plane_above (double_delinearized (right[axis]));
                } else {
                    l_plane = He.Color.critical_plane_above (double_delinearized (left[axis]));
                    r_plane = He.Color.critical_plane_below (double_delinearized (right[axis]));
                }
                for (int i = 0; i < 8; i++) {
                    if (Math.fabs (r_plane - l_plane) <= 1) {
                        break;
                    } else {
                        int m_plane = (int) Math.floor ((l_plane + r_plane) / 2.0);
                        double mid_plane_coord = He.Color.CRITICAL_PLANES[m_plane];
                        double[] mid = set_coordinate (left, mid_plane_coord, right, axis);
                        double mid_hue = hue_of (mid);
                        if (are_in_cyclic_order (left_hue, target_hue, mid_hue)) {
                            right = mid;
                            r_plane = m_plane;
                        } else {
                            left = mid;
                            left_hue = mid_hue;
                            l_plane = m_plane;
                        }
                    }
                }
            }
        }
        return midpoint (left, right);
    }

    public static double y_from_lstar (double lstar) {
        return 100.0 * lab_inverse_fovea ((lstar + 16.0) / 116.0);
    }

    public static int argb_from_lstar (double lstar) {
        double y = y_from_lstar (lstar);
        int component = delinearized (y);
        return He.Color.argb_from_rgb_int (component, component, component);
    }

    public static double lstar_from_argb(int argb) {
        double y = He.Color.xyz_to_argb (argb)[1];
        return 116.0 * lab_fovea (y / 100.0) - 16.0;
    }
}