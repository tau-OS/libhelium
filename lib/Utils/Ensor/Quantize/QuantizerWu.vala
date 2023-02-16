// Adapted from the Java implementation of material-color-utilities licensed under the Apache License, Version 2.0
// Copyright (c) 2021 Google LLC

/**
  * An image quantizer that divides the image's pixels into clusters by recursively cutting an RGB
  * cube, based on the weight of pixels in each area of the cube.
  *
  * <p>The algorithm was described by Xiaolin Wu in Graphic Gems II, published in 1991.
  */
 public class He.QuantizerWu : Quantizer {
   int[] weights;
   int[] moments_r;
   int[] moments_g;
   int[] moments_b;
   double[] moments;
   Box[] cubes;
   
   public QuantizerWu () {}

   // A histogram of all the input colors is constructed. It has the shape of a
   // cube. The cube would be too large if it contained all 16 million colors:
   // historical best practice is to use 5 bits  of the 8 in each channel,
   // reducing the histogram to a volume of ~32,000.
   private const int INDEX_BITS = 5;
   private const int INDEX_COUNT = 33; // ((1 << INDEX_BITS) + 1)
   private const int TOTAL_SIZE = 35937; // INDEX_COUNT * INDEX_COUNT * INDEX_COUNT

   public override QuantizerResult quantize(int[] pixels, int color_count) {
     QuantizerResult map_result = new QuantizerMap().quantize(pixels, color_count);
     construct_histogram (map_result.color_to_count);
     create_moments ();
     CreateBoxesResult create_boxes_result = create_boxes (color_count);
     var colors = create_result (create_boxes_result.result_count);
     var result_map = new HashTable<int, int?> (null, null);
     foreach (var color in colors) {
       result_map.insert (color, 0);
     }
     return new QuantizerResult(result_map);
   }

   static int get_index (int r, int g, int b) {
     return (r << (INDEX_BITS * 2)) + (r << (INDEX_BITS + 1)) + r + (g << INDEX_BITS) + g + b;
   }

   void construct_histogram (HashTable<int, int?> pixels) {
     weights = new int[TOTAL_SIZE];
     moments_r = new int[TOTAL_SIZE];
     moments_g = new int[TOTAL_SIZE];
     moments_b = new int[TOTAL_SIZE];
     moments = new double[TOTAL_SIZE];

     foreach (var pixel in pixels.get_keys ()) {
       int count = pixels.get (pixel);
       int red = Color.red_from_rgba_int (pixel);
       int green = Color.green_from_rgba_int (pixel);
       int blue = Color.blue_from_rgba_int (pixel);
       int bits_to_remove = 8 - INDEX_BITS;
       int i_r = (red >> bits_to_remove) + 1;
       int i_g = (green >> bits_to_remove) + 1;
       int i_b = (blue >> bits_to_remove) + 1;
       int index = get_index (i_r, i_g, i_b);
       weights[index] += count;
       moments_r[index] += (red * count);
       moments_g[index] += (green * count);
       moments_b[index] += (blue * count);
       moments[index] += (count * ((red * red) + (green * green) + (blue * blue)));
     }
   }

   void create_moments () {
     for (int r = 1; r < INDEX_COUNT; ++r) {
       int[] area = new int[INDEX_COUNT];
       int[] area_r = new int[INDEX_COUNT];
       int[] area_g = new int[INDEX_COUNT];
       int[] area_b = new int[INDEX_COUNT];
       double[] area2 = new double[INDEX_COUNT];

       for (int g = 1; g < INDEX_COUNT; ++g) {
         int line = 0;
         int line_r = 0;
         int line_g = 0;
         int line_b = 0;
         double line2 = 0.0;
         for (int b = 1; b < INDEX_COUNT; ++b) {
           int index = get_index (r, g, b);
           line += weights[index];
           line_r += moments_r[index];
           line_g += moments_g[index];
           line_b += moments_b[index];
           line2 += moments[index];

           area[b] += line;
           area_r[b] += line_r;
           area_g[b] += line_g;
           area_b[b] += line_b;
           area2[b] += line2;

           int previous_index = get_index (r - 1, g, b);
           weights[index] = weights[previous_index] + area[b];
           moments_r[index] = moments_r[previous_index] + area_r[b];
           moments_g[index] = moments_g[previous_index] + area_g[b];
           moments_b[index] = moments_b[previous_index] + area_b[b];
           moments[index] = moments[previous_index] + area2[b];
         }
       }
     }
   }

   CreateBoxesResult create_boxes (int max_color_count) {
     cubes = new Box[max_color_count];
     for (int i = 0; i < max_color_count; i++) {
       cubes[i] = new Box ();
     }
     double[] volume_variance = new double[max_color_count];
     Box first_box = cubes[0];
     first_box.r1 = INDEX_COUNT - 1;
     first_box.g1 = INDEX_COUNT - 1;
     first_box.b1 = INDEX_COUNT - 1;

     int generated_color_count = max_color_count;
     int next = 0;
     for (int i = 1; i < max_color_count; i++) {
       if (cut (cubes[next], cubes[i])) {
         volume_variance[next] = (cubes[next].vol > 1) ? variance (cubes[next]) : 0.0;
         volume_variance[i] = (cubes[i].vol > 1) ? variance (cubes[i]) : 0.0;
       } else {
         volume_variance[next] = 0.0;
         i--;
       }

       next = 0;

       double temp = volume_variance[0];
       for (int j = 1; j <= i; j++) {
         if (volume_variance[j] > temp) {
           temp = volume_variance[j];
           next = j;
         }
       }
       if (temp <= 0.0) {
         generated_color_count = i + 1;
         break;
       }
     }

     return new CreateBoxesResult (max_color_count, generated_color_count);
   }

   List<int?> create_result (int color_count) {
     var colors = new List<int?> ();
     for (int i = 0; i < color_count; ++i) {
       Box cube = cubes[i];
       int weight = volume (cube, weights);
       if (weight > 0) {
         int r = volume (cube, moments_r) / weight;
         int g = volume (cube, moments_g) / weight;
         int b = volume (cube, moments_b) / weight;
         int color = (255 << 24) | ((r & 0x0ff) << 16) | ((g & 0x0ff) << 8) | (b & 0x0ff);
         colors.append (color);
       }
     }
     return colors;
   }

   double variance (Box cube) {
     int dr = volume (cube, moments_r);
     int dg = volume (cube, moments_g);
     int db = volume (cube, moments_b);
     double xx =
         moments[get_index (cube.r1, cube.g1, cube.b1)]
             - moments[get_index (cube.r1, cube.g1, cube.b0)]
             - moments[get_index (cube.r1, cube.g0, cube.b1)]
             + moments[get_index (cube.r1, cube.g0, cube.b0)]
             - moments[get_index (cube.r0, cube.g1, cube.b1)]
             + moments[get_index (cube.r0, cube.g1, cube.b0)]
             + moments[get_index (cube.r0, cube.g0, cube.b1)]
             - moments[get_index (cube.r0, cube.g0, cube.b0)];

     int hypotenuse = dr * dr + dg * dg + db * db;
     int volume = volume (cube, weights);
     return xx - hypotenuse / ((double) volume);
   }

   bool cut (Box one, Box two) {
     int whole_r = volume (one, moments_r);
     int whole_g = volume (one, moments_g);
     int whole_b = volume (one, moments_b);
     int whole_weight = volume (one, weights);

     MaximizeResult max_r_result =
         maximize (one, Direction.RED, one.r0 + 1, one.r1, whole_r, whole_g, whole_b, whole_weight);
     MaximizeResult max_g_result =
         maximize (one, Direction.GREEN, one.g0 + 1, one.g1, whole_r, whole_g, whole_b, whole_weight);
     MaximizeResult max_b_result =
         maximize (one, Direction.BLUE, one.b0 + 1, one.b1, whole_r, whole_g, whole_b, whole_weight);
     Direction cut_direction;
     double max_r = max_r_result.maximum;
     double max_g = max_g_result.maximum;
     double max_b = max_b_result.maximum;
     if (max_r >= max_g && max_r >= max_b) {
       if (max_r_result.cut_location < 0) {
         return false;
       }
       cut_direction = Direction.RED;
     } else if (max_g >= max_r && max_g >= max_b) {
       cut_direction = Direction.GREEN;
     } else {
       cut_direction = Direction.BLUE;
     }

     two.r1 = one.r1;
     two.g1 = one.g1;
     two.b1 = one.b1;

     switch (cut_direction) {
       case RED:
         one.r1 = max_r_result.cut_location;
         two.r0 = one.r1;
         two.g0 = one.g0;
         two.b0 = one.b0;
         break;
       case GREEN:
         one.g1 = max_g_result.cut_location;
         two.r0 = one.r0;
         two.g0 = one.g1;
         two.b0 = one.b0;
         break;
       case BLUE:
         one.b1 = max_b_result.cut_location;
         two.r0 = one.r0;
         two.g0 = one.g0;
         two.b0 = one.b1;
         break;
     }

     one.vol = (one.r1 - one.r0) * (one.g1 - one.g0) * (one.b1 - one.b0);
     two.vol = (two.r1 - two.r0) * (two.g1 - two.g0) * (two.b1 - two.b0);

     return true;
   }

   MaximizeResult maximize (
       Box cube,
       Direction direction,
       int first,
       int last,
       int whole_r,
       int whole_g,
       int whole_b,
       int whole_weight
   ) {
     int bottom_r = bottom (cube, direction, moments_r);
     int bottom_g = bottom (cube, direction, moments_g);
     int bottom_b = bottom (cube, direction, moments_b);
     int bottom_weight = bottom (cube, direction, weights);

     double max = 0.0;
     int cut = -1;

     int half_r = 0;
     int half_g = 0;
     int half_b = 0;
     int half_weight = 0;
     for (int i = first; i < last; i++) {
       half_r = bottom_r + top (cube, direction, i, moments_r);
       half_g = bottom_g + top (cube, direction, i, moments_g);
       half_b = bottom_b + top (cube, direction, i, moments_b);
       half_weight = bottom_weight + top (cube, direction, i, weights);
       if (half_weight == 0) {
         continue;
       }

       double temp_num = half_r * half_r + half_g * half_g + half_b * half_b;
       double temp_denom = half_weight;
       double temp = temp_num / temp_denom;

       half_r = whole_r - half_r;
       half_g = whole_g - half_g;
       half_b = whole_b - half_b;
       half_weight = whole_weight - half_weight;
       if (half_weight == 0) {
         continue;
       }

       temp_num = half_r * half_r + half_g * half_g + half_b * half_b;
       temp_denom = half_weight;
       temp += (temp_num / temp_denom);

       if (temp > max) {
         max = temp;
         cut = i;
       }
     }
     return new MaximizeResult (cut, max);
   }

   static int volume (Box cube, int[] moment) {
     return (moment[get_index (cube.r1, cube.g1, cube.b1)]
         - moment[get_index (cube.r1, cube.g1, cube.b0)]
         - moment[get_index (cube.r1, cube.g0, cube.b1)]
         + moment[get_index (cube.r1, cube.g0, cube.b0)]
         - moment[get_index (cube.r0, cube.g1, cube.b1)]
         + moment[get_index (cube.r0, cube.g1, cube.b0)]
         + moment[get_index (cube.r0, cube.g0, cube.b1)]
         - moment[get_index (cube.r0, cube.g0, cube.b0)]);
   }

   static int bottom (Box cube, Direction direction, int[] moment) {
     switch (direction) {
       case RED:
         return -moment[get_index (cube.r0, cube.g1, cube.b1)]
             + moment[get_index (cube.r0, cube.g1, cube.b0)]
             + moment[get_index (cube.r0, cube.g0, cube.b1)]
             - moment[get_index (cube.r0, cube.g0, cube.b0)];
       case GREEN:
         return -moment[get_index (cube.r1, cube.g0, cube.b1)]
             + moment[get_index (cube.r1, cube.g0, cube.b0)]
             + moment[get_index (cube.r0, cube.g0, cube.b1)]
             - moment[get_index (cube.r0, cube.g0, cube.b0)];
       case BLUE:
         return -moment[get_index (cube.r1, cube.g1, cube.b0)]
             + moment[get_index (cube.r1, cube.g0, cube.b0)]
             + moment[get_index (cube.r0, cube.g1, cube.b0)]
             - moment[get_index (cube.r0, cube.g0, cube.b0)];
     }
     error ("Unexpected direction %s".printf (direction.to_string ()));
   }

   static int top (Box cube, Direction direction, int position, int[] moment) {
     switch (direction) {
       case RED:
         return (moment[get_index (position, cube.g1, cube.b1)]
             - moment[get_index (position, cube.g1, cube.b0)]
             - moment[get_index (position, cube.g0, cube.b1)]
             + moment[get_index (position, cube.g0, cube.b0)]);
       case GREEN:
         return (moment[get_index (cube.r1, position, cube.b1)]
             - moment[get_index (cube.r1, position, cube.b0)]
             - moment[get_index (cube.r0, position, cube.b1)]
             + moment[get_index (cube.r0, position, cube.b0)]);
       case BLUE:
         return (moment[get_index (cube.r1, cube.g1, position)]
             - moment[get_index (cube.r1, cube.g0, position)]
             - moment[get_index (cube.r0, cube.g1, position)]
             + moment[get_index (cube.r0, cube.g0, position)]);
     }
     error ("Unexpected direction %s".printf (direction.to_string ()));
   }

   private enum Direction {
     RED,
     GREEN,
     BLUE;

      public string to_string () {
        switch (this) {
          case RED:
            return "red";
          case GREEN:
            return "green";
          case BLUE:
            return "blue";
        }
        return "unknown";
      }
   }

   private class MaximizeResult : Object {
     // < 0 if cut impossible
     public int cut_location;
     public double maximum;

     public MaximizeResult (int cut, double max) {
       this.cut_location = cut;
       this.maximum = max;
     }
   }

   private class CreateBoxesResult : Object {
     public int requested_count;
     public int result_count;

     public CreateBoxesResult (int requested_count, int result_count) {
       this.requested_count = requested_count;
       this.result_count = result_count;
     }
   }

   private class Box : Object {
     public int r0 = 0;
     public int r1 = 0;
     public int g0 = 0;
     public int g1 = 0;
     public int b0 = 0;
     public int b1 = 0;
     public int vol = 0;
   }
 }
