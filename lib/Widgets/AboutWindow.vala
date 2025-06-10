/*
 * Copyright (c) 2022 Fyra Labs
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
 * An AboutWindow is a window that displays information about the application.
 */
public class He.AboutWindow : He.Window {
    private Gtk.Overlay window_overlay = new Gtk.Overlay ();

    private Gtk.Box about_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 30);
    private Gtk.Box content_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 18);
    private Gtk.Box button_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 18);
    private Gtk.Box info_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);
    private Gtk.Box title_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 18);
    private Gtk.Box text_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
    private Gtk.Box developers_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
    private Gtk.Box translators_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);

    private Gtk.Label title_label = new Gtk.Label (null);
    private Gtk.Label license_label = new Gtk.Label (null);

    private Gtk.Image icon_image = new Gtk.Image ();

    private Gtk.ScrolledWindow developers_box_scroller = new Gtk.ScrolledWindow ();
    private Gtk.ScrolledWindow translators_box_scroller = new Gtk.ScrolledWindow ();

    private He.Button translate_app_button = new He.Button (null, _("Translate App"));
    private He.Button report_button = new He.Button (null, _("Report a Problem"));
    private He.Button more_info_button = new He.Button (null, _("More Info…"));

    private He.ModifierBadge version_badge = new He.ModifierBadge ("");

    /**
     * An enum of commonly used licenses to be used in AboutWindow.
     */
    public enum Licenses {
        GPLV3,
        MIT,
        MPLV2,
        UNLICENSE,
        APACHEV2,
        WTFPL,
        PROPRIETARY;

        /**
         * Returns the license url for the license.
         */
        public string get_url () {
            switch (this) {
            case Licenses.GPLV3:
                return "https://choosealicense.com/licenses/gpl-3.0";
            case Licenses.MIT:
                return "https://choosealicense.com/licenses/mit";
            case Licenses.MPLV2:
                return "https://choosealicense.com/licenses/mpl-2.0";
            case Licenses.UNLICENSE:
                return "https://choosealicense.com/licenses/unlicense";
            case Licenses.APACHEV2:
                return "https://choosealicense.com/licenses/apache-2.0";
            case Licenses.WTFPL:
                return "https://choosealicense.com/licenses/wtfpl";
            case Licenses.PROPRIETARY:
                return "https://choosealicense.com/no-permission";
            default:
                return "about:blank";
            }
        }

        /**
         * Returns the license name for the license.
         */
        public string get_name () {
            switch (this) {
            case Licenses.GPLV3:
                return "GPLv3";
            case Licenses.MIT:
                return "MIT";
            case Licenses.MPLV2:
                return "MPLv2";
            case Licenses.UNLICENSE:
                return "Unlicense";
            case Licenses.APACHEV2:
                return "Apache License v2";
            case Licenses.WTFPL:
                return "WTFPL";
            case Licenses.PROPRIETARY:
                return "a proprietary license";
            default:
                return "N/A";
            }
        }
    }

    private He.Colors _color = Colors.PURPLE;

    /**
     * The theme color of the AboutWindow.
     */
    public He.Colors color {
        get {
            return _color;
        }
        set {
            _color = value;
            translate_app_button.custom_color = value;
            report_button.custom_color = value;
            more_info_button.custom_color = value;
            version_badge.color = value;
        }
    }


    private Licenses _license = Licenses.GPLV3;
    /**
     * The license shown in the AboutWindow.
     */
    public Licenses license {
        get { return _license; }
        set {
            _license = value;
            license_label.set_markup (_("This program is licensed under %s").printf ("<a href=\"%s\">%s</a>").printf (value.get_url (), value.get_name ()));
        }
    }

    /**
     * The version shown in the AboutWindow.
     */
    public string version {
        get { return version_badge.label; }
        set { version_badge.label = value; }
    }

    /**
     * The name of the application shown in the AboutWindow.
     */
    public string app_name {
        get { return title_label.get_text (); }
        set { title_label.set_text (value); }
    }

    /**
     *  The icon shown in the AboutWindow.
     */
    public string icon {
        get { return icon_image.get_icon_name (); }
        set { icon_image.set_from_icon_name (value); }
    }

    private string[] translators = {};
    /**
     * The translators shown in the AboutWindow.
     */
    public string[] translator_names {
        get { return translators; }
        set {
            translators = value;

            var first_child = translators_box.get_first_child ();
            while (first_child != null) {
                translators_box.remove (first_child);
                first_child = translators_box.get_first_child ();
            }

            for (int i = 0; i < translators.length; i++) {
                var translator_label = new Gtk.Label ("");
                translator_label.xalign = 0;
                translator_label.set_text (i < translators.length - 1 ? "%s".printf (translators[i]) : translators[i]);
                translator_label.visible = true;
                translators_box.append (translator_label);
                translators_box.visible = true;
            }

            if (translators_box.visible == false) {
                translators_box_scroller.visible = false;
            } else {
                translators_box_scroller.visible = true;
            }
        }
    }

    private void update_copyright (int year, string[] developers) {
        // Clear existing children in developers_box
        var first_child = developers_box.get_first_child ();
        while (first_child != null) {
            developers_box.remove (first_child);
            first_child = developers_box.get_first_child ();
        }

        // Add labels for each developer
        for (int i = 0; i < developers.length; i++) {
            var developer_label = new Gtk.Label ("");
            developer_label.xalign = 0;
            if (i == 0) {
                developer_label.set_text (year > 0
                    ? _("Copyright © %i %s").printf (year, developers[i])
                    : _("Copyright © %s").printf (developers[i]));
            } else {
                developer_label.set_text (developers[i]);
            }
            developer_label.visible = true;
            developers_box.append (developer_label);
            developers_box.visible = true;
        }

        if (developers_box.visible == false) {
            developers_box_scroller.visible = false;
        } else {
            developers_box_scroller.visible = true;
        }
    }

    private string[] developers = {};
    /**
     * The developers shown in the AboutWindow.
     */
    public string[] developer_names {
        get { return developers; }
        set {
            developers = value;
            update_copyright (copyright_year, value);
        }
    }

    private int _copyright_year;
    /**
     * The copyright year shown in the AboutWindow.
     */
    public int copyright_year {
        get { return _copyright_year; }
        set {
            _copyright_year = value;
            update_copyright (value, developers);
        }
    }

    private string? _translate_url;
    private string? _issue_url;
    private string? _more_info_url;

    /**
     * Your application's reverse-domain name.
     */
    public string app_id { get; set; default = ""; }
    /**
     * A URL where contributors can help translate the application.
     */
    public string? translate_url {
        get { return _translate_url; }
        set {
            _translate_url = value;
            if (value != null) {
                translate_app_button.visible = true;
            } else {
                translate_app_button.visible = false;
            }
        }
    }
    /**
     * A URL where users can report a problem with the application.
     */
    public string? issue_url {
        get { return _issue_url; }
        set {
            _issue_url = value;
            if (value != null) {
                report_button.visible = true;
            } else {
                report_button.visible = false;
            }
        }
    }
    /**
     * A URL where users can get more information about the application.
     */
    public string? more_info_url {
        get { return _more_info_url; }
        set {
            _more_info_url = value;
            if (value != null) {
                more_info_button.visible = true;
            } else {
                more_info_button.visible = false;
            }
        }
    }

    construct {
        this.modal = true;
        this.resizable = false;

        var close_button = new He.Button ("window-close-symbolic", "");
        close_button.is_disclosure = true;
        close_button.halign = Gtk.Align.END;
        close_button.valign = Gtk.Align.START;
        close_button.margin_top = 24;
        close_button.margin_end = 24;
        close_button.set_tooltip_text (_("Close"));

        window_overlay.add_overlay (close_button);
        window_overlay.set_child (about_box);

        about_box.add_css_class ("dialog-content");
        about_box.append (content_box);
        about_box.append (button_box);

        icon_image.valign = Gtk.Align.START;
        icon_image.pixel_size = 128;
        icon_image.margin_top = 24;
        icon_image.add_css_class ("icon-dropshadow");

        content_box.append (icon_image);
        content_box.append (info_box);

        info_box.append (title_box);
        info_box.append (text_box);

        version_badge.tinted = true;
        version_badge.margin_end = 24;
        title_label.add_css_class ("display");
        title_box.append (title_label);
        title_box.append (version_badge);

        developers_box.visible = false;
        developers_box.valign = Gtk.Align.START;
        developers_box.vexpand_set = true;
        developers_box_scroller.set_child (developers_box);
        developers_box_scroller.hscrollbar_policy = Gtk.PolicyType.NEVER;
        text_box.append (developers_box_scroller);

        translators_box.visible = false;
        translators_box.valign = Gtk.Align.START;
        translators_box.vexpand_set = true;
        translators_box_scroller.set_child (translators_box);
        translators_box_scroller.hscrollbar_policy = Gtk.PolicyType.NEVER;
        text_box.append (translators_box_scroller);

        license_label.xalign = 0;
        license_label.visible = true;
        text_box.append (license_label);

        translate_app_button.is_textual = true;
        report_button.is_tint = true;
        more_info_button.is_fill = true;

        button_box.valign = Gtk.Align.CENTER;
        button_box.homogeneous = true;
        button_box.append (translate_app_button);
        button_box.append (report_button);
        button_box.append (more_info_button);

        var uri_launcher = new Gtk.UriLauncher ("");

        translate_app_button.clicked.connect (() => {
            uri_launcher.set_uri (translate_url);
            uri_launcher.launch.begin (this.parent, null);
        });

        report_button.clicked.connect (() => {
            uri_launcher.set_uri (issue_url);
            uri_launcher.launch.begin (this.parent, null);
        });

        more_info_button.clicked.connect (() => {
            uri_launcher.set_uri (more_info_url);
            uri_launcher.launch.begin (this.parent, null);
        });

        close_button.clicked.connect (close);

        var window_handle = new Gtk.WindowHandle ();
        window_handle.set_child (window_overlay);

        this.set_child (window_handle);
        this.add_css_class ("dialog-content");
    }

    /**
     * Creates a new AboutWindow.
     * @param parent The parent window.
     * @param app_name Your application's name.
     * @param app_id Your application's reverse-domain name.
     * @param version Your application's version.
     * @param icon Your application's icon.
     * @param translate_url A URL where contributors can help translate the application.
     * @param issue_url A URL where users can report a problem with the application.
     * @param more_info_url A URL where users can get more information about the application.
     * @param translators Your application's translators.
     * @param developers Your application's developers.
     * @param copyright_year Your application's copyright year.
     * @param license Your application's license.
     * @param color The color of the AboutWindow.
     *
     * @since 1.0
     */
    public AboutWindow (Gtk.Window parent,
        string app_name,
        string app_id,
        string? version,
        string? icon,
        string? translate_url,
        string? issue_url,
        string? more_info_url,
        string[]? translators,
        string[]? developers,
        int copyright_year,
        Licenses license,
        He.Colors color) {
        this.parent = parent;
        this.app_name = app_name;
        this.app_id = app_id;
        this.version = version;
        this.icon = icon;
        this.translate_url = translate_url;
        this.issue_url = issue_url;
        this.more_info_url = more_info_url;
        this.translator_names = translators;
        this.developer_names = developers;
        this.copyright_year = copyright_year != 0 ? copyright_year : 69; // Haha.
        this.license = license;
        this.color = color;
    }
}