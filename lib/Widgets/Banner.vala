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
 * A Banner is a widget that displays a message to the user and provides a way for the user to act on the message.
 */
public class He.Banner : He.Bin, Gtk.Buildable {
    private Gtk.Box main_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
    private Gtk.Box text_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);
    private Gtk.Box button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);

    private Gtk.Label title_label = new Gtk.Label (null);
    private Gtk.Label description_label = new Gtk.Label (null);

    private Style _style = Style.INFO;

    /**
     * The title of the banner
     */
    public string title {
        get { return title_label.get_text (); }
        set { title_label.set_text (value); }
    }

    /**
     * The description of the banner
     */
    public string description {
        get { return description_label.get_text (); }
        set { description_label.set_text (value); }
    }

    /**
     * The style of the banner
     */
    public Style style {
        get { return _style; }
        set { set_banner_style (value); }
    }

    /**
     * An enum representing the style of the banner.
     */
    public enum Style {
        INFO,
        WARNING,
        ERROR
    }

    /**
     * Add a child to the banner, should only be used in the context of a UI or Blueprint file. There should be no need to use this method in code.
     */
    public new void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
        if (strcmp (type, "action") == 0) {
            add_action_button ((Gtk.Widget) child);
        } else {
            main_box.append ((Gtk.Widget) child);
        }
    }

    /**
     * Add a button to the banner.
     * @param widget The button to add to the banner.
     */
    public void add_action_button (Gtk.Widget widget) {
        if (button_box.get_first_child () == null) {
            button_box.set_visible (true);
        }

        button_box.append (widget);
    }

    /**
     * Remove a button from the banner.
     * @param widget The button to remove.
     */
    public void remove_action (Gtk.Widget widget) {
        button_box.remove (widget);

        if (button_box.get_first_child () == null) {
            button_box.set_visible (false);
        }
    }

    /**
     * Set the banner style.
     * @param style The style to set the banner to.
     */
    public void set_banner_style (Style style) {
        this.remove_css_class ("info");
        this.remove_css_class ("warning");
        this.remove_css_class ("error");

        if (style == Style.INFO) {
            this.add_css_class ("info");
        } else if (style == Style.WARNING) {
            this.add_css_class ("warning");
        } else if (style == Style.ERROR) {
            this.add_css_class ("error");
        }

        this._style = style;
    }

    /**
     * Construct a new banner.
     * @param title The title of the banner.
     * @param description The description of the banner.
     *
     * @since 1.0
     */
    public Banner (string title, string description) {
        base ();
        this.title = title;
        this.description = description;
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BoxLayout));
    }

    construct {
        this.title_label.add_css_class ("header");
        this.title_label.xalign = 0;
        this.description_label.add_css_class ("body");
        this.description_label.xalign = 0;
        this.add_css_class ("banner");

        this.text_box.append (title_label);
        this.text_box.append (description_label);

        this.text_box.set_halign (Gtk.Align.START);
        this.text_box.set_margin_top (5);
        this.text_box.set_margin_bottom (5);
        this.button_box.set_halign (Gtk.Align.END);
        this.button_box.set_valign (Gtk.Align.END);
        this.button_box.set_vexpand (true);
        this.button_box.set_hexpand (true);

        button_box.set_visible (false);

        main_box.append (text_box);
        main_box.append (button_box);
        main_box.homogeneous = true;
        main_box.set_parent (this);

        this.set_valign (Gtk.Align.START);
        this.set_vexpand (false);
    }
}
