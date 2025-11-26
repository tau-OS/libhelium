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
    // Maximum number of pixel samples to collect for quantization
    // Reduced from 128 - fewer samples means faster quantization with minimal quality loss
    private const int MAX_SAMPLES = 64;

    // Maximum colors for quantization - reduced from 128 for significant speedup
    // 32 colors is sufficient for accent extraction since we only need top 4
    private const int MAX_QUANTIZE_COLORS = 32;

    private GLib.Array<int> accent_from_pixels (uint8[] pixels, bool alpha) {
        // First pass: collect filtered pixels
        int[] filtered_pixels = pixels_to_argb_array (pixels, alpha);

        // Early exit if no valid pixels
        if (filtered_pixels.length == 0) {
            return new GLib.Array<int> ();
        }

        // Second pass: cluster to reduced color count using quantizer
        var celebi = new He.QuantizerCelebi ();
        var result = celebi.quantize (filtered_pixels, MAX_QUANTIZE_COLORS);

        var score = new He.Score ();
        return score.score (result, 4); // We only need 4.
    }

    private int[] pixels_to_argb_array (uint8[] pixels, bool alpha) {
        int factor = alpha ? 4 : 3;

        // Validate pixel array length
        if (pixels.length < factor) {
            return new int[0];
        }

        int total_pixels = (int) pixels.length / factor;

        // Calculate skip factor to sample approximately MAX_SAMPLES pixels
        // Use a larger skip to reduce processing time
        int skip = int.max (1, total_pixels / MAX_SAMPLES);

        // Pre-calculate expected number of samples for array pre-allocation
        int expected_samples = (total_pixels + skip - 1) / skip;

        // Pre-allocate result array with estimated size
        // Using a simple dynamic array approach with capacity
        int[] temp_result = new int[expected_samples];
        int result_count = 0;

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

            // Skip transparent/semi-transparent pixels when alpha channel is present
            if (alpha) {
                uint8 alpha_val = pixels[offset + 3];
                if (alpha_val < 250) {
                    i += skip;
                    continue;
                }
            }

            // Skip very dark pixels (likely shadows/borders)
            // Slightly relaxed threshold for speed
            if (red < 10 && green < 10 && blue < 10) {
                i += skip;
                continue;
            }

            // Skip very light pixels (likely highlights/glare)
            // Slightly relaxed threshold for speed
            if (red > 245 && green > 245 && blue > 245) {
                i += skip;
                continue;
            }

            int argb = argb_from_rgb_int (red, green, blue);

            // Append to result
            if (result_count < expected_samples) {
                temp_result[result_count] = argb;
                result_count++;
            }

            i += skip;
        }

        // Return only the filled portion
        if (result_count == 0) {
            return new int[0];
        }

        int[] result = new int[result_count];
        for (int j = 0; j < result_count; j++) {
            result[j] = temp_result[j];
        }

        return result;
    }

    public async GLib.Array<int> accent_from_pixels_async (uint8[] pixels, bool alpha) {
        SourceFunc callback = accent_from_pixels_async.callback;
        GLib.Array<int> result = null;

        // Copy pixel data for thread safety
        // The original array may be modified/freed while thread is running
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
