class He.BottomBar : Gtk.Box, Gtk.Buildable {
  private Gtk.Box left_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 18);
  private Gtk.Box center_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
  private Gtk.Box right_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 18);

  private Gtk.Label title_label = new Gtk.Label (null);
  private Gtk.Label description_label = new Gtk.Label (null);

  public string title {
    get { return title_label.get_text (); }
    set { title_label.set_text (value); }
  }
  public string description {
    get { return description_label.get_text (); }
    set { description_label.set_text (value); }
  }

  public enum Position {
    LEFT,
    RIGHT,
  }

  public void append_button(He.IconicButton icon, Position position) {
    var box = position == Position.LEFT ? left_box : right_box;
    box.append(icon);
  }

  public void prepend_button(He.IconicButton icon, Position position) {
    var box = position == Position.LEFT ? left_box : right_box;
    box.prepend(icon);
  }

  public void remove_button(He.IconicButton icon, Position position) {
    var box = position == Position.LEFT ? left_box : right_box;
    box.remove(icon);
  }

  public void insert_button_after(He.IconicButton icon, He.IconicButton after, Position position) {
    var box = position == Position.LEFT ? left_box : right_box;
    box.insert_child_after(icon, after);
  }

  public void reorder_button_after(He.IconicButton icon, He.IconicButton after, Position position) {
    var box = position == Position.LEFT ? left_box : right_box;
    box.insert_child_after(icon, after);
  }

  public BottomBar(string title, string description) {
    this.title = title;
    this.description = description;
  }
  
  construct {
    this.title_label.add_css_class ("title");
    this.description_label.add_css_class ("dim-label");
    this.add_css_class ("bottom-bar");

    this.center_box.append(title_label);
    this.center_box.append(description_label);
    this.center_box.homogeneous = true;
    this.center_box.margin_start = this.center_box.margin_end = 18;

    var center_layout = new Gtk.CenterLayout();
    this.layout_manager = center_layout;

    center_layout.set_start_widget(left_box);
    center_layout.set_center_widget(center_box);
    center_layout.set_end_widget(right_box);

    this.append(left_box);
    this.append(center_box);
    this.append(right_box);
  }
}
