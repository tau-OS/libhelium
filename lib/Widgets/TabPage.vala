/**
 * Auxilary Class for handling the contents of Tabs
 */
 public class He.TabPage : He.Bin {
    /**
     * The Tab this page is associated with
     */
    public unowned Tab tab {
        get { return _tab; }
        set { _tab = value; }
    }

    private unowned Tab _tab = null;

    He.TabSwitcher tab_switcher {
        get { return (get_parent () as Gtk.Notebook)?.get_parent () as He.TabSwitcher; }
    }

    /**
     * Create a new Tab Page. This should be handled automatically by the Tab generation code.
     */
    public TabPage (Tab tab) {
        Object (
            tab: tab
        );
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BoxLayout));
    }

    ~TabPage () {
        this.get_first_child ().unparent ();
    }
}