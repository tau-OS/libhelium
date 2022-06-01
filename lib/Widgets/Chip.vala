class He.Chip : Gtk.Button {
  public Chip(string label) {
    this.label = label;
  }

  construct {
    this.add_css_class ("chip");
  }
}