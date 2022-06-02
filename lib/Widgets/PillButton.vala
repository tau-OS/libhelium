public class He.PillButton : He.Button {
    private He.Colors _color;

    public override He.Colors color {
        set {
            if (_color != He.Colors.NONE) this.remove_css_class (_color.to_css_class());
            if (value != He.Colors.NONE) this.add_css_class (value.to_css_class());

            _color = value;
        }

        get {
            return _color;
        }
    }

    public PillButton(string label) {
        this.label = label;
    }

    construct {
        this.add_css_class ("pill-button");
    }
}
