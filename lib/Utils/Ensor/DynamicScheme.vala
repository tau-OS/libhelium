namespace He {
    public enum SchemeVariant {
        DEFAULT,
        VIBRANT,
        MUTED,
        MONOCHROME,
        SALAD,
        CONTENT
    }

    public enum SchemePlatform {
        DESKTOP,
        PHONE
    }

    public class DynamicScheme : Object {
        public HCTColor hct;
        public SchemeVariant variant;
        public bool is_dark;
        public double contrast_level;
        public TonalPalette primary;
        public TonalPalette secondary;
        public TonalPalette tertiary;
        public TonalPalette neutral;
        public TonalPalette neutral_variant;
        public TonalPalette error;
        public SchemePlatform platform;

        // Cached Scheme instance - singleton pattern for the color definitions
        private static Scheme? _cached_scheme = null;
        private static Scheme cached_scheme {
            get {
                if (_cached_scheme == null) {
                    _cached_scheme = new Scheme ();
                }
                return _cached_scheme;
            }
        }

        // Cached DynamicColor instances - these are stateless and can be reused
        private static DynamicColor? _primary_key_color = null;
        private static DynamicColor? _secondary_key_color = null;
        private static DynamicColor? _tertiary_key_color = null;
        private static DynamicColor? _neutral_key_color = null;
        private static DynamicColor? _neutral_variant_key_color = null;
        private static DynamicColor? _background_color = null;
        private static DynamicColor? _on_background_color = null;
        private static DynamicColor? _surface_color = null;
        private static DynamicColor? _surface_dim_color = null;
        private static DynamicColor? _surface_bright_color = null;
        private static DynamicColor? _surface_container_lowest_color = null;
        private static DynamicColor? _surface_container_low_color = null;
        private static DynamicColor? _surface_container_color = null;
        private static DynamicColor? _surface_container_high_color = null;
        private static DynamicColor? _surface_container_highest_color = null;
        private static DynamicColor? _surface_tint_color = null;
        private static DynamicColor? _on_surface_color = null;
        private static DynamicColor? _surface_variant_color = null;
        private static DynamicColor? _on_surface_variant_color = null;
        private static DynamicColor? _inverse_surface_color = null;
        private static DynamicColor? _inverse_on_surface_color = null;
        private static DynamicColor? _outline_color = null;
        private static DynamicColor? _outline_variant_color = null;
        private static DynamicColor? _shadow_color = null;
        private static DynamicColor? _scrim_color = null;
        private static DynamicColor? _primary_color = null;
        private static DynamicColor? _primary_dim_color = null;
        private static DynamicColor? _on_primary_color = null;
        private static DynamicColor? _primary_container_color = null;
        private static DynamicColor? _on_primary_container_color = null;
        private static DynamicColor? _primary_fixed_color = null;
        private static DynamicColor? _primary_fixed_dim_color = null;
        private static DynamicColor? _on_primary_fixed_color = null;
        private static DynamicColor? _on_primary_fixed_variant_color = null;
        private static DynamicColor? _inverse_primary_color = null;
        private static DynamicColor? _secondary_color = null;
        private static DynamicColor? _secondary_dim_color = null;
        private static DynamicColor? _on_secondary_color = null;
        private static DynamicColor? _secondary_container_color = null;
        private static DynamicColor? _on_secondary_container_color = null;
        private static DynamicColor? _secondary_fixed_color = null;
        private static DynamicColor? _secondary_fixed_dim_color = null;
        private static DynamicColor? _on_secondary_fixed_color = null;
        private static DynamicColor? _on_secondary_fixed_variant_color = null;
        private static DynamicColor? _tertiary_color = null;
        private static DynamicColor? _tertiary_dim_color = null;
        private static DynamicColor? _on_tertiary_color = null;
        private static DynamicColor? _tertiary_container_color = null;
        private static DynamicColor? _on_tertiary_container_color = null;
        private static DynamicColor? _tertiary_fixed_color = null;
        private static DynamicColor? _tertiary_fixed_dim_color = null;
        private static DynamicColor? _on_tertiary_fixed_color = null;
        private static DynamicColor? _on_tertiary_fixed_variant_color = null;
        private static DynamicColor? _error_color = null;
        private static DynamicColor? _error_dim_color = null;
        private static DynamicColor? _on_error_color = null;
        private static DynamicColor? _error_container_color = null;
        private static DynamicColor? _on_error_container_color = null;
        private static DynamicColor? _control_activated_color = null;
        private static DynamicColor? _control_normal_color = null;
        private static DynamicColor? _text_primary_inverse_color = null;

        // Per-instance cache for computed hex color results
        // Key format: color_name, Value: computed hex string
        private Gee.HashMap<string, string> _color_cache;

        public DynamicScheme (HCTColor hct,
            SchemeVariant variant,
            bool is_dark,
            double contrast_level,
            TonalPalette primary,
            TonalPalette secondary,
            TonalPalette? tertiary,
            TonalPalette neutral,
            TonalPalette neutral_variant,
            TonalPalette? error,
            SchemePlatform platform = SchemePlatform.DESKTOP) {

            this.hct = hct;
            this.variant = variant;
            this.is_dark = is_dark;
            this.contrast_level = contrast_level;
            this.primary = primary;
            this.secondary = secondary;
            this.tertiary = tertiary;
            this.neutral = neutral;
            this.neutral_variant = neutral_variant;
            this.error = error != null ? error : TonalPalette.from_hue_and_chroma (piecewise_val (
                                                                                                  hct,
                                                                                                  new double[] { 0, 3, 13, 23, 33, 43, 153, 273, 360 },
                                                                                                  new double[] { 12, 22, 32, 12, 22, 32, 22, 12 }), Math.fmax (hct.c, 60.0));
            this.platform = platform;

            // Initialize the per-instance color cache
            this._color_cache = new Gee.HashMap<string, string> ();
        }

        public static DynamicScheme from (DynamicScheme scheme, bool is_dark, double contrast_level) {
            return new DynamicScheme (
                                      scheme.hct,
                                      scheme.variant,
                                      is_dark,
                                      contrast_level,
                                      scheme.primary,
                                      scheme.secondary,
                                      scheme.tertiary,
                                      scheme.neutral,
                                      scheme.neutral_variant,
                                      scheme.error,
                                      scheme.platform
            );
        }

        public HCTColor get_hct (DynamicColor dynamic_color) {
            return dynamic_color.get_hct (this, dynamic_color);
        }

        public double get_hue (DynamicColor dynamic_color) {
            return dynamic_color.get_hue (this);
        }

        public double get_rotated_hue (double[] hb, double[] r) {
            double rotation = piecewise_val (hct, hb, r);
            if (MathUtils.min (hb.length - 1, r.length) <= 0) {
                rotation = 0;
            }
            return MathUtils.sanitize_degrees (hct.h + rotation);
        }

        // Helper to get cached hex or compute and cache it
        private string get_cached_or_compute (string key, ref DynamicColor? color_cache, owned Scheme.ColorFactory factory) {
            // Check instance cache first
            if (_color_cache.has_key (key)) {
                return _color_cache.get (key);
            }

            // Ensure DynamicColor is cached
            if (color_cache == null) {
                color_cache = factory ();
            }

            // Compute the hex value
            string hex = hex_from_hct (color_cache.get_hct (this, color_cache));

            // Cache the result
            _color_cache.set (key, hex);

            return hex;
        }

        // Helper to get cached HCT or compute it
        private HCTColor get_cached_hct_or_compute (string key, ref DynamicColor? color_cache, owned Scheme.ColorFactory factory) {
            // Ensure DynamicColor is cached
            if (color_cache == null) {
                color_cache = factory ();
            }

            return color_cache.get_hct (this, color_cache);
        }

        public string get_primary_key () {
            return get_cached_or_compute ("primary_key", ref _primary_key_color, () => cached_scheme.primary_key ());
        }

        public string get_secondary_key () {
            return get_cached_or_compute ("secondary_key", ref _secondary_key_color, () => cached_scheme.secondary_key ());
        }

        public string get_tertiary_key () {
            return get_cached_or_compute ("tertiary_key", ref _tertiary_key_color, () => cached_scheme.tertiary_key ());
        }

        public string get_neutral_key () {
            return get_cached_or_compute ("neutral_key", ref _neutral_key_color, () => cached_scheme.neutral_key ());
        }

        public string get_neutral_variant_key () {
            return get_cached_or_compute ("neutral_variant_key", ref _neutral_variant_key_color, () => cached_scheme.neutral_variant_key ());
        }

        public string get_background () {
            return get_cached_or_compute ("background", ref _background_color, () => cached_scheme.background ());
        }

        public HCTColor get_background_hct () {
            return get_cached_hct_or_compute ("background_hct", ref _background_color, () => cached_scheme.background ());
        }

        public string get_on_background () {
            return get_cached_or_compute ("on_background", ref _on_background_color, () => cached_scheme.on_background ());
        }

        public string get_surface () {
            return get_cached_or_compute ("surface", ref _surface_color, () => cached_scheme.surface ());
        }

        public string get_surface_dim () {
            return get_cached_or_compute ("surface_dim", ref _surface_dim_color, () => cached_scheme.surface_dim ());
        }

        public string get_surface_bright () {
            return get_cached_or_compute ("surface_bright", ref _surface_bright_color, () => cached_scheme.surface_bright ());
        }

        public string get_surface_container_lowest () {
            return get_cached_or_compute ("surface_container_lowest", ref _surface_container_lowest_color, () => cached_scheme.surface_container_lowest ());
        }

        public string get_surface_container_low () {
            return get_cached_or_compute ("surface_container_low", ref _surface_container_low_color, () => cached_scheme.surface_container_low ());
        }

        public string get_surface_container () {
            return get_cached_or_compute ("surface_container", ref _surface_container_color, () => cached_scheme.surface_container ());
        }

        public string get_surface_container_high () {
            return get_cached_or_compute ("surface_container_high", ref _surface_container_high_color, () => cached_scheme.surface_container_high ());
        }

        public string get_surface_container_highest () {
            return get_cached_or_compute ("surface_container_highest", ref _surface_container_highest_color, () => cached_scheme.surface_container_highest ());
        }

        public string get_surface_tint () {
            return get_cached_or_compute ("surface_tint", ref _surface_tint_color, () => cached_scheme.surface_tint ());
        }

        public string get_on_surface () {
            return get_cached_or_compute ("on_surface", ref _on_surface_color, () => cached_scheme.on_surface ());
        }

        public string get_surface_variant () {
            return get_cached_or_compute ("surface_variant", ref _surface_variant_color, () => cached_scheme.surface_variant ());
        }

        public string get_on_surface_variant () {
            return get_cached_or_compute ("on_surface_variant", ref _on_surface_variant_color, () => cached_scheme.on_surface_variant ());
        }

        public string get_inverse_surface () {
            return get_cached_or_compute ("inverse_surface", ref _inverse_surface_color, () => cached_scheme.inverse_surface ());
        }

        public string get_inverse_on_surface () {
            return get_cached_or_compute ("inverse_on_surface", ref _inverse_on_surface_color, () => cached_scheme.inverse_on_surface ());
        }

        public string get_outline () {
            return get_cached_or_compute ("outline", ref _outline_color, () => cached_scheme.outline ());
        }

        public string get_outline_variant () {
            return get_cached_or_compute ("outline_variant", ref _outline_variant_color, () => cached_scheme.outline_variant ());
        }

        public string get_shadow () {
            return get_cached_or_compute ("shadow", ref _shadow_color, () => cached_scheme.shadow ());
        }

        public string get_scrim () {
            return get_cached_or_compute ("scrim", ref _scrim_color, () => cached_scheme.scrim ());
        }

        public string get_primary () {
            return get_cached_or_compute ("primary", ref _primary_color, () => cached_scheme.primary ());
        }

        public string get_primary_dim () {
            return get_cached_or_compute ("primary_dim", ref _primary_dim_color, () => cached_scheme.primary_dim ());
        }

        public string get_on_primary () {
            return get_cached_or_compute ("on_primary", ref _on_primary_color, () => cached_scheme.on_primary ());
        }

        public string get_primary_container () {
            return get_cached_or_compute ("primary_container", ref _primary_container_color, () => cached_scheme.primary_container ());
        }

        public string get_on_primary_container () {
            return get_cached_or_compute ("on_primary_container", ref _on_primary_container_color, () => cached_scheme.on_primary_container ());
        }

        public string get_primary_fixed () {
            return get_cached_or_compute ("primary_fixed", ref _primary_fixed_color, () => cached_scheme.primary_fixed ());
        }

        public string get_primary_fixed_dim () {
            return get_cached_or_compute ("primary_fixed_dim", ref _primary_fixed_dim_color, () => cached_scheme.primary_fixed_dim ());
        }

        public string get_on_primary_fixed () {
            return get_cached_or_compute ("on_primary_fixed", ref _on_primary_fixed_color, () => cached_scheme.on_primary_fixed ());
        }

        public string get_on_primary_fixed_variant () {
            return get_cached_or_compute ("on_primary_fixed_variant", ref _on_primary_fixed_variant_color, () => cached_scheme.on_primary_fixed_variant ());
        }

        public string get_inverse_primary () {
            return get_cached_or_compute ("inverse_primary", ref _inverse_primary_color, () => cached_scheme.inverse_primary ());
        }

        public string get_secondary () {
            return get_cached_or_compute ("secondary", ref _secondary_color, () => cached_scheme.secondary ());
        }

        public string get_secondary_dim () {
            return get_cached_or_compute ("secondary_dim", ref _secondary_dim_color, () => cached_scheme.secondary_dim ());
        }

        public string get_on_secondary () {
            return get_cached_or_compute ("on_secondary", ref _on_secondary_color, () => cached_scheme.on_secondary ());
        }

        public string get_secondary_container () {
            return get_cached_or_compute ("secondary_container", ref _secondary_container_color, () => cached_scheme.secondary_container ());
        }

        public string get_on_secondary_container () {
            return get_cached_or_compute ("on_secondary_container", ref _on_secondary_container_color, () => cached_scheme.on_secondary_container ());
        }

        public string get_secondary_fixed () {
            return get_cached_or_compute ("secondary_fixed", ref _secondary_fixed_color, () => cached_scheme.secondary_fixed ());
        }

        public string get_secondary_fixed_dim () {
            return get_cached_or_compute ("secondary_fixed_dim", ref _secondary_fixed_dim_color, () => cached_scheme.secondary_fixed_dim ());
        }

        public string get_on_secondary_fixed () {
            return get_cached_or_compute ("on_secondary_fixed", ref _on_secondary_fixed_color, () => cached_scheme.on_secondary_fixed ());
        }

        public string get_on_secondary_fixed_variant () {
            return get_cached_or_compute ("on_secondary_fixed_variant", ref _on_secondary_fixed_variant_color, () => cached_scheme.on_secondary_fixed_variant ());
        }

        public string get_tertiary () {
            return get_cached_or_compute ("tertiary", ref _tertiary_color, () => cached_scheme.tertiary ());
        }

        public string get_tertiary_dim () {
            return get_cached_or_compute ("tertiary_dim", ref _tertiary_dim_color, () => cached_scheme.tertiary_dim ());
        }

        public string get_on_tertiary () {
            return get_cached_or_compute ("on_tertiary", ref _on_tertiary_color, () => cached_scheme.on_tertiary ());
        }

        public string get_tertiary_container () {
            return get_cached_or_compute ("tertiary_container", ref _tertiary_container_color, () => cached_scheme.tertiary_container ());
        }

        public string get_on_tertiary_container () {
            return get_cached_or_compute ("on_tertiary_container", ref _on_tertiary_container_color, () => cached_scheme.on_tertiary_container ());
        }

        public string get_tertiary_fixed () {
            return get_cached_or_compute ("tertiary_fixed", ref _tertiary_fixed_color, () => cached_scheme.tertiary_fixed ());
        }

        public string get_tertiary_fixed_dim () {
            return get_cached_or_compute ("tertiary_fixed_dim", ref _tertiary_fixed_dim_color, () => cached_scheme.tertiary_fixed_dim ());
        }

        public string get_on_tertiary_fixed () {
            return get_cached_or_compute ("on_tertiary_fixed", ref _on_tertiary_fixed_color, () => cached_scheme.on_tertiary_fixed ());
        }

        public string get_on_tertiary_fixed_variant () {
            return get_cached_or_compute ("on_tertiary_fixed_variant", ref _on_tertiary_fixed_variant_color, () => cached_scheme.on_tertiary_fixed_variant ());
        }

        public string get_error () {
            return get_cached_or_compute ("error", ref _error_color, () => cached_scheme.error ());
        }

        public string get_error_dim () {
            return get_cached_or_compute ("error_dim", ref _error_dim_color, () => cached_scheme.error_dim ());
        }

        public string get_on_error () {
            return get_cached_or_compute ("on_error", ref _on_error_color, () => cached_scheme.on_error ());
        }

        public string get_error_container () {
            return get_cached_or_compute ("error_container", ref _error_container_color, () => cached_scheme.error_container ());
        }

        public string get_on_error_container () {
            return get_cached_or_compute ("on_error_container", ref _on_error_container_color, () => cached_scheme.on_error_container ());
        }

        public string get_control_activated () {
            return get_cached_or_compute ("control_activated", ref _control_activated_color, () => cached_scheme.control_activated ());
        }

        public string get_control_normal () {
            return get_cached_or_compute ("control_normal", ref _control_normal_color, () => cached_scheme.control_normal ());
        }

        public string get_text_primary_inverse () {
            return get_cached_or_compute ("text_primary_inverse", ref _text_primary_inverse_color, () => cached_scheme.text_primary_inverse ());
        }

        /**
         * Clears the per-instance color cache.
         * Call this if you need to force recomputation of colors.
         */
        public void invalidate_cache () {
            _color_cache.clear ();
        }
    }
}
