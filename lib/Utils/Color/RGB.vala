namespace He.Color {
    public struct RGBColor {
        public double r;
        public double g;
        public double b;
    }

    public const double[,] XYZ_TO_SRGB = {
        {3.2406, -1.5372, -0.4986},
        {-0.9689, 1.8758, 0.0415},
        {0.0557, -0.2040, 1.0570}
    };

    public RGBColor xyz_to_rgb (XYZColor color) {
        double[] rgbd = MathUtils.elem_mul ({color.x, color.y, color.z}, XYZ_TO_SRGB);

        RGBColor rgb = {rgbd[0], rgbd[1], rgbd[2]};

        rgb.r = MathUtils.adapt (rgb.r) * 255.0;
        rgb.g = MathUtils.adapt (rgb.g) * 255.0;
        rgb.b = MathUtils.adapt (rgb.b) * 255.0;

        return rgb;
    }

    public RGBColor lab_to_rgb (LABColor color) {
        var xyz_lab = lab_to_xyz (color);
        var result = xyz_to_rgb (xyz_lab);
    
        return result;
    }

    public RGBColor lch_to_rgb (LCHColor color) {
        var lab = lch_to_lab (color);
        var rgb = lab_to_rgb (lab);
    
        RGBColor result = rgb;
    
        return result;
    }

    public RGBColor from_gdk_rgba (Gdk.RGBA color) {
        RGBColor result = {
          color.red * 255.0,
          color.green * 255.0,
          color.blue * 255.0,
        };
    
        return result;
    }

    public RGBColor from_hex (string color) {
        RGBColor result = {
          ((uint.parse(color, 16) >> 16) & 0xFF) / 255.0,
          ((uint.parse(color, 16) >> 8) & 0xFF) / 255.0,
          ((uint.parse(color, 16)) & 0xFF) / 255.0
        };
    
        return result;
    }
    
    public RGBColor from_argb_int (int argb) {
        int red = (argb & 0x00ff0000) >> 16;
        int green = (argb & 0x0000ff00) >> 8;
        int blue = (argb & 0x000000ff);
        double redL = He.MathUtils.linearized(red);
        double greenL = He.MathUtils.linearized(green);
        double blueL = He.MathUtils.linearized(blue);
        double x = 0.41233895 * redL + 0.35762064 * greenL + 0.18051042 * blueL;
        double y = 0.2126 * redL + 0.7152 * greenL + 0.0722 * blueL;
        double z = 0.01932141 * redL + 0.11916382 * greenL + 0.95034478 * blueL;

        XYZColor result = {
            x,
            y,
            z
        };
    
        return xyz_to_rgb(result);
    }
}