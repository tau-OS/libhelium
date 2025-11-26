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
 * It has a title label and contents.
 */
public class He.BottomSheet : Gtk.Widget {
    private const int TOP_MARGIN = 42;
    private const int MINIMUM_HEIGHT = 300;
    private const int DEFAULT_HEIGHT = 440; // Dialog HIG
    private const int MOBILE_BREAKPOINT = 600;
    private const int MOBILE_SHEET_WIDTH = 360;
    private const int DESKTOP_SHEET_WIDTH = 440;
    private const int HANDLE_HIDDEN_MARGIN = 24;
    private const int TITLE_LABEL_MARGIN = 12;
    private const int DEFAULT_UPDATE_INTERVAL = 16; // Default for 60Hz

    /**
     * The hidden signal fires when the sheet is hidden.
     */
    public signal void hidden ();

    private Gtk.Widget dimming;
    private Gtk.Widget handle;
    private Gtk.Box sheet_bin;
    private Gtk.Label title_label;
    private He.SpringAnimation show_animation;
    private Gtk.WindowHandle handle_wh;
    private GLib.TimeoutSource? resize_timeout;

    private bool dragging = false;
    private int initial_height = 0;
    private int target_height = 0;
    private int update_interval = DEFAULT_UPDATE_INTERVAL;
    private bool is_mobile_mode = false;
    private bool mode_initialized = false;

    /**
     * The back button in case of a stack-type content.
     */
    public He.Button back_button;

    /**
     * The sheet to display (the content).
     */
    private Gtk.Widget? _sheet;
    public Gtk.Widget? sheet {
        get { return _sheet; }
        set {
            if (_sheet == value)
                return;

            if (_sheet != null) {
                _sheet.unparent ();
            }

            _sheet = value;

            if (_sheet != null) {
                sheet_bin.append (_sheet);
            }
        }
    }

    /**
     * The sheet (as a stack) to display (the content).
     */
    private Gtk.Stack? _sheet_stack;
    public Gtk.Stack? sheet_stack {
        get { return _sheet_stack; }
        set {
            if (_sheet_stack == value)
                return;

            if (_sheet_stack != null) {
                _sheet_stack.unparent ();
            }

            _sheet_stack = value;

            if (_sheet_stack != null) {
                sheet_bin.append (_sheet_stack);
                back_button.set_visible (true);
            } else {
                back_button.set_visible (false);
            }
        }
    }

    /**
     * The action button to use.
     */
    private Gtk.Widget? _button;
    public Gtk.Widget? button {
        get { return _button; }
        set {
            if (_button == value)
                return;

            if (_button != null) {
                _button.unparent ();
            }

            _button = value;

            if (_button != null) {
                sheet_bin.append (_button);
            }
        }
    }

    /**
     * The title to use.
     */
    private string? _title;
    public string? title {
        get { return _title; }
        set {
            if (_title == value)
                return;

            _title = value;

            title_label.label = _title ?? "";
        }
    }

    /**
     * Shows or hides the sheet
     */
    private bool _show_sheet;
    public bool show_sheet {
        get { return _show_sheet; }
        set {
            if (_show_sheet == value)
                return;

            _show_sheet = value;

            show_animation.latch = !_show_sheet;
            show_animation.value_from = show_animation.avalue;
            show_animation.value_to = _show_sheet ? 1 : 0;
            show_animation.play ();
        }
    }

    /**
     * Makes the sheet modal (with background scrim) or not.
     */
    private bool _modal;
    public bool modal {
        get { return _modal; }
        set {
            if (_modal == value)
                return;

            _modal = value;

            if (_modal) {
                dimming.add_css_class ("dimming");
            } else {
                dimming.remove_css_class ("dimming");
            }
        }
    }


    /**
     * Shows or hides the drag handle to be able to adjust sheet height
     */
    private bool _show_handle;
    public bool show_handle {
        get { return _show_handle; }
        set {
            if (_show_handle == value)
                return;

            _show_handle = value;
            handle.visible = _show_handle;

            if (_show_handle) {
                handle_wh.margin_top = 0;
            } else {
                handle_wh.margin_top = HANDLE_HIDDEN_MARGIN;
            }
        }
    }


    /**
     * The preferred sheet initial height. A good value is between 400 and 500;
     */
    private int _preferred_sheet_height;
    public int preferred_sheet_height {
        get { return _preferred_sheet_height; }
        set {
            if (_preferred_sheet_height == value)
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
        handle.halign = Gtk.Align.CENTER;
        handle.add_css_class ("drag-handle");
        handle.add_css_class ("large-radius");

        var gesture_drag = new Gtk.GestureDrag ();
        handle.add_controller (gesture_drag);
        gesture_drag.drag_begin.connect (on_drag_begin);
        gesture_drag.drag_update.connect (on_drag_update);
        gesture_drag.drag_end.connect (on_drag_end);

        title_label = new Gtk.Label ("");
        title_label.margin_start = TITLE_LABEL_MARGIN;
        title_label.valign = Gtk.Align.START;
        title_label.halign = Gtk.Align.START;
        title_label.hexpand = true;
        title_label.add_css_class ("view-subtitle");

        var close_button = new He.Button ("window-close-symbolic", "");
        close_button.is_disclosure = true;
        close_button.valign = Gtk.Align.START;
        close_button.halign = Gtk.Align.START;
        close_button.clicked.connect (() => {
            show_sheet = false;
        });

        back_button = new He.Button ("pan-start-symbolic", "");
        back_button.is_disclosure = true;
        back_button.set_visible (false);
        back_button.valign = Gtk.Align.START;
        back_button.halign = Gtk.Align.START;

        var title_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        title_box.append (close_button);
        title_box.append (back_button);
        title_box.append (title_label);

        handle_wh = new Gtk.WindowHandle ();
        handle_wh.add_css_class ("drag-handle-container");
        handle_wh.set_child (title_box);

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

    private void update_refresh_rate () {
        var monitor = get_display ().get_monitor_at_surface (get_native ().get_surface ());
        if (monitor != null) {
            var refresh_rate = monitor.get_refresh_rate ();
            if (refresh_rate > 0) {
                // refresh_rate is in millihertz, convert to milliseconds per frame
                update_interval = (int) (1000000 / refresh_rate);
            }
        }
    }

    private void on_drag_begin (Gtk.GestureDrag gesture, double x, double y) {
        dragging = true;
        initial_height = preferred_sheet_height;
    }

    private void on_drag_update (Gtk.GestureDrag gesture, double offset_x, double offset_y) {
        if (!dragging)
            return;

        // Calculate the new target height based on the drag offset
        target_height = initial_height - (int) offset_y;

        // Ensure the new target height is within acceptable bounds
        target_height = int.max (target_height, 0);

        // Start the resize timer if not already running
        if (resize_timeout == null) {
            update_refresh_rate ();

            resize_timeout = new GLib.TimeoutSource (update_interval);
            resize_timeout.set_callback (() => {
                // Smoothly update the preferred height towards the target height
                if (Math.fabs (preferred_sheet_height - target_height) > 1) {
                    preferred_sheet_height += (target_height - preferred_sheet_height) / 4;
                } else {
                    preferred_sheet_height = target_height;

                    // Stop the timer if the target height is reached
                    resize_timeout = null;
                    return false;
                }

                // Continue the timer
                return true;
            });
            resize_timeout.attach (GLib.MainContext.default ());
        }
    }

    private void on_drag_end (Gtk.GestureDrag gesture, double offset_x, double offset_y) {
        dragging = false;
        initial_height = 0;

        // If sheet is too small, just hide it, and set default height;
        if (preferred_sheet_height <= MINIMUM_HEIGHT) {
            close_sheet ();
            preferred_sheet_height = DEFAULT_HEIGHT;
        }

        // Stop the resize timer
        if (resize_timeout != null) {
            resize_timeout.destroy ();
            resize_timeout = null;
        }
    }

    private void update_sheet_mode (bool mobile) {
        if (mode_initialized && is_mobile_mode == mobile)
            return;

        mode_initialized = true;
        is_mobile_mode = mobile;

        if (mobile) {
            sheet_bin.add_css_class ("bottom-sheet");
            sheet_bin.remove_css_class ("dialog-sheet");
        } else {
            sheet_bin.add_css_class ("dialog-sheet");
            sheet_bin.remove_css_class ("bottom-sheet");
        }
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
        min = nat = 0;

        sheet_bin.measure (orientation, for_size, out sheet_min, out sheet_nat, null, null);
        dimming.measure (orientation, for_size, out dimming_min, out dimming_nat, null, null);

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

        if (width <= MOBILE_BREAKPOINT) {
            // Mobile size: sheet slides up from bottom
            int sheet_width = int.min (MOBILE_SHEET_WIDTH, width);
            int sheet_x = (width - sheet_width) / 2;

            t = t.translate ({ sheet_x, height - offset_rounded });
            sheet_height = int.max (sheet_height, offset_rounded);
            sheet_bin.allocate (sheet_width, sheet_height, baseline, t);

            // Mobile uses position animation, so keep full opacity
            sheet_bin.opacity = 1;

            update_sheet_mode (true);
            handle.visible = show_handle;
        } else {
            // Desktop size: centered dialog with fade animation
            int sheet_width = int.min (DESKTOP_SHEET_WIDTH, width);
            int sheet_x = (width - sheet_width) / 2;

            t = t.translate ({ sheet_x, (height - sheet_height) / 2 });
            sheet_bin.allocate (sheet_width, sheet_height, baseline, t);

            // Dialog uses opacity animation instead of sliding
            sheet_bin.opacity = show_animation.avalue;

            update_sheet_mode (false);
            handle.visible = false;
        }
    }
}
