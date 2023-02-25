// Adapted from the Java implementation of material-color-utilities licensed under the Apache License, Version 2.0
// Copyright (c) 2021 Google LLC

namespace He {
  public interface PointProvider : Object {
    public abstract double[] from_int (int argb);
    public abstract int to_int (double[] point);
    public abstract double distance (double[] a, double[] b);
  }
}
