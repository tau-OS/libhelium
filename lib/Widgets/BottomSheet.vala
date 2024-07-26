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
 * A BottomSheet is a UI component made to showcase accessory actions.
 * It may have an action button.
 * It has a title label.
 */
public class He.BottomSheet : Gtk.Widget {
    private const int TOP_MARGIN = 54;

    public signal void hidden ();

    private Gtk.Widget dimming;
    private Gtk.Widget handle;
    private Gtk.Box sheet_bin;
    private He.ViewSubTitle title_label;
    private He.SpringAnimation show_animation;
    private Gtk.WindowHandle handle_wh;

    private bool dragging = false;
    private double initial_y = 0;
    private int initial_height = 0;

    private Gtk.Widget? _sheet;
    public Gtk.Widget? sheet {
        get { return _sheet; }
        set {
            if (sheet == value)
                return;

            _sheet = value;

            sheet.unparent (); // Avoiding stacked children
            sheet_bin.append (sheet);
        }
    }

    private Gtk.Widget? _button;
    public Gtk.Widget? button {
        get { return _button; }
        set {
            if (button == value)
                return;

            _button = value;

            button.unparent (); // Avoiding stacked children
            sheet_bin.append (button);
        }
    }

    private string? _title;
    public string? title {
        get { return _title; }
        set {
            if (title == value)
                return;

            _title = value;

            title_label.label = title;
        }
    }

    private bool _show_sheet;
    public bool show_sheet {
        get { return _show_sheet; }
        set {
            if (show_sheet == value)
                return;

            _show_sheet = value;

            show_animation.latch = !show_sheet;
            show_animation.value_from = show_animation.avalue;
            show_animation.value_to = show_sheet ? 1 : 0;
            show_animation.play ();
        }
    }

    private bool _modal;
    public bool modal {
        get { return _modal; }
        set {
            if (modal == value)
                return;

            _modal = value;

            if (value) {
                dimming.add_css_class ("dimming");
            } else {
                dimming.remove_css_class ("dimming");
            }
        }
    }

    private bool _show_handle;
    public bool show_handle {
        get { return _show_handle; }
        set {
            if (show_handle == value)
                return;

            _show_handle = value;
            handle.visible = value;
        }
    }

    private int _preferred_sheet_height;
    public int preferred_sheet_height {
        get { return _preferred_sheet_height; }
        set {
            if (preferred_sheet_height == value)
                return;

            _preferred_sheet_height = value;

            // Animation state as well
            if (show_animation.avalue > 0)
                queue_allocate ();
        }
    }

    construct {
        dimming = new He.Bin ();
        dimming.opacity = 0;
        dimming.set_child_visible (false);
        dimming.add_css_class ("dimming");
        dimming.set_parent (this);

        sheet_bin = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        sheet_bin.set_child_visible (false);
        sheet_bin.halign = Gtk.Align.CENTER;
        sheet_bin.set_parent (this);

        handle = new He.Bin ();
        handle.visible = false;
        handle.add_css_class ("drag-handle");
        handle.add_css_class ("large-radius");

        var gesture_drag = new Gtk.GestureDrag ();
        handle.add_controller (gesture_drag);
        gesture_drag.drag_begin.connect (on_drag_begin);
        gesture_drag.drag_update.connect (on_drag_update);
        gesture_drag.drag_end.connect (on_drag_end);

        title_label = new He.ViewSubTitle ();
        title_label.valign = Gtk.Align.END;
        title_label.hexpand = true;

        handle_wh = new Gtk.WindowHandle ();
        handle_wh.add_css_class ("drag-handle-container");
        handle_wh.set_child (title_label);

        sheet_bin.prepend (handle_wh);
        sheet_bin.prepend (handle);

        var click_gesture = new Gtk.GestureClick ();
        click_gesture.end.connect (close_sheet);
        dimming.add_controller (click_gesture);

        show_animation = new He.SpringAnimation (
                                                 this,
                                                 0,
                                                 1,
                                                 new He.SpringParams (0.9, 1, 200),
                                                 new He.CallbackAnimationTarget ((value) => {
            dimming.opacity = value.clamp (0, 1);
            dimming.set_child_visible (value > 0);
            sheet_bin.set_child_visible (value > 0);
            queue_allocate ();
        }));
        show_animation.done.connect (() => {
            queue_allocate ();

            if (show_animation.avalue < 0.5) {
                dimming.set_child_visible (false);
                sheet_bin.set_child_visible (false);

                hidden ();
            }
        });
        show_animation.epsilon = 0.001;

        show_handle = true;
        modal = true;
    }

    private void close_sheet () {
        show_sheet = false;
    }

    private void on_drag_begin (Gtk.GestureDrag gesture, double x, double y) {
        dragging = true;
        initial_y = y;
        initial_height = preferred_sheet_height;
    }

    private void on_drag_update (Gtk.GestureDrag gesture, double offset_x, double offset_y) {
        if (dragging) {
            // Calculate the new height based on the drag offset
            int new_height = initial_height - (int) offset_y;

            int height;
            measure (VERTICAL, -1, null, out height, null, null);

            // Ensure the new height is within acceptable bounds
            int clamped_height;
            clamped_height = int.min (new_height, 0);
            clamped_height = int.max (new_height, height - TOP_MARGIN);

            // Update the preferred height
            preferred_sheet_height = clamped_height;
        }
    }

    private void on_drag_end (Gtk.GestureDrag gesture, double x, double y) {
        dragging = false;
    }

    protected override void dispose () {
        if (dimming != null) {
            dimming.unparent ();
            dimming = null;
        }

        if (sheet_bin != null) {
            sheet_bin.unparent ();
            sheet_bin = null;
        }

        base.dispose ();
    }

    protected override bool contains (double x, double y) {
        return false;
    }

    protected override void measure (Gtk.Orientation orientation,
                                     int for_size,
                                     out int min,
                                     out int nat,
                                     out int min_baseline,
                                     out int nat_baseline) {
        int sheet_min, sheet_nat;
        int dimming_min, dimming_nat;
        int handle_min, handle_nat;
        min = nat = 0;

        sheet_bin.measure (orientation, for_size, out sheet_min, out sheet_nat, null, null);
        dimming.measure (orientation, for_size, out dimming_min, out dimming_nat, null, null);

        if (handle != null) {
            handle.measure (orientation, for_size, out handle_min, out handle_nat, null, null);
        }

        if (orientation == HORIZONTAL) {
            min = int.max (dimming_min, sheet_min);
            nat = int.max (dimming_nat, sheet_nat);
        } else {
            min = int.max (dimming_min, sheet_min + TOP_MARGIN);
            nat = int.max (dimming_nat, sheet_nat + TOP_MARGIN);
        }
        min_baseline = nat_baseline = -1;
    }

    protected override void size_allocate (int width, int height, int baseline) {
        if (!sheet_bin.get_child_visible ())
            return;

        dimming.allocate (width, height, baseline, null);

        int sheet_height;

        if (preferred_sheet_height < 0) {
            sheet_bin.measure (VERTICAL, -1, null, out sheet_height, null, null);
        } else {
            sheet_bin.measure (VERTICAL, -1, null, null, null, null);
            sheet_height = preferred_sheet_height;
        }

        sheet_height = int.max (sheet_height, 0);
        sheet_height = int.min (sheet_height, height - TOP_MARGIN);

        int offset_rounded = (int) Math.round (show_animation.avalue * sheet_height);

        var t = new Gsk.Transform ();

        if (width <= 396) { // Mobile size (360) + accounting for sheet horizontal margins (18+18)
            if (dragging) {
                t = t.translate ({ 0, height - offset_rounded });
                sheet_height = int.max (sheet_height, offset_rounded);
                sheet_bin.allocate (width, sheet_height, baseline, t);
            } else {
                t = t.translate ({ 0, height - offset_rounded });
                sheet_height = int.max (sheet_height, offset_rounded);
                sheet_bin.allocate (width, sheet_height, baseline, t);
            }
            sheet_bin.add_css_class ("bottom-sheet");
            sheet_bin.remove_css_class ("dialog-sheet");
            handle.visible = show_handle;
        } else {
            if (!dragging) {
                t = t.translate ({ 0, (height - offset_rounded) / 2 });
                sheet_height = int.max (sheet_height, offset_rounded);
                sheet_bin.allocate (width, sheet_height, baseline, t);
            }
            sheet_bin.add_css_class ("dialog-sheet");
            sheet_bin.remove_css_class ("bottom-sheet");
            handle.visible = false;
        }

        if (handle != null) {
            int handle_width = 0, handle_height = 0, handle_x;

            handle.measure (Gtk.Orientation.HORIZONTAL, -1, null, out handle_width, null, null);
            handle.measure (Gtk.Orientation.VERTICAL, -1, null, out handle_height, null, null);

            handle_width = (int) Math.fmin (handle_width, width);
            handle_height = (int) Math.fmin (handle_height, height);

            handle_x = (int) Math.round (((width - handle_width) - 36) / 2); // accounting for sheet horizontal margins (18+18)

            var t2 = new Gsk.Transform ();

            t2 = t2.translate ({ handle_x, 0 });

            handle.allocate (handle_width, handle_height, baseline, t2);
        }
    }
}