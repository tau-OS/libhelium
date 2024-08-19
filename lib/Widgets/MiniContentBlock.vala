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
 * A MiniContentBlock is a content block that is used to display content in a small area.
 */
public class He.MiniContentBlock : He.Bin, Gtk.Buildable {
    private Gtk.Label title_label = new Gtk.Label (null);
    private Gtk.Label subtitle_label = new Gtk.Label (null);
    private Gtk.Box info_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
    private Gtk.Image image = new Gtk.Image ();
    private He.Button _primary_button;
    private Gtk.Box btn_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);

    /**
     * Sets the widget of the content block.
     */
    private Gtk.Widget? _widget;
    public Gtk.Widget? widget {
        get {
            return _widget;
        }
        set {
            if (value == _widget) { return; }
            _widget = value;

            value.set_parent (btn_box);
        }
    }

    /**
     * Sets the title of the content block.
     */
    public string title {
        get {
            return title_label.get_text ();
        }
        set {
            if (value != null) {
                title_label.set_visible (true);
                title_label.set_text (value);
            } else {
                title_label.set_visible (false);
            }
        }
    }

    /**
     * Sets the subtitle of the content block.
     */
    public string subtitle {
        get {
            return subtitle_label.get_text ();
        }
        set {
            if (value != null) {
                subtitle_label.set_visible (true);
                subtitle_label.set_text (value);
            } else {
                subtitle_label.set_visible (false);
            }
        }
    }

    /**
     * Sets the icon of the content block.
     */
    public string icon {
        get {
            return image.get_icon_name ();
        }

        set {
            if (value == null) {
                image.set_visible (false);
            } else {
                image.set_visible (true);
                image.set_from_icon_name (value);
            }
        }
    }

    /**
     * Sets the icon of the content block as a GLib.Icon.
     */
    public GLib.Icon gicon {
        set {
            if (value == null) {
                image.set_visible (false);
            } else {
                image.set_visible (true);
                image.set_from_gicon (value);
            }
        }
    }

    /**
     * Sets the icon of the content block as a Gdk.Paintable.
     */
    public Gdk.Paintable paintable {
        set {
            if (value == null) {
                image.set_visible (false);
            } else {
                image.set_visible (true);
                image.set_from_paintable (value);
            }
        }
    }

    /**
     * The primary button of the content block.
     */
    public He.Button primary_button {
        get {
            return _primary_button;
        }

        set {
            if (_primary_button != null) {
                btn_box.remove (_primary_button);
            }

            value.hexpand = true;
            value.halign = Gtk.Align.END;
            value.is_fill = true;
            _primary_button = value;
            btn_box.append (_primary_button);
        }
    }

    /**
     * Constructs a new MiniContentBlock.
     * @param t The title of the content block.
     * @param s The subtitle of the content block.
     * @param pb The primary button of the content block.
     * @param w The widget of the content block.
     */
    public MiniContentBlock.with_details (string? t, string? s, He.Button ? pb, Gtk.Widget ? w) {
        base ();
        title = t;
        subtitle = s;
        primary_button = pb;
        widget = w;
    }

    /**
     * Add a child to the ContentBlock, should only be used in the context of a UI or Blueprint file. There should be no need to use this method in code.
     */
    public override void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
        btn_box.append ((Gtk.Widget) child);
    }

    /**
     * Constructs a new MiniContentBlock.
     *
     * @since 1.0
     */
    public MiniContentBlock () {
        base ();
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BoxLayout));
    }

    construct {
        image.pixel_size = ((Gtk.IconSize) 24);
        image.set_valign (Gtk.Align.CENTER);
        image.set_halign (Gtk.Align.START);
        image.set_visible (false);

        title_label.xalign = 0;
        title_label.add_css_class ("cb-title");
        title_label.set_visible (false);

        subtitle_label.xalign = 0;
        subtitle_label.add_css_class ("cb-subtitle");
        subtitle_label.wrap = true;
        subtitle_label.ellipsize = Pango.EllipsizeMode.END;
        subtitle_label.set_visible (false);

        info_box.hexpand = true;
        info_box.valign = Gtk.Align.CENTER;
        info_box.append (title_label);
        info_box.append (subtitle_label);

        btn_box.hexpand = true;
        btn_box.valign = Gtk.Align.CENTER;

        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
        box.hexpand = true;
        box.append (image);
        box.append (info_box);
        box.append (btn_box);

        box.set_parent (this);

        add_css_class ("mini-content-block");
    }
}