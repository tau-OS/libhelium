namespace He.Color {
    public struct RGBColor {
        public double r;
        public double g;
        public double b;
    }

    public RGBColor xyz_to_rgb (XYZColor color) {
        RGBColor rgb = {};

        rgb.r = (color.x *  3.240479) + (color.y * -1.537150) + (color.z * -0.498535);
        rgb.g = (color.x * -0.969256) + (color.y *  1.875992) + (color.z *  0.041556);
        rgb.b = (color.x *  0.055648) + (color.y * -0.204043) + (color.z *  1.057311);

        if (rgb.r > 0.0031308) {
            rgb.r = (1.055 * Math.pow(rgb.r, (1.0/2.4))) - 0.055;
        } else {
            rgb.r = rgb.r * 12.92;
        }

        if (rgb.g > 0.0031308) {
            rgb.g = (1.055 * Math.pow(rgb.g, (1.0/2.4))) - 0.055;
        } else {
            rgb.g = rgb.g * 12.92;
        }

        if (rgb.b > 0.0031308) {
            rgb.b = (1.055 * Math.pow(rgb.b, (1.0/2.4))) - 0.055;
        } else {
            rgb.b = rgb.b * 12.92;
        }

        rgb.r = rgb.r * 255.0;
        rgb.g = rgb.g * 255.0;
        rgb.b = rgb.b * 255.0;

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
          uint.parse(color.substring(1, 2), 16),
          uint.parse(color.substring(3, 2), 16),
          uint.parse(color.substring(5, 2), 16),
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