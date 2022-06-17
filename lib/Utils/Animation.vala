/**
 * Useful methods for doing animations.
 */
public class He.Animation {
    public enum AnimationType {
        HE_ANIMATION_LINEAR,
        HE_ANIMATION_EASE_IN_CUBIC,
    }

    private double linear (double v) {
        return v;
    }

    private double ease_in_cubic (double t, double d) {
        double p = t / d;

        return p * p * p;
    }

    public double animation (AnimationType type, double value, double? value2) {
        switch (type) {
            case HE_ANIMATION_LINEAR:
                return linear(value);
            case HE_ANIMATION_EASE_IN_CUBIC:
                return ease_in_cubic (value, value2);
            default:
                return value;
        }
    }
}