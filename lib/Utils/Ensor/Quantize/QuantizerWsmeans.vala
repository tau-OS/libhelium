// Adapted from the Java implementation of material-color-utilities licensed under the Apache License, Version 2.0
// Copyright (c) 2021 Google LLC

public class He.Ensor.Quantize.QuantizerWsmeans {
  private QuantizerWsmeans() {}

  private class Distance {
    public int index;
    public double distance;

    public Distance() {
      this.index = -1;
      this.distance = -1;
    }

    public int compareTo(Distance other) {
      return this.distance > other.distance ? 1 : this.distance < other.distance ? -1 : 0;
    }
  }

  private const int MAX_ITERATIONS = 10;
  private const double MIN_MOVEMENT_DISTANCE = 3.0;

  public static HashTable<int?, int?> quantize(
      int[] inputPixels, int[] startingClusters, int maxColors) {
    // Uses a seeded random number generator to ensure consistent results.
    var random = new Rand.with_seed(0x42688);

    var pixelToCount = new HashTable<int?, int?>(null, null);
    var points = new List<double?>[inputPixels.length];
    int[] pixels = new int[inputPixels.length];
    PointProviderLab pointProvider = new PointProviderLab();

    int pointCount = 0;
    for (int i = 0; i < inputPixels.length; i++) {
      int inputPixel = inputPixels[i];
      int pixelCount = pixelToCount.get(inputPixel);
      if (!pixelToCount.contains(inputPixel)) {
        var point = new List<double?>();
        foreach (var value in pointProvider.from_int(inputPixel)) {
          point.append(value);
        }

        points[pointCount] = (List<double?>) point.copy();
        pixels[pointCount] = inputPixel;
        pointCount++;

        pixelToCount.set(inputPixel, 1);
      } else {
        pixelToCount.set(inputPixel, pixelCount + 1);
      }
    }

    int[] counts = new int[pointCount];
    for (int i = 0; i < pointCount; i++) {
      int pixel = pixels[i];
      int count = pixelToCount.get(pixel);
      counts[i] = count;
    }

    int clusterCount = (int) Math.fmin(maxColors, pointCount);
    if (startingClusters.length != 0) {
      clusterCount = (int) Math.fmin(clusterCount, startingClusters.length);
    }

    var clusters = new List<double?>[clusterCount];
    int clustersCreated = 0;
    for (int i = 0; i < startingClusters.length; i++) {
      var cluster = new List<double?>();
      foreach (var value in pointProvider.from_int(startingClusters[i])) {
        cluster.append(value);
      }

      clusters[i] = (List<double?>) cluster.copy();
      clustersCreated++;
    }

    int additionalClustersNeeded = clusterCount - clustersCreated;
    if (additionalClustersNeeded > 0) {
      for (int i = 0; i < additionalClustersNeeded; i++) {}
    }

    int[] clusterIndices = new int[pointCount];
    for (int i = 0; i < pointCount; i++) {
      clusterIndices[i] = random.int_range(0, clusterCount);
    }

    int[,] indexMatrix = new int[clusterCount,clusterCount];

    List<Distance?>[] distanceToIndexMatrix = new List<Distance?>[clusterCount];
    for (int i = 0; i < clusterCount; i++) {
      distanceToIndexMatrix[i] = new List<Distance?>();

      for (int j = 0; j < clusterCount; j++) {
        distanceToIndexMatrix[i].append(new Distance());
      }
    }

    int[] pixelCountSums = new int[clusterCount];
    for (int iteration = 0; iteration < MAX_ITERATIONS; iteration++) {
      for (int i = 0; i < clusterCount; i++) {
        for (int j = i + 1; j < clusterCount; j++) {
          var a = new double[clusters[i].length()];
          var b = new double[clusters[j].length()];

          for (int k = 0; k < clusters[i].length(); k++) {
            a[k] = clusters[i].nth(k).data;
          }

          for (int k = 0; k < clusters[j].length(); k++) {
            b[k] = clusters[j].nth(k).data;
          }

          double distance = pointProvider.distance(a, b);
          distanceToIndexMatrix[j].nth_data(i).distance = distance;
          distanceToIndexMatrix[j].nth_data(i).index = i;
          distanceToIndexMatrix[i].nth_data(j).distance = distance;
          distanceToIndexMatrix[i].nth_data(j).index = j;
        }

        distanceToIndexMatrix[i].sort((a, b) => a.compareTo(b));
        for (int j = 0; j < clusterCount; j++) {
          indexMatrix[i,j] = distanceToIndexMatrix[i].nth_data(j).index;
        }
      }

      int pointsMoved = 0;
      for (int i = 0; i < pointCount; i++) {
        double[] point = new double[points[i].length()];

        for (int j = 0; j < points[i].length(); j++) {
          point[j] = points[i].nth(j).data;
        }

        int previousClusterIndex = clusterIndices[i];
        double[] previousCluster = new double[clusters[previousClusterIndex].length()];
        for (int j = 0; j < clusters[previousClusterIndex].length(); j++) {
          previousCluster[j] = clusters[previousClusterIndex].nth(j).data;
        }
        double previousDistance = pointProvider.distance(point, previousCluster);

        double minimumDistance = previousDistance;
        int newClusterIndex = -1;
        for (int j = 0; j < clusterCount; j++) {
          if (distanceToIndexMatrix[previousClusterIndex].nth_data(j).distance >= 4 * previousDistance) {
            continue;
          }

          double[] cluster = new double[clusters[j].length()];
          for (int k = 0; k < clusters[j].length(); k++) {
            cluster[k] = clusters[j].nth(k).data;
          }

          double distance = pointProvider.distance(point, cluster);
          if (distance < minimumDistance) {
            minimumDistance = distance;
            newClusterIndex = j;
          }
        }
        if (newClusterIndex != -1) {
          double distanceChange =
              Math.fabs(Math.sqrt(minimumDistance) - Math.sqrt(previousDistance));
          if (distanceChange > MIN_MOVEMENT_DISTANCE) {
            pointsMoved++;
            clusterIndices[i] = newClusterIndex;
          }
        }
      }

      if (pointsMoved == 0 && iteration != 0) {
        break;
      }

      double[] componentASums = new double[clusterCount];
      double[] componentBSums = new double[clusterCount];
      double[] componentCSums = new double[clusterCount];

      for (int i = 0; i < clusterCount; i++) {
        pixelCountSums[i] = 0;
      }

      for (int i = 0; i < pointCount; i++) {
        int clusterIndex = clusterIndices[i];
        double[] point = new double[points[i].length()];
        for (int j = 0; j < points[i].length(); j++) {
          point[j] = points[i].nth(j).data;
        }
        int count = counts[i];
        pixelCountSums[clusterIndex] += count;
        componentASums[clusterIndex] += (point[0] * count);
        componentBSums[clusterIndex] += (point[1] * count);
        componentCSums[clusterIndex] += (point[2] * count);
      }

      for (int i = 0; i < clusterCount; i++) {
        int count = pixelCountSums[i];
        if (count == 0) {
          var cluster = new List<double?> ();
          cluster.append(0.0);
          cluster.append(0.0);
          cluster.append(0.0);

          clusters[i] = (List<double?>) cluster.copy();
          continue;
        }
        double a = componentASums[i] / count;
        double b = componentBSums[i] / count;
        double c = componentCSums[i] / count;
        clusters[i].nth(0).data = a;
        clusters[i].nth(1).data = b;
        clusters[i].nth(2).data = c;
      }
    }

    var argbToPopulation = new HashTable<int?, int?>(null, null);
    for (int i = 0; i < clusterCount; i++) {
      int count = pixelCountSums[i];
      if (count == 0) {
        continue;
      }

      double[] cluster = new double[clusters[i].length()];

      for (int j = 0; j < clusters[i].length(); j++) {
        cluster[j] = clusters[i].nth(j).data;
      }

      int possibleNewCluster = pointProvider.to_int(cluster);
      if (argbToPopulation.contains(possibleNewCluster)) {
        continue;
      }

      argbToPopulation.set(possibleNewCluster, count);
    }

    return argbToPopulation;
  }
}
