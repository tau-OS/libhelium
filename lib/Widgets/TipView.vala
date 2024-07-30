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
 * A TipView is a helper widget for onboarding flow tips in an app's first launch.
 */
public class He.TipView : He.Bin {
    private Gtk.Image image = new Gtk.Image ();
    private Gtk.Label title = new Gtk.Label ("");
    private Gtk.Label message = new Gtk.Label ("");

    /**
     * Emitted when the Tip is closed by activating the close button.
     */
    public signal void closed ();

    /**
     * The action button of the Tip.
     */
    public He.Button button = new He.Button (null, "");

    /**
     * The style of the Tip.
     */
    private He.TipViewStyle _tip_style;
    public He.TipViewStyle tip_style {
        get {
            return _tip_style;
        }
        set {
            if (_tip_style != He.TipViewStyle.NONE)this.remove_css_class (_tip_style.to_css_class ());
            if (value != He.TipViewStyle.NONE)this.add_css_class (value.to_css_class ());

            _tip_style = value;
        }
    }

    /**
     * The Tip itself. Contains image, title, message.
     */
    private He.Tip _tip;
    public He.Tip tip {
        get {
            return _tip;
        }
        set {
            title.set_label (value.title != null ? value.title : "Title");
            image.set_from_icon_name (value.image != null ? value.image : "info-symbolic");
            message.set_label (value.message != null ? value.message : "Message here.");
            button.set_label (value.action_label != null ? value.action_label : "Learn More…");

            if (value.action_label == null) {
                button.visible = false;
            } else {
                button.visible = true;
            }

            _tip = value;
        }
    }

    /**
     * Creates a TipView.
     * @param tip The Tip to use.
     * @param tip_style The TipViewStyle to use.
     */
    public TipView (He.Tip tip, He.TipViewStyle? tip_style) {
        this.tip_style = tip_style;
        this.tip = tip;
    }

    ~TipView () {
        this.dispose ();
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BoxLayout));
    }

    construct {
        var main_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12) {
            hexpand = true
        };
        var body_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);
        var label_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6) {
            hexpand = true
        };

        var close_button = new He.Button ("window-close-symbolic", null);
        close_button.is_disclosure = true;
        close_button.set_valign (Gtk.Align.START);
        close_button.clicked.connect (() => {
            this.visible = false;
            closed ();
        });

        image.set_valign (Gtk.Align.START);
        image.set_pixel_size (24);

        title.add_css_class ("caption");
        title.set_halign (Gtk.Align.START);

        message.set_halign (Gtk.Align.START);
        message.set_width_chars (20);
        message.set_ellipsize (Pango.EllipsizeMode.END);
        message.set_lines (2);
        message.set_margin_top (12);
        message.set_margin_bottom (12);

        label_box.append (title);
        label_box.append (message);
        body_box.append (label_box);

        button.visible = false;
        button.is_textual = true;

        body_box.append (button);

        main_box.append (image);
        main_box.append (body_box);
        main_box.append (close_button);

        this.child = main_box;
    }
}