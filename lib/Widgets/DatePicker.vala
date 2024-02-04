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

    /**
     *  Creates this widget with a predetermined date format.
     */
    public DatePicker.with_format (string format) {
        Object (format: format);
    }

    construct {
        if (format == null)
            format = "%x";

        var calendar = new Gtk.Calendar ();

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

        editable = false;
        primary_icon_gicon = new ThemedIcon.with_default_fallbacks ("office-calendar-symbolic");
        secondary_icon_gicon = new ThemedIcon.with_default_fallbacks ("pan-down-symbolic");

        icon_release.connect (() => {
            popover.popup ();
        });

        calendar.day_selected.connect (() => {
            date = new GLib.DateTime.local (calendar.year, calendar.month + 1, calendar.day, 0, 0, 0);
        });

        notify["date"].connect (() => {
            text = _date.format (format);
            calendar.select_day (date);
        });

        this.add_css_class ("text-field");
    }
}
