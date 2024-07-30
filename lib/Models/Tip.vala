/*
 * Copyright (c) 2024 Fyra Labs
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
 * A TipViewStyle changes the visual look of a tip.
 */
public enum He.TipViewStyle {
    NONE = 0,
    POPUP = 1,
    VIEW = 2;

    public string to_css_class () {
        switch (this) {
        case POPUP:
            return "tip-popup";

        case VIEW:
            return "tip-view";

        case NONE:
        default:
            return "tip-view";
        }
    }

    public string to_string () {
        return this.to_css_class ();
    }
}

/**
 * A Tip is a helper object for onboarding flow tips in an app's first launch.
 */
public class He.Tip : Object {
    /**
     * The Tip's title.
     */
    private string _title;
    public string title {
        get {
            return _title;
        }
        set {
            if (value != null)
                _title = value;
        }
    }
    /**
     * The Tip's image. May be an icon, or a small image.
     */
    private string _image;
    public string image {
        get {
            return _image;
        }
        set {
            if (value != null)
                _image = value;
        }
    }
    /**
     * The Tip's message. Maximum of two lines.
     */
    private string _message;
    public string message {
        get {
            return _message;
        }
        set {
            if (value != null)
                _message = value;
        }
    }
    /**
     * The Tip's action button label. Must be an actionable word like "Learn More…".
     */
    private string _action_label;
    public string action_label {
        get {
            return _action_label;
        }
        set {
            if (value != null)
                _action_label = value;
        }
    }

    public Tip (string title, string? image, string? message, string? action_label) {
        this.title = title;
        this.image = image;
        this.message = message;
        this.action_label = action_label;
    }
}