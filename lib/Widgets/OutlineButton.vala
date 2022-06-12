/**
* An Outline button is a transparent FillButton with a border.
*/
public class He.OutlineButton : He.Button {
    private He.Colors _color;

    /**
     * The color of the outline button.
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
    * Creates a new OutlineButton.
    * @param label The label of the button.
    */
    public OutlineButton(string label) {
        this.label = label;
    }
    
    construct {
        this.add_css_class ("outline-button");
    }
}
