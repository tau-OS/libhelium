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
 * Standard tab designed for TabSwitcher, used to form a tabbed UI
 */
 public class He.Tab : He.Bin {
    /**
     * The label/title of the tab
     **/
    public string label {
        get { return _label.label; }
        set {
            _label.label = value;
            _label.set_tooltip_markup (value);
        }
    }
    Gtk.Label _label;

    /**
     * The Pango marked up text that will be shown in a tooltip when the tab is hovered.
     **/
    public string tooltip {
        set {
            _label.set_tooltip_markup (value);
        }
    }

    private bool _is_current_tab = false;
    internal bool is_current_tab {
        set {
            _is_current_tab = value;
            update_close_btn_visibility ();
        }
    }

    /**
     * Whether a Tab is pinned or not
     */
    private bool _pinned = false;
    public bool pinned {
        get { return _pinned; }
        set {
            if (can_pin) {
                if (value != _pinned) {
                    if (value) {
                        _label.set_visible (false);

                        menu.remove (5);
                        pin_menuitem.set_label ("Unpin");
                        menu.insert_item (5, pin_menuitem);
                    } else {
                        _label.set_visible (true);

                        menu.remove (5);
                        pin_menuitem.set_label ("Pin");
                        menu.insert_item (5, pin_menuitem);
                    }

                    _pinned = value;
                    update_close_btn_visibility ();
                    this.pin ();
                }
            }
        }
    }

    private bool _pinnable = true;
    public bool can_pin {
        get { return _pinnable; }
        set {
            if (!value) {
                pinned = false;
            }

            _pinnable = value;
        }
    }

    private bool _closable = true;
    public bool can_close {
        get { return _closable; }
        set {
            if (value == _closable)
                return;

            _closable = value;
            update_close_btn_visibility ();
        }
    }

    /**
     * The TabPage to hold children, to appear when this tab is active
     **/
    public Gtk.Widget page {
        get {
            return page_container.get_first_child ();
        }
        set {
            weak Gtk.Widget container_child = page_container.get_first_child ();
            if (container_child != null) {
                container_child.unparent ();
            }

            value.set_parent (page_container);
        }
    }
    internal TabPage page_container;

    He.TabSwitcher tab_switcher {
        get { return (get_parent () as Gtk.Notebook)?.get_parent () as He.TabSwitcher; }
    }

    /**
     * The menu appearing when the tab is clicked
     */
    public GLib.Menu menu { get; private set; }
    private MenuItem pin_menuitem;

    private Gtk.Button close_button;

    private Gtk.CenterBox tab_layout;
    private Gtk.PopoverMenu popover { get; set; }

    internal signal void closed ();
    internal signal void close_others ();
    internal signal void close_others_right ();
    internal signal void duplicate ();
    internal signal void pin ();
    internal signal void new_window ();

    public SimpleActionGroup actions { get; construct; }
    private const string ACTION_CLOSE = "action-close";
    private const string ACTION_CLOSE_OTHER = "action-close-other";
    private const string ACTION_CLOSE_RIGHT = "action-close-right";
    private const string ACTION_DUPLICATE = "action-duplicate";
    private const string ACTION_PIN = "action-pin";
    private const string ACTION_NEW_WINDOW = "action-new-window";
    private const ActionEntry[] ENTRIES = {
        { ACTION_CLOSE, action_close },
        { ACTION_CLOSE_OTHER, action_close_other },
        { ACTION_CLOSE_RIGHT, action_close_right },
        { ACTION_DUPLICATE, action_duplicate },
        { ACTION_PIN, action_pin },
        { ACTION_NEW_WINDOW, action_new_window },
    };

    private void action_close () {
        closed ();
    }
    private void action_close_other () {
        close_others ();
    }
    private void action_close_right () {
        close_others_right ();
    }
    private void action_duplicate () {
        duplicate ();
    }
    private void action_pin () {
        pinned = !pinned;
    }
    private void action_new_window () {
        new_window ();
    }

    /**
     * Create a new Tab
     *
     * @since 1.0
     */
    public Tab (string? label = null, Gtk.Widget? page = null) {
        Object (
            label: label
        );

        if (page != null) {
            this.page = page;
        }

        handle_events ();
    }

    construct {
        _label = new Gtk.Label (null);
        _label.hexpand = true;
        _label.ellipsize = Pango.EllipsizeMode.END;

        close_button = new Gtk.Button.from_icon_name ("window-close");
        close_button.valign = Gtk.Align.CENTER;
        close_button.add_css_class ("tab-button");

        close_button.clicked.connect (() => {
            closed ();
        });

        tab_layout = new Gtk.CenterBox ();
        tab_layout.hexpand = true;
        tab_layout.set_end_widget (close_button);
        tab_layout.set_center_widget (_label);

        tab_layout.set_parent (this);

        menu = new GLib.Menu ();
        popover = new Gtk.PopoverMenu.from_model (menu);
        actions = new SimpleActionGroup ();
        actions.add_action_entries (ENTRIES, this);
        this.insert_action_group (label, actions);

        // TODO: Will need to mark this as unsensitive with 1 tab
        menu.append ("Open in New Window", @"$(label).action-new-window");
        menu.append ("Close", @"$(label).action-close");
        menu.append ("Close Others", @"$(label).action-close-other");
        menu.append ("Close Tab to the Right", @"$(label).action-close-right");
        menu.append ("Duplicate", @"$(label).action-duplicate");

        if (can_pin) {
            pin_menuitem = new MenuItem ("Pin", @"$(label).pin");
            // We manually insert this item so I can remove and modify it later
            menu.insert_item (5, pin_menuitem);
        }

        popover.set_menu_model (menu);

        page_container = new TabPage (this);

        this.set_hexpand (true);
        this.add_css_class ("tab-child");
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BoxLayout));
    }

    ~Tab () {
        tab_layout.unparent ();
    }

    private void handle_events () {
        Gtk.GestureClick click = new Gtk.GestureClick () {
            button = 0
        };
        this.add_controller (click);
        popover.set_parent (this);

        click.pressed.connect ((n_press, x, y) => {
            if (click.get_current_button () == Gdk.BUTTON_SECONDARY) {
                Gdk.Rectangle rect = {(int)x,
                                      (int)y,
                                      0,
                                      0};
                popover.set_pointing_to (rect);
                popover.popup ();
            }
        });
    }

    private void update_close_btn_visibility () {
        if (pinned || !can_close) {
            close_button.set_visible (false);
        } else {
            close_button.set_visible (true);
        }
    }
}

