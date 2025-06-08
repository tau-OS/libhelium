namespace He {
    public enum SchemeVariant {
        DEFAULT,
        MUTED,
        VIBRANT,
        SALAD,
        MONOCHROME,
        CONTENT
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

        public DynamicScheme(HCTColor hct,
            SchemeVariant variant,
            bool is_dark,
            double contrast_level,
            TonalPalette primary,
            TonalPalette secondary,
            TonalPalette? tertiary,
            TonalPalette neutral,
            TonalPalette neutral_variant,
            TonalPalette? error) {

            this.hct = hct;
            this.variant = variant;
            this.is_dark = is_dark;
            this.contrast_level = contrast_level;
            this.primary = primary;
            this.secondary = secondary;
            this.tertiary = tertiary;
            this.neutral = neutral;
            this.neutral_variant = neutral_variant;
            this.error = error != null ? error : TonalPalette.from_hue_and_chroma(piecewise_val(
                                                                                                hct,
                                                                                                new double[] { 0, 3, 13, 23, 33, 43, 153, 273, 360 },
                                                                                                new double[] { 12, 22, 32, 12, 22, 32, 22, 12 }), Math.fmax(hct.c, 80.0));
        }

        public HCTColor get_hct(DynamicColor dynamic_color) {
            return dynamic_color.get_hct(this, dynamic_color);
        }

        public double get_hue(DynamicColor dynamic_color) {
            return dynamic_color.get_hue(this);
        }

        public double get_rotated_hue(double[] hb, double[] r) {
            double rotation = piecewise_val(hct, hb, r);
            if (MathUtils.min(hb.length - 1, r.length) <= 0) {
                rotation = 0;
            }
            return MathUtils.sanitize_degrees(hct.h + rotation);
        }

        public string get_primary_key() {
            return hex_from_hct(new Scheme().primary_key().get_hct(this, new Scheme().primary_key()));
        }

        public string get_secondary_key() {
            return hex_from_hct(new Scheme().secondary_key().get_hct(this, new Scheme().secondary_key()));
        }

        public string get_tertiary_key() {
            return hex_from_hct(new Scheme().tertiary_key().get_hct(this, new Scheme().tertiary_key()));
        }

        public string get_neutral_key() {
            return hex_from_hct(new Scheme().neutral_key().get_hct(this, new Scheme().neutral_key()));
        }

        public string get_neutral_variant_key() {
            return hex_from_hct(new Scheme().neutral_variant_key().get_hct(this, new Scheme().neutral_variant_key()));
        }

        public string get_background() {
            return hex_from_hct(new Scheme().background().get_hct(this, new Scheme().background()));
        }

        public HCTColor get_background_hct() {
            return new Scheme().background().get_hct(this, new Scheme().background());
        }

        public string get_on_background() {
            return hex_from_hct(new Scheme().on_background().get_hct(this, new Scheme().on_background()));
        }

        public string get_surface() {
            return hex_from_hct(new Scheme().surface().get_hct(this, new Scheme().surface()));
        }

        public string get_surface_dim() {
            return hex_from_hct(new Scheme().surface_dim().get_hct(this, new Scheme().surface_dim()));
        }

        public string get_surface_bright() {
            return hex_from_hct(new Scheme().surface_bright().get_hct(this, new Scheme().surface_bright()));
        }

        public string get_surface_container_lowest() {
            return hex_from_hct(new Scheme().surface_container_lowest().get_hct(this, new Scheme().surface_container_lowest()));
        }

        public string get_surface_container_low() {
            return hex_from_hct(new Scheme().surface_container_low().get_hct(this, new Scheme().surface_container_low()));
        }

        public string get_surface_container() {
            return hex_from_hct(new Scheme().surface_container().get_hct(this, new Scheme().surface_container()));
        }

        public string get_surface_container_high() {
            return hex_from_hct(new Scheme().surface_container_high().get_hct(this, new Scheme().surface_container_high()));
        }

        public string get_surface_container_highest() {
            return hex_from_hct(new Scheme().surface_container_highest().get_hct(this, new Scheme().surface_container_highest()));
        }

        public string get_on_surface() {
            return hex_from_hct(new Scheme().on_surface().get_hct(this, new Scheme().on_surface()));
        }

        public string get_surface_variant() {
            return hex_from_hct(new Scheme().surface_variant().get_hct(this, new Scheme().surface_variant()));
        }

        public string get_on_surface_variant() {
            return hex_from_hct(new Scheme().on_surface_variant().get_hct(this, new Scheme().on_surface_variant()));
        }

        public string get_inverse_surface() {
            return hex_from_hct(new Scheme().inverse_surface().get_hct(this, new Scheme().inverse_surface()));
        }

        public string get_inverse_on_surface() {
            return hex_from_hct(new Scheme().inverse_on_surface().get_hct(this, new Scheme().inverse_on_surface()));
        }

        public string get_outline() {
            return hex_from_hct(new Scheme().outline().get_hct(this, new Scheme().outline()));
        }

        public string get_outline_variant() {
            return hex_from_hct(new Scheme().outline_variant().get_hct(this, new Scheme().outline_variant()));
        }

        public string get_shadow() {
            return hex_from_hct(new Scheme().shadow().get_hct(this, new Scheme().shadow()));
        }

        public string get_scrim() {
            return hex_from_hct(new Scheme().scrim().get_hct(this, new Scheme().scrim()));
        }

        public string get_primary() {
            return hex_from_hct(new Scheme().primary().get_hct(this, new Scheme().primary()));
        }

        public string get_on_primary() {
            return hex_from_hct(new Scheme().on_primary().get_hct(this, new Scheme().on_primary()));
        }

        public string get_primary_container() {
            return hex_from_hct(new Scheme().primary_container().get_hct(this, new Scheme().primary_container()));
        }

        public string get_on_primary_container() {
            return hex_from_hct(new Scheme().on_primary_container().get_hct(this, new Scheme().on_primary_container()));
        }

        public string get_inverse_primary() {
            return hex_from_hct(new Scheme().inverse_primary().get_hct(this, new Scheme().inverse_primary()));
        }

        public string get_secondary() {
            return hex_from_hct(new Scheme().secondary().get_hct(this, new Scheme().secondary()));
        }

        public string get_on_secondary() {
            return hex_from_hct(new Scheme().on_secondary().get_hct(this, new Scheme().on_secondary()));
        }

        public string get_secondary_container() {
            return hex_from_hct(new Scheme().secondary_container().get_hct(this, new Scheme().secondary_container()));
        }

        public string get_on_secondary_container() {
            return hex_from_hct(new Scheme().on_secondary_container().get_hct(this, new Scheme().on_secondary_container()));
        }

        public string get_tertiary() {
            return hex_from_hct(new Scheme().tertiary().get_hct(this, new Scheme().tertiary()));
        }

        public string get_on_tertiary() {
            return hex_from_hct(new Scheme().on_tertiary().get_hct(this, new Scheme().on_tertiary()));
        }

        public string get_tertiary_container() {
            return hex_from_hct(new Scheme().tertiary_container().get_hct(this, new Scheme().tertiary_container()));
        }

        public string get_on_tertiary_container() {
            return hex_from_hct(new Scheme().on_tertiary_container().get_hct(this, new Scheme().on_tertiary_container()));
        }

        public string get_error() {
            return hex_from_hct(new Scheme().error().get_hct(this, new Scheme().error()));
        }

        public string get_on_error() {
            return hex_from_hct(new Scheme().on_error().get_hct(this, new Scheme().on_error()));
        }

        public string get_error_container() {
            return hex_from_hct(new Scheme().error_container().get_hct(this, new Scheme().error_container()));
        }

        public string get_on_error_container() {
            return hex_from_hct(new Scheme().on_error_container().get_hct(this, new Scheme().on_error_container()));
        }
    }
}