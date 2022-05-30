class He.TintButton : He.Button {
    private He.Colors _color;

    public override He.Colors color {
        set {
            var style_context = this.get_style_context ();
            if (_color != He.Colors.NONE) style_context.remove_class (_color.to_css_class());
            if (value != He.Colors.NONE) style_context.add_class (value.to_css_class());

            _color = value;
        }

        get {
            return _color;
        }
    }

    public TintButton(string label) {
        this.label = label;
    }
    
    construct {
        var style_context = this.get_style_context ();
        style_context.add_class ("tint-button");
    }
}
