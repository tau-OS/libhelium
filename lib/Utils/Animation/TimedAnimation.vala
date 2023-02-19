public class He.TimedAnimation : He.Animation {
    Gtk.Widget? widget = null;
    double value {get; set;}
    double value_from {get; set;}
    double value_to {get; set;}
    int64 duration {get; set;}

    public TimedAnimation (
        Gtk.Widget? widget,
        double to,
        double from,
        int duration
    ) {
        base (
            widget,
            to,
            from,
            duration,
            ease_out_cubic,
            (AnimationValueCallback) timed_animation_value_cb,
            (AnimationDoneCallback) timed_animation_done_cb
        );

        this.widget = widget;
        this.value = from;
        this.value_from = from;
        this.value_to = to;
        this.duration = duration;
    }

    private void timed_animation_value_cb (double value) {
        this.value = value;
        widget.queue_resize ();
    }

    private void timed_animation_done_cb () {
        this.dispose ();
    }
}