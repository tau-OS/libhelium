namespace He {
    public enum SchemeVariant {
        DEFAULT,
        VIBRANT,
        MUTED,
        MONOCHROME,
        SALAD,
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
            TonalPalette tertiary,
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
            this.error = error != null ? error : TonalPalette.from_hue_and_chroma(25.0, 84.0);

            warning ("CREATED SCHEME\n");
        }

        public HCTColor get_hct(DynamicColor dynamic_color) {
            return dynamic_color.get_hct(this);
        }

        public string get_background() {
            return hex_from_hct(new Scheme().background(this).get_hct(this));
        }

        public string get_on_background() {
            return hex_from_hct(new Scheme().on_background(this).get_hct(this));
        }

        public string get_surface() {
            return hex_from_hct(new Scheme().surface(this).get_hct(this));
        }

        public string get_surface_dim() {
            return hex_from_hct(new Scheme().surface_dim(this).get_hct(this));
        }

        public string get_surface_bright() {
            return hex_from_hct(new Scheme().surface_bright(this).get_hct(this));
        }

        public string get_surface_container_lowest() {
            return hex_from_hct(new Scheme().surface_container_lowest(this).get_hct(this));
        }

        public string get_surface_container_low() {
            return hex_from_hct(new Scheme().surface_container_low(this).get_hct(this));
        }

        public string get_surface_container() {
            return hex_from_hct(new Scheme().surface_container(this).get_hct(this));
        }

        public string get_surface_container_high() {
            return hex_from_hct(new Scheme().surface_container_high(this).get_hct(this));
        }

        public string get_surface_container_highest() {
            return hex_from_hct(new Scheme().surface_container_highest(this).get_hct(this));
        }

        public string get_on_surface() {
            return hex_from_hct(new Scheme().on_surface(this).get_hct(this));
        }

        public string get_surface_variant() {
            return hex_from_hct(new Scheme().surface_variant(this).get_hct(this));
        }

        public string get_on_surface_variant() {
            return hex_from_hct(new Scheme().on_surface_variant(this).get_hct(this));
        }

        public string get_inverse_surface() {
            return hex_from_hct(new Scheme().inverse_surface(this).get_hct(this));
        }

        public string get_inverse_on_surface() {
            return hex_from_hct(new Scheme().inverse_on_surface(this).get_hct(this));
        }

        public string get_outline() {
            return hex_from_hct(new Scheme().outline(this).get_hct(this));
        }

        public string get_outline_variant() {
            return hex_from_hct(new Scheme().outline_variant(this).get_hct(this));
        }

        public string get_shadow() {
            return hex_from_hct(new Scheme().shadow(this).get_hct(this));
        }

        public string get_scrim() {
            return hex_from_hct(new Scheme().scrim(this).get_hct(this));
        }

        public string get_primary() {
            return hex_from_hct(new Scheme().primary(this).get_hct(this));
        }

        public string get_on_primary() {
            return hex_from_hct(new Scheme().on_primary(this).get_hct(this));
        }

        public string get_primary_container() {
            return hex_from_hct(new Scheme().primary_container(this).get_hct(this));
        }

        public string get_on_primary_container() {
            return hex_from_hct(new Scheme().on_primary_container(this).get_hct(this));
        }

        public string get_inverse_primary() {
            return hex_from_hct(new Scheme().inverse_primary(this).get_hct(this));
        }

        public string get_secondary() {
            return hex_from_hct(new Scheme().secondary(this).get_hct(this));
        }

        public string get_on_secondary() {
            return hex_from_hct(new Scheme().on_secondary(this).get_hct(this));
        }

        public string get_secondary_container() {
            return hex_from_hct(new Scheme().secondary_container(this).get_hct(this));
        }

        public string get_on_secondary_container() {
            return hex_from_hct(new Scheme().on_secondary_container(this).get_hct(this));
        }

        public string get_tertiary() {
            return hex_from_hct(new Scheme().tertiary(this).get_hct(this));
        }

        public string get_on_tertiary() {
            return hex_from_hct(new Scheme().on_tertiary(this).get_hct(this));
        }

        public string get_tertiary_container() {
            return hex_from_hct(new Scheme().tertiary_container(this).get_hct(this));
        }

        public string get_on_tertiary_container() {
            return hex_from_hct(new Scheme().on_tertiary_container(this).get_hct(this));
        }

        public string get_error() {
            return hex_from_hct(new Scheme().error(this).get_hct(this));
        }

        public string get_on_error() {
            return hex_from_hct(new Scheme().on_error(this).get_hct(this));
        }

        public string get_error_container() {
            return hex_from_hct(new Scheme().error_container(this).get_hct(this));
        }

        public string get_on_error_container() {
            return hex_from_hct(new Scheme().on_error_container(this).get_hct(this));
        }
    }
}
