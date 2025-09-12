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
    private Gdk.Texture? paintable;
    private GLib.Cancellable? _load_cancel = null;
    private int _last_loaded_w = 0;
    private int _last_loaded_h = 0;

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
                // Cancel any previous ongoing load
                if (_load_cancel != null) {
                    _load_cancel.cancel ();
                }
                _load_cancel = new GLib.Cancellable ();

                if (_file == null || _file.length == 0) {
                    paintable = null;
                    queue_draw ();
                    return;
                }

                if (_file.contains ("resource://")) {
                    // Resources are usually small, safe to load synchronously
                    paintable = Gdk.Texture.from_resource (_file.replace ("resource://", ""));
                    queue_draw ();
                } else {
                    // Support both file:// URIs and plain paths
                    string path = _file.contains ("file://") ? _file.replace ("file://", "") : _file;
                    // Load asynchronously at the current (or requested) size
                    load_scaled_texture_async.begin (path, _load_cancel);
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
        Object (file : file);
    }

    // Load the image asynchronously at approximately the current widget size
    private async void load_scaled_texture_async (string path, GLib.Cancellable? cancellable) {
        // Determine target size (fallback to requested size or a reasonable default)
        int target_w = get_width ();
        int target_h = get_height ();
        if (target_w <= 0 || target_h <= 0) {
            target_w = _requested_width > 0 ? _requested_width : 256;
            target_h = _requested_height > 0 ? _requested_height : 256;
        }

        try {
            var file = GLib.File.new_for_path (path);
            var stream = yield file.read_async (GLib.Priority.DEFAULT, cancellable);

            var pixbuf = yield new Gdk.Pixbuf.from_stream_at_scale_async (stream, target_w, target_h, true, cancellable);

            var tex = Gdk.Texture.for_pixbuf (pixbuf);

            // If a newer load was requested, this cancellable would be cancelled
            if (cancellable != null && cancellable.is_cancelled ()) {
                return;
            }

            paintable = tex;
            _last_loaded_w = target_w;
            _last_loaded_h = target_h;
            queue_draw ();
        } catch (Error e) {
            warning ("ERR: %s", e.message);
        }
    }

    public override void size_allocate (int width, int height, int baseline) {
        base.size_allocate (width, height, baseline);

        // If the allocation changed, reload the image at the new size
        if (_file != null && !_file.contains ("resource://")) {
            if (width > 0 && height > 0 && (width != _last_loaded_w || height != _last_loaded_h)) {
                if (_load_cancel != null) {
                    _load_cancel.cancel ();
                }
                _load_cancel = new GLib.Cancellable ();
                string path = _file.contains ("file://") ? _file.replace ("file://", "") : _file;
                load_scaled_texture_async.begin (path, _load_cancel);
            }
        }
    }

    public override void measure (Gtk.Orientation orientation, int for_size, out int min, out int nat, out int min_b = null, out int nat_b = null) {
        double min_width, min_height, nat_width, nat_height;
        double default_size;

        /* for_size = 0 below is treated as -1, but we want to return zeros. */
        if (paintable == null || for_size == 0) {
            min = 0;
            nat = 0;
            min_b = nat_b = -1;
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
            min_b = nat_b = -1;
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
            min_b = nat_b = -1;
        }
    }

    public override void snapshot (Gtk.Snapshot snapshot) {
        if (paintable == null)
            return;

        double width = get_width ();
        double height = get_height ();
        if (width <= 0 || height <= 0)
            return;

        double tex_w = paintable.get_width ();
        double tex_h = paintable.get_height ();
        if (tex_w <= 0 || tex_h <= 0)
            return;

        double scale = Math.fmin (width / tex_w, height / tex_h);
        double scaled_width = tex_w * scale;
        double scaled_height = tex_h * scale;

        var p = Graphene.Point.zero ();
        snapshot.translate (p.init ((float) ((width - scaled_width) / 2.0), (float) ((height - scaled_height) / 2.0)));

        Gsk.ScalingFilter filter = (scale > 1.0) ? Gsk.ScalingFilter.NEAREST : Gsk.ScalingFilter.TRILINEAR;

        var r = Graphene.Rect.zero ();
        r.init (0, 0, (float) scaled_width, (float) scaled_height);
        var rounded = Gsk.RoundedRect ().init_from_rect (r, 24);
        snapshot.push_rounded_clip (rounded);
        snapshot.append_scaled_texture (paintable, filter, r);
        snapshot.pop ();
    }

    ~ContentBlockImage () {
        if (_load_cancel != null) {
            _load_cancel.cancel ();
            _load_cancel = null;
        }
        paintable = null;
        this.unparent ();
    }
}
