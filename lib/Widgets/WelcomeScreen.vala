/*
* Copyright (c) 2022 Fyra Labs
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/

/**
* A WelcomeScreen is a screen that presents options and actions before displaying the main application.
*/
public class He.WelcomeScreen : He.Bin {
    private Gtk.Box action_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
    private Gtk.Box button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
    private Gtk.Label description_label = new Gtk.Label ("");
    private Gtk.Label appname_label = new Gtk.Label ("");
    private Gtk.Box main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);

    private string _appname;
    /**
    * The name of the application.
    */
    public string appname {
        get { return _appname; }
        set {
            _appname = value;
            if (appname_label != null)
                appname_label.label = "Welcome to " + value;
        }
    }

    private string _description;
    /**
    * The application description.
    */
    public string description {
        get { return _description; }
        set {
            _description = value;
            if (description_label != null)
                description_label.label = value;
        }
    }

    /**
    * Add a child to the welcome screen, should only be used in the context of a UI or Blueprint file. There should be no need to use this method in code.
    */
    public new void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
        if (type == "action") {
            ((Gtk.Button) child).set_label (((Gtk.Button) child).get_label () + " →");
            action_box.append ((Gtk.Widget) child);
        } else if (type == "action-button") {
            (Gtk.Widget) child.valign = Gtk.Align.CENTER;
            button_box.append ((Gtk.Widget) child);
        }
    }

    /**
    * Construct a new WelcomeScreen.
    * @param appname The name of the application.
    * @param description The application description.
    *
     * @since 1.0
     */
    public WelcomeScreen (string appname, string description) {
        base ();
        this.appname = appname;
        this.description = description;
    }

    ~WelcomeScreen () {
        this.main_box.unparent ();
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BoxLayout));
    }

    construct {
        main_box.add_css_class ("content-block");
        main_box.hexpand = true;

        action_box.valign = Gtk.Align.START;
        action_box.halign = Gtk.Align.START;

        button_box.valign = Gtk.Align.END;
        button_box.halign = Gtk.Align.END;
        button_box.margin_bottom = button_box.margin_end = 18;

        appname_label.xalign = 0;
        appname_label.valign = Gtk.Align.START;
        appname_label.margin_bottom = appname_label.margin_top = 12;
        appname_label.add_css_class ("view-title");

        description_label.xalign = 0;
        description_label.valign = Gtk.Align.START;
        description_label.vexpand = true;
        description_label.margin_bottom = description_label.margin_top = 12;

        main_box.append (appname_label);
        main_box.append (action_box);
        main_box.append (description_label);
        main_box.append (button_box);

        main_box.set_parent (this);
        this.set_size_request (360, 400);
        this.margin_top = this.margin_bottom = 6;
        this.margin_start = this.margin_end = 12;
    }
}
