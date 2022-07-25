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
 * TabBar widget designed for a variable number of tabs.
 */
 public class He.TabSwitcher : He.Bin, Gtk.Buildable {
    /**
     * The internal Gtk.Notebook. This should only be accessed by a widget implementation
     */
    public Gtk.Notebook notebook;

    /**
     * The number of tabs in the TabSwitcher
     */
    public int n_tabs {
        get { return notebook.get_n_pages (); }
    }

    /**
     * The list of tabs in the TabSwitcher
     */
    public GLib.List<Tab> tabs {
        get {
            _tabs = new GLib.List<Tab> ();
            for (var i = 0; i < n_tabs; i++) {
                _tabs.append (notebook.get_tab_label (notebook.get_nth_page (i)) as Tab);
            }
            return _tabs;
        }
    }
    GLib.List<Tab> _tabs;

    public enum TabBarBehavior {
        ALWAYS = 0,
        SINGLE = 1,
        NEVER = 2
    }

    /**
     * The behavior of the tab bar and its visibility
     */
    public TabBarBehavior tab_bar_behavior {
        set {
            _tab_bar_behavior = value;
            update_tabs_visibility ();
        }

        get { return _tab_bar_behavior; }
    }
    private TabBarBehavior _tab_bar_behavior;

    /**
     * The position in the switcher of the tab
     */
    public int get_tab_position (Tab tab) {
        return notebook.page_num (tab.page_container);
    }

    /**
     * Allow tab duplication
     */
    bool _allow_duplication = false;
    public bool allow_duplicate_tabs {
        get { return _allow_duplication; }
        set {
            _allow_duplication = value;

            foreach (var tab in tabs) {
                // TODO set tab duplicate action
            }
        }
    }

    /**
     * Allow tab dragging. This also allows reordering in general,
     * but...who cares about that
     */
    bool _allow_drag = true;
    public bool allow_drag {
        get { return _allow_drag; }
        set {
            _allow_drag = value;
            foreach (var tab in tabs) {
                notebook.set_tab_reorderable (tab.page_container, value);
            }
        }
    }

    /**
     * Allow tab pinning
     */
    bool _allow_pin = true;
    public bool allow_pinning {
        get { return _allow_pin; }
        set {
            _allow_pin = value;
            foreach (var tab in tabs) {
                tab.can_pin = value;
            }
        }
    }

    /**
     * Allow tab closing
     */
    bool _allow_close = true;
    public bool allow_closing {
        get { return _allow_close; }
        set {
            _allow_close = value;
            foreach (var tab in tabs) {
                tab.can_close = value;
            }
        }
    }

    /**
     * Allow moving tabs to new windows
     */
    bool _allow_window = false;
    public bool allow_new_window {
        get { return _allow_window; }
        set {
            _allow_close = value;
            foreach (var tab in tabs) {
                notebook.set_tab_detachable (tab.page_container, value);
            }
        }
    }

    /**
     * The current visible tab
     */
    public Tab current {
        get { return tabs.nth_data (notebook.get_current_page ()); }
        set { notebook.set_current_page (tabs.index (value)); }
    }

    /**
     * Insert a new tab into the TabSwitcher.
     *
     * To append a tab, you may use -1 as the index.
     */
    public uint insert_tab (Tab tab, int index) {
        index = this.notebook.insert_page (tab.page_container, tab, index <= -1 ? n_tabs : index);
        notebook.set_tab_reorderable (tab.page_container, allow_drag);
        notebook.set_tab_detachable (tab.page_container, allow_new_window);

        tab.can_pin = allow_pinning;
        tab.pinned = false;

        tab.get_parent ().add_css_class ("tab");
        tab.set_size_request (tab_width, -1);

        recalc_order ();

        return index;
    }

    /**
     * Removes a tab from the TabSwitcher.
     */
    public void remove_tab (Tab tab) {
        var pos = get_tab_position (tab);

        if (pos != -1)
            notebook.remove_page (pos);
    }

    /**
     * The menu appearing when the tab bar is clicked on a blank space
     */
    public GLib.Menu menu { get; private set; }

    private Gtk.PopoverMenu popover { get; set; }
    private Tab? old_tab; //stores a reference for tab_switched
    private const int MIN_TAB_WIDTH = 80;
    private const int MAX_TAB_WIDTH = 150;
    private int tab_width = MAX_TAB_WIDTH;

    public signal void tab_added (Tab tab);
    public signal void tab_removed (Tab tab);
    public signal void tab_switched (Tab? old_tab, Tab new_tab);
    public signal void tab_moved (Tab tab);
    public signal void tab_duplicated (Tab duplicated_tab);
    public signal void new_tab_requested ();
    public signal bool close_tab_requested (Tab tab);

    public SimpleActionGroup actions { get; construct; }
    private const string ACTION_NEW_TAB = "action-new-tab";
    private const ActionEntry[] ENTRIES = {
        { ACTION_NEW_TAB, action_new_tab }
    };

    private void action_new_tab () {
        new_tab_requested ();
    }

    /**
     * Create a new TabSwitcher
     *
     * @since 1.0
     */
    public TabSwitcher () {
        handle_events ();
    }

    construct {
        notebook = new Gtk.Notebook ();
        notebook.set_scrollable (true);
        notebook.set_show_border (false);
        _tab_bar_behavior = TabBarBehavior.ALWAYS;
        notebook.add_css_class ("tab-holder");

        var add_button = new He.DisclosureButton.from_icon ("list-add-symbolic");
        add_button.margin_top = 6;
        add_button.margin_bottom = 6;
        add_button.margin_end = 6;
        add_button.tooltip_text = _("New Tab");

        notebook.set_action_widget (add_button, Gtk.PackType.END);

        menu = new GLib.Menu ();

        popover = new Gtk.PopoverMenu.from_model (menu);
        actions = new SimpleActionGroup ();
        actions.add_action_entries (ENTRIES, this);
        this.insert_action_group ("hetabswitcher", actions);

        menu.append ("New Tab", "hetabswitcher.action-new-tab");

        popover.set_menu_model (menu);

        add_button.clicked.connect (() => {
            new_tab_requested ();
        });

        this.destroy.connect (() => {
            notebook.switch_page.disconnect (on_switch_page);
            notebook.page_added.disconnect (on_page_added);
            notebook.page_removed.disconnect (on_page_removed);
            notebook.create_window.disconnect (on_create_window);
        });

        notebook.switch_page.connect (on_switch_page);
        notebook.page_added.connect (on_page_added);
        notebook.page_removed.connect (on_page_removed);
        notebook.create_window.connect (on_create_window);

        notebook.set_parent (this);

        notebook.hexpand = true;
	notebook.vexpand = true;
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BoxLayout));
    }

    ~TabSwitcher () {
        notebook.unparent ();
    }

    private void handle_events () {
        Gtk.GestureClick click = new Gtk.GestureClick () {
            button = 0
        };
        this.add_controller (click);
        popover.set_parent (this);

        click.pressed.connect ((n_press, x, y) => {
            if (n_press != 1) {
                new_tab_requested ();
            } else if (click.get_current_button () == Gdk.BUTTON_SECONDARY) {
                Gdk.Rectangle rect = {(int)x,
                                      (int)y,
                                      0,
                                      0};
                popover.set_pointing_to (rect);
                popover.popup ();
            }
        });
    }

    void on_switch_page (Gtk.Widget page, uint pagenum) {
        var new_tab = (page as TabPage)?.tab;

        // update property accordingly for previous selected tab
        if (old_tab != null)
           old_tab.is_current_tab = false;

        // now set the new tab as current
        new_tab.is_current_tab = true;

        tab_switched (old_tab, new_tab);

        old_tab = new_tab;
    }

    void on_page_added (Gtk.Widget page, uint pagenum) {
        var t = (page as TabPage)?.tab;

        insert_callbacks (t);
        tab_added (t);
        update_tabs_visibility ();
    }

    void on_page_removed (Gtk.Widget page, uint pagenum) {
        var t = (page as TabPage)?.tab;

        remove_callbacks (t);
        tab_removed (t);
        update_tabs_visibility ();
    }

    unowned Gtk.Notebook on_create_window (Gtk.Widget page) {
        var tab = notebook.get_tab_label (page) as Tab;
        tab_moved (tab);
        recalc_order ();
        return (Gtk.Notebook) null;
    }

    private void recalc_order () {
        if (n_tabs == 0)
            return;

        var pinned_tabs = 0;
        for (var i = 0; i < this.notebook.get_n_pages (); i++) {
            if ((this.notebook.get_nth_page (i) as TabPage)?.tab.pinned) {
                pinned_tabs++;
            }
        }

        for (var p = 0; p < pinned_tabs; p++) {
            int sel = p;
            for (var i = p; i < this.notebook.get_n_pages (); i++) {
                if ((this.notebook.get_nth_page (i) as TabPage)?.tab.pinned) {
                    sel = i;
                    break;
                }
            }

            if (sel != p) {
                this.notebook.reorder_child (this.notebook.get_nth_page (sel), p);
            }
        }
    }

    private void insert_callbacks (Tab tab) {
        tab.closed.connect (on_tab_closed);
        tab.close_others.connect (on_close_others);
        tab.close_others_right.connect (on_close_others_right);
        tab.duplicate.connect (on_duplicate);
        tab.pin.connect (on_pin);
        tab.new_window.connect (on_new_window);
    }

    private void remove_callbacks (Tab tab) {
        tab.closed.disconnect (on_tab_closed);
        tab.close_others.disconnect (on_close_others);
        tab.close_others_right.disconnect (on_close_others_right);
        tab.duplicate.disconnect (on_duplicate);
        tab.pin.disconnect (on_pin);
        tab.new_window.disconnect (on_new_window);
    }

    private void on_close_others (Tab clicked_tab) {
        tabs.copy ().foreach ((tab) => {
            if (tab != clicked_tab) {
                tab.closed ();
            }
        });
    }

    private void on_close_others_right (Tab clicked_tab) {
        var is_to_the_right = false;

        tabs.copy ().foreach ((tab) => {
            if (is_to_the_right) {
                tab.closed ();
            }
            if (tab == clicked_tab) {
                is_to_the_right = true;
            }
        });
    }

    private void on_tab_closed (Tab tab) {
        if (!close_tab_requested (tab)) {
            return;
        }
        
        var pos = get_tab_position (tab);

        remove_tab (tab);

        if (pos != -1 && tab.page.get_parent () != null)
            tab.page.unparent ();
    }

    private void on_duplicate (Tab tab) {
        tab_duplicated (tab);
    }

    private void on_pin (Tab tab) {
        if (!allow_pinning)
            return;

        recalc_order ();
    }

    private void on_new_window (Tab tab) {
        notebook.create_window (tab.page_container);
    }

    private void update_tabs_visibility () {
        if (_tab_bar_behavior == TabBarBehavior.SINGLE)
            notebook.show_tabs = n_tabs > 1;
        else if (_tab_bar_behavior == TabBarBehavior.NEVER)
            notebook.show_tabs = false;
        else if (_tab_bar_behavior == TabBarBehavior.ALWAYS)
            notebook.show_tabs = true;
    }
}
