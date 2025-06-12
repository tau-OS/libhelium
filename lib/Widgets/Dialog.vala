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
 * A Dialog is a modal widget that asks the user for input or shows a message.
 */
public class He.Dialog : Gtk.Widget {
    private const int TOP_MARGIN = 42;

    /**
     * The hidden signal fires when the dialog is hidden.
     */
    public signal void hidden ();

    private Gtk.Widget dimming;
    private Gtk.Box dialog_bin;
    private Gtk.Label title_label = new Gtk.Label (null);
    private Gtk.Label info_label = new Gtk.Label (null);
    private Gtk.Image image = new Gtk.Image ();
    private Gtk.Box info_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 24);
    private Gtk.Box child_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);
    private Gtk.Box button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
    private Gtk.WindowHandle dialog_handle = new Gtk.WindowHandle ();
    private He.Button _secondary_button;
    private He.Button _primary_button;
    private Gtk.Window? parent_window;

    /**
     * The cancel button in the dialog.
     */
    public He.Button cancel_button;

    /**
     * Shows or hides the dialog
     */
    private bool _visible = false;
    public bool visible {
        get { return _visible; }
        set {
            if (visible == value)
                return;

            _visible = value;

            if (value) {
                dimming.set_child_visible (true);
                dialog_bin.set_child_visible (true);
            } else {
                dimming.set_child_visible (false);
                dialog_bin.set_child_visible (false);
                hidden ();
            }
            queue_allocate ();
        }
    }

    /**
     * Sets the title of the dialog.
     */
    public string title {
        get {
            return title_label.get_text ();
        }
        set {
            if (value != null) {
                title_label.set_markup (value);
                title_label.visible = true;
            } else {
                title_label.visible = false;
            }
        }
    }

    /**
     * Sets the info text of the dialog.
     */
    public string info {
        get {
            return info_label.get_text ();
        }
        set {
            if (value != null) {
                info_label.set_markup (value);
                info_label.visible = true;
            } else {
                info_label.visible = false;
            }
        }
    }

    /**
     * Sets the icon of the dialog.
     */
    public string icon {
        get {
            return image.get_icon_name ();
        }

        set {
            image.pixel_size = ((Gtk.IconSize) 48);
            image.set_from_icon_name (value);
        }
    }

    /**
     * Sets the secondary button of the dialog.
     */
    public He.Button secondary_button {
        set {
            if (_secondary_button != null) {
                button_box.remove (_secondary_button);
            }

            _secondary_button = value;
            value.is_tint = true;
            button_box.prepend (_secondary_button);
            button_box.reorder_child_after (_secondary_button, cancel_button);
        }

        get {
            return _secondary_button;
        }
    }

    /**
     * Sets the primary button of the dialog.
     */
    public He.Button primary_button {
        get {
            return _primary_button;
        }

        set {
            if (_primary_button != null) {
                button_box.remove (_primary_button);
            }

            _primary_button = value;
            value.is_fill = true;
            button_box.append (_primary_button);

            if (_secondary_button != null) {
                button_box.reorder_child_after (_primary_button, _secondary_button);
            }
        }
    }

    /**
     * Add a child directly to the Dialog. Used only in code.
     *
     * @since 1.0
     */
    public void add (Gtk.Widget widget) {
        child_box.append (widget);
        child_box.visible = true;
    }

    /**
     * Shows the dialog by overlaying it on the parent window.
     */
    public void present () {
        if (parent_window != null) {
            // Find the window's main content area and overlay this dialog
            find_and_overlay_on_parent ();
        }
        this.visible = true;
    }

    /**
     * Hides the dialog.
     */
    public void hide_dialog () {
        this.visible = false;
        // Clean up - remove from parent
        if (this.get_parent () != null) {
            if (this.get_parent () is Gtk.Overlay) {
                ((Gtk.Overlay) this.get_parent ()).remove_overlay (this);
            } else {
                this.unparent ();
            }
        }
    }

    private void find_and_overlay_on_parent () {
        var content = parent_window.get_child ();
        if (content == null) {
            warning ("Dialog: Parent window has no content widget");
            return;
        }

        // Walk the widget tree to find a suitable overlay container
        Gtk.Widget? overlay_target = find_overlay_target (content);

        if (overlay_target != null && overlay_target is Gtk.Overlay) {
            ((Gtk.Overlay) overlay_target).add_overlay (this);
        } else {
            warning ("Dialog: No Gtk.Overlay found in parent window. Modal dialogs require a Gtk.Overlay container.");
            // Don't show the dialog - we can't overlay it properly
            this.visible = false;
        }
    }

    private Gtk.Widget? find_overlay_target (Gtk.Widget widget) {
        // If this widget is an overlay, use it
        if (widget is Gtk.Overlay) {
            return widget;
        }

        // If it's a container, check its children
        if (widget is Gtk.Box) {
            var child = ((Gtk.Box) widget).get_first_child ();
            while (child != null) {
                var result = find_overlay_target (child);
                if (result != null)return result;
                child = child.get_next_sibling ();
            }
        } else if (widget is Gtk.Grid) {
            var child = ((Gtk.Grid) widget).get_first_child ();
            while (child != null) {
                var result = find_overlay_target (child);
                if (result != null)return result;
                child = child.get_next_sibling ();
            }
        }

        return null;
    }

    /**
     * Creates a new dialog.
     * @param parent The parent window of the dialog. The window must contain
     *               a Gtk.Overlay somewhere in its widget hierarchy for modal
     *               overlay behavior to work correctly.
     * @param title The title of the dialog.
     * @param info The info text of the dialog.
     * @param icon The icon of the dialog.
     * @param primary_button The primary button of the dialog.
     * @param secondary_button The secondary button of the dialog.
     *
     * @since 1.0
     */
    public Dialog (Gtk.Window parent,
        string? title = null,
        string? info = null,
        string? icon = null,
        He.Button? primary_button = null,
        He.Button? secondary_button = null) {
        this.parent_window = parent;
        this.title = title;
        this.info = info;
        this.icon = icon;
        this.primary_button = primary_button;
        this.secondary_button = secondary_button;
    }

    construct {
        // Create dimming background
        dimming = new He.Bin ();
        dimming.add_css_class ("dimming");
        dimming.set_child_visible (false);
        dimming.set_parent (this);

        // Create main dialog container
        dialog_bin = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        dialog_bin.halign = Gtk.Align.CENTER;
        dialog_bin.set_child_visible (false);
        dialog_bin.set_parent (this);

        image.valign = Gtk.Align.CENTER;
        image.halign = Gtk.Align.CENTER;
        title_label.add_css_class ("view-title");
        title_label.wrap = true;
        title_label.xalign = 0;
        title_label.wrap_mode = Pango.WrapMode.WORD;
        title_label.visible = false;
        title_label.width_chars = 25;
        info_label.add_css_class ("body");
        info_label.xalign = 0;
        info_label.vexpand = true;
        info_label.hexpand = true;
        info_label.valign = Gtk.Align.START;
        info_label.wrap = true;
        info_label.wrap_mode = Pango.WrapMode.WORD;
        info_label.visible = false;

        info_box.append (image);
        info_box.append (title_label);
        info_box.append (info_label);

        cancel_button = new He.Button (null, _("Cancel"));
        cancel_button.is_textual = true;
        cancel_button.clicked.connect (() => {
            hide_dialog ();
        });

        button_box.homogeneous = true;
        button_box.prepend (cancel_button);

        child_box.visible = false;

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 24);
        main_box.vexpand = true;
        main_box.margin_end = main_box.margin_start = main_box.margin_top = main_box.margin_bottom = 24;
        main_box.append (info_box);
        main_box.append (child_box);
        main_box.append (button_box);

        dialog_handle.set_child (main_box);
        dialog_bin.append (dialog_handle);

        // Click gesture for dimming background
        var click_gesture = new Gtk.GestureClick ();
        click_gesture.end.connect (() => { hide_dialog (); });
        dimming.add_controller (click_gesture);

        this.add_css_class ("dialog-content");
    }

    protected override void dispose () {
        if (dimming != null) {
            dimming.unparent ();
            dimming = null;
        }

        if (dialog_bin != null) {
            dialog_bin.unparent ();
            dialog_bin = null;
        }

        base.dispose ();
    }

    protected override bool contains (double x, double y) {
        return false;
    }

    protected override void measure (Gtk.Orientation orientation,
                                     int for_size,
                                     out int min,
                                     out int nat,
                                     out int min_baseline,
                                     out int nat_baseline) {
        int dialog_min, dialog_nat;
        int dimming_min, dimming_nat;
        min = nat = 0;

        if (dialog_bin.get_child_visible ()) {
            dialog_bin.measure (orientation, for_size, out dialog_min, out dialog_nat, null, null);
            dimming.measure (orientation, for_size, out dimming_min, out dimming_nat, null, null);

            if (orientation == HORIZONTAL) {
                min = int.max (dimming_min, dialog_min);
                nat = int.max (dimming_nat, dialog_nat);
            } else {
                min = int.max (dimming_min, dialog_min + TOP_MARGIN);
                nat = int.max (dimming_nat, dialog_nat + TOP_MARGIN);
            }
        }
        min_baseline = nat_baseline = -1;
    }

    protected override void size_allocate (int width, int height, int baseline) {
        if (!dialog_bin.get_child_visible ())
            return;

        dimming.allocate (width, height, baseline, null);

        int dialog_height;
        dialog_bin.measure (VERTICAL, -1, null, out dialog_height, null, null);
        dialog_height = int.min (dialog_height, height - TOP_MARGIN);

        var t = new Gsk.Transform ();

        if (width <= 600) { // Mobile: bottom sheet behavior
            t = t.translate ({ 0, height - dialog_height });
            dialog_bin.allocate (width, dialog_height, baseline, t);
            dialog_bin.add_css_class ("bottom-sheet");
            dialog_bin.remove_css_class ("dialog-sheet");
        } else { // Desktop: positioned dialog behavior (25% from right/left)
            // Get dialog width for positioning
            int dialog_width;
            dialog_bin.measure (HORIZONTAL, -1, out dialog_width, null, null, null);

            // Position 25% from right (or left if RTL)
            int x_pos;
            if (get_direction () == Gtk.TextDirection.RTL) {
                // RTL: 25% from left
                x_pos = (int) (width * 0.25);
            } else {
                // LTR: 25% from right
                x_pos = (int) (width * 0.75 - dialog_width);
            }

            t = t.translate ({ x_pos, (height - dialog_height) / 2 });
            dialog_bin.allocate (dialog_width, dialog_height, baseline, t);
            dialog_bin.add_css_class ("dialog-sheet");
            dialog_bin.remove_css_class ("bottom-sheet");
        }
    }
}