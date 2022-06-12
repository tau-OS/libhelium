/**
 * A TextButton is a button that displays text. It has a transparent background.
 */
public class He.TextButton : He.Button {
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
     * Creates a new TextButton.
     * @param label The text to display on the button.
     */
    public TextButton(string label) {
        this.label = label;
    }
    
    /**
     * Creates a new TextButton from an icon.
     * @param icon The icon to display on the button.
     */
    public TextButton.from_icon(string icon) {
        this.icon = icon;
    }
    
    construct {
        this.add_css_class ("textual-button");
    }
}
