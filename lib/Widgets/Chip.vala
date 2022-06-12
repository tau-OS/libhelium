/**
* A Chip is an element that can facilitate entering information, making selections, filtering content, or triggering actions.
*/
public class He.Chip : Gtk.Button {
  /**
  * Creates a new Chip.
  * @param text The text to display in the chip.
  */
  public Chip(string label) {
    this.label = label;
  }

  construct {
    this.add_css_class ("chip");
  }
}