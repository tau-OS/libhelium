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
* An AppBar is the header bar of an Window. It usually provides controls to manage the window, as well as optional children for more granular control.
*/
public class He.AppBar : He.Bin {
    private Gtk.Label viewtitle_mini = new Gtk.Label ("");
    private Gtk.Label viewtitle = new Gtk.Label ("");
    private Gtk.Label viewsubtitle = new Gtk.Label ("");
    private Gtk.Box top_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
    private Gtk.Box title_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
    private Gtk.Box control_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
    private Gtk.Box win_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
    private Gtk.Box sub_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
    private Gtk.Box main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
    private Gtk.Box labels_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
    private Gtk.WindowControls title;
    private Gtk.WindowControls sidetitle;

    /**
    * The flatness of the He.AppBar
    *
    * Deprecated for code use. Will break if set manually!
    */
    [Version (deprecated = true)]
    public bool flat;

    /**
    * The button to go back one view displayed in the AppBar.
    */
    public Gtk.Button back_button = new Gtk.Button ();

    /**
    * The button box in the AppBar, shows below and to the right side of the title, or alongside the window controls, based on scrollers.
    */
    public Gtk.Box btn_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);

    private Gtk.Stack _stack;
    /**
    * The stack that the AppBar is associated with. This is used to determine the back button's functionality.
    */
    public Gtk.Stack stack {
        get { return this._stack; }
        set {
            this._stack = value;
        }
    }

    private Gtk.ScrolledWindow _scroller;
    private Gtk.Adjustment vadj;
    /**
    * The ScrolledWindow that the AppBar is associated with. This is used to move the view's title to the AppBar and unsetting flatness.
    */
    public Gtk.ScrolledWindow scroller {
        get { return this._scroller; }
        set {
            this._scroller = value;

            if (value != null) {
                vadj = value.get_vadjustment ();
                if (vadj.value != 0) {
                    if (viewtitle_widget != null) {
                        viewtitle_widget.set_visible (false);
                    } else {
                        viewtitle_mini.set_visible (true);
                        viewtitle_mini.label = _viewtitle_label;
                        viewtitle.set_visible (false);
                    }
                    viewsubtitle.set_visible (false);
                    sub_box.set_visible (false);
                    btn_box.unparent ();
                    title_box.append (btn_box);
                    viewtitle_mini.add_css_class ("title");
                    main_box.add_css_class ("appbar");
                    main_box.remove_css_class ("flat-appbar");
                    top_box.margin_top = 0;
                } else {
                    if (viewtitle_widget != null) {
                        viewtitle_widget.set_visible (true);
                    } else {
                        viewtitle_mini.set_visible (false);
                        viewtitle_mini.label = "";
                        viewtitle.set_visible (true);
                    }
                    viewsubtitle.set_visible (true);
                    sub_box.set_visible (true);
                    btn_box.unparent ();
                    sub_box.append (btn_box);
                    viewtitle_mini.remove_css_class ("title");
                    main_box.add_css_class ("flat-appbar");
                    main_box.remove_css_class ("appbar");
                    if (!_show_buttons) {
                        top_box.margin_top = 36;
                    } else {
                        top_box.margin_top = 0;
                    }
                }
                vadj.value_changed.connect ((a) => {
                    if (a.value != 0) {
                        if (viewtitle_widget != null) {
                            viewtitle_widget.set_visible (false);
                        } else {
                            viewtitle_mini.set_visible (true);
                            viewtitle_mini.label = _viewtitle_label;
                            viewtitle.set_visible (false);
                        }
                        viewsubtitle.set_visible (false);
                        sub_box.set_visible (false);
                        btn_box.unparent ();
                        title_box.append (btn_box);
                        viewtitle_mini.add_css_class ("title");
                        main_box.add_css_class ("appbar");
                        main_box.remove_css_class ("flat-appbar");
                        top_box.margin_top = 0;
                    } else {
                        if (viewtitle_widget != null) {
                            viewtitle_widget.set_visible (true);
                        } else {
                            viewtitle_mini.set_visible (false);
                            viewtitle_mini.label = "";
                            viewtitle.set_visible (true);
                        }
                        viewsubtitle.set_visible (true);
                        sub_box.set_visible (true);
                        btn_box.unparent ();
                        sub_box.append (btn_box);
                        viewtitle_mini.remove_css_class ("title");
                        main_box.add_css_class ("flat-appbar");
                        main_box.remove_css_class ("appbar");
                        if (!_show_buttons) {
                            top_box.margin_top = 36;
                        } else {
                            top_box.margin_top = 0;
                        }
                    }
                });
            } else {
                main_box.add_css_class ("flat-appbar");
                main_box.remove_css_class ("appbar");
                if (!_show_buttons) {
                    top_box.margin_top = 36;
                } else {
                    top_box.margin_top = 0;
                }
            }
        }
    }

    private string _viewtitle_label;
    /**
    * The title to the left on the AppBar.
    */
    public string viewtitle_label {
        get { return this._viewtitle_label; }
        set {
            this._viewtitle_label = value;

            if (value != null && _viewtitle_widget == null) {
                viewtitle.label = value;
                labels_box.visible = true;
                main_box.spacing = 6;
                control_box.append (viewtitle_mini);
            } else {
                viewtitle.label = null;
                control_box.remove (viewtitle_mini);
            }
        }
    }

    private Gtk.Widget? _viewtitle_widget;
    /**
    * The title widget to the left on the AppBar. If this is set, the other title (not subtitle) props won't work, and the mini title on collapsed state won't show.
    */
    public Gtk.Widget? viewtitle_widget {
        get { return this._viewtitle_widget; }
        set {
            this._viewtitle_widget = value;

            if (value != null) {
                labels_box.visible = true;
                main_box.spacing = 6;
                labels_box.prepend (value);
            } else {
                labels_box.remove (value);
            }
        }
    }

    private string _viewsubtitle_label;
    /**
    * The subtitle to the left on the AppBar.
    */
    public string viewsubtitle_label {
        get { return this._viewsubtitle_label; }
        set {
            this._viewsubtitle_label = value;

            if (value != "") {
                viewsubtitle.label = value;
                viewsubtitle.visible = true;
                labels_box.visible = true;
                main_box.spacing = 6;
            } else {
                viewsubtitle.label = "";
                viewsubtitle.visible = false;
            }
        }
    }

    private bool _show_buttons;
    /**
    * Whether the close, minimize and maximize buttons are shown.
    */
    public bool show_buttons {
        get {
            return _show_buttons;
        }
        set {
            _show_buttons = value;

            if (!value) {
                top_box.margin_top = 36;
                title.visible = false;
                sidetitle.visible = false;
            } else {
                top_box.margin_top = 0;
                title.visible = true;
                sidetitle.visible = true;
            }
        }
    }

    private string _decoration_layout;
    /**
    * The layout of the window buttons a.k.a. where to put close, maximize, minimize.
    * It is a string in the format "<left>:<right>".
    */
    public string decoration_layout {
        get {
            return _decoration_layout;
        }
        set {
            _decoration_layout = value;
        }
    }

    private bool _show_back;
    /**
    * Whether the back button is shown.
    */
    public bool show_back {
        get {
            return _show_back;
        }
        set {
            _show_back = value;
            back_button.set_visible (value);
        }
    }

    /**
    * Add a child to the AppBar, should only be used in the context of a UI or Blueprint file. There should be no need to use this method in code.
    * Please note that an AppBar should only have at most three children.
    */
    public override void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
        btn_box.prepend ((Gtk.Widget)child);
        ((Gtk.Widget) child).add_css_class ("disclosure-button");
        ((Gtk.Widget) child).remove_css_class ("image-button");
        labels_box.visible = true;
        main_box.spacing = 6;
    }

    /**
    * Append a child to the AppBar.
    * Please note that an AppBar should only have at most three children.
    * @param child The child to append.
    */
    public void append (Gtk.Widget child) {
        btn_box.append (child);
        ((Gtk.Widget) child).add_css_class ("disclosure-button");
        ((Gtk.Widget) child).remove_css_class ("image-button");
        labels_box.visible = true;
        main_box.spacing = 6;
    }

    /**
    * Remove a child from the AppBar.
    * @param child The child to remove.
    *
    * @since 1.0
    */
    public void remove (Gtk.Widget child) {
        btn_box.remove (child);
    }

    private void create_start_window_controls () {
        sidetitle = new Gtk.WindowControls (Gtk.PackType.START);
        sidetitle.side = Gtk.PackType.START;
        sidetitle.valign = Gtk.Align.CENTER;
        control_box.prepend (sidetitle);
    }

    private void create_end_window_controls () {
        title = new Gtk.WindowControls (Gtk.PackType.END);
        title.side = Gtk.PackType.END;
        title.valign = Gtk.Align.CENTER;
        win_box.prepend (title);
    }

    /**
    * Creates a new AppBar.
    */
    public AppBar () {
        base ();
    }

    construct {
        title_box.halign = Gtk.Align.END;
        win_box.halign = Gtk.Align.END;

        create_start_window_controls ();
        create_end_window_controls ();
        decoration_layout = "close,maximize,minimize:"; // Helium default fallback
        title.bind_property ("empty", title, "visible", SYNC_CREATE);
        title.bind_property ("decoration-layout", this, "decoration-layout", SYNC_CREATE);
        sidetitle.bind_property ("empty", sidetitle, "visible", SYNC_CREATE);
        sidetitle.bind_property ("decoration-layout", this, "decoration-layout", SYNC_CREATE);

        back_button.set_icon_name ("go-previous-symbolic");
        back_button.set_tooltip_text ("Go Back");
        back_button.add_css_class ("flat");
        back_button.add_css_class ("disclosure-button");
        back_button.clicked.connect (() => {
            var selected_page = stack.pages.get_selection ();
            stack.pages.select_item (int.max (((int)selected_page.get_nth (0) - 1), 0), true);
        });
        control_box.append (back_button);
        control_box.halign = Gtk.Align.START;
        control_box.hexpand = true;

        viewtitle = new Gtk.Label ("");
        viewtitle.halign = Gtk.Align.START;
        viewtitle.add_css_class ("view-title");
        viewtitle.set_visible (false);

        viewsubtitle = new Gtk.Label ("");
        viewsubtitle.halign = Gtk.Align.START;
        viewsubtitle.add_css_class ("view-subtitle");
        viewsubtitle.set_visible (false);

        top_box.hexpand = true;
        top_box.append (control_box);
        top_box.append (title_box);
        top_box.append (win_box);

        labels_box.homogeneous = true;
        labels_box.hexpand = true;
        labels_box.visible = false;
        labels_box.append (viewtitle);
        labels_box.append (viewsubtitle);
        labels_box.margin_start = 14;

        btn_box.valign = Gtk.Align.END;
        btn_box.margin_end = 14;

        sub_box.append (labels_box);
        sub_box.append (btn_box);

        main_box.spacing = 0;
        main_box.append (top_box);
        main_box.append (sub_box);

        var winhandle = new Gtk.WindowHandle ();
        winhandle.set_child (main_box);
        winhandle.set_parent (this);
        winhandle.hexpand = true;

        show_buttons = true;
        show_back = false;
        flat = true;
        main_box.add_css_class ("flat-appbar");
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BoxLayout));
    }
}
