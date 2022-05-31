class He.BottomBar : Gtk.Box {
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

    this.left_box.hexpand = true;
    this.right_box.hexpand = true;

    //  this.title_label.vexpand = true;
    //  this.description_label.vexpand = true;

    this.append(left_box);
    this.append(center_box);
    this.append(right_box);
  }
}