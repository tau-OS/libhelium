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
 * A ContentBlockImage component is used to render an image inside a ContentBlock.
 */
public class He.ContentBlockImage : He.Bin, Gtk.Buildable {
    private string _file;
    private int _requested_height;
    private int _requested_width;
    private Gdk.Texture paintable;

    /**
     * The file path of the image.
     */
    public string file {
        get {
            return _file;
        }
        set {
            _file = value;

            try {
                if (_file.contains ("file://")) {
                    paintable = Gdk.Texture.from_filename (_file.replace ("file://", ""));
                } else if (_file.contains ("resource://")) {
                    paintable = Gdk.Texture.from_resource (_file.replace ("resource://", ""));
                }
            } catch (Error e) {
                warning ("ERR: %s", e.message);
            }
        }
    }

    /**
     * The height of the image.
     *
     * @deprecated 1.8
     * @since 1.0
     */
    public int requested_height {
        get {
            return _requested_height;
        }
        set {
            _requested_height = value;
            height_request = _requested_height;
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
            width_request = _requested_width;
        }
    }

    construct {
        this.requested_width = 100;
        this.requested_height = 100;
        this.add_css_class ("content-block-image");
    }

    /**
     * Creates a new ContentBlockImage.
     *
     * @param file The file path of the image.
     */
    public ContentBlockImage (string file) {
        Object (file: file);
    }

    public override void measure (Gtk.Orientation orientation, int for_size, out int min, out int nat, out int min_b, out int nat_b) {
        double min_width, min_height, nat_width, nat_height;
        double default_size;

        /* for_size = 0 below is treated as -1, but we want to return zeros. */
        if (paintable == null || for_size == 0) {
            min = 0;
            nat = 0;
            return;
        }

        default_size = 100.0;
        paintable.compute_concrete_size (
                                         0,
                                         0,
                                         default_size,
                                         default_size,
                                         out min_width,
                                         out min_height
        );

        if (orientation == Gtk.Orientation.HORIZONTAL) {
            paintable.compute_concrete_size (
                                             0,
                                             for_size < 0 ? 0 : for_size,
                                             default_size,
                                             default_size,
                                             out nat_width,
                                             out nat_height
            );
            min = (int) Math.ceil (min_width);
            nat = (int) Math.ceil (nat_width);
        } else {
            paintable.compute_concrete_size (
                                             0,
                                             for_size < 0 ? 0 : for_size,
                                             default_size,
                                             default_size,
                                             out nat_width,
                                             out nat_height
            );
            min = (int) Math.ceil (min_height);
            nat = (int) Math.ceil (nat_height);
        }

        min_b = nat_b = -1;
    }

    public override void snapshot (Gtk.Snapshot snapshot) {
        double scaled_width, scaled_height;
        double width, height;

        if (paintable == null)
            return;

        width = get_width ();
        height = get_height ();

        if (width > height) {
            scaled_height = height;
            scaled_width = (float) width * scaled_height / (float) height;
        } else if (width < height) {
            scaled_width = width;
            scaled_height = (float) height * scaled_width / (float) width;
        } else {
            scaled_width = scaled_height = width;
        }

        var p = Graphene.Point.zero ();
        snapshot.translate (p.init ((float) (width - scaled_width) / 2, (float) (height - scaled_height) / 2));

        Gsk.ScalingFilter filter;
        if (scaled_width > width || scaled_height > height) {
            filter = Gsk.ScalingFilter.NEAREST;
        } else {
            filter = Gsk.ScalingFilter.TRILINEAR;
        }

        var r = Graphene.Rect.zero ();
        r.init (0, 0, (float) scaled_width, (float) scaled_height);
        var rounded = Gsk.RoundedRect ().init_from_rect (r, 24);
        snapshot.push_rounded_clip (rounded);
        snapshot.append_scaled_texture (paintable, filter, r);

        paintable.snapshot (snapshot, scaled_width, scaled_height);
        snapshot.pop ();
    }

    ~ContentBlockImage () {
        file = null;
        this.unparent ();
    }
}