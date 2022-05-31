class He.ViewTitle : Gtk.Box, Gtk.Buildable {
    private Gtk.Label? _label;
    public string? label {
        set {
            if (value == null) {
                if (_label != null) {
                    _label = null;
                }

                return;
            }

            if (_label == null) {
                _label = new Gtk.Label(null);
            }

            _label.set_text(value);
        }

        get {
            if (_label == null) return null;
            return _label.get_text();
        }
    }

	public ViewTitle () {
		_label.xalign = 0;
		_label.add_css_class ("view-title");
		_label.margin_top = 6;
		_label.margin_start = _label.margin_end = 18;
		_label.margin_bottom = 12;
		
		this.append (_label);
	}
}
