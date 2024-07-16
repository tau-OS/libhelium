namespace He {
    public enum Easing {
        LINEAR,
        EASE_OUT_CUBIC,
        EASE_IN_OUT_BOUNCE
    }

    public class TimedAnimation : Animation {
        private double _value_from;
        private double _value_to;
        private uint _duration; // ms
        private uint _repeat_count;
        private bool _reverse;
        private bool _alternate;
        private He.Easing _easing;

        // Properties
        public double value_from {
            get { return _value_from; }
            set {
                if (_value_from != value) {
                    _value_from = value;
                    notify_property("value-from");
                }
            }
        }

        public double value_to {
            get { return _value_to; }
            set {
                if (_value_to != value) {
                    _value_to = value;
                    notify_property("value-to");
                }
            }
        }

        public uint duration {
            get { return _duration; }
            set {
                if (_duration != value) {
                    _duration = value;
                    notify_property("duration");
                }
            }
        }

        public He.Easing easing {
            get { return _easing; }
            set {
                if (_easing != value) {
                    _easing = value;
                    notify_property("easing");
                }
            }
        }

        public uint repeat_count {
            get { return _repeat_count; }
            set {
                if (_repeat_count != value) {
                    _repeat_count = value;
                    notify_property("repeat-count");
                }
            }
        }

        public bool reverse {
            get { return _reverse; }
            set {
                if (_reverse != value) {
                    _reverse = value;
                    notify_property("reverse");
                }
            }
        }

        public bool alternate {
            get { return _alternate; }
            set {
                if (_alternate != value) {
                    _alternate = value;
                    notify_property("alternate");
                }
            }
        }

        // Constructor
        public TimedAnimation (Gtk.Widget widget, double from, double to, uint duration, AnimationTarget target) {
            Object(widget: widget, value_from: from, value_to: to, duration: duration, target: target);
            this._repeat_count = 1;
            this._easing = He.Easing.EASE_OUT_CUBIC;
        }

        // Estimate Duration Method
        public override uint estimate_duration() {
            if (repeat_count == 0) return (uint)0xffffffff;
            return duration * repeat_count;
        }

        // Calculate Value Method
        public override double calculate_value(uint t) {
            if (duration == 0) return value_to;

            double iteration;
            double progress = Math.modf((double)t / duration, out iteration);
            bool reverse_iteration = false;

            if (alternate) reverse_iteration = ((int)iteration % 2) == 1;
            if (reverse) reverse_iteration = !reverse_iteration;

            if (t >= estimate_duration()) 
                return alternate == reverse_iteration ? value_to : value_from;

            progress = reverse_iteration ? (1 - progress) : progress;
            double eased_value = easing_ease(easing, progress);

            return lerp(value_from, value_to, eased_value);
        }

        // Helper Functions
        private double easing_ease(He.Easing easing, double progress) {
            // Implement the easing function logic
            // This is a placeholder. Replace with actual easing function logic.
            switch (easing) {
                case He.Easing.LINEAR:
                    return progress;
                case He.Easing.EASE_OUT_CUBIC:
                    return 1 - Math.pow(1 - progress, 3);
                case He.Easing.EASE_IN_OUT_BOUNCE:
                    // Placeholder for bounce easing function
                    return progress < 0.5 ? (1 - Math.pow(1 - (progress * 2), 3)) / 2 : (Math.pow((progress * 2) - 1, 3) + 1) / 2;
                default:
                    return progress;
            }
        }

        private double lerp(double start, double end, double progress) {
            return start + (end - start) * progress;
        }
    }
}