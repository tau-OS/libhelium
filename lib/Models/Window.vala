/*
 * Copyright (c) 2022-2024 Fyra Labs
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
 * A Window is a container that has an {@link AppBar} and can be moved, resized, and closed.
 * It may be a top-level window or a dialog. The title bar can be made always visible.
 * Has an optional back button. The back button is only visible if has_back_button is true.
 */
public class He.Window : Gtk.Window {
    private He.AppBar appbar = new He.AppBar ();

    /**
     * The parent window of this window. If this is null, then this is a top-level window.
     */
    private new Gtk.Window ? _parent = null;
    public new Gtk.Window ? parent {
        get {
            return this.get_transient_for ();
        }
        set {
            _parent = value;
            set_modal (value != null);
            set_transient_for (value);
        }
    }

    /**
     * If the window has an appbar.
     */
    private bool _has_title;
    public bool has_title {
        get {
            return _has_title;
        }
        set {
            _has_title = value;
            if (!value) {
                var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
                box.visible = false;
                this.set_titlebar (box);
            } else {
                appbar.add_css_class ("flat");
                this.set_titlebar (appbar);
            }
        }
    }

    /**
     * If the window has a back button.
     *
     * @since 1.0
     */
    private bool _has_back_button;
    public bool has_back_button {
        get {
            return _has_back_button;
        }
        set {
            _has_back_button = value;
            appbar.show_back = value;
        }
    }

    construct {
        has_title = false;
        has_back_button = false;
    }
}
