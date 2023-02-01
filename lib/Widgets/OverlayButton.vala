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
 * An OverlayButton is a widget that can be used to show action buttons above the widget that is being overlaid.
 */
public class He.OverlayButton : He.Bin, Gtk.Buildable {
    private Gtk.Button button = new Gtk.Button();
    private Gtk.Box button_content = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
    private Gtk.Box button_row = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 18);
    private Gtk.Image image = new Gtk.Image();
    private Gtk.Overlay overlay = new Gtk.Overlay();
    private Gtk.Button secondary_button = new Gtk.Button();
    private Gtk.Image secondary_image;
    private Gtk.Label? _label;

    public signal void clicked();
    public signal void secondary_clicked();

    /**
     * The size of the button as an enum.
     */
    public enum Size {
        SMALL,
        MEDIUM,
        LARGE;

        /**
         * Returns the string representation of the enum as a CSS class to be used.
         */
        public string? to_css_class() {
            switch (this) {
                case SMALL:
                    return "small";
                case MEDIUM:
                    return null;
                case LARGE:
                    return "large";
                default:
                    return null;
            }
        }
    }
    
    /**
     * The type of the button as an enum.
     */
    public enum TypeButton {
        SURFACE,
        PRIMARY,
        SECONDARY,
        TERTIARY;

        /**
         * Returns the string representation of the enum as a CSS class to be used.
         */
        public string? to_css_class() {
            switch (this) {
                case SURFACE:
                    return null;
                case PRIMARY:
                    return "primary";
                case SECONDARY:
                    return "secondary";
                case TERTIARY:
                    return "tertiary";
                default:
                    return null;
            }
        }
    }

    /**
     * The alignment of the button.
     */
    public enum Alignment {
        LEFT,
        CENTER,
        RIGHT;

        /**
         * Returns the string representation of the enum as an alignment to be used.
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
         * Returns the string representation of the enum as an alignment.
         * @param align The alignment to use.
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

    private Size? _size;
    /**
     * The size of the button.
     */
    public Size size {
        set {
            if (_size != null && _size != Size.MEDIUM) button.remove_css_class (_size.to_css_class());
            if (value != Size.MEDIUM) button.add_css_class (value.to_css_class());

            _size = value;
        }

        get {
            return _size;
        }
    }
    
    private TypeButton? _typeb;
    /**
     * The type of the button.
     */
    public TypeButton typeb {
        set {
            if (_typeb != null && _typeb != TypeButton.SURFACE) button.remove_css_class (_typeb.to_css_class());
            if (value != TypeButton.SURFACE) button.add_css_class (value.to_css_class());

            _typeb = value;
        }

        get {
            return _typeb;
        }
    }
    
    private TypeButton? _typeb2;
    /**
     * The type of the secondary button.
     */
    public TypeButton typeb2 {
        set {
            if (_typeb2 != null && _typeb2 != TypeButton.SURFACE) secondary_button.remove_css_class (_typeb2.to_css_class());
            if (value != TypeButton.SURFACE) secondary_button.add_css_class (value.to_css_class());

            _typeb2 = value;
        }

        get {
            return _typeb2;
        }
    }

    private He.Colors _color;
    /**
     * The color of the button.
     */
    public He.Colors color {
        set {
            if (_color != He.Colors.NONE) button.remove_css_class (_color.to_css_class());
            if (value != He.Colors.NONE) button.add_css_class (value.to_css_class());

            _color = value;
        }

        get {
            return _color;
        }
    }

    private He.Colors _secondary_color;
    /**
     * The color of the secondary button.
     */
    public He.Colors secondary_color {
        set {
            if (_color != He.Colors.NONE) secondary_button.remove_css_class (_secondary_color.to_css_class());
            if (value != He.Colors.NONE) secondary_button.add_css_class (value.to_css_class());

            _secondary_color = value;
        }

        get {
            return _secondary_color;
        }
    }

    /**
     * The secondary button icon.
     */
    public string? secondary_icon {
        set {
            if (value == null) {
                if (secondary_image != null) {
                    secondary_image.destroy();

                    secondary_button.set_child(null);
                    button_row.remove (secondary_button);

                    secondary_image = null;
                }

                return;
            }

            if (secondary_image == null) {
                secondary_image = new Gtk.Image();
                secondary_button.set_child(secondary_image);
                button_row.prepend(secondary_button);
            }

            secondary_image.set_from_icon_name(value);
        }

        owned get {
            if (secondary_image == null) return null;
            return secondary_image.icon_name;
        }
    }

    /**
     * The primary button icon.
     */
    public string icon {
        set {
            image.set_from_icon_name(value);
        }

        owned get {
            return image.icon_name;
        }
    }

    /**
     * The primary button label.
     */
    public string? label {
        set {
            if (value == null) {
                if (_label != null) {
                    button.remove_css_class("textual");
                    button_content.remove(_label);
                    _label = null;
                }

                return;
            }

            if (_label == null) {
                _label = new Gtk.Label(null);
                button.add_css_class("textual");
                button_content.append(_label);
            }

            _label.set_text(value);
        }

        get {
            if (_label == null) return null;
            return _label.get_text();
        }
    }

    /**
     * The widget to be overlaid.
     */
    public new Gtk.Widget? child {
        get {
            return overlay.get_child();
        }

        set {
            overlay.set_child(value);
        }
    }

    /**
    * Add a child to the overlay button, should only be used in the context of a UI or Blueprint file. There should be no need to use this method in code.
    */
    public new void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
        this.child = (Gtk.Widget) child;
    }

    /**
     * The alignment of the button.
     */
    public Alignment alignment {
        set {
            button_row.set_halign(value.to_gtk_align());
        }

        get {
            return Alignment.from_gtk_align(button_row.get_halign());
        }
    }

    /**
     * Creates a new OverlayButton.
     * @param icon The icon of the button.
     * @param label The label of the button.
     * @param secondary_icon The icon of the secondary button.
     *
     * @since 1.0
     */
    public OverlayButton(string icon, string? label, string? secondary_icon) {
        base ();
        this.icon = icon;
        if (label != null) this.label = label;
        if (secondary_icon != null) this.secondary_icon = secondary_icon;
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BinLayout));
    }

    construct {
        button_content.append(image);
        button.set_child(button_content);
        button.add_css_class ("overlay-button");
        button.valign = Gtk.Align.END;

        button_row.append(button);
        button_row.add_css_class("overlay-button-row");
        button_row.valign = Gtk.Align.END;
        
        secondary_button.add_css_class("overlay-button");
        secondary_button.add_css_class("small");
        secondary_button.valign = Gtk.Align.CENTER;
        secondary_button.clicked.connect(() => {
            secondary_clicked();
        });

        overlay.add_overlay(button_row);
        overlay.set_parent (this);
        
        button.clicked.connect(() => {
            clicked();
        });
        
        this.size = Size.MEDIUM;
        this.typeb = TypeButton.SURFACE;
        this.typeb2 = TypeButton.SURFACE;
        this.alignment = Alignment.RIGHT;
        this.vexpand = true;
        this.hexpand = true;
    }
}
