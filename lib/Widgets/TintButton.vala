/**
* A TintButton is similar to a FillButton, except that the color of the button has a tinted appearance. In addition, the TintButton also support icons.
*/
public class He.TintButton : He.Button {
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
    * Create a new TintButton.
    * @param label The text to display on the button.
    */
    public TintButton(string label) {
        this.label = label;
    }

    /**
    * Create a new TintButton from an icon.
    * @param icon The icon to display on the button.
    */
    public TintButton.from_icon(string icon) {
        this.icon = icon;
    }
    
    construct {
        this.add_css_class ("tint-button");
    }
}
