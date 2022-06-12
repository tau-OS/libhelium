/**
* A Chip is an element that can facilitate entering information, making selections, filtering content, or triggering actions.
*/
public class He.Chip : He.Button {
  private He.Colors _color;
  /**
   * The color of the button.
   */
  public override He.Colors color {
      set {
          _color = He.Colors.NONE;
      }

      get {
          return _color;
      }
  }

  /**
  * Creates a new Chip.
  * @param text The text to display in the chip.
  */
  public Chip(string label) {
    this.label = label;
  }

  construct {
    this.add_css_class ("chip");
    this.color = He.Colors.NONE;
  }
}