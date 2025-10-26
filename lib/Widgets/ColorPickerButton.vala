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
            private Gtk.Entry h_entry;
            private Gtk.Entry c_entry;
            private Gtk.Entry t_entry;
            public Gdk.RGBA current_color;
            private ColorPickerButton owner;
            private bool updating_from_sliders = false;
            private bool updating_from_entries = false;

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

                h_entry = new Gtk.Entry ();
                h_entry.set_placeholder_text ("0-360");
                h_entry.set_max_width_chars (6);
                h_entry.set_width_chars (6);
                h_entry.add_css_class ("numeric");

                c_entry = new Gtk.Entry ();
                c_entry.set_placeholder_text ("0-120");
                c_entry.set_max_width_chars (6);
                c_entry.set_width_chars (6);
                c_entry.add_css_class ("numeric");

                t_entry = new Gtk.Entry ();
                t_entry.set_placeholder_text ("0-100");
                t_entry.set_max_width_chars (6);
                t_entry.set_width_chars (6);
                t_entry.add_css_class ("numeric");

                var entries_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
                entries_box.hexpand = true;
                entries_box.homogeneous = true;
                entries_box.append (h_entry);
                entries_box.append (c_entry);
                entries_box.append (t_entry);

                sliders_box.append (entries_box);

                He.RGBColor hct_source = {
                    color.red* 255.0,
                    color.green* 255.0,
                    color.blue* 255.0
                };
                var hct = He.hct_from_int (He.rgb_to_argb_int (hct_source));
                r_slider.set_value (hct.h / 360.0);
                g_slider.set_value (hct.c / 120.0);
                b_slider.set_value (hct.t / 100.0);

                update_entries_from_sliders ();

                r_slider.value_changed.connect (() => update_color_from_sliders ());
                g_slider.value_changed.connect (() => update_color_from_sliders ());
                b_slider.value_changed.connect (() => update_color_from_sliders ());

                h_entry.activate.connect (() => update_color_from_entries ());
                c_entry.activate.connect (() => update_color_from_entries ());
                t_entry.activate.connect (() => update_color_from_entries ());

                h_entry.changed.connect (() => { if (!updating_from_sliders) update_color_from_entries (); });
                c_entry.changed.connect (() => { if (!updating_from_sliders) update_color_from_entries (); });
                t_entry.changed.connect (() => { if (!updating_from_sliders) update_color_from_entries (); });

                set_child (sliders_box);
            }

            private Gtk.Scale create_slider (string type) {
                switch (type) {
                case "g-slider":
                    var slider_g = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0.0, 1.0, 0.01);
                    slider_g.hexpand = true;
                    slider_g.draw_value = true;
                    slider_g.value_pos = Gtk.PositionType.RIGHT;
                    slider_g.set_format_value_func ((scale, value) => ((int) Math.floor (value * 120.0)).to_string ());
                    slider_g.add_css_class (type);
                    return slider_g;
                case "b-slider":
                    var slider_b = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0.0, 1.0, 0.01);
                    slider_b.hexpand = true;
                    slider_b.draw_value = true;
                    slider_b.value_pos = Gtk.PositionType.RIGHT;
                    slider_b.set_format_value_func ((scale, value) => ((int) Math.floor (value * 100.0)).to_string ());
                    slider_b.add_css_class (type);
                    return slider_b;
                default:
                    var slider_r = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0.0, 1.0, 0.01);
                    slider_r.hexpand = true;
                    slider_r.draw_value = true;
                    slider_r.value_pos = Gtk.PositionType.RIGHT;
                    slider_r.set_format_value_func ((scale, value) => ((int) Math.floor (value * 360.0)).to_string ());
                    slider_r.add_css_class (type);
                    return slider_r;
                }
            }

            private void update_entries_from_sliders () {
                updating_from_sliders = true;
                h_entry.set_text (((int) Math.floor (r_slider.get_value () * 360.0)).to_string ());
                c_entry.set_text (((int) Math.floor (g_slider.get_value () * 120.0)).to_string ());
                t_entry.set_text (((int) Math.floor (b_slider.get_value () * 100.0)).to_string ());
                updating_from_sliders = false;
            }

            private void update_color_from_sliders () {
                if (updating_from_entries) {
                    return;
                }

                update_entries_from_sliders ();

                Gdk.RGBA new_color = {};
                new_color.parse (He.hexcode_argb (He.hct_to_argb (
                                                                  r_slider.get_value () * 360.0,
                                                                  g_slider.get_value () * 120.0,
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

            private void update_color_from_entries () {
                if (updating_from_sliders) {
                    return;
                }

                double h_val = double.parse (h_entry.get_text ());
                double c_val = double.parse (c_entry.get_text ());
                double t_val = double.parse (t_entry.get_text ());

                h_val = Math.fmax (0.0, Math.fmin (360.0, h_val));
                c_val = Math.fmax (0.0, Math.fmin (120.0, c_val));
                t_val = Math.fmax (0.0, Math.fmin (100.0, t_val));

                updating_from_entries = true;
                r_slider.set_value (h_val / 360.0);
                g_slider.set_value (c_val / 120.0);
                b_slider.set_value (t_val / 100.0);
                updating_from_entries = false;

                Gdk.RGBA new_color = {};
                new_color.parse (He.hexcode_argb (He.hct_to_argb (h_val, c_val, t_val)));

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