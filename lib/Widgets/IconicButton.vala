class He.IconicButton : Gtk.Button, Gtk.Buildable {
  public string icon {
    get {
      return this.get_icon_name ();
    }
    set {
      this.set_icon_name (value);
    }
  }

  public IconicButton(string icon) {
    this.icon = icon;
  }

  construct {
    this.add_css_class ("flat");
    this.valign = Gtk.Align.CENTER;
  }
}
