/*
 * Copyright (c) 2022-2025 Fyra Labs
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
 * Modes for ChipGroup behavior.
 * Selection mode - chips behave as radio buttons, only one can be active.
 * Filtering mode - multiple chips can be active simultaneously.
 *
 * @since 1.0
 */
public enum He.ChipGroupMode {
    SELECTION,
    FILTERING
}

/**
 * A ChipGroup is a holder widget for Chips.
 */
public class He.ChipGroup : He.Bin {
    private Gtk.SingleSelection _selection_model;
    private List<He.Chip> _buttons;
    private Gtk.FlowBox flowbox;
    private Gtk.ScrolledWindow sw;

    /**
     * The SelectionModel that is controlled by this group.
     *
     * @since 1.0
     */
    public Gtk.SingleSelection selection_model {
        get { return this._selection_model; }
        set {
            if (this._selection_model == value)return;

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

    private void remove_chip (uint position) {
        if (position >= _buttons.length ())return;

        var chip = _buttons.nth_data (position);
        if (chip != null) {
            // Remove from UI
            chip.unparent ();
            _buttons.remove (chip);

            // Update close button settings for remaining chips after removal
            update_close_buttons ();

            // Emit signal
            chip_removed (position);
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
                sw.hscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
            } else {
                flowbox.min_children_per_line = 3;
                sw.hscrollbar_policy = Gtk.PolicyType.NEVER;
            }
        }
    }

    /**
     * The mode of the chip group - selection or filtering.
     * In selection mode, chips behave as radio buttons where only one can be active.
     * In filtering mode, multiple chips can be active simultaneously.
     *
     * @since 1.0
     */
    private ChipGroupMode _mode;
    public ChipGroupMode mode {
        get { return _mode; }
        set {
            _mode = value;
            update_chip_groups ();
        }
    }

    /**
     * Whether to show close buttons on chips in filtering mode.
     * Close buttons allow users to remove individual chips from the group.
     * Only effective when mode is set to FILTERING.
     *
     * @since 1.0
     */
    private bool _show_close_buttons;
    public bool show_close_buttons {
        get { return _show_close_buttons; }
        set {
            _show_close_buttons = value;
            update_close_buttons ();
        }
    }

    /**
     * Signal emitted when filters change in filtering mode.
     * Connect to this signal to respond to filter state changes.
     *
     * @since 1.0
     */
    public signal void filters_changed ();

    /**
     * Signal emitted when a chip is removed from the group.
     * Only emitted in filtering mode when close buttons are enabled.
     * @param position The index of the removed chip
     *
     * @since 1.0
     */
    public signal void chip_removed (uint position);

    /**
     * Creates a new ChipGroup.
     */
    public ChipGroup () {
        base ();
    }

    construct {
        flowbox = new Gtk.FlowBox ();

        sw = new Gtk.ScrolledWindow ();
        sw.hexpand = true;
        sw.vexpand = true;
        sw.valign = Gtk.Align.CENTER;
        sw.vscrollbar_policy = Gtk.PolicyType.NEVER;
        sw.child = flowbox;

        this.child = sw;

        single_line = false;
        mode = ChipGroupMode.SELECTION;
        show_close_buttons = false;
    }

    private void update_chip_groups () {
        if (_buttons.is_empty ())return;

        if (mode == ChipGroupMode.SELECTION) {
            // Set up radio button behavior
            var first_chip = _buttons.nth_data (0);
            for (uint i = 1; i < _buttons.length (); i++) {
                var chip = _buttons.nth_data (i);
                if (chip != null && first_chip != null) {
                    chip.set_group (first_chip);
                }
            }
        } else {
            // Remove radio button behavior for filtering
            for (uint i = 0; i < _buttons.length (); i++) {
                var chip = _buttons.nth_data (i);
                if (chip != null) {
                    chip.set_group (null);
                }
            }
        }

        update_close_buttons ();
    }

    private void update_close_buttons () {
        for (uint i = 0; i < _buttons.length (); i++) {
            var chip = _buttons.nth_data (i);
            if (chip != null) {
                chip.show_close_button = (mode == ChipGroupMode.FILTERING && show_close_buttons);
            }
        }
    }

    private void on_selection_items_changed (uint position, uint removed, uint added) {
        // Remove buttons for removed items
        for (uint i = 0; i < removed; i++) {
            unowned var button_link = this._buttons.nth (position);
            if (button_link != null) {
                button_link.data.unparent ();
                this._buttons.delete_link (button_link);
            }
        }

        // Add buttons for new items
        for (uint i = 0; i < added; i++) {
            uint current_pos = position + i;
            unowned var button_link = this._buttons.nth (current_pos);

            var button = new He.Chip ("") {
                active = this._selection_model.get_selected () == current_pos
            };

            this._selection_model.get_item (current_pos).bind_property ("title", button, "chip-label", SYNC_CREATE);

            button.toggled.connect (() => on_button_toggled (button));

            // Connect close button signal - find position dynamically
            button.close_clicked.connect (() => {
                int button_pos = this._buttons.index (button);
                if (button_pos >= 0) {
                    remove_chip ((uint) button_pos);
                }
            });

            flowbox.append (button);

            this._buttons.insert_before (button_link, button);
        }

        update_chip_groups ();
    }

    private void on_selection_changed (uint position, uint n_items) {
        if (mode != ChipGroupMode.SELECTION)return;

        // Update button states for changed positions
        uint selected = this._selection_model.get_selected ();
        for (uint i = position; i < position + n_items && i < this._buttons.length (); i++) {
            var button = this._buttons.nth_data (i);
            if (button != null) {
                button.active = (i == selected);
            }
        }
    }

    private void on_button_toggled (He.Chip button) {
        if (mode == ChipGroupMode.SELECTION) {
            if (this._selection_model.get_n_items () <= 1) {
                return;
            }

            int button_pos = this._buttons.index (button);
            if (button_pos < 0)return;

            uint position = (uint) button_pos;
            if (button.active) {
                this._selection_model.select_item (position, true);
            } else {
                this._selection_model.unselect_item (position);
            }
        } else {
            // In filtering mode, just emit signal when any chip changes
            filters_changed ();
        }
    }

    /**
     * Get the indices of all active chips.
     * Primarily useful in filtering mode to determine which filters are currently applied.
     * @return Array of indices representing active chips
     *
     * @since 1.0
     */
    public uint[] get_active_filters () {
        uint[] active_indices = {};

        for (uint i = 0; i < _buttons.length (); i++) {
            var chip = _buttons.nth_data (i);
            if (chip != null && chip.active) {
                active_indices += i;
            }
        }

        return active_indices;
    }

    /**
     * Set which chips should be active by their indices.
     * Useful for programmatically setting filter states or restoring previous selections.
     * @param indices Array of chip indices to activate
     *
     * @since 1.0
     */
    public void set_active_filters (uint[] indices) {
        for (uint i = 0; i < _buttons.length (); i++) {
            var chip = _buttons.nth_data (i);
            if (chip != null) {
                chip.active = false;
            }
        }

        foreach (uint index in indices) {
            if (index < _buttons.length ()) {
                var chip = _buttons.nth_data (index);
                if (chip != null) {
                    chip.active = true;
                }
            }
        }
    }

    /**
     * Deactivate all chips, clearing any active filters or selections.
     * Useful for providing a "clear all" functionality to users.
     *
     * @since 1.0
     */
    public void clear_filters () {
        for (uint i = 0; i < _buttons.length (); i++) {
            var chip = _buttons.nth_data (i);
            if (chip != null) {
                chip.active = false;
            }
        }
    }

    /**
     * Remove a chip from the group at the specified position.
     * This will also remove the corresponding item from the selection model.
     * Only effective in filtering mode.
     * @param position Index of the chip to remove
     *
     * @since 1.0
     */
    public void remove_chip_at (uint position) {
        if (mode == ChipGroupMode.FILTERING) {
            remove_chip (position);
        }
    }
}
