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
 * A BottomBar is a bottom toolbar that displays actions and content labels.
 *
 * The BottomBar can operate in two distinct modes:
 * - **Docked Mode**: Acts as a traditional bottom app bar, attached to the window edge
 * - **Floating Mode**: Hovers over content as an overlay with rounded corners and elevation
 *
 * Important Notes
 *
 * - **Button Limitation**: Only accepts `He.Button` widgets as children
 * - **Floating Mode Requirements**: Must set `overlay_widget` when using `Mode.FLOATING`
 * - **Automatic Overlay Creation**: If the target widget isn't in a `Gtk.Overlay`, one is created automatically
 *
 * CSS Classes
 *
 * The BottomBar automatically applies CSS classes for styling:
 * - `bottom-bar`: Always applied to the root element
 * - `docked`: Applied when in docked mode
 * - `floating`: Applied when in floating mode
 * - `default`: Applied when using default style
 * - `vibrant`: Applied when using vibrant style
 *
 * @since 1.0
 */
public class He.BottomBar : He.Bin, Gtk.Buildable {
    private Gtk.Box main_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
    private Gtk.Box left_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 4);
    private Gtk.Box center_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
    private Gtk.Box right_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 4);

    private Gtk.Label title_label = new Gtk.Label ("");
    private Gtk.Label description_label = new Gtk.Label ("");

    private Gtk.Overlay? overlay_parent = null;
    private He.OverlayButton? _overlay_button = null;

    /**
     * The main title text displayed in the center of the bottom bar.
     * This is ideal for showing the current context or selection state,
     * such as "Photos" or "3 items selected".
     *
     * Note: Title is hidden when in vertical mode (LEFT/RIGHT positioning).
     */
    public string title {
        get { return title_label.get_text (); }
        set {
            title_label.set_text (value);
            // Only show if not in vertical mode and has content
            bool is_vertical = (_floating_position == FloatingPosition.LEFT || _floating_position == FloatingPosition.RIGHT);
            title_label.visible = !is_vertical && value.length > 0;
        }
    }

    /**
     * An optional overlay button that appears near the bottom bar when in floating mode.
     *
     * When set, this button will be positioned 18px away from the floating bottom bar.
     * The positioning depends on the floating_position:
     * - BOTTOM: Button appears 18px to the right of the bar
     * - LEFT: Button appears 18px above the bar
     * - RIGHT: Button appears 18px above the bar
     *
     * The overlay button is only visible when the BottomBar is in FLOATING mode.
     * Setting this to null removes the overlay button.
     */
    public He.OverlayButton? overlay_button {
        get { return _overlay_button; }
        set {
            if (_overlay_button == value)return;

            // Remove existing overlay button
            if (_overlay_button != null) {
                remove_overlay_button ();
            }

            _overlay_button = value;

            // Add new overlay button if in floating mode
            if (_overlay_button != null && _mode == Mode.FLOATING && overlay_parent != null) {
                setup_overlay_button ();
            }
        }
    }

    /**
     * The secondary description text displayed below the title.
     * This is ideal for showing additional context or action hints,
     * such as "Tap to select items" or "Ready to share".
     *
     * Note: Description is hidden when in vertical mode (LEFT/RIGHT positioning).
     */
    public string description {
        get { return description_label.get_text (); }
        set {
            description_label.set_text (value);
            // Only show if not in vertical mode and has content
            bool is_vertical = (_floating_position == FloatingPosition.LEFT || _floating_position == FloatingPosition.RIGHT);
            description_label.visible = !is_vertical && value.length > 0;
        }
    }

    /**
     * Display modes for the BottomBar widget.
     *
     * The mode determines how the bottom bar is positioned and styled:
     *
     * - **DOCKED**: Traditional bottom app bar attached to the window edge.
     * Spans the full width and has a flat appearance with subtle elevation.
     *
     * - **FLOATING**: Overlay bar that hovers over content with rounded corners.
     * Requires an `overlay_widget` to be specified for positioning.
     * Has higher elevation and appears above other content.
     */
    public enum Mode {
        DOCKED,
        FLOATING
    }

    /**
     * Visual styles for the BottomBar widget.
     *
     * The style determines the visual appearance and theming:
     *
     * - **DEFAULT**: Standard appearance with system colors and styling.
     * Uses the default theme colors and contrast levels.
     *
     * - **VIBRANT**: Enhanced appearance with more vivid colors and effects.
     * Provides higher visual impact and modern styling. Applies "vibrant" CSS class.
     */
    public enum Style {
        DEFAULT,
        VIBRANT
    }

    /**
     * Positioning options for floating BottomBar.
     *
     * When in floating mode, the bottom bar can be positioned at different edges:
     *
     * - **BOTTOM**: Default positioning at the bottom edge of the overlay widget.
     * - **LEFT**: Positioned at the left edge with vertical orientation.
     * - **RIGHT**: Positioned at the right edge with vertical orientation.
     */
    public enum FloatingPosition {
        BOTTOM,
        LEFT,
        RIGHT
    }

    private Mode _mode = Mode.DOCKED;
    /**
     * The current display mode of the bottom bar.
     *
     * Changing this property automatically updates the CSS classes and positioning.
     * When switching to FLOATING mode, ensure `overlay_widget` is set.
     * The overlay_button is only shown in FLOATING mode.
     *
     * CSS Classes
     * - `docked` class is applied when mode is DOCKED
     * - `floating` class is applied when mode is FLOATING
     */
    public Mode mode {
        get { return _mode; }
        set {
            if (_mode == value)return;

            _mode = value;
            update_mode_styling ();

            // Trigger overlay setup when switching to floating mode
            if (_mode == Mode.FLOATING && overlay_widget != null) {
                setup_overlay (overlay_widget);
            } else if (_mode == Mode.DOCKED) {
                remove_from_overlay ();
            }
        }
    }

    private Style _style = Style.DEFAULT;
    /**
     * The current visual style of the bottom bar.
     *
     * Changing this property automatically updates the CSS classes to apply
     * the appropriate theming and visual effects.
     *
     * CSS Classes
     * - No additional class is applied when style is DEFAULT
     * - `vibrant` class is applied when style is VIBRANT
     */
    public Style style {
        get { return _style; }
        set {
            if (_style == value)return;

            _style = value;
            update_style_classes ();
        }
    }

    private FloatingPosition _floating_position = FloatingPosition.BOTTOM;
    /**
     * The position of the bottom bar when in floating mode.
     *
     * This property determines where the floating bottom bar is positioned
     * relative to the overlay widget. Only affects appearance in FLOATING mode.
     * Also repositions the overlay_button if present.
     *
     * Position Behavior
     * - BOTTOM: Positioned at bottom with horizontal layout (default)
     * - LEFT: Positioned at left edge with vertical layout
     * - RIGHT: Positioned at right edge with vertical layout
     */
    public FloatingPosition floating_position {
        get { return _floating_position; }
        set {
            if (_floating_position == value)return;

            _floating_position = value;

            // Update layout orientation based on position
            update_layout_orientation ();

            // Re-setup overlay if currently floating
            if (_mode == Mode.FLOATING && overlay_widget != null) {
                setup_overlay (overlay_widget);
            }
        }
    }

    /**
     * The widget to overlay when in floating mode.
     *
     * This property is **required** when using FLOATING mode. The bottom bar
     * will be positioned as an overlay on top of this widget.
     *
     * Behavior
     * - If the target widget is not already in a Gtk.Overlay, one will be created automatically
     * - The overlay is inserted into the widget hierarchy, preserving the original structure
     * - Setting this to `null` while in FLOATING mode will show a warning
     */
    public Gtk.Widget? overlay_widget {
        get { return overlay_parent != null? overlay_parent.get_child () : null; }
        set {
            if (mode == Mode.FLOATING && value == null) {
                warning ("overlay_widget must be set when using FLOATING mode");
                return;
            }

            setup_overlay (value);
        }
    }

    /**
     * Positioning options for buttons within the BottomBar.
     *
     * Buttons can be placed on either side of the center content area,
     * allowing for a balanced layout of actions.
     */
    public enum Position {
        LEFT,
        RIGHT
    }

    /**
     * Add a child widget for Gtk.Builder support.
     *
     * This method is called automatically when using UI files or Blueprint.
     * It only accepts He.Button widgets as children.
     *
     * @param builder The Gtk.Builder instance (unused)
     * @param child The child widget to add (must be He.Button)
     * @param type Positioning hint: "left", "right", or null (defaults to left)
     */
    public new void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
        if (!(child is He.Button)) {
            warning ("BottomBar only accepts He.Button children");
            return;
        }

        var position = (type == "right") ? Position.RIGHT : Position.LEFT;
        append_button ((He.Button) child, position);
    }

    /**
     * Create a new BottomBar in docked mode.
     *
     * The bottom bar will be created without title or description text.
     * Use the `title` and `description` properties to set content after creation.
     */
    public BottomBar () {
        base ();
    }

    /**
     * Create a new BottomBar with title and description text.
     *
     * This is a convenience constructor that sets both the title and description
     * in a single call. The bottom bar will be in docked mode by default.
     *
     * @param title The main title text to display
     * @param description The secondary description text to display
     */
    public BottomBar.with_details (string title, string description) {
        base ();
        this.title = title;
        this.description = description;
    }

    /**
     * Create a new BottomBar in floating mode.
     *
     * This convenience constructor automatically sets the mode to FLOATING
     * and configures the overlay widget. The bottom bar will hover over
     * the specified widget with elevated styling.
     *
     * @param overlay_widget The widget to overlay the bottom bar on top of
     */
    public BottomBar.floating (Gtk.Widget overlay_widget) {
        base ();
        this.mode = Mode.FLOATING;
        this.overlay_widget = overlay_widget;
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BoxLayout));
    }

    construct {
        setup_styling ();
        setup_layout ();
        update_mode_styling ();
        update_style_classes ();
        update_layout_orientation ();
    }

    /**
     * Initialize CSS classes and styling properties.
     *
     * Sets up the base styling for title, description, and layout components.
     * Called once during widget construction.
     */
    private void setup_styling () {
        title_label.add_css_class ("title");
        description_label.add_css_class ("dim-label");
        add_css_class ("bottom-bar");

        center_box.halign = Gtk.Align.CENTER;
        center_box.hexpand = true;
    }

    /**
     * Arrange the internal widget hierarchy.
     *
     * Creates the horizontal layout with left, center, and right sections.
     * Called once during widget construction.
     */
    private void setup_layout () {
        center_box.append (title_label);
        center_box.append (description_label);

        main_box.append (left_box);
        main_box.append (center_box);
        main_box.append (right_box);

        main_box.set_parent (this);
    }

    /**
     * Update CSS classes based on current mode.
     *
     * Removes previous mode classes and applies the current mode class.
     * This triggers CSS transitions and styling changes.
     */
    private void update_mode_styling () {
        remove_css_class ("docked");
        remove_css_class ("floating");

        if (_mode == Mode.DOCKED) {
            add_css_class ("docked");
        } else {
            add_css_class ("floating");
        }
    }

    /**
     * Update CSS classes based on current style.
     *
     * Removes previous style classes and applies the current style class.
     * Only applies "vibrant" class when style is VIBRANT.
     */
    private void update_style_classes () {
        remove_css_class ("vibrant");

        if (_style == Style.VIBRANT) {
            add_css_class ("vibrant");
        }
    }

    /**
     * Update layout orientation based on floating position.
     *
     * Changes the main box orientation and alignment based on whether
     * the floating bar is positioned horizontally or vertically.
     * Also hides title and description in vertical mode and adjusts
     * internal box orientations and alignments.
     */
    private void update_layout_orientation () {
        if (_floating_position == FloatingPosition.LEFT || _floating_position == FloatingPosition.RIGHT) {
            // Vertical orientation for left/right positioning
            main_box.orientation = Gtk.Orientation.VERTICAL;
            main_box.halign = Gtk.Align.CENTER;
            main_box.valign = Gtk.Align.CENTER;

            apply_floating_position_settings ();

            // Make button boxes vertical too
            left_box.orientation = Gtk.Orientation.VERTICAL;
            right_box.orientation = Gtk.Orientation.VERTICAL;

            // Center the button boxes within the vertical layout
            left_box.halign = Gtk.Align.CENTER;
            right_box.halign = Gtk.Align.CENTER;
            left_box.valign = Gtk.Align.START;
            right_box.valign = Gtk.Align.END;

            // Center box settings (though hidden)
            center_box.halign = Gtk.Align.CENTER;
            center_box.valign = Gtk.Align.CENTER;

            // Hide title and description in vertical mode
            title_label.visible = false;
            description_label.visible = false;
        } else {
            // Horizontal orientation for bottom positioning (default)
            main_box.orientation = Gtk.Orientation.HORIZONTAL;
            main_box.halign = Gtk.Align.FILL;
            main_box.valign = Gtk.Align.FILL;

            apply_floating_position_settings ();

            // Make button boxes horizontal
            left_box.orientation = Gtk.Orientation.HORIZONTAL;
            right_box.orientation = Gtk.Orientation.HORIZONTAL;

            // Reset button box alignments for horizontal layout
            left_box.halign = Gtk.Align.START;
            right_box.halign = Gtk.Align.END;
            left_box.valign = Gtk.Align.CENTER;
            right_box.valign = Gtk.Align.CENTER;

            // Center box settings for horizontal layout
            center_box.halign = Gtk.Align.CENTER;
            center_box.valign = Gtk.Align.FILL;

            // Show title and description based on their text content
            title_label.visible = title_label.get_text ().length > 0;
            description_label.visible = description_label.get_text ().length > 0;
        }
    }

    /**
     * Configure overlay positioning for floating mode.
     *
     * Creates or uses an existing Gtk.Overlay to position the bottom bar
     * over the target widget. Handles widget reparenting automatically.
     *
     * @param target_widget The widget to overlay, or null to clear overlay
     */
    private void setup_overlay (Gtk.Widget? target_widget) {
        if (target_widget == null)return;

        // Only proceed if in floating mode
        if (mode != Mode.FLOATING)return;

        // Remove from current overlay if already floating
        remove_from_overlay ();

        // Unparent this bottom bar from its current parent
        if (get_parent () != null) {
            unparent ();
        }

        // Create overlay if needed
        if (!(target_widget is Gtk.Overlay)) {
            var parent = target_widget.get_parent ();
            if (parent != null) {
                overlay_parent = new Gtk.Overlay ();
                target_widget.unparent ();
                overlay_parent.set_child (target_widget);

                // Reparent the overlay to the original parent
                reparent_overlay_to_container (overlay_parent, parent);
            }
        } else {
            // Target widget is already an overlay, use it directly
            overlay_parent = (Gtk.Overlay) target_widget;
        }

        if (overlay_parent != null) {
            overlay_parent.add_overlay (this);
            apply_floating_position_settings ();
        }
    }

    /**
     * Apply alignment and margin settings based on floating position.
     *
     * Configures the widget alignment and margins to position the floating
     * bottom bar at the specified edge of the overlay.
     */
    private void apply_floating_position_settings () {
        // Reset all margins first
        margin_start = 0;
        margin_end = 0;
        margin_top = 0;
        margin_bottom = 0;

        switch (_floating_position) {
        case FloatingPosition.BOTTOM :
            halign = Gtk.Align.FILL;
            valign = Gtk.Align.END;
            margin_start = 12;
            margin_end = 12;
            margin_bottom = 12;
            break;

        case FloatingPosition.LEFT :
            halign = Gtk.Align.START;
            valign = Gtk.Align.CENTER;
            margin_start = 12;
            margin_top = 12;
            margin_bottom = 12;
            break;

        case FloatingPosition.RIGHT :
            halign = Gtk.Align.END;
            valign = Gtk.Align.CENTER;
            margin_end = 12;
            margin_top = 12;
            margin_bottom = 12;
            break;
        }

        // Setup overlay button positioning if it exists
        if (_overlay_button != null) {
            setup_overlay_button ();
        }
    }

    /**
     * Setup the overlay button positioning when in floating mode.
     *
     * Positions the overlay button 18px away from the bottom bar based on
     * the current floating_position setting.
     */
    private void setup_overlay_button () {
        if (_overlay_button == null || overlay_parent == null || _mode != Mode.FLOATING) {
            return;
        }

        // Remove from overlay if already added
        if (_overlay_button.get_parent () == overlay_parent) {
            overlay_parent.remove_overlay (_overlay_button);
        }

        // Add to overlay and position
        overlay_parent.add_overlay (_overlay_button);
        apply_overlay_button_positioning ();
    }

    /**
     * Apply positioning settings to the overlay button based on floating position.
     *
     * Positions the button 18px away from the bottom bar in the appropriate direction.
     */
    private void apply_overlay_button_positioning () {
        if (_overlay_button == null)return;

        // Reset all margins first
        _overlay_button.margin_start = 0;
        _overlay_button.margin_end = 0;
        _overlay_button.margin_top = 0;
        _overlay_button.margin_bottom = 0;

        switch (_floating_position) {
        case FloatingPosition.BOTTOM :
            // Position 18px to the right of the bar
            _overlay_button.halign = Gtk.Align.END;
            _overlay_button.valign = Gtk.Align.END;
            _overlay_button.margin_end = 12 - 18; // Extend beyond the bar by 18px
            _overlay_button.margin_bottom = 12;
            break;

        case FloatingPosition.LEFT :
            // Position 18px above the bar (same horizontal alignment as bar)
            _overlay_button.halign = Gtk.Align.START;
            _overlay_button.valign = Gtk.Align.END;
            _overlay_button.margin_start = 12;
            _overlay_button.margin_bottom = 12 + get_allocated_height () + 18;
            break;

        case FloatingPosition.RIGHT:
            // Position 18px above the bar (same horizontal alignment as bar)
            _overlay_button.halign = Gtk.Align.END;
            _overlay_button.valign = Gtk.Align.END;
            _overlay_button.margin_end = 12;
            _overlay_button.margin_bottom = 12 + get_allocated_height () + 18;
            break;
        }
    }

    /**
     * Remove the overlay button from the overlay parent.
     */
    private void remove_overlay_button () {
        if (_overlay_button != null && overlay_parent != null && _overlay_button.get_parent () == overlay_parent) {
            overlay_parent.remove_overlay (_overlay_button);
        }
    }

    /**
     * Simple method to reparent the overlay to various container types.
     *
     * @param overlay The overlay widget to reparent
     * @param container The parent container
     */
    private void reparent_overlay_to_container (Gtk.Overlay overlay, Gtk.Widget container) {
        // Handle common container types where floating makes sense
        if (container is Gtk.Box) {
            ((Gtk.Box) container).append (overlay);
        } else {
            // Generic fallback using GObject properties
            var child_prop = container.get_class ().find_property ("child");
            if (child_prop != null) {
                container.set_property ("child", overlay);
            } else {
                warning ("Container type %s does not support floating BottomBar",
                         container.get_type ().name ());
            }
        }
    }

    /**
     * Remove the bottom bar from any overlay parent.
     */
    private void remove_from_overlay () {
        // Remove overlay button first
        remove_overlay_button ();

        if (overlay_parent != null && get_parent () == overlay_parent) {
            overlay_parent.remove_overlay (this);
        }

        // Reset margins when not floating
        margin_start = 0;
        margin_end = 0;
        margin_top = 0;
        margin_bottom = 0;
    }

    /**
     * Clean up overlay relationships when the widget is destroyed.
     */
    ~BottomBar () {
        remove_from_overlay ();
    }

    /**
     * Add a button to the end of the bottom bar.
     *
     * The button is added to the specified position (left or right side)
     * after any existing buttons in that position.
     *
     * @param button The He.Button to add to the bottom bar
     * @param position Which side of the bar to add the button to
     *
     */
    public void append_button (He.Button button, Position position) {
        var target_box = (position == Position.LEFT) ? left_box : right_box;
        target_box.append (button);
    }

    /**
     * Add a button to the beginning of the bottom bar.
     *
     * The button is added to the specified position (left or right side)
     * before any existing buttons in that position.
     *
     * @param button The He.Button to add to the bottom bar
     * @param position Which side of the bar to add the button to
     *
     */
    public void prepend_button (He.Button button, Position position) {
        var target_box = (position == Position.LEFT) ? left_box : right_box;
        target_box.prepend (button);
    }

    /**
     * Remove a button from the bottom bar.
     *
     * The button is removed from whichever position it's currently in.
     * If the button is not a child of this bottom bar, no action is taken.
     *
     * @param button The He.Button to remove from the bottom bar
     *
     */
    public void remove_button (He.Button button) {
        var parent = button.get_parent ();
        if (parent != null && (parent == left_box || parent == right_box)) {
            ((Gtk.Box) parent).remove (button);
        }
    }

    /**
     * Insert a button after another button.
     *
     * The new button is inserted immediately after the reference button
     * in the specified position. Both buttons must be in the same position.
     *
     * @param button The He.Button to insert
     * @param after The existing He.Button to insert after
     * @param position Which side of the bar to insert the button into
     *
     */
    public void insert_button_after (He.Button button, He.Button after, Position position) {
        var target_box = (position == Position.LEFT) ? left_box : right_box;
        target_box.insert_child_after (button, after);
    }

    /**
     * Remove all buttons from the bottom bar.
     *
     * This removes all buttons from both the left and right sides of the bar.
     * The buttons are unparented but not destroyed, so they can be reused.
     *
     */
    public void clear_buttons () {
        Gtk.Widget? child;

        while ((child = left_box.get_first_child ()) != null) {
            left_box.remove (child);
        }

        while ((child = right_box.get_first_child ()) != null) {
            right_box.remove (child);
        }
    }

    /**
     * Get the number of buttons in a specific position.
     *
     * This counts all He.Button widgets currently added to the specified
     * side of the bottom bar.
     *
     * @param position Which side of the bar to count buttons for
     * @return The number of buttons in the specified position
     *
     */
    public int get_button_count (Position position) {
        var target_box = (position == Position.LEFT) ? left_box : right_box;
        int count = 0;

        var child = target_box.get_first_child ();
        while (child != null) {
            count++;
            child = child.get_next_sibling ();
        }

        return count;
    }
}