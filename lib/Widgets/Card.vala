/*
 * Copyright (c) 2022 Fyra Labs
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

/**
 * Type of card appearance
 */
public enum He.CardType {
    DEFAULT,
    OUTLINE,
    FILLED,
    ELEVATED
}

/**
 * Layout style of the card
 */
public enum He.CardLayout {
    VERTICAL, // ContentBlock style - icon/text/buttons vertically
    HORIZONTAL // MiniContentBlock style - icon, text, buttons horizontally
}

/**
 * A Card displays content with an icon, text and optional buttons.
 * Combines functionality of ContentBlock and MiniContentBlock.
 */
public class He.Card : He.Bin, Gtk.Buildable {
    private Gtk.Label title_label;
    private Gtk.Label subtitle_label;
    private Gtk.Image image = new Gtk.Image ();
    private Gtk.Box info_box;
    private Gtk.Box button_box;
    private Gtk.Box main_box;
    private He.Button _secondary_button;
    private He.Button _primary_button;
    private Gtk.Widget? _widget;

    // Store text separately to preserve across layout changes
    private string? _title_text;
    private string? _subtitle_text;

    private CardType _card_type = CardType.DEFAULT;
    private CardLayout _layout = CardLayout.VERTICAL;

    /**
     * Sets the type of the card for styling.
     */
    public CardType card_type {
        get {
            return _card_type;
        }
        set {
            if (_card_type == value)return;

            // Remove old CSS class
            switch (_card_type) {
            case CardType.OUTLINE :
                remove_css_class ("outline");
                break;
            case CardType.FILLED:
                remove_css_class ("filled");
                break;
            case CardType.ELEVATED:
                remove_css_class ("elevated");
                break;
            case CardType.DEFAULT:
            default:
                remove_css_class ("outline");
                remove_css_class ("elevated");
                break;
            }

            _card_type = value;

            // Add new CSS class
            switch (_card_type) {
            case CardType.OUTLINE:
                add_css_class ("outline");
                break;
            case CardType.FILLED:
                add_css_class ("filled");
                break;
            case CardType.ELEVATED:
                add_css_class ("elevated");
                break;
            case CardType.DEFAULT:
            default:
                add_css_class ("filled");
                break;
            }
        }
    }

    /**
     * Sets the layout of the card.
     */
    public CardLayout layout {
        get {
            return _layout;
        }
        set {
            if (_layout == value)return;
            _layout = value;
            rebuild_layout ();
        }
    }

    /**
     * Sets the title of the card.
     */
    public virtual string title {
        get {
            return _title_text ?? "";
        }
        set {
            _title_text = value;
            if (title_label != null) {
                if (value != null && value != "") {
                    title_label.set_text (value);
                    title_label.set_visible (true);
                } else {
                    title_label.set_visible (false);
                }
            }
        }
    }

    /**
     * Sets the subtitle of the card.
     */
    public virtual string subtitle {
        get {
            return _subtitle_text ?? "";
        }
        set {
            _subtitle_text = value;
            if (subtitle_label != null) {
                if (value != null && value != "") {
                    subtitle_label.set_text (value);
                    subtitle_label.set_visible (true);
                } else {
                    subtitle_label.set_visible (false);
                }
            }
        }
    }

    /**
     * Sets the icon of the card.
     */
    public virtual string icon {
        get {
            return image.get_icon_name ();
        }
        set {
            if (value == null) {
                image.set_visible (false);
            } else {
                image.set_visible (true);
                image.set_from_icon_name (value);
            }
        }
    }

    /**
     * Sets the icon of the card, as a GLib.Icon.
     */
    public virtual GLib.Icon gicon {
        set {
            if (value == null) {
                image.set_visible (false);
            } else {
                image.set_visible (true);
                image.set_from_gicon (value);
            }
        }
    }

    /**
     * Sets the icon of the card as a Gdk.Paintable.
     */
    public virtual Gdk.Paintable paintable {
        set {
            if (value == null) {
                image.set_visible (false);
            } else {
                image.set_visible (true);
                image.set_from_paintable (value);
            }
        }
    }

    /**
     * Sets the widget of the card (for horizontal layout).
     */
    public virtual Gtk.Widget? widget {
        get {
            return _widget;
        }
        set {
            if (value == _widget)return;

            if (_widget != null && button_box != null) {
                button_box.remove (_widget);
            }

            _widget = value;

            if (value != null && button_box != null) {
                button_box.append (value);
            }
        }
    }

    /**
     * Sets the secondary button of the card.
     */
    public virtual He.Button secondary_button {
        set {
            if (_secondary_button != null && button_box != null) {
                button_box.remove (_secondary_button);
            }

            if (value != null) {
                value.is_tint = true;
                _secondary_button = value;
                if (button_box != null) {
                    button_box.prepend (_secondary_button);
                }
            }
        }
        get {
            return _secondary_button;
        }
    }

    /**
     * Sets the primary button of the card.
     */
    public virtual He.Button primary_button {
        get {
            return _primary_button;
        }
        set {
            if (_primary_button != null && button_box != null) {
                button_box.remove (_primary_button);
            }

            if (value != null) {
                _primary_button = value;
                value.is_fill = true;

                if (_layout == CardLayout.HORIZONTAL) {
                    value.hexpand = true;
                    value.halign = Gtk.Align.END;
                }

                if (button_box != null) {
                    button_box.append (_primary_button);
                }
            }
        }
    }

    /**
     * Constructs a new Card with vertical layout (ContentBlock style).
     */
    public Card (string? title = null,
        string? subtitle = null,
        string? icon = null,
        He.Button? primary_button = null,
        He.Button? secondary_button = null) {
        base ();
        _layout = CardLayout.VERTICAL;
        setup_components ();

        this.title = title;
        this.subtitle = subtitle;
        this.icon = icon;
        this.primary_button = primary_button;
        this.secondary_button = secondary_button;
    }

    /**
     * Constructs a new Card with horizontal layout (MiniContentBlock style).
     */
    public Card.horizontal (string? title = null,
                            string? subtitle = null,
                            string? icon = null,
                            He.Button ? primary_button = null,
                            Gtk.Widget ? widget = null) {
        base ();
        _layout = CardLayout.HORIZONTAL;
        setup_components ();

        this.title = title;
        this.subtitle = subtitle;
        this.icon = icon;
        this.primary_button = primary_button;
        this.widget = widget;
    }

    /**
     * Add a child to the Card, should only be used in the context of a UI or Blueprint file.
     */
    public override void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
        if (button_box != null) {
            button_box.append ((Gtk.Widget) child);
        }
    }

    private void setup_components () {
        // Setup image
        image.set_valign (Gtk.Align.CENTER);
        image.set_halign (Gtk.Align.START);
        image.set_visible (false);

        rebuild_layout ();
    }

    private void create_labels () {
        // Create fresh labels for clean state
        title_label = new Gtk.Label (null);
        title_label.xalign = 0;
        title_label.add_css_class ("cb-title");
        title_label.set_visible (false);

        subtitle_label = new Gtk.Label (null);
        subtitle_label.xalign = 0;
        subtitle_label.add_css_class ("cb-subtitle");
        subtitle_label.wrap = true;
        subtitle_label.ellipsize = Pango.EllipsizeMode.END;
        subtitle_label.set_visible (false);

        // Restore text if we had it
        if (_title_text != null && _title_text != "") {
            title_label.set_text (_title_text);
            title_label.set_visible (true);
        }

        if (_subtitle_text != null && _subtitle_text != "") {
            subtitle_label.set_text (_subtitle_text);
            subtitle_label.set_visible (true);
        }
    }

    private void rebuild_layout () {
        // Store existing components that need to be re-added
        var temp_primary = _primary_button;
        var temp_secondary = _secondary_button;
        var temp_widget = _widget;

        // Clear references to prevent issues during rebuild
        _primary_button = null;
        _secondary_button = null;
        _widget = null;

        // Remove existing layout if any
        if (main_box != null) {
            main_box.unparent ();
        }

        // Create fresh labels for clean state
        create_labels ();

        if (_layout == CardLayout.VERTICAL) {
            // ContentBlock style layout
            image.pixel_size = 48;
            image.halign = Gtk.Align.START;
            image.valign = Gtk.Align.CENTER;

            subtitle_label.hexpand = true;

            info_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
            info_box.append (image);
            info_box.append (title_label);
            info_box.append (subtitle_label);

            button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 18);
            button_box.halign = Gtk.Align.END;
            button_box.hexpand = true;

            main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            main_box.append (info_box);
            main_box.append (button_box);

            add_css_class ("content-block");
            remove_css_class ("mini-content-block");
        } else {
            // MiniContentBlock style layout
            image.pixel_size = 24;

            info_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
            info_box.hexpand = true;
            info_box.valign = Gtk.Align.CENTER;
            info_box.append (title_label);
            info_box.append (subtitle_label);

            button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
            button_box.hexpand = true;
            button_box.valign = Gtk.Align.CENTER;

            main_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
            main_box.hexpand = true;
            main_box.append (image);
            main_box.append (info_box);
            main_box.append (button_box);

            add_css_class ("mini-content-block");
            remove_css_class ("content-block");
        }

        main_box.set_parent (this);

        // Re-add existing buttons and widgets if they exist
        if (temp_primary != null) {
            primary_button = temp_primary;
        }

        if (temp_secondary != null) {
            secondary_button = temp_secondary;
        }

        if (temp_widget != null) {
            widget = temp_widget;
        }
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BoxLayout));
    }

    construct {
        _title_text = null;
        _subtitle_text = null;
        setup_components ();
    }
}

// Compatibility aliases with proper GObject property exposure
public class He.ContentBlock : He.Card {
    public override string title {
        get { return base.title; }
        set { base.title = value; }
    }

    public override string subtitle {
        get { return base.subtitle; }
        set { base.subtitle = value; }
    }

    public override string icon {
        get { return base.icon; }
        set { base.icon = value; }
    }

    public override GLib.Icon gicon {
        set { base.gicon = value; }
    }

    public override He.Button secondary_button {
        get { return base.secondary_button; }
        set { base.secondary_button = value; }
    }

    public override He.Button primary_button {
        get { return base.primary_button; }
        set { base.primary_button = value; }
    }

    public ContentBlock (string? title = null,
        string? subtitle = null,
        string? icon = null,
        He.Button? primary_button = null,
        He.Button? secondary_button = null) {
        base (title, subtitle, icon, primary_button, secondary_button);
    }
}

public class He.MiniContentBlock : He.Card {
    public override Gtk.Widget? widget {
        get { return base.widget; }
        set { base.widget = value; }
    }

    public override string title {
        get { return base.title; }
        set { base.title = value; }
    }

    public override string subtitle {
        get { return base.subtitle; }
        set { base.subtitle = value; }
    }

    public override string icon {
        get { return base.icon; }
        set { base.icon = value; }
    }

    public override GLib.Icon gicon {
        set { base.gicon = value; }
    }

    public override Gdk.Paintable paintable {
        set { base.paintable = value; }
    }

    public override He.Button primary_button {
        get { return base.primary_button; }
        set { base.primary_button = value; }
    }

    public MiniContentBlock () {
        base.horizontal ();
    }

    public MiniContentBlock.with_details (string? title = null,
                                          string? subtitle = null,
                                          He.Button ? primary_button = null,
                                          Gtk.Widget ? widget = null) {
        base.horizontal (title, subtitle, null, primary_button, widget);
        this.widget = widget;
    }
}