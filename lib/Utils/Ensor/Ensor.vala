/*
 * Copyright (c) 2023 Fyra Labs
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
[CCode (gir_namespace = "He", gir_version = "1", cheader_filename = "libhelium-1.h")]
namespace He.Ensor {
    private GLib.Array<int> accent_from_pixels (uint8[] pixels, bool alpha) {
        var celebi = new He.QuantizerCelebi ();
        var result = celebi.quantize (pixels_to_argb_array (pixels, alpha), 128);
        var score = new He.Score ();
        return score.score (result, 4); // We only need 4.
    }

    private int[] pixels_to_argb_array (uint8[] pixels, bool alpha) {
        int[] list = {};

        int factor = alpha ? 4 : 3;

        // Validate pixel array length
        if (pixels.length < factor) {
            return list;
        }

        int i = 0;
        int max_i = (int) pixels.length / factor;
        while (i < max_i) {
            int offset = i * factor;
            // Bounds check before accessing
            if (offset + factor > pixels.length) {
                break;
            }

            uint8 red = pixels[offset];
            uint8 green = pixels[offset + 1];
            uint8 blue = pixels[offset + 2];

            // Filter out pixels that are too dark, too bright, or monochrome grays
            // Keep pure black (0,0,0) and pure white (255,255,255)
            bool is_pure_black = (red == 0 && green == 0 && blue == 0);
            bool is_pure_white = (red == 255 && green == 255 && blue == 255);
            bool is_too_dark = (red < 20 && green < 20 && blue < 20);
            bool is_too_bright = (red > 235 && green > 235 && blue > 235);
            
            // Check if pixel is monochrome gray (R≈G≈B within threshold)
            int max_channel = (int)Math.fmax(red, Math.fmax(green, blue));
            int min_channel = (int)Math.fmin(red, Math.fmin(green, blue));
            bool is_gray = (max_channel - min_channel) < 15;
            
            // Filter out scientifically disgusting hues (yellow-green, muddy browns)
            bool is_disgusting_hue = false;
            if (!is_gray && (max_channel - min_channel) > 20) {
                int argb = argb_from_rgb_int(red, green, blue);
                HCTColor hct = hct_from_int(argb);
                bool hue_passes = MathUtils.round_double(hct.h) >= 90.0 && MathUtils.round_double(hct.h) <= 111.0;
                bool chroma_passes = MathUtils.round_double(hct.c) > 16.0;
                bool tone_passes = MathUtils.round_double(hct.t) < 65.0;
                is_disgusting_hue = hue_passes && chroma_passes && tone_passes;
            }

            if ((is_too_dark && !is_pure_black) || (is_too_bright && !is_pure_white) || (is_gray && !is_pure_black && !is_pure_white) || is_disgusting_hue) {
                i += 10;
                continue;
            }

            int rgb = argb_from_rgb_int (red, green, blue);
            list += (rgb);

            i += 10;
        }
        return list;
    }

    public async GLib.Array<int> accent_from_pixels_async (uint8[] pixels, bool alpha) {
        SourceFunc callback = accent_from_pixels_async.callback;
        GLib.Array<int> result = null;

        uint length = pixels.length;
        uint8[] pixels_copy = new uint8[length];
        Memory.copy (pixels_copy, pixels, length);

        ThreadFunc<bool> run = () => {
            result = accent_from_pixels (pixels_copy, alpha);
            Idle.add ((owned) callback);
            return true;
        };
        new Thread<bool> ("ensor-process", (owned) run);

        yield;
        return result;
    }
}