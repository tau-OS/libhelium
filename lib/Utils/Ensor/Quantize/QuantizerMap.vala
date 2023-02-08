// Adapted from the Java implementation of material-color-utilities licensed under the Apache License, Version 2.0
// Copyright (c) 2021 Google LLC

/** Creates a dictionary with keys of colors, and values of count of the color */
 public class He.QuantizerMap : Quantizer, Object {
  HashTable<int, int> color_to_count;

  public QuantizerResult quantize (int[] pixels, int color_count) {
    var pixel_by_count = new HashTable<int, int> (null, null);
    foreach (var pixel in pixels) {
     // LMAO what will this do???
      int current_pixel_count = pixel_by_count.get(pixel);
      var new_pixel_count = !pixel_by_count.contains (pixel) ? 1 : current_pixel_count + 1;
      pixel_by_count.set (pixel, new_pixel_count);
    }
    color_to_count = pixel_by_count;
    return new QuantizerResult (pixel_by_count);
  }

  public HashTable<int, int> get_color_to_count () {
    return color_to_count;
  }
}
