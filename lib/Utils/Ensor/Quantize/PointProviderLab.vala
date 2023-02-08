// Adapted from the Java implementation of material-color-utilities licensed under the Apache License, Version 2.0
// Copyright (c) 2021 Google LLC

public class He.PointProviderLab : PointProvider, Object {
  public double[] from_int(int argb) {
    var lab = Color.rgb_to_lab(Color.from_argb_int(argb));
    return new double[] {lab.l, lab.a, lab.b};
  }

  public int to_int(double[] lab) {
    var lab_color = Color.LABColor () {
      l = lab[0],
      a = lab[1],
      b = lab[2]
    };

    return Color.to_argb_int(Color.lab_to_rgb(lab_color));
  }

  public double distance(double[] one, double[] two) {
    double dL = (one[0] - two[0]);
    double dA = (one[1] - two[1]);
    double dB = (one[2] - two[2]);
    return (dL * dL + dA * dA + dB * dB);
  }
}
