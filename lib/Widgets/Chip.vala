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
 * A Chip is an element that can facilitate entering information,
 * making selections, filtering content, or triggering actions.
 */
public class He.Chip : Gtk.ToggleButton, Gtk.Actionable {
    He.ButtonContent chip_box;
    Gtk.Button close_button;
    Gtk.Box container;

    private string _chip_label;
    public string chip_label {
        get { return _chip_label; }
        set {
            _chip_label = value;
            chip_box.label = _chip_label;
        }
    }

    /**
     * Whether to show a close button on this chip.
     * When enabled, displays a small close button that emits the close_clicked signal.
     *
     * @since 1.0
     */
    private bool _show_close_button;
    public bool show_close_button {
        get { return _show_close_button; }
        set {
            _show_close_button = value;
            update_close_button ();
        }
    }

    /**
     * Signal emitted when the close button is clicked.
     * Connect to this signal to handle chip removal.
     *
     * @since 1.0
     */
    public signal void close_clicked ();

    /**
     * Creates a new Chip.
     * @param label The text to display in the chip.
     *
     * @since 1.0
     */
    public Chip (string label) {
        _chip_label = label;
        chip_box.label = _chip_label;
    }

    construct {
        this.add_css_class ("chip");

        chip_box = new He.ButtonContent ();
        chip_box.hexpand = true;
        chip_box.label = _chip_label;

        // Create container to hold both chip content and close button
        container = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        container.append (chip_box);

        // Hide icon initially and show when active
        var icon_widget = chip_box.get_first_child ();
        if (icon_widget != null) {
            var actual_icon = icon_widget.get_first_child ();
            if (actual_icon != null) {
                actual_icon.visible = false;
            }
        }
        chip_box.icon = "";

        notify["active"].connect (() => {
            if (this.active) {
                if (icon_widget != null) {
                    var actual_icon = icon_widget.get_first_child ();
                    if (actual_icon != null) {
                        actual_icon.visible = true;
                    }
                }
                chip_box.icon = "emblem-default-symbolic";
            } else {
                if (icon_widget != null) {
                    var actual_icon = icon_widget.get_first_child ();
                    if (actual_icon != null) {
                        actual_icon.visible = false;
                    }
                }
                chip_box.icon = "";
            }
        });

        this.child = container;
        show_close_button = false;
    }

    private void update_close_button () {
        if (close_button != null) {
            close_button.unparent ();
            close_button = null;
        }

        if (show_close_button) {
            close_button = new Gtk.Button () {
                icon_name = "window-close-symbolic",
                has_frame = false,
                valign = Gtk.Align.CENTER,
                tooltip_text = "Remove"
            };
            close_button.add_css_class ("chip-close");
            close_button.add_css_class ("flat");

            // Add gesture to claim click events and prevent toggling parent Chip
            var click_gesture = new Gtk.GestureClick ();
            click_gesture.released.connect ((n_press, x, y) => {
                click_gesture.set_state (Gtk.EventSequenceState.CLAIMED);
                close_clicked ();
            });
            close_button.add_controller (click_gesture);

            container.append (close_button);
        }
    }
}
