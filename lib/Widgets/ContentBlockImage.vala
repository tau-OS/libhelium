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
 * A ContentBlockImage component is used to render an image inside a ContentBlock.
 */
public class He.ContentBlockImage : He.Bin, Gtk.Buildable {
    private string _file;
    private int _requested_height;
    private int _requested_width;

    /**
     * The file path of the image.
     */
    public string file {
        get {
            return _file;
        }
        set {
            _file = value;

            var css_provider = new Gtk.CssProvider ();
            css_provider.load_from_data (".content-block-image { background-image: url('%s'); background-size: cover; }".printf (_file).data);
            var context = this.get_style_context ();
            context.add_provider (css_provider, 69);
        }
    }

    /**
     * The height of the image.
     */
    public int requested_height {
        get {
            return _requested_height;
        }
        set {
            _requested_height = value;
            this.set_size_request (this.requested_width == 0 ? -1 : this.requested_width, value);
        }
    }

    /**
     * The width of the image.
     *
     * @since 1.0
     */
    public int requested_width {
        get {
            return _requested_width;
        }
        set {
            _requested_width = value;
            this.set_size_request (value, this.requested_height == 0 ? -1 : this.requested_height);
        }
    }

    construct {
        this.requested_width = -1;
        this.requested_height = 300;
        this.add_css_class ("content-block-image");
    }

    public ContentBlockImage (string file) {
        base ();
        this.file = file;
    }
}
