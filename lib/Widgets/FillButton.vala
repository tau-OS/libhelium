/**
* A FillButton is a solid button with a label.
*/
public class He.FillButton : He.Button {
    private He.Colors _color;

    /**
     * The color of the button.
     */
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

    /**
    * Creates a new FillButton.
    * @param label The label of the button.
    */
    public FillButton(string label) {
        this.label = label;
    }

    construct {
        this.add_css_class ("fill-button");
    }
}
