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
 * A ChipGroup is a holder widget for Chips.
 */
 public class He.ChipGroup : He.Bin {
    private Gtk.SingleSelection _selection_model;
    private List<He.Chip> _buttons;
    private Gtk.FlowBox flowbox;
    private Gtk.ScrolledWindow sw;
    /**
     * The selectionmodel that is controlled by this group.
     *
     * @since 1.0
     */
    public Gtk.SingleSelection selection_model {
        get { return this._selection_model; }
        set {
            if (this._selection_model == value) return;

            if (this._selection_model != null) {
                this._selection_model.selection_changed.disconnect (on_selection_changed);
                this._selection_model.items_changed.disconnect (on_selection_items_changed);
            }

            this._selection_model = value;

            this._selection_model.selection_changed.connect (on_selection_changed);
            this._selection_model.items_changed.connect (on_selection_items_changed);

            on_selection_items_changed (0, 0, this._selection_model.get_n_items ());
        }
    }

    /**
     * If the chip group should be single-line or not
     */
    private bool _single_line;
    public bool single_line {
        get { return _single_line; }
        set {
            _single_line = value;
            if (value) {
                flowbox.min_children_per_line = 999;
                sw.hscrollbar_policy = (Gtk.PolicyType.ALWAYS);
            } else {
                flowbox.min_children_per_line = 3;
                sw.hscrollbar_policy = (Gtk.PolicyType.NEVER);
            }
        }
    }

    /**
     * Creates a new ChipGroup.
     */
    public ChipGroup () {
        base ();
    }

    construct {
        this.valign = Gtk.Align.START;

        flowbox = new Gtk.FlowBox ();

        sw = new Gtk.ScrolledWindow ();
        sw.hexpand = true;
        sw.vexpand = true;
        sw.vscrollbar_policy = (Gtk.PolicyType.NEVER);
        sw.set_child (flowbox);

        this.child = sw;

        single_line = false;
    }

    private void on_selection_items_changed (uint position, uint removed, uint added) {
        while (removed-- > 0 && this._buttons.nth (position) != null) {
            unowned var button_link = this._buttons.nth (position);

            button_link.data.unparent ();

            unowned var link = button_link;
            button_link = button_link.next;

            this._buttons.delete_link (link);
        }

        while (added-- > 0) {
            unowned var button_link = this._buttons.nth (position);

            var button = new He.Chip ("") {
                active = this._selection_model.get_selected () == position ? true : false,
            };

            this._selection_model.get_item (position).bind_property ("title", button, "chip-label", SYNC_CREATE);

            button.toggled.connect (() => on_button_toggled (button));
            flowbox.append (button);

            if (!this._buttons.is_empty ()) {
                button.set_group ((He.Chip) this._buttons.nth_data (0));
            }

            this._buttons.insert_before (button_link, button);

            position++;
        }
    }

    private void on_selection_changed (uint position, uint n_items) {
        unowned var button_link = this._buttons.nth (position);

        while (n_items-- > 0 && button_link != null) {
            button_link.data.active = this._selection_model.get_selected () == position++ ? true : false;
            button_link = button_link.next;
        }
    }

    private void on_button_toggled (He.Chip button) {
        if (this._selection_model.get_n_items () <= 1) {
            return;
        }

        unowned int position = this._buttons.index (button);
        if (button.active) {
            this._selection_model.select_item (position, true);
            return;
        }

        this._selection_model.unselect_item (position);
    }
}
