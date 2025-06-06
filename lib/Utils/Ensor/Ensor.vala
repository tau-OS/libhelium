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
    GLib.Array<int64> accent_from_pixels (uint8[] pixels, bool alpha) {
        var celebi = new He.QuantizerCelebi ();
        var result = celebi.quantize (pixels_to_argb_array (pixels, alpha), 128);
        var score = new He.Score ();
        return score.score (result, 4); // We only need 4.
    }

    private int[] pixels_to_argb_array (uint8[] pixels, bool alpha) {
        int[] list = {};

        int channels = alpha ? 4 : 3;
        int quality = 4; // Quality setting: 1 = min, 4 = default, 10 = max

        int pixel_count = pixels.length / channels;

        for (int i = 0; i < pixel_count; i += quality) {
            int offset = i * channels;

            // Ensure we don't go out of bounds
            if (offset + 2 >= pixels.length) {
                break;
            }

            uint8 red = pixels[offset];
            uint8 green = pixels[offset + 1];
            uint8 blue = pixels[offset + 2];

            int rgb = argb_from_rgb_int (red, green, blue);
            list += rgb;
        }

        return list;
    }

    public async GLib.Array<int64> accent_from_pixels_async (uint8[] pixels, bool alpha) {
        SourceFunc callback = accent_from_pixels_async.callback;
        GLib.Array<int64> result = null;

        ThreadFunc<bool> run = () => {
            result = accent_from_pixels (pixels, alpha);
            Idle.add ((owned) callback);
            return true;
        };
        new Thread<bool> ("ensor-process", (owned) run);

        yield;
        return result;
    }
}