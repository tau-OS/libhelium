// Adapted from the Java implementation of material-color-utilities licensed under the Apache License, Version 2.0
// Copyright (c) 2021 Google LLC

public class He.QuantizerResult : Object {
  public HashTable<int, int?> color_to_count;

  public QuantizerResult (HashTable<int, int?> color_to_count) {
    this.color_to_count = color_to_count;
  }
}
