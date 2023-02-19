/*
* Copyright (c) 2022 Fyra Labs
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/
public abstract class He.Animation : Object {
    Gtk.Widget? widget = null;

    double value {get; set;}
    double value_from {get; set;}
    double value_to {get; set;}

    int64 duration {get; set;}
    int64 start_time {get; set;}

    uint tick_cb_id {get; set;}

    AnimationEasingFunc easing_func;
    AnimationValueCallback value_cb;
    AnimationDoneCallback done_cb;
    public delegate void AnimationValueCallback (double value);
    public delegate void AnimationDoneCallback ();
    public delegate double AnimationEasingFunc (double t);

    Animation (Gtk.Widget? widget,
                      double to,
                      double from,
                      int duration,
                      AnimationEasingFunc easing,
                      AnimationValueCallback value_cb,
                      AnimationDoneCallback done_cb
    ) {
        this.widget = widget;
        this.value = from;
        this.value_from = from;
        this.value_to = to;
        this.duration = duration;
        this.easing_func = easing;
        this.value_cb = value_cb;
        this.done_cb = done_cb;
    }

    ~Animation () {
        stop ();
        this.dispose ();
    }

    public bool tick_cb (Gtk.Widget widget, Gdk.FrameClock frame_clock) {
        int64 frame_time = frame_clock.get_frame_time () / 1000;
        double t = (double) (frame_time - start_time) / duration;

        if (t >= 1) {
            tick_cb_id = 0;
            value = value_to;
            done_cb ();

            return GLib.Source.REMOVE;
        }

        value = MathUtils.lerp (value_from, value_to, easing_func (t));

        return GLib.Source.CONTINUE;
    }


    public void start () {
        if (!get_enable_animations (widget) ||
            !widget.get_mapped () ||
            this.duration <= 0)
        {
            value = value_to;
            done_cb ();
        }

        this.start_time = widget.get_frame_clock ().get_frame_time () / 1000;

        GLib.Signal.connect_swapped (this, "unmap", (Callback)stop, this);
        this.tick_cb_id = widget.add_tick_callback ((Gtk.TickCallback) tick_cb);
    }

    public void stop () {
        widget.remove_tick_callback (tick_cb_id);
        tick_cb_id = 0;
        done_cb ();
    }

    public bool get_enable_animations (Gtk.Widget widget) {
        bool enable_animations = true;

        widget.get_settings ().get ("gtk-enable-animations", out enable_animations, null);

        return enable_animations;
    }

    public double ease_out_cubic (double t) {
        double p = t - 1;
        return p * p * p + 1;
    }
}