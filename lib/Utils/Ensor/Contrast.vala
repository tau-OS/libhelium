public class He.Contrast {
    // Constants
    public const double RATIO_MIN = 1.0;
    public const double RATIO_MAX = 21.0;
    public const double RATIO_30 = 3.0;
    public const double RATIO_45 = 4.5;
    public const double RATIO_70 = 7.0;

    private const double CONTRAST_RATIO_EPSILON = 0.04;
    private const double LUMINANCE_GAMUT_MAP_TOLERANCE = 0.4;

    // Prevent instantiation
    private Contrast() {}

    /**
     * Contrast ratio is a measure of legibility, used to compare the lightness of two colors.
     */
    public static double ratio_of_ys(double y1, double y2) {
        double lighter = Math.fmax(y1, y2);
        double darker = (lighter == y2) ? y1 : y2;
        // Ensure denominator is never zero
        return (lighter + 5.0) / Math.fmax(1e-10, darker + 5.0);
    }

    /**
     * Contrast ratio of two tones (T in HCT, L* in L*a*b*).
     */
    public static double ratio_of_tones(double t1, double t2) {
        return ratio_of_ys(MathUtils.y_from_lstar(t1), MathUtils.y_from_lstar(t2));
    }

    /**
     * Returns tone >= tone parameter that ensures the ratio with the input tone.
     */
    public static double lighter(double tone, double ratio) {
        if (tone < 0.0 || tone > 100.0) {
            return -1.0;
        }

        double dark_y = MathUtils.y_from_lstar(tone);
        double light_y = ratio * (dark_y + 5.0) - 5.0;

        if (light_y < 0.0 || light_y > 100.0) {
            return -1.0;
        }

        double real_contrast = ratio_of_ys(light_y, dark_y);
        double delta = Math.fabs(real_contrast - ratio);

        if (real_contrast < ratio && delta > CONTRAST_RATIO_EPSILON) {
            return -1.0;
        }

        double return_value = MathUtils.lstar_from_y(light_y) + LUMINANCE_GAMUT_MAP_TOLERANCE;

        if (return_value < 0 || return_value > 100) {
            return -1.0;
        }

        return return_value;
    }

    /**
     * Tone >= tone parameter that ensures ratio. Returns 100 if ratio cannot be achieved.
     */
    public static double lighter_unsafe(double tone, double ratio) {
        double lighter_safe = lighter(tone, ratio);
        return lighter_safe < 0.0 ? 100.0 : lighter_safe;
    }

    /**
     * Returns tone <= tone parameter that ensures the ratio with the input tone.
     */
    public static double darker(double tone, double ratio) {
        if (tone < 0.0 || tone > 100.0) {
            return -1.0;
        }

        double light_y = MathUtils.y_from_lstar(tone);
        // Protect against division by zero
        double safe_ratio = Math.fmax(1e-10, ratio);
        double dark_y = ((light_y + 5.0) / safe_ratio) - 5.0;

        if (dark_y < 0.0 || dark_y > 100.0) {
            return -1.0;
        }

        double real_contrast = ratio_of_ys(light_y, dark_y);
        double delta = Math.fabs(real_contrast - ratio);

        if (real_contrast < ratio && delta > CONTRAST_RATIO_EPSILON) {
            return -1.0;
        }

        double return_value = MathUtils.lstar_from_y(dark_y) - LUMINANCE_GAMUT_MAP_TOLERANCE;

        if (return_value < 0 || return_value > 100) {
            return -1.0;
        }

        return return_value;
    }

    /**
     * Tone <= tone parameter that ensures ratio. Returns 0 if ratio cannot be achieved.
     */
    public static double darker_unsafe(double tone, double ratio) {
        double darker_safe = darker(tone, ratio);
        return Math.fmax(0.0, darker_safe);
    }
}