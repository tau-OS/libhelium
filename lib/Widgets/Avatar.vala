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
 * An Avatar is a image representation of a person, or its initials. Shows their status using a badge.
 */
public class He.Avatar : Gtk.Widget {
    private Gdk.Texture? texture;
    private Gsk.RenderNode? blur_node;

    public enum StatusColor {
        RED,
        GREEN,
        YELLOW
    }

    private int _size;
    public int size {
        get { return _size; }
        set {
            _size = value;
            set_size_request (value, value);
            update_blur_node ();
            queue_draw ();
        }
    }

    private string? _text;
    public string? text {
        get { return _text; }
        set {
            _text = value;
            queue_draw ();
        }
    }

    private bool _status;
    public bool status {
        get { return _status; }
        set {
            _status = value;
            queue_draw ();
        }
    }

    private string _status_color;
    public StatusColor status_color {
        get {
            switch (_status_color) {
            case "red" :
                return StatusColor.RED;
            case "yellow" :
                return StatusColor.YELLOW;
            default:
                return StatusColor.GREEN;
            }
        }
        set {
            switch (value) {
            case StatusColor.RED:
                _status_color = "red";
                break;
            case StatusColor.YELLOW:
                _status_color = "yellow";
                break;
            default:
                _status_color = "green";
                break;
            }
            queue_draw ();
        }
    }

    private string? _image;
    public string? image {
        get { return _image; }
        set {
            _image = value;
            if (value != null) {
                try {
                    if (value.has_prefix ("resource://")) {
                        var resource_path = value.substring (11);
                        var bytes = resources_lookup_data (resource_path, ResourceLookupFlags.NONE);
                        texture = Gdk.Texture.from_bytes (bytes);
                    } else if (value.has_prefix ("file://")) {
                        var file = File.new_for_uri (value);
                        texture = Gdk.Texture.from_file (file);
                    } else {
                        var file = File.new_for_path (value);
                        texture = Gdk.Texture.from_file (file);
                    }
                    update_blur_node ();
                } catch (Error e) {
                    warning ("Failed to load image: %s", e.message);
                    texture = null;
                    blur_node = null;
                }
            } else {
                texture = null;
                blur_node = null;
            }
            queue_draw ();
        }
    }

    public Avatar (int size, string? image, string? text, bool status = false, StatusColor? status_color = StatusColor.GREEN) {
        Object (
                size : size,
                image: image,
                text: text,
                status: status,
                status_color: status_color
        );
    }

    static construct {
        set_css_name ("avatar");
    }

    construct {
        notify.connect (notify_cb);
        _status_color = "green"; // Default color
    }

    private void notify_cb (ParamSpec pspec) {
        queue_draw ();
    }

    private string extract_initials (string t) {
        string ret = "";
        if (t.length == 0)return "";
        ret += t[0].to_string ().up ();
        for (int i = 1; i < t.length - 1; i++)
            if (t[i] == ' ')
                ret += t[i + 1].to_string ().up ();
        return ret;
    }

    private void update_blur_node () {
        if (texture == null) {
            blur_node = null;
            return;
        }

        // Increase the size of the blur area
        var expanded_size = _size * 1.2f;
        var rect = Graphene.Rect ().init (-(_size * 0.1f), -(_size * 0.1f), expanded_size, expanded_size);

        var texture_node = new Gsk.TextureNode (texture, rect);
        var blur_effect = new Gsk.BlurNode (texture_node, _size <= 32 ? 0 : 20);

        blur_node = blur_effect;
    }

    public override void snapshot (Gtk.Snapshot snapshot) {
        var width = get_width ();
        var height = get_height ();

        var rect = Graphene.Rect ().init (0, 0, width, height);
        var blur_rect = Graphene.Rect ().init (-3, -3, width + 6, height + 6);

        // Draw blurred background
        if (blur_node != null && _size > 32) {
            // Fallback to gray if no image
            var rounded_rect = Gsk.RoundedRect () {
                bounds = blur_rect,
                corner = {
                    { width / 2, height / 2 },
                    { width / 2, height / 2 },
                    { width / 2, height / 2 },
                    { width / 2, height / 2 }
                }
            };
            snapshot.push_rounded_clip (rounded_rect);
            snapshot.push_opacity (0.25);
            snapshot.append_node (blur_node);
            snapshot.pop ();
            snapshot.pop ();
        } else {
            // Fallback to gray if no image
            var rounded_rect = Gsk.RoundedRect () {
                bounds = rect,
                corner = {
                    { width / 2, height / 2 },
                    { width / 2, height / 2 },
                    { width / 2, height / 2 },
                    { width / 2, height / 2 }
                }
            };
            snapshot.push_rounded_clip (rounded_rect);
            Gdk.RGBA color = { (float) 0.5, (float) 0.5, (float) 0.5, (float) 0.8 };
            snapshot.append_color (color, rect);
            snapshot.pop ();
        }

        // Draw main image or text
        if (texture != null) {
            var rounded_rect = Gsk.RoundedRect () {
                bounds = rect,
                corner = {
                    { width / 2, height / 2 },
                    { width / 2, height / 2 },
                    { width / 2, height / 2 },
                    { width / 2, height / 2 }
                }
            };
            snapshot.push_rounded_clip (rounded_rect);
            snapshot.append_texture (texture, rect);
            snapshot.pop ();
        } else if (_text != null) {
            var layout = create_pango_layout (extract_initials (_text));
            var font_size = (int) (7.5 * (_size / 16));
            var font_desc = new Pango.FontDescription ();
            font_desc.set_size (font_size * Pango.SCALE);
            layout.set_font_description (font_desc);

            int text_width, text_height;
            layout.get_pixel_size (out text_width, out text_height);

            snapshot.save ();
            snapshot.translate (Graphene.Point () { x = (width - text_width) / 2, y = (height - text_height) / 2 });
            snapshot.append_layout (layout, { 1, 1, 1, 1 });
            snapshot.restore ();
        }

        // Draw border
        Gdk.RGBA border_color = { (float) 0.45, (float) 0.45, (float) 0.45, (float) 0.32 };
        var border_width = 1;
        var rounded_rect = Gsk.RoundedRect () {
            bounds = rect,
            corner = { { height / 2, height / 2 }, { height / 2, height / 2 }, { height / 2, height / 2 }, { height / 2, height / 2 } }
        };
        snapshot.append_border (
                                rounded_rect,
                                { border_width, border_width, border_width, border_width },
                                { border_color, border_color, border_color, border_color });

        // Draw status badge
        if (_status) {
            var badge_size = width / 4;
            var badge_rect = Graphene.Rect ().init (
                                                    width - badge_size - border_width,
                                                    height - badge_size - border_width,
                                                    badge_size,
                                                    badge_size
            );

            Gdk.RGBA badge_color;
            switch (_status_color) {
            case "red":
                badge_color = {
                    (float) 0.8588,
                    (float) 0.1568,
                    (float) 0.3764,
                    1
                };
                break;
            case "yellow":
                badge_color = {
                    (float) 0.8784,
                    (float) 0.6313,
                    (float) 0.0039,
                    1
                };
                break;
            default:
                badge_color = {
                    (float) 0.2862,
                    (float) 0.8156,
                    (float) 0.3686,
                    1
                };
                break;
            }

            snapshot.append_color (badge_color, badge_rect);
        }
    }
}
