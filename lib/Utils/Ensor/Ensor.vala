namespace He.Ensor {
  GLib.List<int> accent_from_pixels (uint8[] pixels) {
    var celebi = new He.QuantizerCelebi ();
    var result = celebi.quantize (pixels_to_argb_array (pixels, false), 128);
    var score = new He.Score ();
    return score.score (result);
  }

  private int[] pixels_to_argb_array (uint8[] pixels, bool has_alpha) {
      int[] list = {};

      int factor;
      if (has_alpha) {
          factor = 4;
      } else {
          factor = 3;
      }

      int i = 0;
      int inc = 6; // quality (10 = max, 6 = default; we go with default)

      int count = pixels.length / factor;
      while (i < count) {
          int offset = i * factor;
          uint8 red = pixels[offset];
          uint8 green = pixels[offset + 1];
          uint8 blue = pixels[offset + 2];

          Color.RGBColor color = {red, green, blue};
          int rgb = Color.rgb_to_argb_int (color);
          list += (rgb);

          i += inc;
      }

      return list;
  }

  public async GLib.List<int> accent_from_pixels_async (uint8[] pixels) {
    SourceFunc callback = accent_from_pixels_async.callback;
    GLib.List<int> result = null;

    ThreadFunc<bool> run = () => {
      result = accent_from_pixels (pixels);
      Idle.add ((owned) callback);
      return true;
    };
    new Thread<bool> ("ensor-process", run);

    yield;
    return result.copy ();
  }
}
