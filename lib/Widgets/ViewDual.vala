/*
 * Copyright (c) 2024 Fyra Labs
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA
 */

/**
 * A ViewDual is a view that displays two views side by side.
 */
public class He.ViewDual : Gtk.Widget, Gtk.Buildable {
    private const double MIDDLE_SPACING = 24.0;

    private Gtk.Widget handle;
    private Gtk.GestureDrag drag_gesture;
    private Gtk.Widget base_bin;
    private Gtk.Box child_start_bin;
    private Gtk.Box child_end_bin;
    private Gtk.Box handle_bin;
    private GLib.TimeoutSource? resize_timeout;

    private bool dragging = false;
    private double initial_xy = 0;
    private double initial_pos = 0;
    private double target_pos = 0;
    private int update_interval = 16; // Default for 60Hz
    private double[] snap_values = { 0.66, 1.0, 1.44 };
    private double snap_threshold = 0.1; // Threshold for snapping

    /**
     * The orientation of the ViewDual.
     */
    private Gtk.Orientation _orientation;
    public Gtk.Orientation orientation {
        get { return _orientation; }
        set {
            _orientation = value;
            update_handle_look ();
            queue_draw ();
        }
    }

    /**
     * Show/hide the handle between views.
     */
    private bool _show_handle;
    public bool show_handle {
        get { return _show_handle; }
        set {
            _show_handle = value;
            handle.visible = _show_handle;
        }
    }

    /**
     * The view on the left (start)
     */
    private Gtk.Widget? _child_start;
    public Gtk.Widget? child_start {
        get { return _child_start; }
        set {
            if (_child_start != null) {
                _child_start.unparent ();
            }
            _child_start = value;
            if (_child_start != null) {
                child_start_bin.append (_child_start);
            }
        }
    }

    /**
     * The view on the right (end)
     */
    private Gtk.Widget? _child_end;
    public Gtk.Widget? child_end {
        get { return _child_end; }
        set {
            if (_child_end != null) {
                _child_end.unparent ();
            }
            _child_end = value;
            if (_child_end != null) {
                child_end_bin.append (_child_end);
            }
        }
    }

    private double _handle_position;
    private double handle_position {
        get { return _handle_position; }
        set {
            if (_handle_position == value)return;
            _handle_position = value;
            queue_allocate ();
        }
    }

    /**
     * Add a child to the widget, should only be used in the context of a UI or Blueprint file. There should be no need to use this method in code.
     */
    public new void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
        if (type == "start") {
            _child_start.unparent ();
            child_start_bin.append ((Gtk.Widget) child);
        } else if (type == "end") {
            _child_end.unparent ();
            child_end_bin.append ((Gtk.Widget) child);
        } else {
            _child_start.unparent ();
            child_start_bin.append ((Gtk.Widget) child);
        }
    }

    public ViewDual (Gtk.Orientation orientation = Gtk.Orientation.HORIZONTAL, bool show_handle = true) {
        this.orientation = orientation;
        this.handle_position = 1.0;
        this.show_handle = show_handle;
    }

    construct {
        this.margin_start = this.margin_end = this.margin_bottom = 8;

        base_bin = new He.Bin ();
        base_bin.set_parent (this);

        child_start_bin = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        child_start_bin.set_parent (base_bin);

        handle = new He.Bin ();
        handle.add_css_class ("circle-radius");
        update_handle_look ();

        drag_gesture = new Gtk.GestureDrag ();
        drag_gesture.drag_begin.connect (on_drag_begin);
        drag_gesture.drag_update.connect (on_drag_update);
        drag_gesture.drag_end.connect (on_drag_end);
        handle.add_controller (drag_gesture);

        handle_bin = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        handle_bin.set_parent (base_bin);
        handle_bin.append (handle);

        child_end_bin = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        child_end_bin.set_parent (base_bin);
    }

    private void update_handle_look () {
        if (orientation == Gtk.Orientation.HORIZONTAL) {
            handle.add_css_class ("drag-handle-vertical");
            handle.remove_css_class ("drag-handle");
            handle_bin.add_css_class ("drag-handle-container-vertical");
            handle_bin.remove_css_class ("drag-handle-container");
        } else {
            handle.add_css_class ("drag-handle");
            handle.remove_css_class ("drag-handle-vertical");
            handle_bin.add_css_class ("drag-handle-container");
            handle_bin.remove_css_class ("drag-handle-container-vertical");
        }
    }

    private void update_refresh_rate () {
        var monitor = get_display ().get_monitor_at_surface (get_native ().get_surface ());
        if (monitor != null) {
            var refresh_rate = monitor.get_refresh_rate ();
            if (refresh_rate > 0) {
                update_interval = (int) (1000 / (refresh_rate / 1000));
            }
        }
    }

    private void on_drag_begin (Gtk.GestureDrag gesture, double x, double y) {
        dragging = true;
        initial_xy = (orientation == Gtk.Orientation.HORIZONTAL) ? x : y;
        initial_pos = handle_position;
    }

    private double snap_to_nearest (double value) {
        double closest_snap = value;
        double min_distance = double.MAX;

        foreach (double snap in snap_values) {
            double distance = Math.fabs (value - snap);
            if (distance < min_distance) {
                min_distance = distance;
                if (distance < snap_threshold) {
                    closest_snap = snap;
                }
            }
        }

        return closest_snap;
    }

    private double lerp (double start, double end, double t) {
        return start + (end - start) * t;
    }

    private void on_drag_update (Gtk.GestureDrag gesture, double offset_x, double offset_y) {
        if (dragging) {
            if (orientation == Gtk.Orientation.HORIZONTAL) {
                target_pos = initial_pos + offset_x;
            } else {
                target_pos = initial_pos + offset_y;
            }

            // Clamp target_pos to be between 0.6 and 1.5
            target_pos = target_pos.clamp (0.6, 1.5);

            // Snap target_pos to the nearest snap value
            target_pos = snap_to_nearest (target_pos);

            if (resize_timeout == null) {
                update_refresh_rate ();
                resize_timeout = new GLib.TimeoutSource (update_interval);
                resize_timeout.set_callback (() => {
                    // Smooth transition towards the snapped target position using lerp
                    double lerp_amount = 0.05; // Adjust for desired smoothness
                    if (Math.fabs (target_pos - handle_position) > 0.01) {
                        handle_position = lerp (handle_position, target_pos, lerp_amount);
                        queue_allocate ();
                        return true;
                    } else {
                        handle_position = target_pos;
                        resize_timeout = null;
                        queue_allocate ();
                        return false;
                    }
                });
                resize_timeout.attach (GLib.MainContext.default ());
            }
        }
    }

    private void on_drag_end (Gtk.GestureDrag gesture, double offset_x, double offset_y) {
        dragging = false;
        initial_pos = 0;
        if (resize_timeout != null) {
            resize_timeout.destroy ();
            resize_timeout = null;
        }
    }

    protected override void dispose () {
        if (child_end_bin != null) {
            child_end_bin.unparent ();
        }
        if (child_start_bin != null) {
            child_start_bin.unparent ();
        }
        if (handle_bin != null) {
            handle_bin.unparent ();
        }
        if (base_bin != null) {
            base_bin.unparent ();
        }
        base.dispose ();
    }

    protected override bool contains (double x, double y) {
        return false;
    }

    protected override void measure (Gtk.Orientation orientation, int for_size, out int min, out int nat, out int min_baseline, out int nat_baseline) {
        int csmin, cemin, handle_min, base_bin_min;
        min = nat = 0;

        child_start_bin.measure (orientation, for_size, out csmin, null, null, null);
        child_end_bin.measure (orientation, for_size, out cemin, null, null, null);
        handle.measure (orientation, for_size, out handle_min, null, null, null);
        base_bin.measure (orientation, for_size, out base_bin_min, null, null, null);

        if (orientation == Gtk.Orientation.HORIZONTAL) {
            min = int.max (base_bin_min, csmin + cemin + handle_min);
        } else {
            min = int.max (base_bin_min, csmin + cemin + handle_min);
        }

        min_baseline = -1;
        nat_baseline = -1;
    }

    protected override void size_allocate (int width, int height, int baseline) {
        base_bin.allocate (width, height, -1, null);

        int child_start_min;
        int child_end_min;
        child_start_bin.measure (this.orientation, width, out child_start_min, null, null, null);
        child_end_bin.measure (this.orientation, width, out child_end_min, null, null, null);

        int handle_width = 0, handle_height = 0;

        int offset_rounded_x = (int) Math.round (handle_position * width);
        int offset_rounded_y = (int) Math.round (handle_position * height);

        var ts = new Gsk.Transform ();
        var te = new Gsk.Transform ();
        var th = new Gsk.Transform ();

        if (orientation == Gtk.Orientation.HORIZONTAL) {
            ts = ts.translate ({ 0, 0 });
            te = te.translate ({ (offset_rounded_x / 2) + (int) MIDDLE_SPACING, 0 });
            child_start_bin.allocate ((int) ((width / 2) * handle_position), height, -1, ts);
            child_end_bin.allocate ((int) ((width / handle_position) * handle_position) - ((offset_rounded_x / 2) + (int) MIDDLE_SPACING), height, -1, te);
        } else {
            ts = ts.translate ({ 0, 0 });
            te = te.translate ({ 0, (offset_rounded_y / 2) + (int) MIDDLE_SPACING });
            child_start_bin.allocate (width, (int) ((height / 2) * handle_position), -1, ts);
            child_end_bin.allocate (width, (int) ((height / handle_position) * handle_position) - ((offset_rounded_y / 2) + (int) MIDDLE_SPACING), -1, te);
        }

        if (handle_bin != null) {
            handle_bin.measure (Gtk.Orientation.HORIZONTAL, -1, null, out handle_width, null, null);
            handle_bin.measure (Gtk.Orientation.VERTICAL, -1, null, out handle_height, null, null);

            if (orientation == Gtk.Orientation.HORIZONTAL) {
                th = th.translate ({ offset_rounded_x / 2, height / 2 });
                handle_bin.allocate (handle_width, handle_height, -1, th);
            } else {
                th = th.translate ({ width / 2, offset_rounded_y / 2 });
                handle_bin.allocate (handle_width, handle_height, -1, th);
            }
        }
    }
}