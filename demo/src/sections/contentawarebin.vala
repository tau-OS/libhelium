/*
 * Content-aware color demo for He.Bin.
 */

using Gee;

namespace Demo {
    private errordomain PaletteError {
        INVALID_TEXTURE,
        EMPTY_RESULT
    }

    [GtkTemplate (ui = "/com/fyralabs/Helium1/Demo/contentawarebin.ui")]
    public class ContentAwareBin : He.Bin {
        [GtkChild] private unowned Gtk.DropDown palette_selector;
        [GtkChild] private unowned Gtk.Picture hero_picture;
        [GtkChild] private unowned Gtk.Switch override_switch;
        [GtkChild] private unowned He.Button accent_button;
        [GtkChild] private unowned He.Button secondary_button;
        [GtkChild] private unowned He.Button tertiary_button;
        [GtkChild] private unowned Gtk.Label accent_value;
        [GtkChild] private unowned Gtk.Label secondary_value;
        [GtkChild] private unowned Gtk.Label tertiary_value;
        [GtkChild] private unowned Gtk.Box spacer;

        private const string[] PALETTE_IDS = { "mountain", "sand", "snow", "stone" };
        private HashMap<string, PaletteColors> palette_cache = new HashMap<string, PaletteColors> ();
        private He.Desktop desktop = new He.Desktop ();
        private string current_palette_id = PALETTE_IDS[0];
        private string? pending_palette_id = null;

        private class PaletteColors : Object {
            public He.RGBColor source;
            public string source_hex;
            public string accent_hex;
            public string secondary_hex;
            public string tertiary_hex;

            public PaletteColors (He.RGBColor source,
                string source_hex,
                string accent_hex,
                string secondary_hex,
                string tertiary_hex) {
                this.source = source;
                this.source_hex = source_hex;
                this.accent_hex = accent_hex;
                this.secondary_hex = secondary_hex;
                this.tertiary_hex = tertiary_hex;
            }
        }

        construct {
            content_color_override = true;
            override_switch.active = content_color_override;

            accent_button.color = He.ButtonColor.PRIMARY;
            secondary_button.color = He.ButtonColor.SECONDARY;
            tertiary_button.color = He.ButtonColor.TERTIARY;

            palette_selector.notify["selected"].connect (() => update_palette_from_selection_async.begin ());
            override_switch.notify["active"].connect (() => on_override_toggled ());

            update_palette_from_selection_async.begin ();

            spacer.remove_css_class ("disclosure-button");
        }

        private void on_override_toggled () {
            content_color_override = override_switch.active;

            if (content_color_override) {
                apply_palette_async.begin (current_palette_id);
            }
        }

        private async void update_palette_from_selection_async () {
            uint index = palette_selector.selected;
            if (index >= PALETTE_IDS.length) {
                return;
            }

            current_palette_id = PALETTE_IDS[index];
            yield apply_palette_async (current_palette_id);
        }

        private async void apply_palette_async (string palette_id) {
            pending_palette_id = palette_id;

            string resource_path = "/com/fyralabs/Helium1/Demo/%s.jpg".printf (palette_id);
            hero_picture.set_resource (resource_path);

            PaletteColors? palette = null;

            try {
                palette = yield get_palette_async (palette_id);
            } catch (Error e) {
                warning ("Failed to extract palette for %s: %s", palette_id, e.message);
                pending_palette_id = null;
                return;
            }

            if (pending_palette_id != palette_id) {
                return;
            }

            content_source_color = palette.source;

            accent_value.label = palette.accent_hex;
            secondary_value.label = palette.secondary_hex;
            tertiary_value.label = palette.tertiary_hex;

            pending_palette_id = null;
        }

        private async PaletteColors get_palette_async (string palette_id) throws Error {
            bool is_dark = desktop.prefers_color_scheme == He.Desktop.ColorScheme.DARK;
            double contrast = desktop.contrast;
            string cache_key = cache_key_for_palette (palette_id, is_dark, contrast);

            if (palette_cache.has_key (cache_key)) {
                return palette_cache.get (cache_key);
            }

            var texture = Gdk.Texture.from_resource (
                                                     "/com/fyralabs/Helium1/Demo/%s.jpg".printf (palette_id)
            );

            int width = texture.get_width ();
            int height = texture.get_height ();

            if (width <= 0 || height <= 0) {
                throw new PaletteError.INVALID_TEXTURE ("Texture %s has invalid size".printf (palette_id));
            }

            uint row_stride = (uint) (width * 4);
            uint8[] pixels = new uint8[width * height * 4];
            texture.download (pixels, row_stride);

            // GDK texture download is in BGRA format, but Ensor expects RGBA
            // Swap B and R channels
            for (int i = 0; i < pixels.length; i += 4) {
                uint8 temp = pixels[i]; // Save B
                pixels[i] = pixels[i + 2]; // B = R
                pixels[i + 2] = temp; // R = old B
            }

            var scored = yield He.Ensor.accent_from_pixels_async (pixels, true);

            if (scored == null || scored.length == 0) {
                throw new PaletteError.EMPTY_RESULT ("Ensor returned no colors for %s".printf (palette_id));
            }

            PaletteColors palette = build_palette_from_results (scored, is_dark, contrast);

            palette_cache.set (cache_key, palette);
            return palette;
        }

        private string cache_key_for_palette (string palette_id, bool is_dark, double contrast) {
            return "%s|%s|%.2f".printf (palette_id, is_dark ? "dark" : "light", contrast);
        }

        private PaletteColors build_palette_from_results (GLib.Array<int> results, bool is_dark, double contrast) {
            int source_argb = results.index (0);
            string source_hex = He.hexcode_argb (source_argb);
            He.RGBColor source_rgb = He.from_hex (source_hex.replace ("#", ""));

            var content_scheme = new He.ContentScheme ();
            var scheme = content_scheme.generate (He.hct_from_int (source_argb), is_dark, contrast);

            string accent_hex = scheme.get_primary ();
            string secondary_hex = scheme.get_secondary ();
            string tertiary_hex = scheme.get_tertiary ();

            return new PaletteColors (source_rgb,
                                      source_hex,
                                      accent_hex,
                                      secondary_hex,
                                      tertiary_hex);
        }
    }
}