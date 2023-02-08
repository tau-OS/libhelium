public interface He.Ensor.Quantize.PointProvider {
  public abstract double[] from_int(int argb);
  public abstract int to_int(double[] point);
  public abstract double distance(double[] a, double[] b);
}
