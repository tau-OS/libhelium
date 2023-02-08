// Adapted from the Java implementation of material-color-utilities licensed under the Apache License, Version 2.0
// Copyright (c) 2021 Google LLC

[CCode (gir_namespace = "He", gir_version = "1", cheader_filename = "libhelium-1.h")]
namespace He {
  public interface Quantizer : Object {
    public abstract QuantizerResult quantize (int[] pixels, int max_colors);
  }
}
