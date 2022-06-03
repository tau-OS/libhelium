public class He.ViewSwitcher : Gtk.Widget {
    private Gtk.SelectionModel _stack_pages;
    private List<Gtk.ToggleButton> _buttons;

    private Gtk.Stack _stack;
    public Gtk.Stack stack {
        get { return this._stack; }
        set {
            if (this._stack == value) return;

            if (this._stack_pages != null) {
                this._stack_pages.selection_changed.disconnect (on_selected_stack_page_changed);
                this._stack_pages.items_changed.disconnect (on_stack_pages_changed);
            }

            this._stack = value;
            this._stack_pages = value.pages;

            this._stack_pages.selection_changed.connect (on_selected_stack_page_changed);
            this._stack_pages.items_changed.connect (on_stack_pages_changed);
        }
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BoxLayout));
    }

    construct {
        this.add_css_class ("view-switcher");
    }

    private void on_stack_pages_changed (uint position, uint removed, uint added) {
        unowned var button_link = this._buttons.nth (position);

        while (removed-- > 0 && button_link != null) {
            button_link.data.unparent ();

            unowned var link = button_link;
            button_link = button_link.next;

            this._buttons.delete_link (link);
        }

        while (added-- > 0) {
            var button = new Gtk.ToggleButton () {
                active = this._stack_pages.is_selected (position),
            };

            this._stack_pages.get_item (position).bind_property ("title", button, "label", SYNC_CREATE);

            button.toggled.connect (() => on_button_toggled (button, position));
            button.set_parent (this);

            this._buttons.insert_before (button_link, button);

            position++;
        }
    }

    private void on_selected_stack_page_changed (uint position, uint n_items) {
        unowned var button_link = this._buttons.nth (position);

        while (n_items-- > 0 && button_link != null) {
            button_link.data.active = this._stack_pages.is_selected (position++);
            button_link = button_link.next;
        }
    }

    private void on_button_toggled (Gtk.ToggleButton button, uint position) {
        if (button.active) {
            this._stack_pages.select_item (position, true);
            return;
        }

        this._stack_pages.unselect_item (position);
    }
}