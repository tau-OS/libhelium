class libhelium.FillButton : libhelium.Button {
    private libhelium.Colors _color;

    public override libhelium.Colors color {
        set {
            var style_context = this.get_style_context ();
            if (_color != libhelium.Colors.NONE) style_context.remove_class (_color.to_css_class());
            if (value != libhelium.Colors.NONE) style_context.add_class (value.to_css_class());

            this.

            _color = value;
        }

        get {
            return _color;
        }
    }

    public FillButton(string label) {
        this.label = label;
    }
}
