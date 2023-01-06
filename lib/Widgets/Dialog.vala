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
 * A Dialog is a modal window that asks the user for input or shows a message.
 */
public class He.Dialog : He.Window {
    private Gtk.Label title_label = new Gtk.Label(null);
    private Gtk.Label subtitle_label = new Gtk.Label(null);
    private Gtk.Label info_label = new Gtk.Label(null);
    private Gtk.Image image = new Gtk.Image();
    private Gtk.Box info_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 24);
    private Gtk.Box child_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 6);
    private Gtk.Box button_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 24);
    private Gtk.WindowHandle dialog_handle = new Gtk.WindowHandle ();
    private He.TintButton _secondary_button;
    private He.FillButton _primary_button;

    /**
     * The cancel button in the dialog.
     */
    public He.TextButton cancel_button;

    /**
     * Sets the title of the dialog.
     */
    public new string title {
        get {
            return title_label.get_text ();
        }
        set {
            title_label.set_markup (value);
        }
    }

    /**
     * Sets the subtitle of the dialog.
     */
    public string subtitle {
        get {
            return subtitle_label.get_text ();
        }
        set {
            subtitle_label.set_markup (value);
        }
    }

    /**
     * Sets the info text of the dialog.
     */
    public string info {
        get {
            return info_label.get_text ();
        }
        set {
            info_label.set_markup (value);
        }
    }

    /**
     * Sets the icon of the dialog.
     */
    public string icon {
        get {
            return image.get_icon_name ();
        }

        set {
            image.pixel_size = ((Gtk.IconSize)64);
            image.set_from_icon_name (value);
        }
    }

    /**
     * Sets the secondary button of the dialog.
     */
    public He.TintButton secondary_button {
        set {
            if (_secondary_button != null) {
                button_box.remove (_secondary_button);
            }

            _secondary_button = value;
            button_box.prepend(_secondary_button);
            button_box.reorder_child_after (_secondary_button, cancel_button);
        }

        get {
            return _secondary_button;
        }
    }

    /**
     * Sets the primary button of the dialog.
     */
    public He.FillButton primary_button {
        get {
            return _primary_button;
        }

        set {
            if (_primary_button != null) {
                button_box.remove (_primary_button);
            }

            _primary_button = value;
            button_box.append (_primary_button);

            if (_secondary_button != null) {
                button_box.reorder_child_after (_primary_button, _secondary_button);
            }
        }
    }

    /**
     * Add a child to the Dialog, should only be used in the context of a UI or Blueprint file. There should be no need to use this method in code.
     *
     * @since 1.0
     */
    public void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
        child_box.append ((Gtk.Widget)child);
        child_box.visible = true;
    }

    /**
     * Add a child directly to the Dialog. Used only in code.
     *
     * @since 1.0
     */
    public void set_child (Gtk.Widget widget) {
        child_box.append (widget);
        child_box.visible = true;
    }

    /**
     * Creates a new dialog.
     * @param modal Whether the dialog is modal.
     * @param parent The parent window of the dialog.
     * @param title The title of the dialog.
     * @param subtitle The subtitle of the dialog.
     * @param info The info text of the dialog.
     * @param icon The icon of the dialog.
     * @param primary_button The primary button of the dialog.
     * @param secondary_button The secondary button of the dialog.
     *
     * @since 1.0
     */
    public Dialog(bool modal, Gtk.Window? parent, string title, string subtitle, string info, string icon, He.FillButton? primary_button, He.TintButton? secondary_button) {
        this.modal = modal;
        this.parent = parent;
        this.title = title;
        this.subtitle = subtitle;
        this.info = info;
        this.icon = icon;
        this.primary_button = primary_button;
        this.secondary_button = secondary_button;
    }

    ~Dialog() {
        this.unparent();
        this.dialog_handle.dispose();
    }

    construct {
        image.valign = Gtk.Align.CENTER;
        title_label.add_css_class ("view-title");
        title_label.wrap = true;
        title_label.wrap_mode = Pango.WrapMode.WORD;
        subtitle_label.xalign = 0;
        subtitle_label.add_css_class ("view-subtitle");
        subtitle_label.ellipsize = Pango.EllipsizeMode.END;
        subtitle_label.wrap = true;
        subtitle_label.wrap_mode = Pango.WrapMode.WORD;
        info_label.add_css_class ("body");
        info_label.xalign = 0;
        info_label.vexpand = true;
        info_label.valign = Gtk.Align.START;
        info_label.wrap = true;
        info_label.wrap_mode = Pango.WrapMode.WORD;
        
        info_box.append(image);
        info_box.append(title_label);
        info_box.append(subtitle_label);
        info_box.append(info_label);

        cancel_button = new He.TextButton ("Cancel");
        cancel_button.clicked.connect (() => {
            this.close ();
        });

        button_box.homogeneous = true;
        button_box.prepend (cancel_button);

        child_box.visible = false;

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 24);
        main_box.vexpand = true;
        main_box.margin_end = main_box.margin_start = main_box.margin_top = main_box.margin_bottom = 24;
        main_box.append(info_box);
        main_box.append(child_box);
        main_box.append(button_box);
        dialog_handle.set_child (main_box);

        this.set_child (dialog_handle);
        this.resizable = false;
        this.set_size_request (360, 400);
        this.set_default_size (360, 400);
        this.has_title = false;
    }
}
