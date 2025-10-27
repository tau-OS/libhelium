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
        // First pass: collect filtered pixels
        int[] filtered_pixels = pixels_to_argb_array (pixels, alpha);
        
        // Second pass: cluster to 128 colors using quantizer
        var celebi = new He.QuantizerCelebi ();
        var result = celebi.quantize (filtered_pixels, 128);
        
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

        int total_pixels = (int) pixels.length / factor;
        // Sample more pixels initially, then cluster to 128
        int skip = (int)Math.fmax(1.0, total_pixels / 512.0);
        
        int i = 0;
        while (i < total_pixels) {
            int offset = i * factor;
            // Bounds check before accessing
            if (offset + factor > pixels.length) {
                break;
            }

            uint8 red = pixels[offset];
            uint8 green = pixels[offset + 1];
            uint8 blue = pixels[offset + 2];
            uint8 alpha_val = alpha ? pixels[offset + 3] : 255;

            // Skip anti-aliased/transparent pixels - only use fully opaque pixels
            if (alpha && alpha_val < 250) {
                i += skip;
                continue;
            }
            
            // Check if pixel is likely blended by comparing to neighbors
            bool is_blended = false;
            int neighbor_offset = (i + 1) * factor;
            if (neighbor_offset + factor <= pixels.length) {
                uint8 next_r = pixels[neighbor_offset];
                uint8 next_g = pixels[neighbor_offset + 1];
                uint8 next_b = pixels[neighbor_offset + 2];
                
                // If RGB values are within 10 of neighbor, likely anti-aliased
                int r_diff = (int)Math.fabs(red - next_r);
                int g_diff = (int)Math.fabs(green - next_g);
                int b_diff = (int)Math.fabs(blue - next_b);
                
                if (r_diff < 10 && g_diff < 10 && b_diff < 10) {
                    is_blended = true;
                }
            }
            
            if (is_blended) {
                i += skip;
                continue;
            }

            int argb = argb_from_rgb_int(red, green, blue);

            list += argb;

            i += skip;
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