// Copyright (C) 2023 Fyra Labs

using Gtk;
using Math;

namespace He {
    public class SpringParams : Object {
        public double damping { get; set; }
        public double damping_ratio { get; set; }
        public double mass { get; set; }
        public double stiffness { get; set; }

        public SpringParams(double damping_ratio, double mass, double stiffness) {
            double critical_damping, damping;
            critical_damping = 2 * sqrt(mass * stiffness);
            damping = damping_ratio * critical_damping;

            this.damping = damping;
            this.mass = mass;
            this.stiffness = stiffness;
        }

        public SpringParams.full(double damping, double mass, double stiffness) {
            this.damping = damping;
            this.mass = mass;
            this.stiffness = stiffness;
        }
    }

    public class SpringAnimation : Animation {
        public double epsilon { get; set; }
        public uint estimated_duration { get; set; }
        public double initial_velocity { get; set; }
        public bool latch { get; set; }
        public SpringParams spring_params { get; set construct; }
        public double value_from { get; set construct; }
        public double value_to { get; set construct; }
        public double velocity { get; set; }

        private const double EPSILON = 0.001;
        private const double MS_TO_S = 0.001; // Milliseconds to seconds

        public SpringAnimation(Widget widget, double from, double to, owned SpringParams sparams, owned AnimationTarget target) {
            this.epsilon = EPSILON;

            base.widget = widget;
            base.target = target;

            if (sparams != null) {
                this.spring_params = sparams;
                estimates_duration();
            }
        }

        public override uint estimate_duration() {
            return estimated_duration;
        }

        private void estimates_duration() {
            /* This function can be called during construction */
            if (spring_params == null)
                return;

            estimated_duration = (uint) calculate_duration();
        }

        public override double calculate_value(uint t) {
            double value;

            if (t >= estimated_duration) {
                velocity = 0;
                return value_to;
            }

            value = oscillate(t, velocity);
            return value;
        }

        private uint calculate_duration() {
            double damping = spring_params.damping;
            double mass = spring_params.mass;
            double stiffness = spring_params.stiffness;
            double beta = damping / (2 * mass);
            double omega0;
            double x0, y0;
            double x1, y1;
            double m;

            int i = 0;

            if (beta <= 0)
                return (uint) 0xffffffff;

            if (latch) {
                return get_first_zero();
            }

            omega0 = sqrt(stiffness / mass);

            /*
             * As the first ansatz for the overdamped solution,
             * and general estimation for the oscillating ones,
             * we take the value of the envelope when it's < epsilon.
             */
            x0 = -Math.log(epsilon) / beta;

            if (beta <= omega0)
                return (uint) (x0 * 1000);

            /*
             * Since the overdamped solution decays way slower than the envelope,
             * we need to use the value of the oscillation itself.
             * Newton's root-finding method is a good candidate in this particular case.
             * Reference: https://en.wikipedia.org/wiki/Newton%27s_method
             */
            y0 = oscillate(x0 * 1000, null);
            m = (oscillate((x0 + 0.001) * 1000, null) - y0) / 0.001;

            x1 = (value_to - y0 + m * x0) / m;
            y1 = oscillate(x1 * 1000, null);

            while (fabs(value_to - y1) > epsilon) {
                if (i > 1000)
                    return 0;
                x0 = x1;
                y0 = y1;

                m = (oscillate((x0 + 0.001) * 1000, null) - y0) / 0.001;

                x1 = (value_to - y0 + m * x0) / m;
                y1 = oscillate(x1 * 1000, null);
                i++;
            }

            return (uint) (x1 * 1000);
        }

        private double oscillate(double time, double? velocity) {
            double b = spring_params.damping;
            double m = spring_params.mass;
            double k = spring_params.stiffness;
            double v0 = initial_velocity;

            double t = time * MS_TO_S; // Convert milliseconds to seconds

            double beta = b / (2 * m);
            double omega0 = sqrt(k / m);

            double x0 = value_from - value_to;

            double envelope = exp(-beta * t);

            /*
             * Solutions of the form C1*e^(lambda1*x) + C2*e^(lambda2*x)
             * for the differential equation m*ẍ+b*ẋ+kx = 0
             */

            /* Underdamped */
            if (beta < omega0) {
                double omega1 = sqrt((omega0 * omega0) - (beta * beta));

                if (velocity != null)
                    velocity = envelope * (v0 * cos(omega1 * t) - (x0 * omega1 + (beta * beta * x0 + beta * v0)
                                                                   / (omega1)) * sin(omega1 * t));
                return value_to + envelope * (x0 * cos(omega1 * t) + ((beta * x0 + v0) / omega1) * sin(omega1 * t));
            }

            /* Overdamped */
            if (beta > omega0) {
                double omega2 = sqrt((beta * beta) - (omega0 * omega0));

                if (velocity != null)
                    velocity = envelope * (v0 * cosh(omega2 * t) + (omega2 * x0 - (beta * beta * x0 + beta * v0)
                                                                    / omega2) * sinh(omega2 * t));
                return value_to + envelope * (x0 * cosh(omega2 * t) + ((beta * x0 + v0) / omega2) * sinh(omega2 * t));
            }

            /* Critically damped */
            if (velocity != null)
                velocity = envelope * (beta * x0 + v0) * (1 - beta);
            return value_to + envelope * (x0 + (beta * x0 + v0) * t);
        }

        private uint get_first_zero() {
            /* The first frame is not that important, and we avoid finding the trivial 0
             * for in-place animations. */
            uint i = 1;
            double y = oscillate(i, velocity);

            while ((value_to - value_from > float.EPSILON && value_to - y > epsilon) ||
                   (value_from - value_to > float.EPSILON && y - value_to > epsilon)) {
                if (i > 200000)
                    return 0;

                y = oscillate(++i, velocity);
            }

            return i;
        }
    }
}