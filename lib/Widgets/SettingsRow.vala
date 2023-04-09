/*
* Copyright (c) 2023 Fyra Labs
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
* A SettingsRow is a settings row that is used to display content
* in a small area that is activatable if desired.
*/
public class He.SettingsRow : Gtk.ListBoxRow, Gtk.Buildable {
    private Gtk.Label title_label = new Gtk.Label (null);
    private Gtk.Label subtitle_label = new Gtk.Label (null);
    private Gtk.Box info_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
    private Gtk.Image image = new Gtk.Image ();
    private He.Button _primary_button;
    private Gtk.Box btn_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
    private Gtk.Widget? _activatable_widget;
    private Gtk.Widget? _previous_parent;
    Binding? activatable_binding;

    public signal void activated ();

    /**
     * Sets the title of the settings row.
     */
     public string title {
        get {
            return title_label.get_text ();
        }
        set {
            if (value != null) {
                title_label.set_visible (true);
                title_label.set_text (value);
            } else {
                title_label.set_visible (false);
            }
        }
    }

    /**
     * Sets the subtitle of the settings row.
     */
    public string subtitle {
        get {
            return subtitle_label.get_text ();
        }
        set {
            if (value != null) {
                subtitle_label.set_visible (true);
                subtitle_label.set_text (value);
            } else {
                subtitle_label.set_visible (false);
            }
        }
    }

    /**
     * Sets the icon of the settings row.
     */
    public string icon {
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
    * Sets the icon of the settings row as a GLib.Icon.
    */
    public GLib.Icon gicon {
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
    * Sets the icon of the settings row as a Gdk.Paintable.
    */
    public Gdk.Paintable paintable {
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
    * The primary button of the settings row.
    */
    public He.Button primary_button {
        get {
            return _primary_button;
        }

        set {
            if (_primary_button != null) {
                btn_box.remove (_primary_button);
            }

            value.hexpand = true;
            value.halign = Gtk.Align.END;
            _primary_button = value;
            btn_box.append (_primary_button);
        }
    }

    /**
     * Sets the activatable widget of the settings row, if any.
     */
    public Gtk.Widget? activatable_widget {
        get {
            return _activatable_widget;
        }
        set {
            if (_activatable_widget == value)
                return;

            activatable_binding?.unbind ();

            if (value != null) {
                _activatable_widget = value;
                activatable_binding = _activatable_widget.bind_property ("sensitive", this, "activatable", SYNC_CREATE);
            }
        }
    }


    /**
     * Add a child to the SettingsRow, should only be used in the context of a UI or Blueprint file. There should be no need to use this method in code.
     */
    public void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
        btn_box.append ((Gtk.Widget)child);
    }


    /**
    * Constructs a new SettingsRow.
    * @param title The title of the settings row.
    * @param subtitle The subtitle of the settings row.
    * @param primary_button The primary button of the settings row.
    */
    public SettingsRow.with_details (string? title, string? subtitle, He.Button? primary_button) {
        this.title = title;
        this.subtitle = subtitle;
        this.primary_button = primary_button;
    }

     /**
      * Constructs a new SettingsRow.
      *
     * @since 1.0
     */
    public SettingsRow () {
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BoxLayout));
    }

    construct {
        this.image.pixel_size = 24;
        this.image.set_valign (Gtk.Align.CENTER);
        this.image.set_halign (Gtk.Align.START);
        this.image.set_visible (false);

        this.title_label.xalign = 0;
        this.title_label.add_css_class ("cb-title");
        this.title_label.set_visible (false);

        this.subtitle_label.xalign = 0;
        this.subtitle_label.add_css_class ("cb-subtitle");
        this.subtitle_label.wrap = true;
        this.subtitle_label.ellipsize = Pango.EllipsizeMode.END;
        this.subtitle_label.set_visible (false);

        this.info_box.append (this.title_label);
        this.info_box.append (this.subtitle_label);
        this.info_box.valign = Gtk.Align.CENTER;

        this.btn_box.halign = Gtk.Align.END;
        this.btn_box.hexpand = true;
        this.btn_box.valign = Gtk.Align.CENTER;

        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 16);
        box.hexpand = true;
        box.append (this.image);
        box.append (this.info_box);
        box.append (this.btn_box);
        box.set_parent (this);
        box.add_css_class ("mini-content-block");

        this.activatable = false;
        this.activated.connect (on_activate);
        this.notify["parent"].connect (parent_cb);
    }

    private void row_activated_cb (Gtk.ListBoxRow row) {
        if (this == row)
            this.activated ();
    }
    private void parent_cb () {
        Gtk.Widget? parent = this.get_parent ();

        if (_previous_parent != null) {
            _previous_parent = null;
        }

        if (parent == null)
            return;

        _previous_parent = parent;
        ((Gtk.ListBox)parent).row_activated.connect (row_activated_cb);
    }
    private void on_activate () {
        if (_activatable_widget != null)
            _activatable_widget.mnemonic_activate (false);
    }

}
