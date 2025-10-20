// Copyright (C) 2023 Fyra Labs

/**
 * A {@link He.Dropdown} is a simple variant of {@link Gtk.DropDown} for easy developing.
 */
public sealed class He.Dropdown : Gtk.Grid {
    /**
     * Emitted when the active item is changed.
     */
    public signal void changed ();

    /**
     * The value of the ID column of the active row.
     */
    public string? active_id { get; set; }

    /**
     * The desired maximum width of the label, in characters.
     *
     * If this property is set to -1, the width will be calculated automatically.
     */
    public int max_width_chars { get; set; }

    /**
     * The preferred place to ellipsize the string, if the label does not have enough room to display the entire string.
     */
    public Pango.EllipsizeMode ellipsize { get; set; }

    /**
     * A {@link Gtk.DropDown} which this uses internally.
     */
    public Gtk.DropDown dropdown { get; set; }

    private class ListStoreItem : Object {
        public string id { get; construct; }
        public string text { get; construct; }

        public ListStoreItem (string? id, string text) {
            Object (
                    id: id ?? (Random.next_int ().to_string ()),
                    text: text
            );
        }
    }

    private class DropdownRow : Gtk.Box {
        public Gtk.Label label { get; set; }

        public DropdownRow () {
        }

        construct {
            label = new Gtk.Label (null);
            label.xalign = 0.0f;
            label.valign = Gtk.Align.CENTER;

            append (label);
        }
    }

    private ListStore liststore;

    /**
     * Creates a new {@link He.Dropdown}.
     * @return A new {@link He.Dropdown}
     */
    public Dropdown () {
    }

    construct {
        Random.set_seed ((uint32) time_t (null));

        liststore = new ListStore (typeof (ListStoreItem));

        var factory = new Gtk.SignalListItemFactory ();
        factory.setup.connect ((obj) => {
            var list_item = obj as Gtk.ListItem;

            var row = new DropdownRow ();
            list_item.child = row;
        });
        factory.bind.connect ((obj) => {
            var list_item = obj as Gtk.ListItem;
            var item = list_item.item as ListStoreItem;
            var row = list_item.child as DropdownRow;
            Gtk.Label label = row.label;

            label.label = item.text;
            bind_property ("max-width-chars", label, "max-width-chars", BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE);
            bind_property ("ellipsize", label, "ellipsize", BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE);
        });

        dropdown = new Gtk.DropDown (liststore, null) {
            factory = factory
        };

        attach (dropdown, 0, 0);

        dropdown.bind_property ("selected", this, "active-id",
                                BindingFlags.BIDIRECTIONAL,
                                (binding, from_value, ref to_value) => {
            var pos = (uint) from_value;
            // No item is selected
            if (pos == Gtk.INVALID_LIST_POSITION) {
                to_value.set_string (null);
                return false;
            }

            var item = (ListStoreItem) liststore.get_item (pos);
            to_value.set_string (item.id);
            return true;
        },
                                (binding, from_value, ref to_value) => {
            uint pos;
            var id = (string) from_value;
            liststore.find_with_equal_func (
                                            // Find with id
                                            new ListStoreItem (id, ""),
                                            (a, b) => {
                return (((ListStoreItem) a).id == ((ListStoreItem) b).id);
            },
                                            out pos
            );
            to_value.set_uint (pos);
            return true;
        });

        notify["active-id"].connect (() => { changed (); });
    }

    /**
     * Appends text to the list of strings stored in this.
     *
     * This is the same as calling {@link He.Dropdown.insert} with a position of -1.
     *
     * @param text      A string
     */
    public void append (string text) {
        var item = new ListStoreItem (null, text);
        /* Use append so the item is added at the end of the list. Using
         * liststore.insert(-1, ...) is incorrect here and may not behave
         * as intended across bindings. */
        liststore.append (item);
    }

    /**
     * Returns the currently active string in this.
     *
     * If no row is currently selected, null is returned. If this contains an entry, this function will return its contents (which will not necessarily be an item from the list).
     *
     * @return          A newly allocated string containing the currently active text. Must be freed with g_free.
     */
    public string ? get_active () {
        Object? selected_item = dropdown.selected_item;
        if (selected_item == null) {
            return null;
        }

        return ((ListStoreItem) selected_item).text;
    }

    /**
     * Inserts text at position in the list of strings stored in this.
     *
     * If position is negative then text is appended.<<BR>>
     * This is the same as calling {@link He.Dropdown.insert} with a null ID string.
     *
     * @param position  An index to insert text
     * @param text      A string
     */
    public void insert (int position, string text) {
        var item = new ListStoreItem (null, text);
        if (position < 0) {
            liststore.append (item);
        } else {
            liststore.insert (position, item);
        }
    }

    /**
     * Prepends text to the list of strings stored in this.
     *
     * This is the same as calling {@link He.Dropdown.insert} with a position of 0.
     *
     * @param text      A string
     */
    public void prepend (string text) {
        var item = new ListStoreItem (null, text);
        liststore.insert (0, item);
    }

    /**
     * Removes the string at position from this.
     *
     * @param position  Index of the item to remove
     */
    public new void remove (int position) {
        liststore.remove (position);
    }

    /**
     * Removes all the text entries from the dropdown.
     */
    public void remove_all () {
        liststore.remove_all ();
    }
}