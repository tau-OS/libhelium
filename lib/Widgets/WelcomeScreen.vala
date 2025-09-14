/*
 * Copyright (c) 2022-2025 Fyra Labs
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

/*
 * A WelcomeRow is a single row in a WelcomeScreen, consisting of an icon, title, subtitle, and accent color.
 */
public class WelcomeRow : Gtk.Box {
    private Gtk.Image icon;
    private Gtk.Label title_lbl;
    private Gtk.Label subtitle_lbl;

    /*
     * Sets the icon by name. Use symbolic icons.
     */
    private string _icon_name;
    public string icon_name {
        get { return _icon_name; }
        set { _icon_name = value; icon.set_from_icon_name (_icon_name); }
    }

    /*
     * Sets the icon color.
     */
    private He.Colors _color = He.Colors.PURPLE;
    private string applied_class = "";
    public He.Colors color {
        get { return _color; }
        set {
            if (applied_class != "")icon.remove_css_class (applied_class);
            _color = value;
            applied_class = map_color_class (_color);
            if (applied_class != "")icon.add_css_class (applied_class);
        }
    }

    /*
     * Sets the title text (bold).
     */
    private string _title;
    public string title {
        get { return _title; }
        set { _title = value; title_lbl.set_markup ("<b>%s</b>".printf (_title)); }
    }

    /*
     * Sets the subtitle text (dim).
     */
    private string _subtitle;
    public string subtitle {
        get { return _subtitle; }
        set { _subtitle = value; subtitle_lbl.label = _subtitle; }
    }

    public WelcomeRow (string icon_name, string title_text, string subtitle_text, He.Colors accent) {
        Object (orientation: Gtk.Orientation.HORIZONTAL, spacing: 12);

        icon = new Gtk.Image.from_icon_name (icon_name);
        icon.set_pixel_size (32);

        var labels = new Gtk.Box (Gtk.Orientation.VERTICAL, 4);
        title_lbl = new Gtk.Label (null);
        title_lbl.set_use_markup (true);
        title_lbl.set_xalign (0.0f);
        subtitle_lbl = new Gtk.Label ("");
        subtitle_lbl.set_xalign (0.0f);
        subtitle_lbl.add_css_class ("dim-label");
        labels.append (title_lbl);
        labels.append (subtitle_lbl);

        append (icon);
        append (labels);

        this.icon_name = icon_name;
        this.title = title_text;
        this.subtitle = subtitle_text;
        this.color = accent; // adds the CSS class mapped below
    }

    private static string map_color_class (He.Colors c) {
        switch (c) {
        case He.Colors.RED:     return "accent-red";
        case He.Colors.ORANGE:  return "accent-orange";
        case He.Colors.YELLOW:  return "accent-yellow";
        case He.Colors.GREEN:   return "accent-green";
        case He.Colors.INDIGO:  return "accent-indigo";
        case He.Colors.BLUE:    return "accent-blue";
        case He.Colors.PURPLE:  return "accent-purple";
        case He.Colors.PINK:    return "accent-pink";
        case He.Colors.MINT:    return "accent-mint";
        case He.Colors.BROWN:   return "accent-brown";
        default:                         return "";
        }
    }
}

/**
 * A WelcomeScreen is a screen that presents options and actions before displaying the main application.
 */
public class WelcomeScreen : He.Window {
    private Gtk.Box main_box;
    private Gtk.Box rows_box;
    private He.Button start_btn;
    private Gtk.Label heading;

    /*
     * Sets the app's name in the heading.
     */
    private string _app_name = "Welcome To App Name!";
    public string app_name {
        get { return _app_name; }
        set {
            _app_name = value;
            heading.set_label ("Welcome To %s".printf (_app_name));
        }
    }

    public WelcomeScreen (Gtk.Window parent) {
        this.parent = parent;
        add_css_class ("welcome-card");

        main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 24);
        main_box.margin_top = 24;
        main_box.margin_bottom = 24;
        main_box.margin_start = 24;
        main_box.margin_end = 24;

        heading = new Gtk.Label (null);
        heading.add_css_class ("view-title");

        rows_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);

        start_btn = new He.Button ("", "Start");
        start_btn.is_pill = true;
        start_btn.set_halign (Gtk.Align.CENTER);
        start_btn.clicked.connect (() => close ());

        main_box.append (heading);
        main_box.append (rows_box);
        main_box.append (start_btn);
        child = main_box;

        app_name = _app_name;
    }

    /*
     * Adds a row to the welcome screen.
     */
    public void add_row (WelcomeRow row) { rows_box.append (row); }
}
