/*
* Copyright (c) 2023 Fyra Labs
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
* An Avatar is an element that displays an image that represents a person.
*/
public class He.Avatar : He.Bin {
    private string? _image;
    private int _size;
    private string? _text;

    private Gtk.Image img = new Gtk.Image ();
    private Gtk.Image img_blur = new Gtk.Image ();
    private Gtk.Label label = new Gtk.Label ("");

    /**
    * The size of the avatar.
    */
    public int size {
        get {
            return _size;
        }
        set {
            _size = value;
            this.set_size_request (value, value);
            img.pixel_size = value;
            img_blur.pixel_size = value;

            var css_provider_label = new Gtk.CssProvider ();
            css_provider_label.load_from_data ("""
                .avatar-label {
                    font-size: %0.2fpx;
                    font-weight: 700;
                    color: @accent_fg_color;
                }
            """.printf ((_size / 16) * 7.5).data); // calc the font size based on avatar size
            var context_label = label.get_style_context ();
            context_label.add_provider (css_provider_label, 69);
        }
    }

    /**
    * The text of the avatar.
    */
    public string? text {
        get {
            return _text;
        }
        set {
            _text = value;
            if (value != null) {
                label.label = extract_initials (value);
            }
        }
    }

    private string extract_initials (string t) {
        string ret = "";

        if (t.length == 0)
            return "";

        ret += t[0].to_string ().up ();

        for (int i = 1; i < t.length - 1; i++)
            if (t[i] == ' ')
                ret += t[i + 1].to_string ().up ();

        return ret;
    }

    /**
    * The image of the avatar.
    */
    public string? image {
        get {
            return _image;
        }
        set {
            _image = value;

            if (value != null) {
                label.visible = false;
            } else {
                label.visible = true;
            }

            var css_provider = new Gtk.CssProvider ();
            css_provider.load_from_data ("""
            .avatar {
                background-image: url('%s');
                background-size: cover;
                background-color: @accent_bg_color;
                border-radius: 999px;
                box-shadow: inset 0 0 0 1px @borders;
            }
            """.printf (_image).data);
            var context = img.get_style_context ();
            context.add_provider (css_provider, 69);

            var css_provider_blur = new Gtk.CssProvider ();
            if (_size <= 32) {
                css_provider_blur.load_from_data ("""
                .avatar-blur {
                    background-image: url('%s');
                    background-size: cover;
                    background-color: @accent_bg_color;
                    border-radius: 999px;
                    box-shadow: inset 0 0 0 1px @borders;
                    filter: drop-shadow(0px 0px 1px @borders);
                }
                """.printf (_image).data);
            } else {
                css_provider_blur.load_from_data ("""
                .avatar-blur {
                    background-image: url('%s');
                    background-size: cover;
                    background-color: @accent_bg_color;
                    border-radius: 999px;
                    box-shadow: inset 0 0 0 1px @borders;
                    filter: drop-shadow(0px 0px 1px @borders) blur(2px);
                }
                """.printf (_image).data);
            }
            var context_blur = img_blur.get_style_context ();
            context_blur.add_provider (css_provider_blur, 69);
        }
    }


    /**
    * Creates a new Avatar.
    * @param image The image to display
    *
    * @since 1.1
    */
    public Avatar (int size, string? image, string? text) {
        base ();

        this.image = image;
        this.text = text;
        this.size = size;
    }

    construct {
        img.add_css_class ("avatar");
        img.halign = Gtk.Align.CENTER;
        img.valign = Gtk.Align.CENTER;

        img_blur.add_css_class ("avatar-blur");
        img_blur.halign = Gtk.Align.CENTER;
        img_blur.valign = Gtk.Align.CENTER;

        label.halign = Gtk.Align.CENTER;
        label.valign = Gtk.Align.CENTER;
        label.add_css_class ("dim-label");
        label.add_css_class ("avatar-label");
        label.visible = false;

        var ioverlay = new Gtk.Overlay ();
        ioverlay.set_child (img_blur);
        ioverlay.add_overlay (img);

        var overlay = new Gtk.Overlay ();
        overlay.set_child (ioverlay);
        overlay.add_overlay (label);

        overlay.set_parent (this);
    }
}
