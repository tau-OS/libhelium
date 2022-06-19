/*
 * Copyright (C) 2022 Fyra Labs
 * Copyright (C) 2018 Purism SPC
 *
 * The following code is a derivative work of the code from the libadwaita project, 
 * which is licensed LGPLv2. This code is relicensed to the terms of GPLv3 while keeping
 * the original attribution.
 *
 * Additionally, sourced from:
 *   https://gitlab.gnome.org/GNOME/clutter/-/blob/a236494ea7f31848b4a459dad41330f225137832/clutter/clutter-easing.c
 *   https://gitlab.gnome.org/GNOME/clutter/-/blob/a236494ea7f31848b4a459dad41330f225137832/clutter/clutter-enums.h
 *
 * Copyright (C) 2011  Intel Corporation
 *
 */

/**
 * Useful utilties for doing animations.
 */
namespace He.Animation {
    public delegate double AnimationFunction (double t, double d);

    public double linear (double t, double d) {
        return t / d;
    }

    public double ease_in_quad (double t, double d) {
        double p = t / d;
        return p * p;
    }

    public double ease_out_quad (double t, double d) {
        double p = t / d;

        return -1.0 * p * (p - 2);
    }

    public double ease_in_out_quad (double t, double d) {
        double p = t / (d / 2);

        if (p < 1)
            return 0.5 * p * p;

        p -= 1;

        return -0.5 * (p * (p - 2) - 1);
    }

    public double ease_in_cubic (double t, double d) {
        double p = t / d;

        return p * p * p;
    }

    public double ease_out_cubic (double t, double d) {
        double p = t / d - 1;

        return p * p * p + 1;
    }

    public double ease_in_out_cubic (double t, double d) {
        double p = t / (d / 2);

        if (p < 1)
            return 0.5 * p * p * p;

        p -= 2;

        return 0.5 * (p * p * p + 2);
    }

    public double ease_in_quart (double t, double d) {
        double p = t / d;

        return p * p * p * p;
    }

    public double ease_out_quart (double t, double d) {
        double p = t / d - 1;

        return -1.0 * (p * p * p * p - 1);
    }

    public double ease_in_out_quart (double t, double d) {
        double p = t / (d / 2);

        if (p < 1)
            return 0.5 * p * p * p * p;

        p -= 2;

        return -0.5 * (p * p * p * p - 2);
    }

    public double ease_in_quint (double t, double d) {
        double p = t / d;

        return p * p * p * p * p;
    }

    public double ease_out_quint (double t, double d) {
        double p = t / d - 1;

        return p * p * p * p * p + 1;
    }

    public double ease_in_out_quint (double t, double d) {
        double p = t / (d / 2);

        if (p < 1)
            return 0.5 * p * p * p * p * p;

        p -= 2;

        return 0.5 * (p * p * p * p * p + 2);
    }

    public double ease_in_sine (double t, double d) {
        return -1.0 * Math.cos (t / d * Math.PI_2) + 1.0;
    }

    public double ease_out_sine (double t, double d) {
        return Math.sin (t / d * Math.PI_2);
    }

    public double ease_in_out_sine (double t, double d) {
        return -0.5 * (Math.cos (Math.PI * t / d) - 1);
    }
    
    public double ease_in_expo (double t, double d) {
        return (t == 0) ? 0.0 : Math.pow (2, 10 * (t / d - 1));
    }

    public double ease_out_expo (double t, double d) {
        return (t == d) ? 1.0 : -Math.pow (2, -10 * t / d) + 1;
    }

    public double ease_in_out_expo (double t, double d) {
        double p;

        if (t == 0)
            return 0.0;

        if (t == d)
            return 1.0;

        p = t / (d / 2);

        if (p < 1)
            return 0.5 * Math.pow (2, 10 * (p - 1));

        p -= 1;

        return 0.5 * (-Math.pow (2, -10 * p) + 2);
    }

    public double ease_in_circ (double t, double d) {
        double p = t / d;

        return -1.0 * (Math.sqrt (1 - p * p) - 1);
    }

    public double ease_out_circ (double t, double d) {
        double p = t / d - 1;

        return Math.sqrt (1 - p * p);
    }

    public double ease_in_out_circ (double t, double d) {
        double p = t / (d / 2);

        if (p < 1)
            return -0.5 * (Math.sqrt (1 - p * p) - 1);

        p -= 2;

        return 0.5 * (Math.sqrt (1 - p * p) + 1);
    }

    public double ease_in_elastic (double t, double d) {
        double p = d * 0.3;
        double s = p / 4;
        double q = t / d;

        if (q == 1)
            return 1.0;

        q -= 1;

        return -(Math.pow (2, 10 * q) * Math.sin ((q * d - s) * (2 * Math.PI) / p));
    }

    public double ease_out_elastic (double t, double d) {
        double p = d * 0.3;
        double s = p / 4;
        double q = t / d;

        if (q == 1)
            return 1.0;

        return Math.pow (2, -10 * q) * Math.sin ((q * d - s) * (2 * Math.PI) / p) + 1.0;
    }

    public double ease_in_out_elastic (double t, double d) {
        double p = d * (0.3 * 1.5);
        double s = p / 4;
        double q = t / (d / 2);

        if (q == 2)
            return 1.0;

        if (q < 1) {
            q -= 1;

            return -0.5 * (Math.pow (2, 10 * q) * Math.sin ((q * d - s) * (2 * Math.PI) / p));
        } else {
        q -= 1;

        return Math.pow (2, -10 * q)
            * Math.sin ((q * d - s) * (2 * Math.PI) / p)
            * 0.5 + 1.0;
        }
    }

    public double ease_in_back (double t, double d) {
        double p = t / d;

        return p * p * ((1.70158 + 1) * p - 1.70158);
    }

    public double ease_out_back (double t, double d) {
        double p = t / d - 1;

        return p * p * ((1.70158 + 1) * p + 1.70158) + 1;
    }

    public double ease_in_out_back (double t, double d) {
        double p = t / (d / 2);
        double s = 1.70158 * 1.525;

        if (p < 1)
            return 0.5 * (p * p * ((s + 1) * p - s));

        p -= 2;

        return 0.5 * (p * p * ((s + 1) * p + s) + 2);
    }

    public double ease_out_bounce (double t, double d) {
        double p = t / d;

        if (p < (1 / 2.75)) {
            return 7.5625 * p * p;
        } else if (p < (2 / 2.75)) {
            p -= (1.5 / 2.75);

            return 7.5625 * p * p + 0.75;
        } else if (p < (2.5 / 2.75)) {
            p -= (2.25 / 2.75);

            return 7.5625 * p * p + 0.9375;
        } else {
            p -= (2.625 / 2.75);

            return 7.5625 * p * p + 0.984375;
        }
    }

    public double ease_in_bounce (double t, double d) {
        return 1.0 - ease_out_bounce (d - t, d);
    }

    public double ease_in_out_bounce (double t, double d) {
        if (t < d / 2)
            return ease_in_bounce (t * 2, d) * 0.5;
        else
            return ease_out_bounce (t * 2 - d, d) * 0.5 + 1.0 * 0.5;
    }
}