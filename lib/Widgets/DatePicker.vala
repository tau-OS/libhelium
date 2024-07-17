/*
 * Copyright (c) 2022-2023 Fyra Labs
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
public class He.DatePicker : Gtk.Entry {
    /**
     *  The string format of how to display the date.
     */
    public string format { get; construct; }
    /**
     *  The date to be used.
     */
    public GLib.DateTime date { get; set; }

    private CalendarWidget calendar;

    /**
     *  Creates this widget with a predetermined date format.
     */
    public DatePicker.with_format (string format) {
        Object (format: format);
    }

    construct {
        if (format == null)
            format = "%x";

        calendar = new CalendarWidget ();

        var popover = new Gtk.Popover () {
            halign = Gtk.Align.END,
            autohide = true,
            child = calendar,
            has_arrow = false,
            position = Gtk.PositionType.BOTTOM
        };
        popover.set_parent (this);
        popover.has_arrow = false;

        date = new GLib.DateTime.now_local ();

        calendar.day = date.get_day_of_month ();
        calendar.month = date.get_month () - 1; // 0-indexed
        calendar.year = date.get_year ();

        editable = false;
        primary_icon_gicon = new ThemedIcon.with_default_fallbacks ("office-calendar-symbolic");
        secondary_icon_gicon = new ThemedIcon.with_default_fallbacks ("pan-down-symbolic");

        icon_release.connect (() => {
            popover.popup ();
        });

        calendar.day_selected.connect ((day, month, year) => {
            date = new GLib.DateTime.local (year, month + 1, day, 0, 0, 0);
        });

        text = _date.format (format);
        notify["date"].connect (() => {
            text = _date.format (format);
            calendar.select_day (date);
        });

        this.add_css_class ("text-field");
    }
}

private class He.CalendarWidget : He.Bin {
    private Gtk.Grid calendar_grid;
    private He.TextButton header_label;
    private He.DisclosureButton left_arrow;
    private He.DisclosureButton right_arrow;
    private bool showing_days;

    public int day { get; set; }
    public int month { get; set; }
    public int year { get; set; }

    private string[] month_names = {_("January"), _("February"), _("March"), _("April"), _("May"), _("June"), _("July"), _("August"), _("September"), _("October"), _("November"), _("December")};
    private int[] days_in_month = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};

    construct {
        var date = new GLib.DateTime.now_local ();
        day = date.get_day_of_month ();
        month = date.get_month () - 1; // 0-indexed
        year = date.get_year ();

        Gtk.Box main_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 6) {
            margin_bottom = margin_top = 18
        };

        // Header with month name and arrows
        Gtk.Box header_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 6);

        header_label = new He.TextButton (month_names[month] + " " + year.to_string()) {
            halign = Gtk.Align.START,
            valign = Gtk.Align.CENTER,
            hexpand = true,
            margin_start = 18,
            tooltip_text = _("Select Month")
        };
        ((Gtk.Label)header_label.get_first_child()).set_width_chars (14);
        ((Gtk.Label)header_label.get_first_child()).add_css_class("cb-title");
        header_label.add_css_class("flat");
        header_label.clicked.connect(() => toggle_view());

        left_arrow = new He.DisclosureButton ("go-previous-symbolic") {
            halign = Gtk.Align.END,
            tooltip_text = _("Previous Month")
        };
        left_arrow.clicked.connect(() => change_month(-1));

        right_arrow = new He.DisclosureButton ("go-next-symbolic") {
            halign = Gtk.Align.END,
            margin_end = 18,
            tooltip_text = _("Next Month")
        };
        right_arrow.clicked.connect(() => change_month(1));

        header_box.append(header_label);
        header_box.append(left_arrow);
        header_box.append(right_arrow);
        main_box.append(header_box);

        var divider = new He.Divider ();
        main_box.append(divider);

        // Calendar grid
        calendar_grid = new Gtk.Grid () {
            row_homogeneous = true,
            column_homogeneous = true,
            width_request = 150,
            height_request = 240,
            margin_start = 18,
            margin_end = 18
        };
        main_box.append(calendar_grid);

        showing_days = true;
        update_calendar_grid();
        this.child = (main_box);
    }

    private void toggle_view() {
        showing_days = !showing_days;
        update_calendar_grid();
    }

    private void change_month(int delta) {
        month += delta;
        if (month < 0) {
            month = 11;
            year--;
        } else if (month > 11) {
            month = 0;
            year++;
        }
        header_label.set_label (month_names[month] + " " + year.to_string());
        update_calendar_grid();
    }

    private void update_calendar_grid() {
        do {
            calendar_grid.remove(calendar_grid.get_last_child());
        } while (calendar_grid.get_last_child() != null);

        if (showing_days) {
            int days = days_in_month[month];
            if (_month == 1 && is_leap_year(year)) {
                days = 29;
            }

            make_weekday_labels ();

            for (int i = 0; i < 6; i++) {
                for (int j = 0; j < 7; j++) {
                    int day = i * 7 + j + 1;
                    if (day > days) break;

                    var day_label = new He.TextButton (day.to_string()) {
                        halign = Gtk.Align.CENTER,
                        valign = Gtk.Align.CENTER,
                    };
                    day_label.add_css_class("numeric");
                    day_label.add_css_class("circular");
                    day_label.clicked.connect(() => day_selected (int.parse(day_label.get_label()), month, year));

                    if (day_label.get_label() == day.to_string()) {
                        day_label.add_css_class("surface-container-highest-bg-color");
                        day_label.remove_css_class("flat");
                    } else {
                        day_label.remove_css_class("surface-container-highest-bg-color");
                        day_label.add_css_class("flat");
                    }

                    calendar_grid.attach(day_label, j, i + 1, 1, 1);
                }
            }
        } else {
            for (int i = 0; i < 3; i++) {
                for (int j = 0; j < 4; j++) {
                    int month_index = i * 4 + j;

                    var month_label = new He.TextButton (month_names[month_index].substring(0, 3)) {
                        halign = Gtk.Align.CENTER,
                        valign = Gtk.Align.CENTER,
                        hexpand = true,
                        width_request = 42,
                        height_request = 42
                    };
                    month_label.add_css_class("cb-subtitle");
                    month_label.add_css_class("flat");
                    month_label.add_css_class("circular");
                    month_label.clicked.connect(() => select_month(month_index));

                    calendar_grid.attach(month_label, j, i, 1, 1);
                }
            }
        }
    }

    private void make_weekday_labels () {
        for (int i = 0; i < 7; i++) {
            var label = new Gtk.Label (get_day_of_week_string (i));
            label.set_halign (Gtk.Align.START);
            label.set_size_request (-1, 20);
            label.add_css_class ("caption");
            label.add_css_class ("numeric");
            label.add_css_class ("dim-label");
            label.set_width_chars (5); // Prevent layout jumping
            calendar_grid.attach (label, (i % 7), 0, 1, 1);
        }
    }
    public string get_day_of_week_string (int day_index) {
        // Returns the short name of the day of the week (e.g., "Sun", "Mon", etc.)
        DateTime sample = new DateTime (new DateTime.now_local ().get_timezone (), 2022, 6, 6, 0, 0, 0);  // A Monday as reference
        DateTime day_date = sample.add_days (day_index);
        return day_date.format ("%a");
    }

    public void select_day (DateTime date) {
        day = date.get_day_of_month ();
        update_calendar_grid();
    }

    private void select_month(int month_index) {
        month = month_index;
        showing_days = true;
        header_label.set_label (month_names[month] + " " + year.to_string());
        update_calendar_grid();
    }

    private bool is_leap_year(int year) {
        return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
    }

    public signal void day_selected (int day, int month, int year);
}
