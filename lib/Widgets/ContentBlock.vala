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
 * A ContentBlock displays a single block of content, which contains an icon, text and optional buttons.
 */
public class He.ContentBlock : He.Bin, Gtk.Buildable {
    private Gtk.Label title_label = new Gtk.Label (null);
    private Gtk.Label subtitle_label = new Gtk.Label (null);
    private Gtk.Image image = new Gtk.Image ();
    private Gtk.Box info_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
    private Gtk.Box button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 18);
    private He.Button _secondary_button;
    private He.Button _primary_button;

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
     * Sets the icon of the content block, as a GLib.Icon.
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
     * Sets the secondary button of the content block.
     */
    public He.Button secondary_button {
        set {
            if (_secondary_button != null) {
                button_box.remove (_secondary_button);
            }

            value.add_css_class ("tint-button");
            value.add_css_class ("pill");
            _secondary_button = value;
            button_box.prepend (_secondary_button);
        }

        get {
            return _secondary_button;
        }
    }

    /**
     * Sets the primary button of the content block.
     */
    public He.Button primary_button {
        get {
            return _primary_button;
        }

        set {
            if (_primary_button != null) {
                button_box.remove (_primary_button);
            }

            _primary_button = value;
            button_box.append (_primary_button);
        }
    }

    /**
     * Constructs a new ContentBlock.
     * @param title The title of the content block.
     * @param subtitle The subtitle of the content block.
     * @param icon The icon of the content block.
     * @param primary_button The primary button of the content block.
     * @param secondary_button The secondary button of the content block.
     */
    public ContentBlock (
        string title,
        string subtitle,
        string icon,
        He.Button primary_button,
        He.Button secondary_button
    ) {
        base ();
        this.title = title;
        this.subtitle = subtitle;
        this.icon = icon;
        this.primary_button = primary_button;
        this.secondary_button = secondary_button;
    }

    /**
     * Add a child to the ContentBlock, should only be used in the context of a UI or Blueprint file. There should be no need to use this method in code.
     *
     * @since 1.0
     */
    public override void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
        button_box.append ((Gtk.Widget)child);
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BoxLayout));
    }

    construct {
        this.add_css_class ("content-block");

        image.pixel_size = ((Gtk.IconSize)48);
        image.halign = Gtk.Align.START;
        image.valign = Gtk.Align.CENTER;
        image.set_visible (false);

        title_label.xalign = 0;
        title_label.add_css_class ("cb-title");
        title_label.set_visible (false);

        subtitle_label.xalign = 0;
        subtitle_label.add_css_class ("cb-subtitle");
        subtitle_label.wrap = true;
        subtitle_label.hexpand = true;
        subtitle_label.ellipsize = Pango.EllipsizeMode.END;
        subtitle_label.set_visible (false);

        info_box.append (image);
        info_box.append (title_label);
        info_box.append (subtitle_label);

        button_box.halign = Gtk.Align.END;
        button_box.hexpand = true;

        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        box.append (info_box);
        box.append (button_box);
        box.set_parent (this);
    }
}
