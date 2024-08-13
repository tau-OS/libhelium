namespace He {
    public struct RGBColor {
        public double r;
        public double g;
        public double b;
    }

    private const double[,] XYZ_TO_SRGB = {
        { 3.2406, -1.5372, -0.4986 },
        { -0.9689, 1.8758, 0.0415 },
        { 0.0557, -0.2040, 1.0570 }
    };

    public RGBColor xyz_to_rgb (XYZColor color) {
        double[] rgbd = MathUtils.elem_mul ({ color.x, color.y, color.z }, XYZ_TO_SRGB);

        RGBColor rgb = { rgbd[0], rgbd[1], rgbd[2] };

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
            color.red,
            color.green,
            color.blue,
        };

        return result;
    }

    public RGBColor from_hex (string color) {
        RGBColor result = {
            ((uint.parse (color, 16) >> 16) & 0xFF) / 255.0,
            ((uint.parse (color, 16) >> 8) & 0xFF) / 255.0,
            ((uint.parse (color, 16)) & 0xFF) / 255.0
        };

        return result;
    }

    public RGBColor from_argb_int (int argb) {
        double r = MathUtils.linearized (red_from_rgba_int (argb));
        double g = MathUtils.linearized (green_from_rgba_int (argb));
        double b = MathUtils.linearized (blue_from_rgba_int (argb));
        var d = MathUtils.elem_mul (new double[] { r, g, b }, SRGB_TO_XYZ);

        return xyz_to_rgb ({ d[0], d[1], d[2] });
    }
}