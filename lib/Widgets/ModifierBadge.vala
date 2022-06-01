class He.ModifierBadge : Gtk.Box {
  private Gtk.Label _label;

  public string? label {
    get {
      return _label?.get_text();
    }

    set {
      if (value == null) {
        this._label = null;
        this.remove(_label);
        return;
      }

      if (_label == null) {
        _label = new Gtk.Label(null);
        this.append(_label);
      }

      _label.set_text (value);
    }
  }

  public ModifierBadge(string? label) {
    this.label = label;
  }
  
  construct {
    this.set_size_request(16, 16);
    this.add_css_class ("modifier-badge");
    this.hexpand = false;
    this.vexpand = false;
    this.hexpand_set = true;
  }
}