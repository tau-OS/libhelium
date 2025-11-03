/*
 * Copyright (c) 2025 Fyra Labs
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

namespace He {

/**
 * Size presets for the active indicator.
 */
    public enum ActiveIndicatorSize {
        /** Small size (24px) */
        SMALL,
        /** Medium size (32px) - default */
        MEDIUM,
        /** Large size (48px) */
        LARGE,
        /** Extra large size (64px) */
        XLARGE
    }

/**
 * Color presets for the active indicator.
 */
    public enum ActiveIndicatorColor {
        /** Surface color - typically black or theme foreground */
        SURFACE,
        /** Primary accent color */
        PRIMARY,
        /** Secondary accent color */
        SECONDARY,
        /** Tertiary accent color */
        TERTIARY
    }

/**
 * A customizable active indicator widget that displays a Helium atom with orbiting electrons.
 *
 * The widget shows a nucleus (center circle) with two electrons orbiting around it.
 * When active, the electrons animate in circular motion on different orbital paths.
 * The widget supports multiple size presets, color themes via CSS classes, and an optional background circle.
 *
 * The widget can be used both programmatically and in Gtk.Builder .ui files.
 * Colors are themed via CSS classes that automatically adapt to the current GTK theme.
 *
 * @since 1.0
 */
    public class ActiveIndicator : Gtk.Widget {

        // Constants for visual proportions
        private const double NUCLEUS_RATIO = 0.20;
        private const double ELECTRON_RATIO = 0.10;
        private const double ORBIT_INNER_RATIO = 0.4;
        private const double ORBIT_OUTER_RATIO = 0.7;
        private const double BACKGROUND_RATIO = 0.9;

        // Animation constants
        private const double ANIMATION_SPEED = 0.1; // radians per frame
        private const uint FRAME_RATE_MS = 16; // ~60fps (1000/60)
        private const double STATIC_ANGLE = Math.PI / 4.0; // 45 degrees

        // Size mappings
        private const int[] SIZE_PIXELS = { 24, 32, 48, 64 };

        // State variables
        private bool _active = false;
        private ActiveIndicatorSize _size_preset = ActiveIndicatorSize.MEDIUM;
        private ActiveIndicatorColor _color_preset = ActiveIndicatorColor.SURFACE;
        private bool _show_background = false;

        // Animation state
        private double _rotation_angle = 0.0;
        private uint _animation_id = 0;

        // Cached values for performance
        private int _widget_size = 32;
        private Gdk.RGBA _cached_fg_color = { 0, 0, 0, 1 };
        private Gdk.RGBA _cached_bg_color = { 0, 0, 0, 0.1f };
        private bool _colors_cached = false;
        private He.Desktop desktop = new He.Desktop();
        private ulong desktop_accent_handler = 0;
        private ulong desktop_scheme_handler = 0;
        private ulong desktop_contrast_handler = 0;
        private ulong desktop_prefers_handler = 0;
        private const double FALLBACK_DARK_ACCENT_R = 0.7450 * 255.0;
        private const double FALLBACK_DARK_ACCENT_G = 0.6270 * 255.0;
        private const double FALLBACK_DARK_ACCENT_B = 0.8590 * 255.0;
        private const double FALLBACK_LIGHT_ACCENT_R = 0.5490 * 255.0;
        private const double FALLBACK_LIGHT_ACCENT_G = 0.3370 * 255.0;
        private const double FALLBACK_LIGHT_ACCENT_B = 0.7490 * 255.0;

        /**
         * Emitted when the animation stops.
         */
        public signal void animation_stopped();

        /**
         * Whether the animation is currently active.
         */
        public bool active {
            get { return _active; }
            set { set_active_state_full(value); }
        }

        /**
         * The size preset for the widget.
         */
        public ActiveIndicatorSize size_preset {
            get { return _size_preset; }
            set { set_size_preset_full(value); }
        }

        /**
         * The color preset for the widget.
         */
        public ActiveIndicatorColor color_preset {
            get { return _color_preset; }
            set { set_color_preset_full(value); }
        }

        /**
         * Whether to show the background circle.
         */
        public bool show_background {
            get { return _show_background; }
            set {
                if (_show_background != value) {
                    _show_background = value;
                    queue_draw();
                }
            }
        }

        /**
         * Deprecated property for backward compatibility.
         */
        public bool is_active {
            get { return active; }
            set { active = value; }
        }

        static construct {
            set_css_name("activeindicator");
        }

        /**
         * Creates a new He. active indicator.
         */
        public ActiveIndicator(ActiveIndicatorSize size = ActiveIndicatorSize.MEDIUM,
            ActiveIndicatorColor color = ActiveIndicatorColor.SURFACE,
            bool show_bg = false) {
            Object(
                   size_preset: size,
                   color_preset: color,
                   show_background: show_bg,
                   hexpand: false,
                   vexpand: false,
                   halign: Gtk.Align.CENTER,
                   valign: Gtk.Align.CENTER
            );
        }

        construct {
            update_widget_size();
            update_css_classes();

            // Connect to style changes to invalidate color cache
            map.connect(() => {
                invalidate_cached_colors();
            });

            desktop_accent_handler = desktop.notify["accent-color"].connect(invalidate_cached_colors);
            desktop_prefers_handler = desktop.notify["prefers-color-scheme"].connect(invalidate_cached_colors);
            desktop_contrast_handler = desktop.notify["contrast"].connect(invalidate_cached_colors);
            desktop_scheme_handler = desktop.notify["ensor-scheme"].connect(invalidate_cached_colors);
        }

        private void invalidate_cached_colors() {
            _colors_cached = false;
            queue_draw();
        }

        private void disconnect_desktop_signals() {
            if (desktop_accent_handler != 0) {
                GLib.SignalHandler.disconnect(desktop, desktop_accent_handler);
                desktop_accent_handler = 0;
            }

            if (desktop_prefers_handler != 0) {
                GLib.SignalHandler.disconnect(desktop, desktop_prefers_handler);
                desktop_prefers_handler = 0;
            }

            if (desktop_contrast_handler != 0) {
                GLib.SignalHandler.disconnect(desktop, desktop_contrast_handler);
                desktop_contrast_handler = 0;
            }

            if (desktop_scheme_handler != 0) {
                GLib.SignalHandler.disconnect(desktop, desktop_scheme_handler);
                desktop_scheme_handler = 0;
            }
        }

        private void set_active_state_full(bool value) {
            if (_active == value)return;

            _active = value;

            if (_active) {
                start_animation();
            } else {
                stop_animation();
            }

            queue_draw();
        }

        private void set_size_preset_full(ActiveIndicatorSize value) {
            if (_size_preset == value)return;

            _size_preset = value;
            update_widget_size();
            queue_resize();
            queue_draw();
        }

        private void set_color_preset_full(ActiveIndicatorColor value) {
            if (_color_preset == value) {
                return;
            }

            _color_preset = value;
            update_css_classes();
            invalidate_cached_colors();
        }

        private void update_widget_size() {
            _widget_size = SIZE_PIXELS[_size_preset];
            set_size_request(_widget_size, _widget_size);
        }

        private void update_css_classes() {
            // Remove all color classes
            remove_css_class("surface");
            remove_css_class("primary");
            remove_css_class("secondary");
            remove_css_class("tertiary");

            // Add appropriate color class
            string class_name;
            switch (_color_preset) {
            case ActiveIndicatorColor.SURFACE:
                class_name = "surface";
                break;
            case ActiveIndicatorColor.PRIMARY:
                class_name = "primary";
                break;
            case ActiveIndicatorColor.SECONDARY:
                class_name = "secondary";
                break;
            case ActiveIndicatorColor.TERTIARY:
            default:
                class_name = "tertiary";
                break;
            }
            add_css_class(class_name);
        }

        private void cache_colors() {
            if (_colors_cached) {
                return;
            }

            if (!get_mapped()) {
                // Can't cache colors until widget is mapped
                return;
            }

            var scheme = build_dynamic_scheme();
            string fg_hex = resolve_foreground_hex(scheme);
            string bg_hex = scheme.get_surface();

            _cached_fg_color = rgba_from_hex(fg_hex, 1.0f);
            _cached_bg_color = rgba_from_hex(bg_hex, 0.1f);

            _colors_cached = true;
        }

        private DynamicScheme build_dynamic_scheme() {
            bool is_dark = desktop.prefers_color_scheme == He.Desktop.ColorScheme.DARK;
            double contrast = desktop.contrast;

            RGBColor accent = select_accent_color(is_dark);
            RGBColor normalized = ensure_argb_scale(accent);
            HCTColor source_hct = hct_from_int(rgb_to_argb_int(normalized));

            SchemeVariant variant = desktop.ensor_scheme.to_variant();
            switch (variant) {
            case SchemeVariant.VIBRANT:
                return new VibrantScheme().generate(source_hct, is_dark, contrast);
            case SchemeVariant.MUTED:
                return new MutedScheme().generate(source_hct, is_dark, contrast);
            case SchemeVariant.MONOCHROME:
                return new MonochromaticScheme().generate(source_hct, is_dark, contrast);
            case SchemeVariant.SALAD:
                return new SaladScheme().generate(source_hct, is_dark, contrast);
            case SchemeVariant.CONTENT:
                return new ContentScheme().generate(source_hct, is_dark, contrast);
            default:
                return new DefaultScheme().generate(source_hct, is_dark, contrast);
            }
        }

        private RGBColor select_accent_color(bool is_dark) {
            RGBColor? accent = desktop.accent_color;
            if (accent != null) {
                return (RGBColor) accent;
            }

            RGBColor fallback = {
                is_dark? FALLBACK_DARK_ACCENT_R : FALLBACK_LIGHT_ACCENT_R,
                is_dark ? FALLBACK_DARK_ACCENT_G : FALLBACK_LIGHT_ACCENT_G,
                is_dark ? FALLBACK_DARK_ACCENT_B : FALLBACK_LIGHT_ACCENT_B
            };

            return fallback;
        }

        private RGBColor ensure_argb_scale(RGBColor color) {
            bool already_scaled = color.r > 1.0 || color.g > 1.0 || color.b > 1.0;
            if (already_scaled) {
                RGBColor clamped = {
                    MathUtils.clamp_double(0.0, 255.0, color.r),
                    MathUtils.clamp_double(0.0, 255.0, color.g),
                    MathUtils.clamp_double(0.0, 255.0, color.b)
                };

                return clamped;
            }

            RGBColor scaled = {
                MathUtils.clamp_double(0.0, 255.0, color.r * 255.0),
                MathUtils.clamp_double(0.0, 255.0, color.g * 255.0),
                MathUtils.clamp_double(0.0, 255.0, color.b * 255.0)
            };

            return scaled;
        }

        private string resolve_foreground_hex(DynamicScheme scheme) {
            switch (_color_preset) {
            case ActiveIndicatorColor.PRIMARY :
                return scheme.get_primary();
            case ActiveIndicatorColor.SECONDARY:
                return scheme.get_secondary();
            case ActiveIndicatorColor.TERTIARY:
                return scheme.get_tertiary();
            default:
                return scheme.get_on_surface();
            }
        }

        private Gdk.RGBA rgba_from_hex(string hex, float alpha) {
            string trimmed = hex;
            if (trimmed.has_prefix("#")) {
                trimmed = trimmed.substring(1);
            }

            uint value = uint.parse(trimmed, 16);
            uint red = (value >> 16) & 0xFF;
            uint green = (value >> 8) & 0xFF;
            uint blue = value & 0xFF;

            Gdk.RGBA color = {
                (float) red / 255.0f,
                (float) green / 255.0f,
                (float) blue / 255.0f,
                alpha
            };

            return color;
        }

        private void start_animation() {
            if (_animation_id == 0) {
                _animation_id = Timeout.add(FRAME_RATE_MS, on_animation_tick);
            }
        }

        private void stop_animation() {
            if (_animation_id != 0) {
                Source.remove(_animation_id);
                _animation_id = 0;
                animation_stopped();
            }
        }

        private bool on_animation_tick() {
            if (!_active) {
                _animation_id = 0;
                return Source.REMOVE;
            }

            _rotation_angle += ANIMATION_SPEED;
            if (_rotation_angle >= 2 * Math.PI) {
                _rotation_angle -= 2 * Math.PI;
            }

            queue_draw();
            return Source.CONTINUE;
        }

        public override void snapshot(Gtk.Snapshot snapshot) {
            int width = get_width();
            int height = get_height();

            if (width <= 0 || height <= 0) {
                return;
            }

            // Always try to cache colors when drawing
            // cache_colors() will return early if already cached or widget not mapped
            cache_colors();

            var bounds = Graphene.Rect();
            bounds.init(0, 0, width, height);
            var cr = snapshot.append_cairo(bounds);

            draw_atom(cr, width, height);
        }

        private void draw_atom(Cairo.Context cr, int width, int height) {
            double center_x = width * 0.5;
            double center_y = height * 0.5;
            double size = double.min(width, height);

            // Calculate scaled dimensions (rounded for crisp rendering)
            double nucleus_radius = Math.round(size * NUCLEUS_RATIO * 0.5);
            double electron_radius = Math.round(size * ELECTRON_RATIO * 0.5);
            double orbit_inner = Math.round(size * ORBIT_INNER_RATIO * 0.5);
            double orbit_outer = Math.round(size * ORBIT_OUTER_RATIO * 0.5);
            double bg_radius = Math.round(size * BACKGROUND_RATIO * 0.5);

            // Draw background circle
            if (_show_background) {
                cr.set_source_rgba(_cached_bg_color.red, _cached_bg_color.green,
                                   _cached_bg_color.blue, _cached_bg_color.alpha);
                cr.arc(center_x, center_y, bg_radius, 0, 2 * Math.PI);
                cr.fill();
            }

            // Draw orbital paths (visible in both states, different opacity)
            double orbit_opacity = _active ? 0.3 : 0.2;
            cr.set_source_rgba(_cached_fg_color.red, _cached_fg_color.green,
                               _cached_fg_color.blue, orbit_opacity);
            cr.set_line_width(Math.fmax(1.0, size / 32.0));

            cr.arc(center_x, center_y, orbit_inner, 0, 2 * Math.PI);
            cr.stroke();
            cr.arc(center_x, center_y, orbit_outer, 0, 2 * Math.PI);
            cr.stroke();

            // Draw nucleus
            cr.set_source_rgba(_cached_fg_color.red, _cached_fg_color.green,
                               _cached_fg_color.blue, _cached_fg_color.alpha);
            cr.arc(center_x, center_y, nucleus_radius, 0, 2 * Math.PI);
            cr.fill();
            cr.set_line_width(Math.fmax(1.0, size / 48.0));
            cr.arc(center_x, center_y, nucleus_radius, 0, 2 * Math.PI);
            cr.stroke();

            // Draw electrons
            if (_active) {
                draw_animated_electrons(cr, center_x, center_y, orbit_inner, orbit_outer, electron_radius);
            } else {
                draw_static_electrons(cr, center_x, center_y, orbit_inner, orbit_outer, electron_radius);
            }
        }

        private void draw_animated_electrons(Cairo.Context cr, double center_x, double center_y,
                                             double orbit_inner, double orbit_outer, double electron_radius) {
            // Inner electron (clockwise)
            double x1 = center_x + orbit_inner * Math.cos(_rotation_angle);
            double y1 = center_y + orbit_inner * Math.sin(_rotation_angle);
            cr.arc(x1, y1, electron_radius, 0, 2 * Math.PI);
            cr.fill();

            // Outer electron (counter-clockwise)
            double x2 = center_x + orbit_outer * Math.cos(-_rotation_angle);
            double y2 = center_y + orbit_outer * Math.sin(-_rotation_angle);
            cr.arc(x2, y2, electron_radius, 0, 2 * Math.PI);
            cr.fill();
        }

        private void draw_static_electrons(Cairo.Context cr, double center_x, double center_y,
                                           double orbit_inner, double orbit_outer, double electron_radius) {
            // Inner electron at 45°
            double x1 = center_x + orbit_inner * Math.cos(STATIC_ANGLE);
            double y1 = center_y + orbit_inner * Math.sin(STATIC_ANGLE);
            cr.arc(x1, y1, electron_radius, 0, 2 * Math.PI);
            cr.fill();

            // Outer electron at 225° (opposite)
            double x2 = center_x + orbit_outer * Math.cos(STATIC_ANGLE + Math.PI);
            double y2 = center_y + orbit_outer * Math.sin(STATIC_ANGLE + Math.PI);
            cr.arc(x2, y2, electron_radius, 0, 2 * Math.PI);
            cr.fill();
        }

        /**
         * Starts the animation.
         */
        public void start() {
            active = true;
        }

        /**
         * Stops the animation.
         */
        public void stop() {
            active = false;
        }

        /**
         * Toggles the animation state.
         */
        public void toggle() {
            active = !active;
        }

        public override void dispose() {
            disconnect_desktop_signals();
            stop_animation();
            base.dispose();
        }
    }
}