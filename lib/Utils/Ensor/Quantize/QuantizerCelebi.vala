// Adapted from the Java implementation of material-color-utilities licensed under the Apache License, Version 2.0
// Copyright (c) 2021 Google LLC

public class He.QuantizerCelebi {
  public QuantizerCelebi () {}

  public HashTable<int, int> quantize(int[] pixels, int max_colors) {
    QuantizerWu wu = new QuantizerWu ();
    QuantizerResult wu_result = wu.quantize (pixels, 16);

    var wu_clusters_as_objects = wu_result.color_to_count.get_values ();
    print("Wu Clusters: %u\n", wu_clusters_as_objects.length ());
    int index = 0;
    int[] wu_clusters = new int[wu_clusters_as_objects.length ()];

    foreach (int argb in wu_clusters_as_objects) {
      wu_clusters[index++] = argb;
    }

    return QuantizerWsmeans.quantize (pixels, wu_clusters, 16);
  }
}
