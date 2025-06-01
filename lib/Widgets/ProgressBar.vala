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
    private Gdk.RGBA _accent_color = { 1, 1, 1, 1 };
    public Gdk.RGBA accent_color {
        get { return _accent_color; }
        set { _accent_color = value; wavy_drawing_area.queue_draw (); }
    }

    /**
     * The progressbar inside the Progressbar.
     */
    public Gtk.ProgressBar progressbar = new Gtk.ProgressBar ();

    /**
     * The wavy drawing area for custom wavy progressbar.
     */
    private Gtk.DrawingArea wavy_drawing_area = new Gtk.DrawingArea ();

    /**
     * Progress value from 0.0 to 1.0.
     */
    private double _progress = 0.0;
    public double progress {
        get {
            return _progress;
        }
        set {
            _progress = Math.fmax (0.0, Math.fmin (1.0, value));
            if (_is_wavy) {
                wavy_drawing_area.queue_draw ();
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
                // Apply OSD styling if needed
                if (_is_osd) {
                    wavy_drawing_area.add_css_class ("osd");
                }
            } else {
                pb_overlay.set_child (progressbar);
                // Sync progress to standard progressbar
                progressbar.set_fraction (_progress);
                // Apply OSD styling if needed
                if (_is_osd) {
                    progressbar.add_css_class ("osd");
                }
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
     * Draws the wavy progress indicator using Cairo.
     */
    private void draw_wavy_progress (Gtk.DrawingArea area, Cairo.Context cr, int width, int height) {
        // Get theme colors
        Gdk.RGBA bg_color = { is_dark ? 1.0f : 0.0f, is_dark ? 1.0f : 0.0f, is_dark ? 1.0f : 0.0f, 0.12f };

        cr.set_line_width (1.0);

        // Draw background
        cr.set_source_rgba (bg_color.red, bg_color.green, bg_color.blue, bg_color.alpha);
        cr.rectangle (0, 0, width, height);
        cr.fill ();

        // Calculate progress width
        double progress_width = width * _progress;
        if (progress_width <= 0) {
            return;
        }

        // Draw wavy progress using accent color
        cr.set_source_rgba (((is_dark ? 0.50 : 0.50) * accent_color.red), ((is_dark ? 0.50 : 0.50) * accent_color.green), ((is_dark ? 0.50 : 0.50) * accent_color.blue), 1);

        // Create wavy path
        double wave_height = height * 0.3;
        double wave_frequency = 0.1;
        double center_y = height * 0.5;

        cr.move_to (0, center_y);

        for (double x = 0; x <= progress_width; x += 1.0) {
            double y = center_y + Math.sin (x * wave_frequency) * wave_height;
            cr.line_to (x, y);
        }

        // Complete the filled area
        cr.line_to (progress_width, height);
        cr.line_to (0, height);
        cr.close_path ();
        cr.fill ();

        // Draw wavy top edge with 1px line
        cr.set_source_rgba (((is_dark ? 0.50 : 0.50) * accent_color.red), ((is_dark ? 0.50 : 0.50) * accent_color.green), ((is_dark ? 0.50 : 0.50) * accent_color.blue), 1);
        cr.move_to (0, center_y);
        for (double x = 0; x <= progress_width; x += 1.0) {
            double y = center_y + Math.sin (x * wave_frequency) * wave_height;
            cr.line_to (x, y);
        }
        cr.stroke ();
    }
}
