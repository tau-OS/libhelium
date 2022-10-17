/*
 * Copyright (C) 2022 Fyra Labs
 * Copyright (C) 2018 Purism SPC
 *
 * The following code is a derivative work of the code from the libadwaita project, 
 * which is licensed LGPLv2. This code is relicensed to the terms of GPLv3 while keeping
 * the original attribution.
 *
 */
class He.LatchLayout : Gtk.LayoutManager, Gtk.Orientable {
    private int _tightening_threshold;
    public int tightening_threshold { 
        get {
            return _tightening_threshold;
        }
        set {
            _tightening_threshold = value;
            this.layout_changed ();
        }
    }

    private int _maximum_size;
    public int maximum_size { 
        get {
            return _maximum_size;
        }
        set {
            _maximum_size = value;
            this.layout_changed ();
        }
    }

    public He.Animation anime;

    construct {
        this.tightening_threshold = 400;
        this.maximum_size = 600;
    }

    private Gtk.Orientation _orientation;
    public Gtk.Orientation orientation {
        get { return _orientation; }
        set {
            if (_orientation != value) {
                _orientation = value;
                set_orientation (_orientation);
            }
        }
    }

    private double lerp (double a, double b, double t) {
        return a + (b - a) * t;
    }

    private double inverse_lerp (double a, double b, double t) {
        return (t - a) / (b - a);
    }

    private int latch_size_from_child (int min, int nat) {
        int max = 0, lower = 0, upper = 0;
        double progress;

        lower = int.max (int.min (tightening_threshold, maximum_size), min);
        max = int.max (lower, maximum_size);
        upper = lower + 3 * (max - lower);

        if (nat <= lower)
            progress = 0;
        else if (nat >= max)
            progress = 1;
        else {
            double ease = inverse_lerp (lower, max, nat);

            progress = 1 + Math.cbrt (ease - 1);
        }

        return (int) Math.ceil (lerp (lower, upper, progress));
    }

    private int child_size_from_latch (Gtk.Widget child, int for_size, int maximum_size, int lower_threshold) {
        int min = 0, nat = 0, max = 0, lower = 0, upper = 0;
        double progress;

        child.measure (orientation, -1, out min, out nat, null, null);

        lower = int.max (int.min (tightening_threshold, maximum_size), min);
        max = int.max (lower, maximum_size);
        upper = lower + 3 * (max - lower);

        if (maximum_size != 0)
            maximum_size = max;
        if (lower_threshold != 0)
            lower_threshold = lower;

        if (for_size < 0)
            return int.min (nat, max);

        if (for_size <= lower)
            return for_size;

        if (for_size >= upper)
            return max;
        
        progress = inverse_lerp (lower, upper, for_size);
        return (int) lerp (lower, max, anime.ease_in_cubic (3, progress));
    }

    public override Gtk.SizeRequestMode get_request_mode (Gtk.Widget widget) {
        return orientation == Gtk.Orientation.HORIZONTAL ? Gtk.SizeRequestMode.HEIGHT_FOR_WIDTH : Gtk.SizeRequestMode.WIDTH_FOR_HEIGHT;
    }

    public override void measure (Gtk.Widget widget, Gtk.Orientation orientation, int for_size, out int minimum, out int natural, out int minimum_baseline, out int natural_baseline) {
        Gtk.Widget child;
        natural = 0;
        minimum = 0;
        minimum_baseline = -1;
        natural_baseline = -1;
        for (child = widget.get_first_child (); child != null; child = child.get_next_sibling ()) {
            int child_min = 0;
            int child_nat = 0;
            int child_min_baseline = -1;
            int child_nat_baseline = -1;

            if (!child.should_layout ())
                continue;

            if (orientation == Gtk.Orientation.HORIZONTAL) {
                child.measure (orientation, for_size,
                               out child_min, out child_nat,
                               out child_min_baseline, out child_nat_baseline);

                child_nat = latch_size_from_child (child_min, child_nat);
            } else {
                int child_size = child_size_from_latch (child, for_size, child_nat, child_min);

                child.measure (orientation, child_size,
                               out child_min, out child_nat,
                               out child_min_baseline, out child_nat_baseline);
            }

            if (minimum != -1) {
                minimum = int.max (minimum, child_min);
            }
            if (natural != -1) {
                natural = int.max (natural, child_nat);
            }

            if (minimum_baseline != -1 && child_min_baseline > -1)
                minimum_baseline = int.max (minimum_baseline, child_min_baseline);
            if (natural_baseline != -1 && child_nat_baseline > -1)
                natural_baseline = int.max (natural_baseline, child_nat_baseline);
        }
    }

    public override void allocate (Gtk.Widget widget, int width, int height, int baseline) {
        Gtk.Widget child;
        Gtk.Allocation child_allocation = Gtk.Allocation ();
        for (child = widget.get_first_child (); child != null; child = child.get_next_sibling ()) {
            int child_maximum = 0, lower_threshold = 0;
            int child_latched_size;

            if (orientation == Gtk.Orientation.HORIZONTAL) {
                child_allocation.width = child_size_from_latch (child, width,
                                                                child_maximum,
                                                                lower_threshold);
                child_allocation.height = height;

                child_latched_size = child_allocation.width;
            } else {
                child_allocation.width = width;
                child_allocation.height = child_size_from_latch (child, height,
                                                                 child_maximum,
                                                                 lower_threshold);

                child_latched_size = child_allocation.height;
            }

            if (orientation == Gtk.Orientation.HORIZONTAL) {
                child_allocation.x = (width - child_allocation.width) / 2;
                child_allocation.y = 0;
            } else {
                child_allocation.x = 0;
                child_allocation.y = (height - child_allocation.height) / 2;
            }

            if (child.should_layout ()) {
				child.allocate_size (child_allocation, baseline);
			}
        }
    }
}
