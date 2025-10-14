/*
 * Helium ColorPickerButton widget ported from Gafu.
 */
namespace He {
    public class ColorPickerButton : He.Bin {
        private Gtk.DrawingArea color_preview = new Gtk.DrawingArea ();
        private Gtk.Label color_label = new Gtk.Label ("");
        private Gtk.Button main_button = new Gtk.Button ();
        private Gtk.Button copy_button = new Gtk.Button.from_icon_name ("edit-copy-symbolic");

        private Gdk.RGBA _current_color = { 0.0f, 0.0f, 0.0f, 1.0f };
        public Gdk.RGBA current_color {
            get {
                return _current_color;
            }
            set {
                apply_color (value, false);
            }
        }

        private bool _has_label = false;
        public bool has_label {
            get {
                return _has_label;
            }
            set {
                if (_has_label == value) {
                    return;
                }

                _has_label = value;
                update_label_visibility ();
            }
        }

        public signal void color_changed (Gdk.RGBA new_color);

        construct {
            set_size_request (150, 48);
            add_css_class ("color-picker-button");

            color_label.add_css_class ("numeric");
            color_label.set_max_width_chars (7);
            color_label.set_width_chars (7);

            var hbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
            color_preview.set_size_request (40, 40);
            hbox.append (color_preview);
            hbox.append (color_label);

            main_button.set_child (hbox);
            main_button.add_css_class ("main-button");

            copy_button.set_tooltip_text ("Copy color to clipboard");
            copy_button.set_size_request (40, 40);
            copy_button.add_css_class ("copy-button");

            update_label_visibility ();

            var main_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
            main_box.vexpand = true;
            main_box.valign = Gtk.Align.CENTER;
            main_box.append (main_button);
            main_box.append (copy_button);

            this.child = main_box;

            color_preview.set_draw_func (draw_color_preview);
            main_button.clicked.connect (() => show_color_dialog ());
            copy_button.clicked.connect (() => copy_color_to_clipboard ());
        }

        private void update_label_visibility () {
            color_label.set_visible (_has_label);
            copy_button.set_visible (_has_label);
            update_label ();
        }

        private void update_label () {
            if (!_has_label) {
                return;
            }

            color_label.set_text (He.hexcode (
                                              _current_color.red * 255.0,
                                              _current_color.green * 255.0,
                                              _current_color.blue * 255.0
            ));
        }

        private void apply_color (Gdk.RGBA color, bool emit_signal) {
            _current_color = color;
            update_label ();
            color_preview.queue_draw ();

            if (emit_signal) {
                color_changed (_current_color);
            }
        }

        private void draw_color_preview (Gtk.DrawingArea area, Cairo.Context cr, int width, int height) {
            int diameter = width - 8;
            if (diameter < 0) {
                diameter = 0;
            }

            int radius = diameter / 2;
            int center_x = width / 2;
            int center_y = height / 2;

            cr.set_source_rgba (
                                _current_color.red,
                                _current_color.green,
                                _current_color.blue,
                                _current_color.alpha
            );
            cr.arc (center_x, center_y, radius, 0, 2 * Math.PI);
            cr.fill_preserve ();

            cr.set_source_rgba (0.0, 0.0, 0.0, 0.3);
            cr.stroke ();
        }

        private void show_color_dialog () {
            var popover = new ColorPickerPopover (this, _current_color);
            popover.set_parent (color_preview);
            popover.show ();
        }

        private void copy_color_to_clipboard () {
            var clipboard = get_display ().get_clipboard ();
            string color_hex = He.hexcode (
                                           _current_color.red * 255.0,
                                           _current_color.green * 255.0,
                                           _current_color.blue * 255.0
            );
            clipboard.set_text (color_hex);
        }

        private class ColorPickerPopover : Gtk.Popover {
            private Gtk.Scale r_slider;
            private Gtk.Scale g_slider;
            private Gtk.Scale b_slider;
            public Gdk.RGBA current_color;
            private ColorPickerButton owner;

            public signal void color_changed (Gdk.RGBA new_color);

            public ColorPickerPopover (ColorPickerButton owner, Gdk.RGBA color) {
                this.owner = owner;
                this.current_color = color;
                set_position (Gtk.PositionType.BOTTOM);
                set_size_request (300, -1);
                has_arrow = false;

                var sliders_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 24);
                sliders_box.margin_top = 18;
                sliders_box.margin_bottom = 18;
                sliders_box.margin_end = 18;
                sliders_box.margin_start = 18;

                r_slider = create_slider ("r-slider");
                g_slider = create_slider ("g-slider");
                b_slider = create_slider ("b-slider");

                var h_label = new Gtk.Label (_("H"));
                var h_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
                h_box.hexpand = true;
                h_box.append (h_label);
                h_box.append (r_slider);

                var c_label = new Gtk.Label (_("C"));
                var c_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
                c_box.hexpand = true;
                c_box.append (c_label);
                c_box.append (g_slider);

                var t_label = new Gtk.Label (_("T"));
                var t_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
                t_box.hexpand = true;
                t_box.append (t_label);
                t_box.append (b_slider);

                sliders_box.append (h_box);
                sliders_box.append (c_box);
                sliders_box.append (t_box);

                He.RGBColor hct_source = {
                    color.red* 255.0,
                    color.green* 255.0,
                    color.blue* 255.0
                };
                var hct = He.hct_from_int (He.rgb_to_argb_int (hct_source));
                r_slider.set_value (hct.h / 360.0);
                g_slider.set_value (hct.c / 150.0);
                b_slider.set_value (hct.t / 100.0);

                r_slider.value_changed.connect (() => update_color ());
                g_slider.value_changed.connect (() => update_color ());
                b_slider.value_changed.connect (() => update_color ());

                set_child (sliders_box);
            }

            private Gtk.Scale create_slider (string type) {
                switch (type) {
                case "g-slider":
                    var slider_g = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0.0, 0.75, 0.01);
                    slider_g.hexpand = true;
                    slider_g.draw_value = true;
                    slider_g.value_pos = Gtk.PositionType.RIGHT;
                    slider_g.set_format_value_func ((scale, value) => ((int) (value * 150)).to_string ());
                    slider_g.add_css_class (type);
                    return slider_g;
                case "b-slider":
                    var slider_b = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0.0, 1.0, 0.01);
                    slider_b.hexpand = true;
                    slider_b.draw_value = true;
                    slider_b.value_pos = Gtk.PositionType.RIGHT;
                    slider_b.set_format_value_func ((scale, value) => ((int) (value * 100)).to_string ());
                    slider_b.add_css_class (type);
                    return slider_b;
                default:
                    var slider_r = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0.0, 1.0, 0.01);
                    slider_r.hexpand = true;
                    slider_r.draw_value = true;
                    slider_r.value_pos = Gtk.PositionType.RIGHT;
                    slider_r.set_format_value_func ((scale, value) => ((int) (value * 360)).to_string ());
                    slider_r.add_css_class (type);
                    return slider_r;
                }
            }

            private void update_color () {
                Gdk.RGBA new_color = {};
                new_color.parse (He.hexcode_argb (He.hct_to_argb (
                                                                  r_slider.get_value () * 360.0,
                                                                  g_slider.get_value () * 150.0,
                                                                  b_slider.get_value () * 100.0
                )));

                if (new_color.red == current_color.red &&
                    new_color.green == current_color.green &&
                    new_color.blue == current_color.blue &&
                    new_color.alpha == current_color.alpha) {
                    return;
                }

                current_color = new_color;
                owner.apply_color (new_color, true);
                color_changed (current_color);
            }
        }
    }
}