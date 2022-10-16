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
 * Useful utilities for doing animations.
 *
 * @since 1.0
 */

public abstract class He.AnimationTarget : Object {
    public double value { get; set; }

    AnimationTarget () {
    }
}

public class He.CallbackAnimationTarget : He.AnimationTarget {
    public delegate void AnimationTargetFunc (double value);

    public CallbackAnimationTarget (owned AnimationTargetFunc callback) { base (); }
}

public class He.TimedAnimation : He.Animation {
    public TimedAnimation (Gtk.Widget? widget, double from, double to, uint duration, He.AnimationTarget target) {
        base (widget, to, from, duration, target);
    }

    public double calculate_value (He.Animation animation, uint t) {
        double iteration, progress;
        bool reverse = false;

        if (duration == 0)
            return to;

        progress = GLib.Math.modf (((double) t / duration), out iteration);

        if (alternate)
            reverse = ((int) iteration % 2) != 0 ? true : false;

        if (reverse)
            reverse = !reverse;

        if (t >= estimate_duration (animation))
            return alternate == reverse ? to : from;

        progress = reverse ? (1 - progress) : progress;

        value = animation.ease_out_cubic (value, progress);

        return animation.lerp (from, to, value);
    }

    public new uint estimate_duration (He.Animation animation) {
        if (repeat_count == 0)
            return (uint) 0xffffffff;

        return duration * repeat_count;
    }
}

public enum He.AnimationState {
  HE_ANIMATION_IDLE,
  HE_ANIMATION_PAUSED,
  HE_ANIMATION_PLAYING,
  HE_ANIMATION_FINISHED,
}

public class He.Animation : Object {
    public double from { get; set; }
    public double to { get; set; }
    public uint duration { get; set; } /* ms */
    public uint repeat_count { get; set; }
    public bool reverse { get; set; }
    public bool alternate { get; set; }
    public new double value { get; set; }
    public Gtk.Widget widget { get; set; }
    public He.AnimationTarget target { get; set; }
    public He.AnimationState state { get; set; }

    int64 start_time; /* ms */
    int64 paused_time;
    uint  tick_cb_id;

    public Animation (Gtk.Widget? widget, double from, double to, uint duration, He.AnimationTarget target) {
        this.from = from;
        this.to = to;
        this.duration = duration;
        this.widget = widget;
        this.target = target;
    }

    public delegate double AnimationFunction (double t, double d);

    public uint estimate_duration (He.Animation animation) {
        if (repeat_count == 0)
            return (uint) 0xffffffff;

        return duration * repeat_count;
    }

    public void play () {
        if (this.state == He.AnimationState.HE_ANIMATION_PLAYING) {
            critical ("Trying to play animation %p, but it's already playing", this);
            return;
        }

        this.state = He.AnimationState.HE_ANIMATION_PLAYING;

        if (!this.widget.get_mapped ()) {
            skip ();
            return;
        }

        this.start_time += this.widget.get_frame_clock ().get_frame_time () / 1000;
        this.start_time -= this.paused_time;

        if (this.tick_cb_id != 0)
            return;

        this.tick_cb_id  = this.widget.add_tick_callback     (tick_cb);

    }

    public bool tick_cb (Gtk.Widget widget, Gdk.FrameClock frame_clock) {
        int64 frame_time = frame_clock.get_frame_time () / 1000; /* ms */
        uint duration = estimate_duration (this);
        uint t = (uint) (frame_time - start_time);

        if (t >= duration && duration != (uint) 0xffffffff) {
            skip ();

            return GLib.Source.REMOVE;
        }

        value = t;

        return GLib.Source.CONTINUE;
    }


    public void skip () {
        bool was_playing;

        if (this.state == HE_ANIMATION_FINISHED)
            return;

        was_playing = this.state == HE_ANIMATION_PLAYING;

        this.state = HE_ANIMATION_FINISHED;

        stop_animation ();

        value = estimate_duration (this);

        this.start_time = 0;
        this.paused_time = 0;
    }

    public void stop_animation () {
      if (this.tick_cb_id != 0) {
        this.widget.remove_tick_callback (this.tick_cb_id);
        this.tick_cb_id = 0;
      }
    }

    public double lerp (double a, double b, double t) {
      return a * (1.0 - t) + b * t;
    }

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
