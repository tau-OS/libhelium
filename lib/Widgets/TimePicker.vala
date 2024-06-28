/*
 * Copyright (c) 2022-2024 Fyra Labs
 * Copyright (c) 2014–2021 elementary, Inc. (https://elementary.io)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */
public class He.TimePicker : Gtk.Entry {
    /**
     *  The signal when time is changed with this widget.
     */
    public signal void time_changed ();

    /**
     *  The string format of how to display the time when in 12h mode.
     */
    public string format_12 { get; construct; }

    /**
     *  The string format of how to display the time when in 24h mode.
     */
    public string format_24 { get; construct; }

    private GLib.DateTime _time = null;
    public GLib.DateTime time {
        get {
            if (_time == null) {
                time = new GLib.DateTime.now_local ();
            }

            return _time;
        }

        set {
            _time = value;
            changing_time = true;

            if (_time.get_hour () >= 12) {
                pm_togglebutton.active = true;
            } else {
                am_togglebutton.active = true;
            }

            update_text (true);
            clock.hour = _time.get_hour ();
            clock.minute = _time.get_minute ();
            changing_time = false;
        }
    }

    private bool changing_time = false;
    private string old_string = "";
    private Gtk.Box am_pm_box;
    private Gtk.Popover popover;
    private Gtk.SpinButton hours_spinbutton;
    private Gtk.SpinButton minutes_spinbutton;
    private Gtk.ToggleButton am_togglebutton;
    private Gtk.ToggleButton pm_togglebutton;
    private ClockWidget clock;

    /**
    * Creates a new TimePicker widget with the given format strings.
    *
    * @param format_12 The string format of how to display the time when in 12h mode.
    * @param format_24 The string format of how to display the time when in 24h mode.
    */
    public TimePicker.with_format (string format_12, string format_24) {
        Object (format_12: format_12, format_24: format_24);
    }

    construct {
        if (format_12 == null) {
            format_12 = _("%-l:%M %p");
        }

        if (format_24 == null) {
            format_24 = _("%H:%M");
        }

        max_length = 8;
        primary_icon_gicon = new ThemedIcon.with_default_fallbacks ("clock-symbolic");
        secondary_icon_gicon = new ThemedIcon.with_default_fallbacks ("pan-down-symbolic");
        icon_release.connect (on_icon_press);

        am_togglebutton = new Gtk.ToggleButton.with_label (_("AM")) {
            vexpand = true
        };
        pm_togglebutton = new Gtk.ToggleButton.with_label (_("PM")) {
            group = am_togglebutton,
            vexpand = true
        };

        am_pm_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
            valign = Gtk.Align.START,
            margin_start = 16
        };
        am_pm_box.add_css_class ("linked");
        am_pm_box.append (am_togglebutton);
        am_pm_box.append (pm_togglebutton);

        if (is_clock_format_12h ()) {
            hours_spinbutton = new Gtk.SpinButton.with_range (1, 12, 1);
            clock.is_military_mode = false;
        } else {
            hours_spinbutton = new Gtk.SpinButton.with_range (0, 23, 1);
            clock.is_military_mode = true;
        }

        hours_spinbutton.orientation = Gtk.Orientation.VERTICAL;
        hours_spinbutton.wrap = true;
        hours_spinbutton.add_css_class ("display");
        hours_spinbutton.add_css_class ("flat");
        hours_spinbutton.value_changed.connect (() => update_time (true));

        minutes_spinbutton = new Gtk.SpinButton.with_range (0, 59, 1);
        minutes_spinbutton.orientation = Gtk.Orientation.VERTICAL;
        minutes_spinbutton.wrap = true;
        minutes_spinbutton.add_css_class ("display");
        minutes_spinbutton.add_css_class ("flat");
        minutes_spinbutton.value_changed.connect (() => update_time (false));

        minutes_spinbutton.output.connect (() => {
            var val = minutes_spinbutton.get_value ();
            if (val < 10) {
                minutes_spinbutton.set_text ("0" + val.to_string ());
                return true;
            }

            return false;
        });

        var separation_label = new Gtk.Label (":");
        separation_label.add_css_class ("display");

        var pop_grid_top = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6) {
            margin_top = 12,
            margin_start = 12,
            margin_end = 12,
        };
        pop_grid_top.append (hours_spinbutton);
        pop_grid_top.append (separation_label);
        pop_grid_top.append (minutes_spinbutton);
        pop_grid_top.append (am_pm_box);

        clock = new ClockWidget ();
        clock.time_selected.connect ((hour, minute) => {
            hours_spinbutton.set_text (hour.to_string ());
            if (minute < 10) {
                minutes_spinbutton.set_text ("0" + minute.to_string ());
            } else {
                minutes_spinbutton.set_text (minute.to_string ());
            }

            time_changed ();
            update_time (true);
            update_time (false);
        });

        var pop_grid_middle = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6) {
            margin_start = 12,
            margin_end = 12,
        };
        pop_grid_middle.append (clock);

        var pop_grid = new Gtk.Box (Gtk.Orientation.VERTICAL, 24);
        pop_grid.append (pop_grid_top);
        pop_grid.append (pop_grid_middle);

        popover = new Gtk.Popover () {
            autohide = true,
            child = pop_grid,
            has_arrow = false,
            position = Gtk.PositionType.BOTTOM,
        };
        popover.set_parent (this);
        popover.has_arrow = false;

        var focus_controller = new Gtk.EventControllerFocus ();
        var scroll_controller = new Gtk.EventControllerScroll (
            Gtk.EventControllerScrollFlags.BOTH_AXES | Gtk.EventControllerScrollFlags.DISCRETE
        );

        add_controller (focus_controller);
        add_controller (scroll_controller);

        focus_controller.leave.connect (() => {
            is_unfocused ();
        });

        scroll_controller.scroll.connect ((dx, dy) => {
            double largest = dx.abs () > dy.abs () ? dx : dy;
            if (largest < 0) {
                _time = _time.add_minutes (1);
            } else {
                _time = _time.add_minutes (-1);
            }

            update_text ();
            return false;
        });

        activate.connect (is_unfocused);

        am_togglebutton.clicked.connect (() => {
            update_am_pm (-12);
        });

        pm_togglebutton.clicked.connect (() => {
            update_am_pm (12);
        });

        this.add_css_class ("text-field");

        update_text ();
    }

    private static bool is_clock_format_12h () {
        string format = null;
        var h24_settings = new GLib.Settings ("org.gnome.desktop.interface");
        format = h24_settings.get_string ("clock-format");
        return (format.contains ("12h"));
    }

    private void update_am_pm (int hours) {
        if (changing_time) {
            return;
        }

        time = _time.add_hours (hours);
        time_changed ();

        update_text (true);
    }

    private void update_time (bool is_hour) {
        if (changing_time) {
            return;
        }

        if (is_hour) {
            var new_hour = hours_spinbutton.get_value_as_int () - time.get_hour ();

            if (is_clock_format_12h ()) {
                if (hours_spinbutton.get_value_as_int () == 12 && am_togglebutton.active = true) {
                    _time = _time.add_hours (-_time.get_hour ());
                } else if (hours_spinbutton.get_value_as_int () < 12 && am_togglebutton.active = true) {
                    _time = _time.add_hours (new_hour);
                } else if (hours_spinbutton.get_value_as_int () == 12 && pm_togglebutton.active = true) {
                    _time = _time.add_hours (-_time.get_hour () + 12);
                } else if (hours_spinbutton.get_value_as_int () < 12 && pm_togglebutton.active = true) {
                    _time = _time.add_hours (new_hour + 12);

                    if (time.get_hour () <= 12) {
                        _time = _time.add_hours (12);
                    }
                }
            } else {
                _time = _time.add_hours (new_hour);
            }
        } else {
            _time = time.add_minutes (minutes_spinbutton.get_value_as_int () - time.get_minute ());
        }

        update_text ();
    }

    private void on_icon_press (Gtk.EntryIconPosition position) {
        // If the mode is changed from 12h to 24h or visa versa, the entry updates on icon press
        update_text ();
        changing_time = true;

        if (is_clock_format_12h () && time.get_hour () > 12) {
            hours_spinbutton.set_value (time.get_hour () - 12);
        } else {
            hours_spinbutton.set_value (time.get_hour ());
        }

        if (is_clock_format_12h ()) {
            am_pm_box.show ();

            if (time.get_hour () > 12) {
                hours_spinbutton.set_value (time.get_hour () - 12);
            } else if (time.get_hour () == 0) {
                hours_spinbutton.set_value (12);
            } else {
                hours_spinbutton.set_value (time.get_hour ());
            }

            // Make sure that bounds are set correctly
            hours_spinbutton.set_range (1, 12);
            clock.is_military_mode = false;
        } else {
            am_pm_box.hide ();
            hours_spinbutton.set_value (time.get_hour ());

            hours_spinbutton.set_range (0, 23);
            clock.is_military_mode = true;
        }

        minutes_spinbutton.set_value (time.get_minute ());
        changing_time = false;

        popover.popup ();
    }

    private void is_unfocused () {
        if (!popover.visible && old_string.collate (text) != 0) {
            old_string = text;
            parse_time (text.dup ());
        }
    }

    private void parse_time (string timestr) {
        string current = "";
        bool is_hours = true;
        bool is_suffix = false;
        bool has_suffix = false;

        int? hour = null;
        int? minute = null;
        foreach (var c in timestr.down ().to_utf8 ()) {
            if (c.isdigit ()) {
                current = "%s%c".printf (current, c);
            } else {
                if (!is_suffix) {
                    if (current != "") {
                        if (is_hours) {
                            is_hours = false;
                            hour = int.parse (current);
                            current = "";
                        } else {
                            minute = int.parse (current);
                            current = "";
                        }
                    }

                    if (c.to_string ().contains ("a") || c.to_string ().contains ("p")) {
                        is_suffix = true;
                        current = "%s%c".printf (current, c);
                    }
                }

                if (c.to_string ().contains ("m") && is_suffix) {
                    if (hour == null) {
                        return;
                    } else if (minute == null) {
                        minute = 0;
                    }

                    // We can imagine that some will try to set it to "19:00 am"
                    if (current.contains ("a") || hour >= 12) {
                        time = time.add_hours (hour - time.get_hour ());
                    } else {
                        time = time.add_hours (hour + 12 - time.get_hour ());
                    }

                    if (current.contains ("a") && hour == 12) {
                        time = time.add_hours (-12);
                    }

                    time = time.add_minutes (minute - time.get_minute ());
                    has_suffix = true;
                }
            }
        }

        if (is_hours == false && is_suffix == false && current != "") {
            minute = int.parse (current);
        }

        if (hour == null) {
            if (current.length < 3) {
                hour = int.parse (current);
                minute = 0;
            } else if (current.length == 4) {
                hour = int.parse (current.slice (0, 2));
                minute = int.parse (current.slice (2, 4));
                if (hour > 23 || minute > 59) {
                    hour = null;
                    minute = null;
                }
            }
        }

        if (hour == null || minute == null) {
            update_text ();
            return;
        }

        if (has_suffix == false) {
            time = time.add_hours (hour - time.get_hour ());
            time = time.add_minutes (minute - time.get_minute ());
        }

        update_text ();
    }

    private void update_text (bool no_signal = false) {
        if (is_clock_format_12h ()) {
            set_text (time.format (format_12));
        } else {
            set_text (time.format (format_24));
        }

        old_string = text;

        if (no_signal == false) {
            time_changed ();
        }
    }

    private class ClockWidget : Gtk.Widget {
        private const double SIZE = 256.0;
        private const double CENTER = SIZE / 2;
        private const double RADIUS = (SIZE / 2) - 10.0;
        private const double SELECTION_CIRCLE_RADIUS = 24.0;
        private const double INNER_RADIUS = RADIUS - SELECTION_CIRCLE_RADIUS - 30.0;
        private const double OUTER_RADIUS = RADIUS - SELECTION_CIRCLE_RADIUS;
        private const double HAND_LINE_WIDTH = 2.0;
        private const double HAND_CENTER_WIDTH = 4.0;
        private const string FONT_FAMILY = "Manrope";
        private const int HOUR_FONT_SIZE = 20;
        private const int MINUTE_FONT_SIZE = 18;
        private const int HALF_DAY = 12;
        private const int FULL_DAY = 24;
        private const int MINUTES = 60;

        public bool selecting_hour { get; set; default = true;}
        public bool is_military_mode { get; set; default = false;}

        private int selected_hour = 0;
        private int selected_minute = 0;
        private double last_angle = 0.0;

        private Gdk.RGBA _accent_color = { 1, 1, 1, 1 };
        public Gdk.RGBA accent_color {
            get { return _accent_color; }
            set { _accent_color = value; queue_draw (); }
        }

        public int hour {
            get { return selected_hour; }
            set {
                selected_hour = ((int)(value * (is_military_mode ? FULL_DAY : HALF_DAY) / (2 * Math.PI)) + 3) % (is_military_mode ? FULL_DAY : HALF_DAY);
                if (selected_hour == 0) selected_hour = (is_military_mode ? FULL_DAY : HALF_DAY);
                queue_draw ();
            }
        }
    
        public int minute {
            get { return selected_minute; }
            set {
                selected_minute = (int)Math.round ((value * 30 / Math.PI) + 15) % MINUTES;
                queue_draw ();
            }
        }

        public signal void time_selected (int hour, int minute);

        construct {
            var click_gesture = new Gtk.GestureClick ();
            click_gesture.pressed.connect ((n_press, x, y) => { 
                last_angle = get_angle_from_coords (x, y);
            });
            click_gesture.released.connect (() => {
                if (selecting_hour) {
                    selecting_hour = false;
                    queue_draw ();
                } else {
                    emit_time_selected ();
                    reset_to_hour_selection ();
                }
            });
            add_controller (click_gesture);
    
            var drag_gesture = new Gtk.GestureDrag ();
            drag_gesture.drag_update.connect ((offset_x, offset_y) => {
                double x, y;
                drag_gesture.get_bounding_box_center (out x, out y);
                update_selection (x, y);
            });
            add_controller (drag_gesture);

            hexpand = true;
            vexpand = true;
            width_request = (int)SIZE;
            height_request = (int)SIZE;
        }

        protected override void dispose () {
            reset_to_hour_selection ();
            base.dispose ();
        }

        protected override void snapshot (Gtk.Snapshot snapshot) {
            var rect = Graphene.Rect ();
            rect.init (0, 0, (float)SIZE, (float)SIZE);
            var cr = snapshot.append_cairo (rect);

            // Font used
            cr.select_font_face (FONT_FAMILY, Cairo.FontSlant.NORMAL, Cairo.FontWeight.NORMAL);

            // Draw clock face
            cr.set_source_rgba ((0.15 * 1), (0.15 * 1), (0.15 * 1), 0.08);
            cr.arc (CENTER, CENTER, RADIUS, 0, 2 * Math.PI);
            cr.fill ();

            // Draw selection hand
            double hand_angle = selecting_hour ? get_hour_angle () : get_minute_angle ();
            double hand_radius = get_hand_radius (RADIUS);
            double hand_x = CENTER + hand_radius * Math.cos (hand_angle);
            double hand_y = CENTER + hand_radius * Math.sin (hand_angle);
            cr.set_source_rgba (accent_color.red, accent_color.green, accent_color.blue, 1);
            cr.arc (CENTER, CENTER, HAND_CENTER_WIDTH, 0, 2 * Math.PI);
            cr.fill_preserve ();
            cr.set_source_rgba (accent_color.red, accent_color.green, accent_color.blue, 1);
            cr.set_line_width (HAND_LINE_WIDTH);
            cr.move_to (CENTER, CENTER);
            cr.line_to (hand_x, hand_y);
            cr.stroke ();
            cr.set_source_rgba (accent_color.red, accent_color.green, accent_color.blue, 1);
            cr.arc (hand_x, hand_y, SELECTION_CIRCLE_RADIUS, 0, 2 * Math.PI);
            cr.fill ();
            
            // Draw minutes
            if (!selecting_hour) {
                for (int i = 0; i < MINUTES; i += 5) {
                    double minute_angle = (i - 15) * (2 * Math.PI) / MINUTES;
                    double minute_x = CENTER + OUTER_RADIUS * Math.cos (minute_angle);
                    double minute_y = CENTER + OUTER_RADIUS * Math.sin (minute_angle);
    
                    double selection_angle = get_minute_angle ();
                    if (selection_angle < -Math.PI / 2) {
                        selection_angle += 2 * Math.PI;
                    }
                    double label_angle = minute_angle;
                    if (label_angle < -Math.PI / 2) {
                        label_angle += 2 * Math.PI;
                    }
                    
                    bool is_selected = Math.fabs (selection_angle - label_angle) < Math.PI / MINUTES;

                    if (is_selected) {
                        cr.set_source_rgba ((0.32 * 1), (0.32 * 1), (0.32 * 1), 1);
                    } else {
                        cr.set_source_rgba ((0.15 * 1), (0.15 * 1), (0.15 * 1), 1);
                    }

                    cr.set_font_size (MINUTE_FONT_SIZE);
    
                    if (i >= 6) {
                        cr.move_to (minute_x - 18 / 2.0, minute_y + 16 / 2.0);
                    } else if (i == 1) {
                        cr.move_to (minute_x - 6 / 2.0, minute_y + 16 / 2.0);
                    } else {
                        cr.move_to (minute_x - 10 / 2.0, minute_y + 16 / 2.0);
                    }
                    cr.show_text (i.to_string ());
                }
            }
            
            // Draw hours
            if (selecting_hour) {
                int hour_count = is_military_mode ? FULL_DAY : HALF_DAY;

                for (int i = 1; i <= hour_count; i++) {
                    double hour_angle = ((i - 3) * Math.PI) / (HALF_DAY / 2);
                    double label_radius = (i > HALF_DAY && is_military_mode) ? INNER_RADIUS : OUTER_RADIUS;
                    double label_x = CENTER + label_radius * Math.cos (hour_angle);
                    double label_y = CENTER + label_radius * Math.sin (hour_angle);

                    double selection_angle = get_hour_angle ();
                    if (selection_angle < -Math.PI / 2) {
                        selection_angle += 2 * Math.PI;
                    }
                    double label_angle = hour_angle;
                    if (label_angle < -Math.PI / 2) {
                        label_angle += 2 * Math.PI;
                    }

                    bool is_selected = Math.fabs (selection_angle - label_angle) < Math.PI / HALF_DAY;
    
                    if (is_selected) {
                        cr.set_source_rgba ((0.32 * 1), (0.32 * 1), (0.32 * 1), 1);
                    } else {
                        cr.set_source_rgba ((0.15 * 1), (0.15 * 1), (0.15 * 1), 1);
                    }

                    if (i >= 10) {
                        cr.move_to (label_x - 18 / 2.0, label_y + 16 / 2.0);
                    } else if (i == 1) {
                        cr.move_to (label_x - 6 / 2.0, label_y + 16 / 2.0);
                    } else {
                        cr.move_to (label_x - 10 / 2.0, label_y + 16 / 2.0);
                    }

                    if (i <= HALF_DAY) {
                        cr.set_font_size (HOUR_FONT_SIZE);
                    } else {
                        cr.set_font_size (MINUTE_FONT_SIZE);
                    }

                    // If i is 1 to 12, display 1 to 12
                    // If i is 13 to 23, display 13 to 23
                    // If i is 24, display 0
                    cr.show_text ((i > HALF_DAY ? (i == 24 ? 0 : i) : i).to_string ());
                }
            }
        }

        private void emit_time_selected () {
            time_selected (selected_hour, selected_minute);
        }
        
        private void reset_to_hour_selection () {
            selecting_hour = true;
            queue_draw ();
        }

        private double get_hour_angle () {
            double hour = selected_hour % HALF_DAY;
            if (hour == 0) hour = HALF_DAY;
            double angle = (hour * (2 * Math.PI / HALF_DAY)) - Math.PI / 2;
            return angle;
        }
    
        private double get_minute_angle () {
            return (selected_minute % MINUTES) * (2 * Math.PI / MINUTES) - Math.PI / 2;
        }

        private double get_hand_radius (double base_radius) {
            if (selecting_hour && is_military_mode && selected_hour > HALF_DAY) {
                return INNER_RADIUS;
            } else {
                return OUTER_RADIUS;
            }
        }
    
        private void update_selection (double x, double y) {
            double dx = x - CENTER;
            double dy = y - CENTER;

            double distance = Math.sqrt (dx * dx + dy * dy);
            double angle = Math.atan2 (dy, dx) + Math.PI / 2;
            if (angle < 0) {
                angle += 2 * Math.PI;
            }

            if (selecting_hour) {
                int temp_hour = (int)Math.round ((angle * HALF_DAY / (2 * Math.PI)));
                if (temp_hour <= 0) temp_hour += HALF_DAY;
                if (is_military_mode) {
                    if (distance < INNER_RADIUS) {
                        temp_hour += HALF_DAY;
                    }
                }
                selected_hour = temp_hour;
            } else {
                selected_minute = (int)Math.round ((angle * MINUTES / (2 * Math.PI))) % MINUTES;
                if (selected_minute < 0) selected_minute += MINUTES;
            }

            last_angle = angle;

            queue_draw ();
        }

        private double get_angle_from_coords (double x, double y) {
            double angle = Math.atan2 (y - CENTER, x - CENTER);
            if (angle < -Math.PI / 2) {
                angle += 2 * Math.PI;
            }

            return angle;
        }
    }
}