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
 * An EmptyPage is a page that is used to display a message and a button when there is no data to display.
 */
public class He.EmptyPage : He.Bin {
    private string _title;
    private string _description;
    private string _icon;
    private string _button;

    private Gtk.Label title_label = new Gtk.Label(null);
    private Gtk.Label description_label = new Gtk.Label(null);
    private Gtk.Image icon_image = new Gtk.Image();
    private Gtk.Box box = new Gtk.Box(Gtk.Orientation.VERTICAL, 24);
    private Gtk.Box box_title = new Gtk.Box(Gtk.Orientation.VERTICAL, 12);

    /**
     * The action button of the empty page.
     * Can connect to the clicked signal to get notified when the button is clicked.
     * e.g. action_button.clicked.connect(() => { ... });
     */
    public He.PillButton action_button = new He.PillButton("");

    /**
     * Sets the title of the empty page.
     */
    public string title {
        get {
            return _title;
        }
        set {
            _title = value;
            title_label.label = _title;
        }
    }

    /**
     * Sets the description of the empty page.
     */
    public string description {
        get {
            return _description;
        }
        set {
            _description = value;
            description_label.label = _description;
        }
    }

    /**
     * Sets the icon of the empty page.
     */
    public string icon {
        get {
            return _icon;
        }
        set {
            _icon = value;
            icon_image.set_from_icon_name (_icon);
        }
    }

    /**
     * Sets the button of the empty page.
     *
 * @since 1.0
 */
    public string button {
        get {
            return _button;
        }
        set {
            _button = value;
            action_button.label = value;
        }
    }

    construct {
        title_label.add_css_class("view-title");
        description_label.add_css_class("body");
        icon_image.pixel_size = 128;
        icon_image.add_css_class("dim-label");

        set_layout_manager(new Gtk.BoxLayout(Gtk.Orientation.VERTICAL));

        box_title.append(title_label);
        box_title.append(description_label);

        box.append(icon_image);
        box.append(box_title);
        box.append(action_button);
        box.set_parent (this);

        this.valign = Gtk.Align.CENTER;
        this.halign = Gtk.Align.CENTER;
        this.hexpand = true;
        this.vexpand = true;
    }

    ~EmptyPage() {
        box.unparent();
    }
}