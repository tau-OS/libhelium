public class He.ModifierBadge : Gtk.Box {
    private Gtk.Label _label;

    private He.Colors _color;

    public He.Colors color {
        set {
            if (_color != He.Colors.NONE) this.remove_css_class (_color.to_css_class());
            if (value != He.Colors.NONE) this.add_css_class (value.to_css_class());

            _color = value;
        }

        get {
            return _color;
        }
    }

    private bool _tinted = false;
    public bool tinted {
        get {
            return _tinted;
        }
        set {
            _tinted = value;

            if (value) {
                this.add_css_class ("tint-badge");
            } else {
                this.remove_css_class ("tint-badge");
            }
        }
    }


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
  
    public enum Alignment {
        LEFT,
        CENTER,
        RIGHT;

        public Gtk.Align to_gtk_align() {
            switch (this) {
                case LEFT:
                    return Gtk.Align.START;
                case CENTER:
                    return Gtk.Align.CENTER;
                case RIGHT:
                    return Gtk.Align.END;
                default:
                    return Gtk.Align.END;
            }
        }

        public static Alignment from_gtk_align(Gtk.Align align) {
            switch (align) {
                case Gtk.Align.START:
                    return Alignment.LEFT;
                case Gtk.Align.CENTER:
                    return Alignment.CENTER;
                case Gtk.Align.END:
                    return Alignment.RIGHT;
                default:
                    return Alignment.RIGHT;
            }
        }
    }

    public Alignment alignment {
        set {
            this.set_halign(value.to_gtk_align());
        }

        get {
            return Alignment.from_gtk_align(this.get_halign());
        }
    }

    construct {
        this.color = He.Colors.YELLOW;
        this.height_request = 16;
        this.add_css_class ("modifier-badge");
        this.hexpand = false;
        this.vexpand = false;
        this.valign = Gtk.Align.CENTER;
        this.alignment = Alignment.RIGHT;
    }
}
