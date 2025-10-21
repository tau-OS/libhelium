public class He.SnapItem : Gtk.Box {
    private Gtk.Widget content;
    private double focus_factor = 0.0;
    private int current_width = 56;
    private const int MIN_WIDTH = 40;

    public SnapItem (Gtk.Widget child) {
        Object (orientation: Gtk.Orientation.VERTICAL, spacing: 0);
        content = child;
        content.set_hexpand (true);
        content.set_vexpand (true);
        append (content);

        content.add_css_class ("xxx-large-radius");
    }

    public void set_focus_profile (double value, int width_request, bool show_content) {
        focus_factor = clamp_double (value);
        current_width = width_request;
        if (current_width < MIN_WIDTH) {
            current_width = MIN_WIDTH;
        }
        set_size_request (current_width, -1);
        var first_child = content.get_first_child ();
        if (first_child != null) {
            first_child.set_visible (show_content);
        } else {
            content.set_visible (show_content);
        }
        queue_resize ();
    }

    private double clamp_double (double value) {
        double limited = Math.fmax (value, 0.0);
        return Math.fmin (limited, 1.0);
    }

    public Gtk.Widget get_content () {
        return content;
    }

    protected override void measure (Gtk.Orientation orientation,
                                     int for_size,
                                     out int minimum,
                                     out int natural,
                                     out int minimum_baseline,
                                     out int natural_baseline) {
        if (orientation == Gtk.Orientation.HORIZONTAL) {
            minimum = current_width;
            natural = current_width;
            minimum_baseline = -1;
            natural_baseline = -1;
            return;
        }

        base.measure (orientation,
                      for_size,
                      out minimum,
                      out natural,
                      out minimum_baseline,
                      out natural_baseline);
    }
}

public class He.SnapScrollBox : He.Bin {
    private const int MIN_TOTAL_WIDTH = 360;
    private const int MIN_TOTAL_HEIGHT = 186;
    private const double SMALL_MIN_WIDTH = 40.0;
    private const double SMALL_MAX_WIDTH = 56.0;
    private const double SECOND_MIN_WIDTH = 56.0;
    private const double FOCUS_MIN_WIDTH = 56.0;
    private const double FOCUS_RATIO = 1.00000000;
    private const double SECOND_RATIO = 3.55000000;
    private const double COLLAPSED_WIDTH = 40.0;

    private Gtk.ScrolledWindow scrolled_window;
    private Gtk.Box container;
    private He.Button action_button;
    private Gee.ArrayList<SnapItem> children = new Gee.ArrayList<SnapItem> ();
    private int current_index = 0;
    private int last_focused_index = -1;
    private int visible_center = -1;
    private int window_start = 0;
    private int window_end = -1;
    private uint animation_id = 0;
    private uint snap_idle_id = 0;
    private const uint KEY_LEFT = 0xff51;
    private const uint KEY_RIGHT = 0xff53;
    private bool focus_update_in_progress = false;
    private bool focus_update_pending = false;
    private int desired_focus_index = -1;

    public signal void focus_changed (int index);

    private bool show_button_state = false;
    public bool show_button {
        get {
            return show_button_state;
        }
        set {
            if (show_button_state == value) {
                return;
            }
            show_button_state = value;
            action_button.set_visible (value);
        }
    }

    public SnapScrollBox () {
        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 8);
        margin_start = 16;
        margin_end = 16;

        container = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 8);
        container.set_valign (Gtk.Align.FILL);
        container.set_halign (Gtk.Align.FILL);
        container.set_hexpand (true);
        container.margin_bottom = 18;

        scrolled_window = new Gtk.ScrolledWindow ();
        scrolled_window.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.NEVER);
        scrolled_window.set_child (container);
        scrolled_window.set_propagate_natural_width (false);
        scrolled_window.set_propagate_natural_height (true);
        scrolled_window.set_kinetic_scrolling (true);
        scrolled_window.set_hexpand (true);
        main_box.append (scrolled_window);

        var scroll_controller = new Gtk.EventControllerScroll (Gtk.EventControllerScrollFlags.VERTICAL);
        scroll_controller.scroll.connect ((dx, dy) => {
            handle_scroll (dy);
            update_focus_factors ();
            return true;
        });
        scrolled_window.add_controller (scroll_controller);

        var key_controller = new Gtk.EventControllerKey ();
        key_controller.key_pressed.connect ((keyval, keycode, state) => {
            if (keyval == KEY_LEFT && current_index > 0) {
                current_index--;
                snap_to_child (current_index);
                return true;
            } else if (keyval == KEY_RIGHT && current_index < children.size - 1) {
                current_index++;
                snap_to_child (current_index);
                return true;
            }
            return false;
        });
        add_controller (key_controller);

        action_button = new He.Button ("", "Show all");
        action_button.add_css_class ("flat");
        action_button.set_halign (Gtk.Align.END);
        action_button.set_valign (Gtk.Align.END);
        action_button.set_visible (show_button_state);

        main_box.append (action_button);
        child = main_box;

        scrolled_window.get_hadjustment ().value_changed.connect (() => {
            update_focus_factors ();
        });
        scrolled_window.get_hadjustment ().changed.connect (() => {
            update_focus_factors ();
        });
    }

    protected override void measure (Gtk.Orientation orientation,
                                     int for_size,
                                     out int minimum,
                                     out int natural,
                                     out int minimum_baseline,
                                     out int natural_baseline) {
        base.measure (orientation,
                      for_size,
                      out minimum,
                      out natural,
                      out minimum_baseline,
                      out natural_baseline);

        if (orientation == Gtk.Orientation.HORIZONTAL) {
            if (minimum < MIN_TOTAL_WIDTH) {
                minimum = MIN_TOTAL_WIDTH;
            }
            if (natural < MIN_TOTAL_WIDTH) {
                natural = MIN_TOTAL_WIDTH;
            }
        } else {
            if (minimum < MIN_TOTAL_HEIGHT) {
                minimum = MIN_TOTAL_HEIGHT;
            }
            if (natural < MIN_TOTAL_HEIGHT) {
                natural = MIN_TOTAL_HEIGHT;
            }
        }
    }

    public Gtk.Button get_action_button () {
        return action_button;
    }

    public int get_focus_index () {
        if (last_focused_index >= 0) {
            return last_focused_index;
        }
        return current_index;
    }

    public void add_item (Gtk.Widget item) {
        var wrapped = new SnapItem (item);
        wrapped.set_valign (Gtk.Align.FILL);
        wrapped.set_vexpand (true);
        wrapped.set_hexpand (false);
        wrapped.set_halign (Gtk.Align.CENTER);
        container.append (wrapped);
        children.add (wrapped);
        apply_visibility_window (get_focus_index ());
        update_focus_factors ();
    }

    public void snap_to_child (int index) {
        if (index < 0 || index >= children.size) {
            return;
        }

        apply_visibility_window (index, false);
        container.queue_resize ();
        update_focus_factors ();
        desired_focus_index = index;

        if (snap_idle_id != 0) {
            Source.remove (snap_idle_id);
            snap_idle_id = 0;
        }

        int target_index = index;
        snap_idle_id = GLib.Idle.add (() => {
            snap_idle_id = 0;
            perform_snap_to_index (target_index);
            return false;
        });
    }

    private void perform_snap_to_index (int index) {
        if (index < 0 || index >= children.size) {
            return;
        }

        var child = children[index];
        if (!child.get_visible ()) {
            child.set_visible (true);
        }

        var adjustment = scrolled_window.get_hadjustment ();
        int child_width = child.get_width ();

        Graphene.Rect bounds;
        if (!child.compute_bounds (container, out bounds)) {
            container.queue_resize ();
            if (snap_idle_id == 0) {
                int retry_index = index;
                snap_idle_id = GLib.Idle.add (() => {
                    snap_idle_id = 0;
                    perform_snap_to_index (retry_index);
                    return false;
                });
            }
            return;
        }

        if (child_width <= 0) {
            container.queue_resize ();
            if (snap_idle_id == 0) {
                int retry_index = index;
                snap_idle_id = GLib.Idle.add (() => {
                    snap_idle_id = 0;
                    perform_snap_to_index (retry_index);
                    return false;
                });
            }
            return;
        }

        double page_size = adjustment.get_page_size ();
        double margin_left = margin_start;
        double margin_right = margin_end;
        double margin_total = margin_left + margin_right;
        double inner_width = page_size - margin_total;
        if (inner_width <= 0.0) {
            inner_width = page_size;
            margin_left = 0.0;
            margin_right = 0.0;
            margin_total = 0.0;
        }

        double target_scroll = bounds.origin.x + bounds.size.width / 2.0 - (margin_left + inner_width / 2.0);
        double upper_limit = adjustment.get_upper () - page_size;
        target_scroll = clamp (target_scroll, adjustment.get_lower (), upper_limit);

        animate_scroll_to (target_scroll);
    }

    private void handle_scroll (double delta) {
        if (children.size == 0) {
            return;
        }

        if (delta > 0 && current_index < children.size - 1) {
            current_index++;
        } else if (delta < 0 && current_index > 0) {
            current_index--;
        }

        desired_focus_index = current_index;
        snap_to_child (current_index);
    }

    private void animate_scroll_to (double target) {
        if (animation_id != 0) {
            Source.remove (animation_id);
            animation_id = 0;
        }

        var adjustment = scrolled_window.get_hadjustment ();
        double start = adjustment.get_value ();
        double duration = 500.0;
        double elapsed = 0.0;
        uint interval = 16;

        animation_id = GLib.Timeout.add (interval, () => {
            elapsed += interval;
            double t = Math.fmin (elapsed / duration, 1.0);
            double eased = ease_out_cubic (t);
            double value = start + (target - start) * eased;
            adjustment.set_value (value);

            update_focus_factors ();

            if (t >= 1.0) {
                animation_id = 0;
                return false;
            }
            return true;
        });
    }

    private double ease_out_cubic (double t) {
        double inv = 1.0 - t;
        return 1.0 - inv * inv * inv;
    }

    protected override void size_allocate (int width, int height, int baseline) {
        base.size_allocate (width, height, baseline);
        update_focus_factors ();
    }

    private void update_focus_factors () {
        if (focus_update_in_progress) {
            focus_update_pending = true;
            return;
        }
        focus_update_in_progress = true;
        focus_update_pending = false;

        try {
            if (children.size == 0 || scrolled_window.get_hadjustment () == null) {
                return;
            }

            var adjustment = scrolled_window.get_hadjustment ();
            double scroll_value = adjustment.get_value ();
            double page_size = adjustment.get_page_size ();
            double margin_left = margin_start;
            double margin_right = margin_end;
            double margin_total = margin_left + margin_right;
            double inner_width = get_width () - margin_total;
            if (inner_width <= 0.0) {
                inner_width = page_size;
                margin_left = 0.0;
                margin_right = 0.0;
                margin_total = 0.0;
            }
            double lower_bound = adjustment.get_lower ();
            double upper_bound = adjustment.get_upper ();
            bool at_start = Math.fabs (scroll_value - lower_bound) < 1.0;
            bool at_end = Math.fabs ((scroll_value + page_size) - upper_bound) < 1.0;

            int count = children.size;
            double[] focus_values = new double[count];
            int best_index = -1;
            double best_focus = -1.0;

            for (int i = 0; i < count; i++) {
                var item = children[i];
                Graphene.Rect item_bounds;
                if (!item.compute_bounds (container, out item_bounds)) {
                    continue;
                }

                double center = scroll_value + margin_left + inner_width / 2.0;
                double item_center = item_bounds.origin.x + item_bounds.size.width / 2.0;
                double distance = Math.fabs (center - item_center);
                double normalized = 1.0;

                double denom = (inner_width > 0.0) ? inner_width : page_size;
                if (denom > 0.0) {
                    normalized = clamp (distance / denom, 0.0, 1.0);
                }

                double focus = 1.0 - normalized;
                focus_values[i] = focus;

                if (focus > best_focus) {
                    best_focus = focus;
                    best_index = i;
                }
            }

            int resolved_index = best_index;
            if (at_start) {
                resolved_index = 0;
            } else if (at_end) {
                resolved_index = count - 1;
            }

            if (resolved_index < 0) {
                resolved_index = current_index;
            }

            if (desired_focus_index >= 0 && desired_focus_index < count) {
                resolved_index = desired_focus_index;
            } else {
                desired_focus_index = -1;
            }

            int target_start;
            int target_end;
            int bounded_center = compute_window_bounds (resolved_index, out target_start, out target_end);
            if (bounded_center < 0) {
                return;
            }
            resolved_index = bounded_center;

            int visible_slots = (target_end >= target_start) ? (target_end - target_start + 1) : 0;
            if (visible_slots < 1) {
                visible_slots = (count < 3) ? count : 3;
            }

            double width_budget = inner_width - 1.0 * (visible_slots - 1);
            if (width_budget <= 0.0) {
                width_budget = inner_width;
            }

            for (int i = 0; i < count; i++) {
                bool in_window = (i >= target_start) && (i <= target_end);
                var item = children[i];
                if (!in_window) {
                    item.set_focus_profile (0.0, (int) COLLAPSED_WIDTH, false);
                    item.set_margin_start (0);
                    item.set_margin_end (0);
                    continue;
                }

                int rank = i - resolved_index;
                if (rank < 0) {
                    rank = -rank;
                }

                double width_value = rank_width (rank, inner_width, count);
                if (rank >= 2) {
                    width_value = clamp (width_value, SMALL_MIN_WIDTH, SMALL_MAX_WIDTH);
                } else if (rank == 1) {
                    width_value = Math.fmax (width_value, SECOND_MIN_WIDTH);
                } else {
                    width_value = Math.fmax (width_value, FOCUS_MIN_WIDTH);
                    width_value = clamp (width_value, 0.0, width_budget);
                }

                int width_request = (int) Math.rint (width_value);
                bool is_focus = (i == resolved_index);
                bool show_content = is_focus || width_request > 56;
                item.set_focus_profile (focus_values[i], width_request, show_content);
                item.set_margin_start (0);
                item.set_margin_end ((i < target_end) ? (int) 1.0 : 0);
            }

            if (resolved_index >= 0) {
                current_index = resolved_index;
                if (resolved_index != last_focused_index) {
                    last_focused_index = resolved_index;
                    focus_changed (resolved_index);
                }
                if (resolved_index != visible_center) {
                    apply_visibility_window (resolved_index);
                }
                if (desired_focus_index == resolved_index) {
                    desired_focus_index = -1;
                }
            }

            container.queue_resize ();
        } finally {
            focus_update_in_progress = false;
            if (focus_update_pending) {
                focus_update_pending = false;
                update_focus_factors ();
            }
        }
    }

    private int compute_window_bounds (int center, out int start, out int end) {
        int count = children.size;
        if (count == 0) {
            start = 0;
            end = -1;
            return -1;
        }

        if (center < 0) {
            center = 0;
        }
        if (center >= count) {
            center = count - 1;
        }

        start = center;
        end = center;

        int desired = (count < 3) ? count : 3;
        if (desired <= 1) {
            return center;
        }

        int shown = 1;
        int left = center - 1;
        int right = center + 1;

        while (shown < desired) {
            if (left >= 0) {
                start = left;
                left--;
                shown++;
                if (shown >= desired) {
                    break;
                }
            }

            if (right < count) {
                end = right;
                right++;
                shown++;
            } else if (left >= 0) {
                start = left;
                left--;
                shown++;
            } else {
                break;
            }
        }

        return center;
    }

    private double clamp (double value, double min_value, double max_value) {
        if (max_value < min_value) {
            max_value = min_value;
        }
        double limited = Math.fmax (value, min_value);
        return Math.fmin (limited, max_value);
    }

    private void apply_visibility_window (int center, bool record = true) {
        int start;
        int end;
        int bounded_center = compute_window_bounds (center, out start, out end);
        int count = children.size;

        if (count == 0 || bounded_center < 0) {
            if (record) {
                visible_center = -1;
            }
            window_start = 0;
            window_end = -1;
            return;
        }

        window_start = start;
        window_end = end;

        if (record) {
            visible_center = bounded_center;
        }
        for (int i = 0; i < count; i++) {
            bool show = (i >= start) && (i <= end);
            var item = children[i];
            item.set_opacity (1.0);
            item.set_sensitive (show);
            item.set_can_target (show);
            item.set_focusable (show);
            item.set_margin_start (0);
            item.set_margin_end (show && i < end ? (int) 1.0 : 0);
        }
    }

    private double rank_width (int rank, double inner_width, int count) {
        double viewport = (inner_width > 0.0) ? inner_width : MIN_TOTAL_WIDTH;

        int visible_slots = count;
        if (visible_slots > 3) {
            visible_slots = 3;
        }
        if (visible_slots < 1) {
            visible_slots = 1;
        }

        double total_spacing = 1.0 * (visible_slots - 1);
        double available = viewport - total_spacing;
        if (available <= 0.0) {
            available = viewport;
        }

        double min_focus = FOCUS_MIN_WIDTH;
        double min_second = SECOND_MIN_WIDTH;
        double min_small = SMALL_MIN_WIDTH;
        double max_small = SMALL_MAX_WIDTH;

        double desired_focus = (FOCUS_RATIO > 0.0) ? (viewport / FOCUS_RATIO) : viewport;
        double desired_second = (SECOND_RATIO > 0.0) ? (viewport / SECOND_RATIO) : viewport;

        double focus_width = 0.0;
        double second_width = 0.0;
        double small_width = 0.0;

        if (visible_slots == 1) {
            focus_width = Math.fmax (desired_focus, min_focus);
            if (focus_width > available) {
                focus_width = available;
            }
            if (focus_width < min_focus && available >= min_focus) {
                focus_width = min_focus;
            }
        } else if (visible_slots == 2) {
            focus_width = min_focus;
            second_width = min_second;
            double min_total = focus_width + second_width;

            if (available < min_total && min_total > 0.0) {
                double scale = available / min_total;
                if (scale < 0.0) {
                    scale = 0.0;
                }
                focus_width *= scale;
                second_width *= scale;
            } else {
                double leftover = available - min_total;
                double extra_focus = Math.fmax (Math.fmax (desired_focus, min_focus) - focus_width, 0.0);
                double extra_second = Math.fmax (Math.fmax (desired_second, min_second) - second_width, 0.0);
                double total_extra = extra_focus + extra_second;

                if (leftover > 0.0) {
                    if (total_extra > 0.0) {
                        double focus_take = Math.fmin (leftover * (extra_focus / total_extra), extra_focus);
                        double second_take = Math.fmin (leftover * (extra_second / total_extra), extra_second);
                        double used = focus_take + second_take;
                        focus_width += focus_take;
                        second_width += second_take;
                        leftover -= used;
                    }

                    if (leftover > 0.0) {
                        focus_width += leftover * 0.5;
                        second_width += leftover * 0.5;
                        leftover = 0.0;
                    }
                }
            }
        } else {
            focus_width = min_focus;
            second_width = min_second;
            small_width = min_small;
            double min_total = focus_width + second_width + small_width;

            if (available < min_total && min_total > 0.0) {
                double scale = available / min_total;
                if (scale < 0.0) {
                    scale = 0.0;
                }
                focus_width *= scale;
                second_width *= scale;
                small_width *= scale;
            } else {
                double leftover = available - min_total;

                if (leftover > 0.0) {
                    double extra_focus = Math.fmax (Math.fmax (desired_focus, min_focus) - focus_width, 0.0);
                    double extra_second = Math.fmax (Math.fmax (desired_second, min_second) - second_width, 0.0);
                    double focus_share = 0.0;
                    double second_share = 0.0;
                    double total_extra = extra_focus + extra_second;

                    if (total_extra > 0.0) {
                        focus_share = extra_focus / total_extra;
                        second_share = extra_second / total_extra;
                    } else {
                        focus_share = 0.5;
                        second_share = 0.5;
                    }

                    double focus_take = Math.fmin (leftover * focus_share, extra_focus);
                    double second_take = Math.fmin (leftover * second_share, extra_second);
                    double used = focus_take + second_take;
                    focus_width += focus_take;
                    second_width += second_take;
                    leftover -= used;

                    if (leftover > 0.0) {
                        double small_room = Math.fmin (max_small - small_width, leftover);
                        if (small_room > 0.0) {
                            small_width += small_room;
                            leftover -= small_room;
                        }
                    }

                    if (leftover > 0.0) {
                        focus_width += leftover * 0.5;
                        second_width += leftover * 0.5;
                        leftover = 0.0;
                    }
                }
            }
        }

        if (rank == 0) {
            return Math.fmax (focus_width, 0.0);
        }
        if (rank == 1) {
            return (count >= 2) ? Math.fmax (second_width, 0.0) : min_small;
        }
        if (rank == 2) {
            if (count >= 3) {
                return Math.fmax (Math.fmin (small_width, max_small), 0.0);
            }
            return min_small;
        }
        return 1.0;
    }
}