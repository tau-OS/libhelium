/*
* Copyright (c) 2022 Fyra Labs
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/

/**
 * A ModiferBadge is a badge that can be used to show that the state of something has changed.
 */
public class He.ModifierBadge : He.Bin {
    private Gtk.Label _label;
    private He.Colors _color;

    /**
     * The color of the badge.
     */
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

    /**
     * If the badge is tinted. If false, the badge will be solid.
     */
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


    /**
     * The text of the badge.
     */
    public string? label {
        get {
          return _label?.get_text();
        }

        set {
            if (value == null) {
                this._label = null;
                _label.unparent();
                return;
            }

            if (_label == null) {
                _label = new Gtk.Label(null);
                _label.set_parent (this);
            }

            _label.set_text (value);
        }
    }

    /**
     * Creates a new ModifierBadge.
     * @param label The text of the badge.
     */
    public ModifierBadge(string? label) {
        base ();
        this.label = label;
    }
  
    /** 
     * The alignment of the badge in a enum.
     */
    public enum Alignment {
        LEFT,
        CENTER,
        RIGHT;

        /**
         * Returns the alignment as a Gtk.Alignment.
         */
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

        /**
         * Sets the alignment from a Gtk.Align.
         * @param align The alignment to set.
         */
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

    /**
     * The alignment of the badge.
     *
     * @since 1.0
     */
    public Alignment alignment {
        set {
            this.set_halign(value.to_gtk_align());
        }

        get {
            return Alignment.from_gtk_align(this.get_halign());
        }
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BinLayout));
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
