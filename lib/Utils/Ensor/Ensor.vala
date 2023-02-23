/*
* Copyright (c) 2023 Fyra Labs
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/
[CCode (gir_namespace = "He", gir_version = "1", cheader_filename = "libhelium-1.h")]
namespace He.Ensor {
  GLib.Array<int> accent_from_pixels (uint8[] pixels) {
    var celebi = new He.QuantizerCelebi ();
    var result = celebi.quantize (pixels_to_argb_array (pixels), 128);
    var score = new He.Score ();
    return score.score (result);
  }

  private int[] pixels_to_argb_array (uint8[] pixels) {
      int[] list = {};

      for (int i = 0; i < pixels.length; i += 4) {
          uint8 red = pixels[i];
          uint8 green = pixels[i + 1];
          uint8 blue = pixels[i + 2];

          int rgb = (255 << 24 | (red & 255) << 16 | (green & 255) << 8 | blue & 255);
          list += (rgb);
      }
      return list;
  }

   public async GLib.Array<int> accent_from_pixels_async (uint8[] pixels) {
    SourceFunc callback = accent_from_pixels_async.callback;
    GLib.Array<int> result = null;

    ThreadFunc<bool> run = () => {
      result = accent_from_pixels (pixels);
      Idle.add ((owned) callback);
      return true;
    };
    new Thread<bool> ("ensor-process", (owned) run);

    yield;
    return result;
  }
}
