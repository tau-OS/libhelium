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
 * A Progressbar indicates the progress of some process and contains
 * a disable-able Stop Indicator for accessibility purposes.
 * Can display either a standard progressbar or a custom wavy progressbar.
 */
public class He.ProgressBar : He.Bin, Gtk.Buildable {
    private Gtk.Box main_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
    private Gtk.Box stop_indicator = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
    private Gtk.Overlay pb_overlay = new Gtk.Overlay ();
    private He.Desktop desktop = new He.Desktop ();
    private bool is_dark;
    private Gdk.RGBA accent_color = { 1.0f, 1.0f, 1.0f, 1.0f };

    /**
     * The progressbar inside the Progressbar.
     */
    public Gtk.ProgressBar progressbar = new Gtk.ProgressBar ();

    /**
     * The wavy drawing area for custom wavy progressbar.
     */
    private Gtk.DrawingArea wavy_drawing_area = new Gtk.DrawingArea ();

    /**
     * Wave amplitude in pixels for the wavy progressbar.
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
     * Wave wavelength in pixels for the wavy progressbar.
     */
    private int _wave_wavelength = 40;
    public int wave_wavelength {
        get { return _wave_wavelength; }
        set {
            _wave_wavelength = (int) Math.fmax (5, value);
            wavy_drawing_area.queue_draw ();
        }
    }

    /**
     * Wave thickness in pixels for the wavy progressbar.
     */
    private int _wave_thickness = 4;
    public int wave_thickness {
        get { return _wave_thickness; }
        set {
            _wave_thickness = (int) Math.fmax (1, value);
            wavy_drawing_area.queue_draw ();
        }
    }

    /**
     * Wave phase for animation.
     */
    private double _wave_phase = 0.0;

    /**
     * Animation state tracking.
     */
    private uint _animation_tick_id = 0;
    private bool _continuous_animation = false;

    /**
     * Wave flattening state tracking.
     */
    private bool _is_flattening = false;
    private int64 _flatten_start_time = 0;
    private const int64 FLATTEN_DURATION = 200000; // 200ms in microseconds

    /**
     * Controls whether the wavy progressbar should animate.
     * Set to true when progress is actively changing, false when static.
     */
    private bool _animate = true;
    public bool animate {
        get { return _animate; }
        set {
            _animate = value;
            if (_is_wavy) {
                if (_animate && _continuous_animation && _animation_tick_id == 0) {
                    _animation_tick_id = wavy_drawing_area.add_tick_callback (on_animation_tick);
                } else if (!_animate && _animation_tick_id != 0) {
                    wavy_drawing_area.remove_tick_callback (_animation_tick_id);
                    _animation_tick_id = 0;
                }
            }
        }
    }

    /**
     * Progress value from 0.0 to 1.0.
     */
    private double _progress = 0.0;
    public double progress {
        get {
            return _progress;
        }
        set {
            double old_progress = _progress;
            _progress = Math.fmax (0.0, Math.fmin (1.0, value));

            // Start flattening animation when crossing 90% threshold
            if (old_progress < 0.9 && _progress >= 0.9 && !_is_flattening) {
                _is_flattening = true;
                _flatten_start_time = GLib.get_monotonic_time ();
            }
            // Reset flattening if progress goes back below 90%
            else if (_progress < 0.9 && _is_flattening) {
                _is_flattening = false;
            }

            if (_is_wavy) {
                wavy_drawing_area.queue_draw ();
                update_stop_indicator_position ();
            } else {
                progressbar.set_fraction (_progress);
            }
        }
    }

    /**
     * Sets the visibility of the stop indicator of the Progressbar.
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
     * Sets the OSD styling of the Progressbar.
     */
    private bool _is_osd;
    public bool is_osd {
        get {
            return _is_osd;
        }
        set {
            _is_osd = value;
            if (_is_osd) {
                if (_is_wavy) {
                    wavy_drawing_area.add_css_class ("osd");
                } else {
                    progressbar.add_css_class ("osd");
                }
            } else {
                if (_is_wavy) {
                    wavy_drawing_area.remove_css_class ("osd");
                } else {
                    progressbar.remove_css_class ("osd");
                }
            }
        }
    }

    /**
     * Sets whether to use a wavy progressbar instead of the standard one.
     */
    private bool _is_wavy;
    public bool is_wavy {
        get {
            return _is_wavy;
        }
        set {
            _is_wavy = value;
            if (_is_wavy) {
                pb_overlay.set_child (wavy_drawing_area);
                // Sync progress to wavy drawing
                wavy_drawing_area.queue_draw ();
                update_stop_indicator_position ();
                // Apply OSD styling if needed
                if (_is_osd) {
                    wavy_drawing_area.add_css_class ("osd");
                }
                // Check if flattening should be active based on current progress
                if (_progress >= 0.9 && !_is_flattening) {
                    _is_flattening = true;
                    _flatten_start_time = GLib.get_monotonic_time ();
                }
                // Start continuous animation automatically
                start_continuous_animation ();
            } else {
                pb_overlay.set_child (progressbar);
                // Sync progress to standard progressbar
                progressbar.set_fraction (_progress);
                // Reset stop indicator margin for standard progressbar
                stop_indicator.margin_end = 14;
                // Apply OSD styling if needed
                if (_is_osd) {
                    progressbar.add_css_class ("osd");
                }
                // Reset flattening state when leaving wavy mode
                _is_flattening = false;
                // Stop animation when leaving wavy mode
                stop_continuous_animation ();
            }
        }
    }

    /**
     * Constructs a new Progressbar.
     *
     * @since 1.0
     */
    public ProgressBar () {
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BoxLayout));
    }

    construct {
        stop_indicator.margin_end = 14;
        if (_is_wavy && _stop_indicator_visibility) {
            // Adjust margin to account for wave margin so stop indicator aligns with wavy area end
            stop_indicator.margin_end = 10;
        }
        stop_indicator.valign = Gtk.Align.CENTER;
        stop_indicator.halign = Gtk.Align.END;
        stop_indicator.set_visible (true);
        stop_indicator.add_css_class ("stop-indicator");

        // Setup wavy drawing area
        wavy_drawing_area.hexpand = true;
        wavy_drawing_area.set_size_request (-1, 6);
        wavy_drawing_area.set_draw_func (draw_wavy_progress);

        pb_overlay.hexpand = true;
        pb_overlay.add_overlay (stop_indicator);
        pb_overlay.set_child (progressbar);

        main_box.append (pb_overlay);
        main_box.valign = Gtk.Align.CENTER;
        main_box.hexpand = true;
        main_box.add_css_class ("progressbar");
        main_box.set_parent (this);

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

        is_osd = false;
        stop_indicator_visibility = true;
        is_wavy = false;

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
     * Updates the stop indicator position to align with the wavy progress end.
     */
    private void update_stop_indicator_position () {
        if (_is_wavy && _stop_indicator_visibility) {
            // No margin needed since the wavy progress fills the full width
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
            print ("ProgressBar accent color updated: r=%f, g=%f, b=%f (from %s, original: %f,%f,%f)\n",
                   r, g, b, is_from_application ? "application" : "desktop",
                   effective_color.r, effective_color.g, effective_color.b);
        } else {
            // Fallback to a visible color if no accent color is available
            accent_color = { 0.2f, 0.6f, 1.0f, 1.0f }; // Blue fallback
            print ("ProgressBar using fallback accent color\n");
        }
    }

    /**
     * Animation tick callback.
     */
    private bool on_animation_tick (Gtk.Widget widget, Gdk.FrameClock frame_clock) {
        // Stop animation if not enabled
        if (!_continuous_animation || !_animate) {
            _animation_tick_id = 0;
            return false; // Stop the tick callback
        }

        // Update wave phase for animation - create flowing effect
        _wave_phase += _wave_wavelength * 0.01; // Move the wave pattern forward
        if (_wave_phase > 2.0 * Math.PI) {
            _wave_phase -= 2.0 * Math.PI;
        }

        // Always redraw to show flattening animation progress
        wavy_drawing_area.queue_draw ();
        return true; // Continue animation
    }

    /**
     * Starts continuous wave animation (internal).
     */
    private void start_continuous_animation () {
        _continuous_animation = true;
        if (_animate && _animation_tick_id == 0) {
            _animation_tick_id = wavy_drawing_area.add_tick_callback (on_animation_tick);
        }
    }

    /**
     * Stops continuous wave animation (internal).
     */
    private void stop_continuous_animation () {
        _continuous_animation = false;
        if (_animation_tick_id != 0) {
            wavy_drawing_area.remove_tick_callback (_animation_tick_id);
            _animation_tick_id = 0;
        }
    }

    /**
     * Draws the wavy progress indicator using Cairo.
     */
    private void draw_wavy_progress (Gtk.DrawingArea area, Cairo.Context cr, int width, int height) {
        // Get theme colors
        Gdk.RGBA bg_color = { is_dark ? 1.0f : 0.0f, is_dark ? 1.0f : 0.0f, is_dark ? 1.0f : 0.0f, 0.12f };

        cr.set_line_width (_wave_thickness);
        cr.set_line_cap (Cairo.LineCap.ROUND);

        // Calculate progress width
        double progress_width = width * _progress;
        double center_y = height * 0.5;

        // Draw background as a simple straight line from progress end to full width
        if (progress_width < width) {
            cr.set_source_rgba (bg_color.red, bg_color.green, bg_color.blue, bg_color.alpha);
            cr.move_to (progress_width + 6.0, center_y);
            cr.line_to (width, center_y);
            cr.stroke ();
        }

        // Draw wavy progress using accent color
        if (progress_width > 0) {
            cr.set_source_rgba (((is_dark ? 0.50f : 0.60f) * accent_color.red), ((is_dark ? 0.50f : 0.60f) * accent_color.green), ((is_dark ? 0.50f : 0.60f) * accent_color.blue), 1.0f);

            // Create wavy path using properties
            double wave_height = _wave_amplitude;
            double wave_frequency = 2.0 * Math.PI / _wave_wavelength;

            // Apply time-based flattening if progress >= 90%
            if (_is_flattening) {
                int64 current_time = GLib.get_monotonic_time ();
                int64 elapsed = current_time - _flatten_start_time;

                if (elapsed < FLATTEN_DURATION) {
                    // Gradually reduce wave amplitude over 200ms
                    double flatten_factor = (double) elapsed / (double) FLATTEN_DURATION;
                    flatten_factor = Math.fmin (1.0, flatten_factor); // Clamp to max 1.0
                    wave_height *= (1.0 - flatten_factor); // Reduce amplitude
                } else {
                    // Flattening complete, wave is flat
                    wave_height = 0.0;
                }
            }

            cr.move_to (0, center_y);

            for (double x = 0; x <= progress_width; x += 1.0) {
                double y = center_y + Math.sin (x * wave_frequency + _wave_phase) * wave_height;
                cr.line_to (x, y);
            }

            cr.stroke ();
        }
    }
}