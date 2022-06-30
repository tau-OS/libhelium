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
* A MiniContentBlock is a content block that is used to display content in a small area.
*/
public class He.MiniContentBlock : He.Bin, Gtk.Buildable {
    private Gtk.Label title_label = new Gtk.Label(null);
    private Gtk.Label subtitle_label = new Gtk.Label(null);
    private Gtk.Box info_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 6);
    private Gtk.Image image = new Gtk.Image();
    private He.Button _primary_button;
    private Gtk.Box btn_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
    
    /** 
     * Sets the title of the content block.
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
     * Sets the subtitle of the content block.
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
     * Sets the icon of the content block.
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
    * The primary button of the content block.
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
            value.add_css_class ("fill-button");
            value.add_css_class ("pill");
            btn_box.append (_primary_button);
        }
    }
    
    /**
    * Constructs a new MiniContentBlock.
    * @param title The title of the content block.
    * @param subtitle The subtitle of the content block.
    * @param primary_button The primary button of the content block.
    */
    public MiniContentBlock.with_details (string? title, string? subtitle, He.Button? primary_button) {
        this.title = title;
        this.subtitle = subtitle;
        this.primary_button = primary_button;
    }

    /**
     * Add a child to the ContentBlock, should only be used in the context of a UI or Blueprint file. There should be no need to use this method in code.
     */
    public override void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
        btn_box.append ((Gtk.Widget)child);
    }

     /**
      * Constructs a new MiniContentBlock.
      *
     * @since 1.0
     */
    public MiniContentBlock () {}
    
    static construct {
        set_layout_manager_type (typeof (Gtk.BoxLayout));
    }
    
    construct {
        this.image.pixel_size = ((Gtk.IconSize)32);
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
        
        this.info_box.append(this.title_label);
        this.info_box.append(this.subtitle_label);
        this.info_box.valign = Gtk.Align.CENTER;
        
        this.btn_box.halign = Gtk.Align.END;
        this.btn_box.hexpand = true;
        this.btn_box.valign = Gtk.Align.CENTER;

        var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 18);
        box.hexpand = true;
        box.append(this.image);
        box.append(this.info_box);
        box.append(this.btn_box);
        
        box.set_parent(this);
        
        this.add_css_class ("mini-content-block");
    }
}
