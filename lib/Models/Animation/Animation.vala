// Copyright (C) 2023 Fyra Labs

using Gtk;

namespace He {
    public enum AnimationState {
        IDLE,
        PAUSED,
        PLAYING,
        FINISHED
    }

    public abstract class AnimationTarget : Object {
        protected AnimationTarget () {}

        public abstract void set_value (double value);
    }

    public delegate void AnimationTargetFunc (double value);

    public sealed class CallbackAnimationTarget : AnimationTarget {
        unowned AnimationTargetFunc callback;

        public CallbackAnimationTarget (owned AnimationTargetFunc callback) {
            this.callback = callback;
        }

        public override void set_value (double value) {
            callback (value);
        }
    }

    public sealed class PropertyAnimationTarget : AnimationTarget {
        public Object? object { get; set; default = null; }
        public ParamSpec? pspec { get; set; default = null; }

        public PropertyAnimationTarget () {
        }

        public void animate_property (double value) {
            if (object != null && pspec != null) {
                object.set_property (pspec.name, value);
            }
        }

        public override void set_value (double value) {
            if (object != null && pspec != null) {
                object.set_property (pspec.name, value);
            }
        }
    }

    public abstract class Animation : Object {
        public AnimationState state { get; set; }
        public AnimationTarget target { get; set; }
        public Widget widget { get; set; }

        private double _avalue;
        public double avalue {
            get {
                return _avalue;
            }
            set {
                _avalue = calculate_value ((uint) value);
                target.set_value (_avalue);
            }
        }

        private double start_time;
        private double paused_time;
        private ulong unmap_cb_id;
        private uint tick_cb_id;

        protected Animation () {
            state = AnimationState.IDLE;
            avalue = 0;
        }

        public void pause () {
            if (state != AnimationState.PLAYING) {
                return;
            }

            state = AnimationState.PAUSED;
            stop_animation ();
            paused_time = this.widget.get_frame_clock ().get_frame_time () / 1000;
        }

        public void play () {
            if (state != AnimationState.IDLE) {
                state = AnimationState.IDLE;
                start_time = 0;
                paused_time = 0;
            }

            priv_play ();
        }

        private void priv_play () {
            if (state == AnimationState.PLAYING) {
                critical ("Trying to play animation, but it's already playing");
                return;
            }

            state = AnimationState.PLAYING;

            if (!this.widget.get_mapped ()) {
                skip ();
                return;
            }

            start_time += this.widget.get_frame_clock ().get_frame_time () / 1000;
            start_time -= paused_time;

            if (tick_cb_id != 0) {
                return;
            }

            unmap_cb_id = this.widget.unmap.connect ((widget) => {
                skip ();
            });

            tick_cb_id = this.widget.add_tick_callback ((widget, frame_clock) => {
                var frame_time = frame_clock.get_frame_time () / 1000; // ms
                var duration = estimate_duration ();
                var t = (uint) (frame_time - start_time);

                if (t >= duration && duration != 0xffffffff) {
                    skip ();
                    return Source.REMOVE;
                }

                this.avalue = t;
                return Source.CONTINUE;
            });

            ref ();
        }

        public void reset () {
            if (state == AnimationState.IDLE) {
                return;
            }

            bool was_playing = state == AnimationState.PLAYING;
            state = AnimationState.IDLE;
            stop_animation ();
            avalue = 0;
            start_time = 0;
            paused_time = 0;

            if (was_playing) {
                unref ();
            }
        }

        public void resume () {
            if (state != AnimationState.PAUSED) {
                critical ("Trying to resume animation, but it's not paused");
                return;
            }

            priv_play ();
        }

        public void skip () {
            if (state == AnimationState.FINISHED) {
                return;
            }

            bool was_playing = state == AnimationState.PLAYING;
            state = AnimationState.FINISHED;
            stop_animation ();
            avalue = estimate_duration ();
            start_time = 0;
            paused_time = 0;
            done ();

            if (was_playing) {
                unref ();
            }
        }

        private void stop_animation () {
            if (tick_cb_id != 0) {
                this.widget.remove_tick_callback (tick_cb_id);
                tick_cb_id = 0;
            }

            if (unmap_cb_id != 0) {
                this.widget.disconnect (unmap_cb_id);
                unmap_cb_id = 0;
            }
        }

        public signal void done ();
        public abstract uint estimate_duration ();
        public abstract double calculate_value (uint t);
    }
}