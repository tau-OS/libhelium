/*
 * Copyright (c) 2024 Fyra Labs
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA
 */

namespace He {
    public enum ButtonColor {
        SURFACE,
        PRIMARY,
        SECONDARY,
        TERTIARY
    }
    public enum ButtonSize {
        XSMALL,
        SMALL,
        MEDIUM,
        LARGE,
        XLARGE
    }
    public enum ButtonWidth {
        DEFAULT,
        NARROW,
        WIDE
    }
}

/**
 * A class to derive UI Buttons from.
 *
 * @since 1.0
 */
public class He.Button : Gtk.Button, Gtk.Buildable {

    /**
     * Signal emitted when toggle state changes
     */
    public signal void toggled (bool active);

    /**
     * The custom color of the button.
     * For when Surface/Primary/Secondary/Tertiary doesn't give it semantic value.
     * @since 1.0
     */
    private He.Colors _custom_color;
    public He.Colors custom_color {
        set {
            if (_custom_color != He.Colors.NONE)
                this.remove_css_class (_custom_color.to_css_class ());
            if (value != He.Colors.NONE)
                this.add_css_class (value.to_css_class ());

            _custom_color = value;
        }

        get {
            return _custom_color;
        }
    }

    /**
     * The color of the button.
     */
    private He.ButtonColor _color;
    public He.ButtonColor color {
        set {
            // Remove old color classes
            this.remove_css_class ("surface");
            this.remove_css_class ("primary");
            this.remove_css_class ("secondary");
            this.remove_css_class ("tertiary");

            _color = value;

            // Add new color class
            switch (_color) {
            case He.ButtonColor.SURFACE:
                this.add_css_class ("surface");
                break;
            case He.ButtonColor.PRIMARY:
                this.add_css_class ("primary");
                break;
            case He.ButtonColor.SECONDARY:
                this.add_css_class ("secondary");
                break;
            case He.ButtonColor.TERTIARY:
                this.add_css_class ("tertiary");
                break;
            }
        }

        get {
            return _color;
        }
    }

    /**
     * The size of the button.
     */
    private He.ButtonSize _size;
    public He.ButtonSize size {
        set {
            // Remove old size classes
            this.remove_css_class ("small");
            this.remove_css_class ("medium");
            this.remove_css_class ("large");
            this.remove_css_class ("xlarge");

            _size = value;

            // Add new size class
            switch (_size) {
            case He.ButtonSize.XSMALL:
                this.add_css_class ("xsmall");
                break;
            case He.ButtonSize.SMALL:
                this.add_css_class ("small");
                break;
            case He.ButtonSize.MEDIUM:
                this.add_css_class ("medium");
                break;
            case He.ButtonSize.LARGE:
                this.add_css_class ("large");
                break;
            case He.ButtonSize.XLARGE:
                this.add_css_class ("xlarge");
                break;
            }
        }

        get {
            return _size;
        }
    }

    /**
     * The width of the button.
     */
    private He.ButtonWidth _width;
    public He.ButtonWidth width {
        set {
            // Remove old width classes
            this.remove_css_class ("narrow");
            this.remove_css_class ("wide");

            _width = value;

            // Add new width class
            switch (_width) {
            case He.ButtonWidth.DEFAULT:
                this.remove_css_class ("narrow");
                this.remove_css_class ("wide");
                break;
            case He.ButtonWidth.WIDE:
                this.add_css_class ("wide");
                break;
            case He.ButtonWidth.NARROW:
                this.add_css_class ("narrow");
                break;
            }
        }

        get {
            return _width;
        }
    }

    /**
     * Whether the button is in toggle mode
     */
    private bool _toggle_mode;
    public bool toggle_mode {
        get {
            return _toggle_mode;
        }
        set {
            _toggle_mode = value;
            if (value) {
                this.add_css_class ("toggle-button");
            } else {
                this.remove_css_class ("toggle-button");
                this.remove_css_class ("active");
                _active = false;
            }
        }
    }

    /**
     * Whether the button is active (only relevant in toggle mode)
     */
    private bool _active;
    public bool active {
        get {
            return _active;
        }
        set {
            if (_toggle_mode && _active != value) {
                _active = value;
                if (_active) {
                    this.add_css_class ("active");
                } else {
                    this.remove_css_class ("active");
                }
                toggled (_active);
            }
        }
    }

    /**
     * If the button is disclosure styled
     */
    private bool _is_disclosure;
    public bool is_disclosure {
        get {
            return _is_disclosure;
        }
        set {
            _is_disclosure = value;
            custom_color = He.Colors.NONE;
            if (value) {
                this.add_css_class ("disclosure-button");
                this.remove_css_class ("image-button");
                this.remove_css_class ("text-button");
            } else {
                this.remove_css_class ("disclosure-button");
                this.remove_css_class ("image-button");
                this.remove_css_class ("text-button");
            }
        }
    }

    /**
     * If the button is iconic styled
     */
    private bool _is_iconic;
    public bool is_iconic {
        get {
            return _is_iconic;
        }
        set {
            _is_iconic = value;
            custom_color = He.Colors.NONE;
            if (value) {
                this.add_css_class ("iconic-button");
                this.add_css_class ("flat");
                this.remove_css_class ("image-button");
                this.remove_css_class ("text-button");
            } else {
                this.remove_css_class ("iconic-button");
                this.remove_css_class ("flat");
                this.remove_css_class ("image-button");
                this.remove_css_class ("text-button");
            }
        }
    }

    /**
     * If the button is outline styled
     */
    private bool _is_outline;
    public bool is_outline {
        get {
            return _is_outline;
        }
        set {
            _is_outline = value;
            if (value) {
                this.add_css_class ("outline-button");
                this.remove_css_class ("image-button");
                this.remove_css_class ("text-button");
            } else {
                this.remove_css_class ("outline-button");
                this.remove_css_class ("image-button");
                this.remove_css_class ("text-button");
            }
        }
    }

    /**
     * If the button is tint styled
     */
    private bool _is_tint;
    public bool is_tint {
        get {
            return _is_tint;
        }
        set {
            _is_tint = value;
            if (value) {
                this.add_css_class ("tint-button");
                this.remove_css_class ("image-button");
                this.remove_css_class ("text-button");
            } else {
                this.remove_css_class ("tint-button");
                this.remove_css_class ("image-button");
                this.remove_css_class ("text-button");
            }
        }
    }

    /**
     * If the button is fill styled
     */
    private bool _is_fill;
    public bool is_fill {
        get {
            return _is_fill;
        }
        set {
            _is_fill = value;
            if (value) {
                this.add_css_class ("fill-button");
                this.remove_css_class ("image-button");
                this.remove_css_class ("text-button");
            } else {
                this.remove_css_class ("fill-button");
                this.remove_css_class ("image-button");
                this.remove_css_class ("text-button");
            }
        }
    }

    /**
     * If the button is pill styled
     */
    private bool _is_pill;
    public bool is_pill {
        get {
            return _is_pill;
        }
        set {
            _is_pill = value;
            if (value) {
                this.add_css_class ("pill-button");
                this.remove_css_class ("image-button");
                this.remove_css_class ("text-button");
            } else {
                this.remove_css_class ("pill-button");
                this.remove_css_class ("image-button");
                this.remove_css_class ("text-button");
            }
        }
    }

    /**
     * If the button is textual styled
     */
    private bool _is_textual;
    public bool is_textual {
        get {
            return _is_textual;
        }
        set {
            _is_textual = value;
            if (value) {
                this.add_css_class ("textual-button");
                this.remove_css_class ("image-button");
                this.remove_css_class ("text-button");
            } else {
                this.remove_css_class ("textual-button");
                this.remove_css_class ("image-button");
                this.remove_css_class ("text-button");
            }
        }
    }

    /**
     * The icon of the Button.
     * @since 1.0
     */
    private string? _icon;
    public string? icon {
        set {
            _icon = value;
            set_icon_name (_icon);
        }

        get {
            return _icon;
        }
    }

    /**
     * The text of the Button.
     * @since 1.0
     */
    private string? _text;
    public string text {
        set {
            _text = value;
            if (_text != "")
                set_label (_text);
        }

        get {
            return _text;
        }
    }

    public Button (string? icon, string? text) {
        this.icon = (icon != "" || icon != null) ? icon : "list-add-symbolic";
        this.text = text;
    }

    construct {
        is_outline = false;
        is_tint = false;
        is_fill = false;
        is_pill = false;
        is_textual = false;
        is_disclosure = false;
        is_iconic = false;
        toggle_mode = false;
        _active = false;
        size = He.ButtonSize.SMALL;
        width = He.ButtonWidth.DEFAULT;

        // Handle toggle functionality
        this.clicked.connect (() => {
            if (_toggle_mode) {
                active = !_active;
            }
        });
    }
}