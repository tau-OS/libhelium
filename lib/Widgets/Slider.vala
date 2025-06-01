/*
 * Copyright (c) 2024-2025 Fyra Labs
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
 * A Slider is a widget that is used to select a value by means of a
 * dial running across a trough. Contains optional icons for the slider
 * purpose, and a disable-able Stop Indicator for accessibility purposes.
 * Can display either a standard scale or a custom wavy slider.
 *
 * When using the Stop Indicator, it's advisable to add a mark with the value
 * of 1.0 along the trough of the Slider so that the user can discern why the
 * end point is marked.
 */
public class He.Slider : He.Bin, Gtk.Buildable {
    private Gtk.Box main_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
    private Gtk.Box stop_indicator = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
    private Gtk.Image left_icon_img = new Gtk.Image ();
    private Gtk.Image right_icon_img = new Gtk.Image ();
    private Gtk.Overlay slider_overlay = new Gtk.Overlay ();
    private He.Desktop desktop = new He.Desktop ();
    private bool is_dark;
    private Gdk.RGBA accent_color = { 1, 1, 1, 1 };

    /**
     * The scale inside the Slider.
     */
    public Gtk.Scale scale = new Gtk.Scale (Gtk.Orientation.HORIZONTAL, null);

    /**
     * The wavy drawing area for custom wavy slider.
     */
    private Gtk.DrawingArea wavy_drawing_area = new Gtk.DrawingArea ();

    /**
     * Mouse gesture for wavy slider interaction.
     */
    private Gtk.GestureDrag drag_gesture;

    /**
     * Wave amplitude in pixels for the wavy slider.
     */
    private int _wave_amplitude = 4;
    public int wave_amplitude {
        get { return _wave_amplitude; }
        set {
            _wave_amplitude = (int) Math.fmax (1, value);
            wavy_drawing_area.queue_draw ();
        }
    }

    /**
     * Wave wavelength in pixels for the wavy slider.
     */
    private int _wave_wavelength = 40;
    public int wave_wavelength {
        get { return _wave_wavelength; }
        set {
            _wave_wavelength = (int) Math.fmax (10, value);
            wavy_drawing_area.queue_draw ();
        }
    }

    /**
     * Wave thickness in pixels for the wavy slider.
     */
    private int _wave_thickness = 8;
    public int wave_thickness {
        get { return _wave_thickness; }
        set {
            _wave_thickness = (int) Math.fmax (1, value);
            wavy_drawing_area.queue_draw ();
        }
    }

    /**
     * Fixed wave margin in pixels for the wavy slider.
     */
    private const int WAVE_MARGIN = 12;

    /**
     * Minimum and maximum values for the slider.
     */
    private double _min_value = 0.0;
    private double _max_value = 1.0;

    /**
     * Current value of the slider.
     */
    private double _value = 0.0;
    public double value {
        get {
            return _value;
        }
        set {
            _value = Math.fmax (_min_value, Math.fmin (_max_value, value));
            if (_is_wavy) {
                wavy_drawing_area.queue_draw ();
                update_stop_indicator_position ();
                scale.set_value (_value);
            } else {
                scale.set_value (_value);
            }
        }
    }

    /**
     * Sets the left icon of the Slider.
     */
    private string _left_icon;
    public string left_icon {
        get {
            return _left_icon;
        }
        set {
            _left_icon = value;
            if (_left_icon != null) {
                left_icon_img.set_visible (true);
                left_icon_img.set_from_icon_name (_left_icon);
            } else {
                left_icon_img.set_visible (false);
            }
        }
    }

    /**
     * Sets the right icon of the Slider.
     */
    private string _right_icon;
    public string right_icon {
        get {
            return _right_icon;
        }
        set {
            _right_icon = value;
            if (_right_icon != null) {
                right_icon_img.set_visible (true);
                right_icon_img.set_from_icon_name (_right_icon);
            } else {
                right_icon_img.set_visible (false);
            }
        }
    }

    /**
     * Sets the visibility of the stop indicator of the Slider.
     */
    private bool _stop_indicator_visibility;
    public bool stop_indicator_visibility {
        get {
            return _stop_indicator_visibility;
        }
        set {
            _stop_indicator_visibility = value;
            if (_stop_indicator_visibility) {
                stop_indicator.set_visible (true);
            } else {
                stop_indicator.set_visible (false);
            }
        }
    }

    /**
     * Sets whether to use a wavy slider instead of the standard one.
     */
    private bool _is_wavy;
    public bool is_wavy {
        get {
            return _is_wavy;
        }
        set {
            _is_wavy = value;
            if (_is_wavy) {
                slider_overlay.set_child (wavy_drawing_area);
                // Sync value from scale to wavy slider
                if (scale.get_adjustment () != null) {
                    _value = scale.get_value ();
                    _min_value = scale.get_adjustment ().get_lower ();
                    _max_value = scale.get_adjustment ().get_upper ();
                }
                wavy_drawing_area.queue_draw ();
                update_stop_indicator_position ();
            } else {
                slider_overlay.set_child (scale);
                // Sync value from wavy slider to scale
                scale.set_value (_value);
                // Reset stop indicator margin for standard scale
                stop_indicator.margin_end = 16;
            }
        }
    }

    /**
     * Signal emitted when the value changes.
     */
    public signal void value_changed ();

    /**
     * Constructs a new Slider.
     *
     * @since 1.0
     */
    public Slider () {
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BoxLayout));
    }

    construct {
        left_icon_img.halign = Gtk.Align.START;
        left_icon_img.valign = Gtk.Align.CENTER;
        left_icon_img.set_visible (false);

        right_icon_img.halign = Gtk.Align.END;
        right_icon_img.valign = Gtk.Align.CENTER;
        right_icon_img.set_visible (false);

        stop_indicator.margin_end = 16;
        if (_is_wavy && _stop_indicator_visibility) {
            // Adjust margin to account for wave margin so stop indicator aligns with wavy area end
            stop_indicator.margin_end = 10;
        }
        stop_indicator.margin_bottom = 12;
        stop_indicator.margin_top = 12;
        stop_indicator.valign = Gtk.Align.CENTER;
        stop_indicator.halign = Gtk.Align.END;
        stop_indicator.set_visible (false);
        stop_indicator.add_css_class ("stop-indicator");

        // Setup wavy drawing area
        wavy_drawing_area.hexpand = true;
        wavy_drawing_area.set_size_request (-1, 40);
        wavy_drawing_area.set_draw_func (draw_wavy_slider);

        // Setup mouse interaction for wavy slider
        drag_gesture = new Gtk.GestureDrag ();
        drag_gesture.set_button (1); // Left mouse button
        wavy_drawing_area.add_controller (drag_gesture);

        drag_gesture.drag_begin.connect (on_drag_begin);
        drag_gesture.drag_update.connect (on_drag_update);

        // Setup scale value change signal
        scale.value_changed.connect (() => {
            if (!_is_wavy) {
                _value = scale.get_value ();
                value_changed ();
                wavy_drawing_area.queue_draw ();
            }
        });

        slider_overlay.hexpand = true;
        slider_overlay.add_overlay (stop_indicator);
        slider_overlay.set_child (scale);

        main_box.append (left_icon_img);
        main_box.append (slider_overlay);
        main_box.append (right_icon_img);
        main_box.valign = Gtk.Align.CENTER;
        main_box.hexpand = true;
        main_box.add_css_class ("slider");
        main_box.set_parent (this);

        // Initialize with scale's default values
        if (scale.get_adjustment () != null) {
            _min_value = scale.get_adjustment ().get_lower ();
            _max_value = scale.get_adjustment ().get_upper ();
            _value = scale.get_value ();
        }

        is_dark = desktop.prefers_color_scheme == He.Desktop.ColorScheme.DARK ? true : false;

        // Setup accent color monitoring
        desktop.notify["accent-color"].connect (update_accent_color);

        // Monitor for when widget gets added to application
        notify["root"].connect (() => {
            var app = get_he_application ();
            if (app != null) {
                app.accent_color_changed.connect (update_accent_color);
                update_accent_color ();
                wavy_drawing_area.queue_draw ();
            }
        });

        update_accent_color ();
        wavy_drawing_area.queue_draw ();
    }

    /**
     * Gets the He.Application instance from the widget hierarchy.
     */
    private He.Application? get_he_application () {
        var root = get_root ();
        if (root is Gtk.Window) {
            var app = ((Gtk.Window) root).get_application ();
            if (app is He.Application) {
                return (He.Application) app;
            }
        }
        return null;
    }

    /**
     * Updates the stop indicator position to align with the wavy slider end.
     */
    private void update_stop_indicator_position () {
        if (_is_wavy && _stop_indicator_visibility) {
            // Adjust margin to account for wave margin so stop indicator aligns with wavy area end
            stop_indicator.margin_end = 10;
        }
    }

    private void update_accent_color () {
        RGBColor? effective_color = null;
        bool is_from_application = false;

        // Try to get accent color from application first
        var app = get_he_application ();
        if (app != null) {
            effective_color = app.get_effective_accent_color ();
            is_from_application = (app.is_content && app.default_accent_color != null);
        }

        // Fall back to desktop accent color
        if (effective_color == null) {
            effective_color = desktop.accent_color;
        }

        if (effective_color != null) {
            float r, g, b;

            if (is_from_application) {
                // Application colors are in 0.0-255.0 range, convert to 0.0-1.0
                r = (float) Math.fmax (0.0, Math.fmin (255.0, effective_color.r)) / 255.0f;
                g = (float) Math.fmax (0.0, Math.fmin (255.0, effective_color.g)) / 255.0f;
                b = (float) Math.fmax (0.0, Math.fmin (255.0, effective_color.b)) / 255.0f;
            } else {
                // Desktop colors are already in 0.0-1.0 range
                r = (float) Math.fmax (0.0, Math.fmin (1.0, effective_color.r));
                g = (float) Math.fmax (0.0, Math.fmin (1.0, effective_color.g));
                b = (float) Math.fmax (0.0, Math.fmin (1.0, effective_color.b));
            }

            accent_color = { r, g, b, 1.0f };

            // Debug output to help identify the issue
            print ("Slider accent color updated: r=%f, g=%f, b=%f (from %s, original: %f,%f,%f)\n",
                   r, g, b, is_from_application ? "application" : "desktop",
                   effective_color.r, effective_color.g, effective_color.b);
        } else {
            // Fallback to a visible color if no accent color is available
            accent_color = { 0.2f, 0.6f, 1.0f, 1.0f }; // Blue fallback
            print ("Slider using fallback accent color\n");
        }
    }

    /**
     * Adds a mark with some information along the trough of the Slider.
     */
    public void add_mark (double value, string? text) {
        scale.add_mark (value, Gtk.PositionType.BOTTOM, text);
    }

    /**
     * Sets the range of the slider.
     */
    public void set_range (double min, double max) {
        _min_value = min;
        _max_value = max;
        scale.set_range (min, max);
        if (_is_wavy) {
            wavy_drawing_area.queue_draw ();
        }
    }

    /**
     * Sets the adjustment for the slider.
     */
    public void set_adjustment (Gtk.Adjustment adjustment) {
        scale.set_adjustment (adjustment);
        _min_value = adjustment.get_lower ();
        _max_value = adjustment.get_upper ();
        _value = adjustment.get_value ();
        if (_is_wavy) {
            wavy_drawing_area.queue_draw ();
        }
    }

    /**
     * Handles the start of a drag operation on the wavy slider.
     */
    private void on_drag_begin (double start_x, double start_y) {
        update_value_from_position (start_x);
    }

    /**
     * Handles drag updates on the wavy slider.
     */
    private void on_drag_update (double offset_x, double offset_y) {
        double start_x, start_y;
        drag_gesture.get_start_point (out start_x, out start_y);
        update_value_from_position (start_x + offset_x);
    }

    /**
     * Updates the slider value based on mouse position.
     */
    private void update_value_from_position (double x) {
        int width = wavy_drawing_area.get_width ();
        if (width <= 0) {
            return;
        }

        // Account for wave margins - the effective area is smaller
        double effective_width = width - 2 * WAVE_MARGIN;
        double adjusted_x = x - WAVE_MARGIN;

        double position = Math.fmax (0.0, Math.fmin (1.0, adjusted_x / effective_width));
        double new_value = _min_value + position * (_max_value - _min_value);

        if (new_value != _value) {
            _value = new_value;
            wavy_drawing_area.queue_draw ();
            value_changed ();
        }
    }

    /**
     * Helper function to draw a rounded rectangle.
     */
    private void draw_rounded_rectangle (Cairo.Context cr, double x, double y, double width, double height, double radius) {
        cr.move_to (x + radius, y);
        cr.arc (x + width - radius, y + radius, radius, -Math.PI * 0.5, 0);
        cr.arc (x + width - radius, y + height - radius, radius, 0, Math.PI * 0.5);
        cr.arc (x + radius, y + height - radius, radius, Math.PI * 0.5, Math.PI);
        cr.arc (x + radius, y + radius, radius, Math.PI, Math.PI * 1.5);
        cr.close_path ();
    }

    /**
     * Draws the wavy slider using Cairo.
     */
    private void draw_wavy_slider (Gtk.DrawingArea area, Cairo.Context cr, int width, int height) {
        // Get theme colors
        Gdk.RGBA bg_color = { is_dark ? 1.0f : 0.0f, is_dark ? 1.0f : 0.0f, is_dark ? 1.0f : 0.0f, 0.12f };

        cr.set_line_width (_wave_thickness);
        cr.set_line_cap (Cairo.LineCap.ROUND);

        // Calculate slider position accounting for margins
        double range = _max_value - _min_value;
        double position = range > 0 ? (_value - _min_value) / range : 0.0;
        double effective_width = width - 2 * WAVE_MARGIN;
        double slider_x = WAVE_MARGIN + effective_width * position;

        // Wave parameters using properties
        double track_y = height * 0.5;
        double wave_amplitude = _wave_amplitude;
        double wave_frequency = 2.0 * Math.PI / _wave_wavelength;

        // Handle position
        double handle_center_y = track_y;
        double handle_width = 4.0;
        double handle_height = 34.0;
        double border_margin = 6.0;
        double border_x = slider_x - (handle_width * 0.5) - border_margin;
        double border_y = handle_center_y - (handle_height * 0.5) - border_margin;
        double border_width = handle_width + (border_margin * 2.0);
        double border_height = handle_height + (border_margin * 2.0);

        // Draw background track as a simple straight line from slider position to end
        double inactive_start = border_x + border_width;
        if (inactive_start < width - WAVE_MARGIN) {
            cr.set_source_rgba (bg_color.red, bg_color.green, bg_color.blue, bg_color.alpha);
            cr.move_to (inactive_start, track_y);
            cr.line_to (width - WAVE_MARGIN, track_y);
            cr.stroke ();
        }

        // Draw filled portion (wavy) with margins, avoiding handle border area
        double filled_end = Math.fmin (slider_x, width - WAVE_MARGIN);
        if (filled_end > WAVE_MARGIN) {
            cr.set_source_rgba (((is_dark ? 0.40 : 0.80) * accent_color.red), ((is_dark ? 0.40 : 0.80) * accent_color.green), ((is_dark ? 0.40 : 0.80) * accent_color.blue), 1);
            bool path_started = false;
            for (double x = WAVE_MARGIN; x <= filled_end; x += 1.0) {
                double y = track_y + Math.sin (x * wave_frequency) * wave_amplitude;

                // Check if we're in the handle border area
                if (x >= border_x && x <= border_x + border_width &&
                    y >= border_y && y <= border_y + border_height) {
                    // Skip this point, end current path if we have one
                    if (path_started) {
                        cr.stroke ();
                        path_started = false;
                    }
                } else {
                    // Draw this point
                    if (!path_started) {
                        cr.move_to (x, y);
                        path_started = true;
                    } else {
                        cr.line_to (x, y);
                    }
                }
            }
            if (path_started) {
                cr.stroke ();
            }
        }

        // Reset line width for handle border
        cr.set_line_width (1.0);

        // Draw rounded rectangular slider handle (4px wide, 32px high)
        double handle_x = slider_x - handle_width * 0.5;
        double handle_y = handle_center_y - handle_height * 0.5;
        double corner_radius = 4.0;

        // Fill handle
        cr.set_source_rgba (((is_dark ? 0.40 : 0.80) * accent_color.red), ((is_dark ? 0.40 : 0.80) * accent_color.green), ((is_dark ? 0.40 : 0.80) * accent_color.blue), 1);
        draw_rounded_rectangle (cr, handle_x, handle_y, handle_width, handle_height, corner_radius);
        cr.fill ();

        // Draw handle border
        cr.set_source_rgba (is_dark ? 0.0f : 1.0f, is_dark ? 0.0f : 1.0f, is_dark ? 0.0f : 1.0f, 1.0);
        draw_rounded_rectangle (cr, handle_x, handle_y, handle_width, handle_height, corner_radius);
        cr.stroke ();
    }
}
