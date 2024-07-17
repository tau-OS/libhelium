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
 * TextField is a {@link Gtk.Entry}-like subclass that is meant to be used in
 * forms where input must be validated before the form can be submitted. It
 * provides feedback to users about the state of input validation and keeps
 * track of its own validation state. By default, input is considered invalid.
 * This widget can also be used in place of a {@link Gtk.Entry} for HIG
 * compliance purposes.
 *
 * ''Example''<<BR>>
 * {{{
 *   var validated_entry = new He.TextField ();
 *   username_entry.changed.connect (() => {
 *       username_entry.is_valid = username_entry.text == "valid input";
 *   });
 * }}}
 *
 * If the TextField.from_regex () constructor is used then the entry automatically
 * sets its validity status. A valid regex must be passed to this constructor.
 *
 * ''Example''<<BR>>
 * {{{
 *   GLib.Regex? regex = null;
 *   He.TextField only_lower_case_letters_entry;
 *   try {
 *       regex = new Regex ("^[a-z]*$");
 *       only_lower_case_letters_entry = new He.TextField.from_regex (regex);
 *   } catch (Error e) {
 *       critical (e.message);
 *       // Provide a fallback entry here
 *   }
 * }}}
 */
public class He.TextField : Gtk.ListBoxRow {
    /**
     * Whether or not text is considered valid input.
     */
    public bool is_valid { get; set; default = false; }
    /**
     * Whether or not text needs to be validated.
     */
    public bool needs_validation { get; set; default = false; }
    /**
     * The minimum length to start validating.
     */
    public int min_length { get; set; default = 0; }
    /**
     * The regular expression used for validation.
     */
    public Regex regex { get; construct set; default = null; }
    /**
     * Whether or not this is a search entry.
     */
    private bool _is_search;
    public bool is_search {
        get {
            return _is_search;
        }
        set {
            _is_search = value;
            if (value) {
                _prefix_icon = "system-search-symbolic";
                row_box.add_css_class ("search");
            } else {
                row_box.remove_css_class ("search");
                _prefix_icon = "";
            }
        }
    }
    /**
     * Whether or not this is styled as an outlined TextField instead of having a background.
     */
    private bool _is_outline;
    public bool is_outline {
        get {
            return _is_outline;
        }
        set {
            _is_outline = value;
            if (value) {
                row_box.add_css_class ("outline");
            } else {
                row_box.remove_css_class ("outline");
            }
        }
    }

    /**
     * The Gtk.Text widget to allow using Gtk.Editable props.
     */
    private Gtk.Text _entry = new Gtk.Text ();
    public Gtk.Text entry {
        get {
            return _entry;
        }
    }
    /**
     * A function to be used in code (not Blueprint) to get the Gtk.Text widget.
     */
    public Gtk.Text get_internal_entry () {
        return _entry;
    }

    private Gtk.Label empty_title = new Gtk.Label ("");
    private Gtk.Label support_label;
    private Gtk.Box row_box;
    private Gtk.Image suffix_img = new Gtk.Image ();
    private Gtk.Image prefix_img = new Gtk.Image ();

    /**
     * The entry text.
     */
    private string? _text;
    public string? text {
        get {
            return _text;
        }
        set {
            _text = value;
            entry.text = value;
        }
    }

    /**
     * The suffix icon.
     */
    private string? _suffix_icon;
    public string? suffix_icon {
        get {
            return _suffix_icon;
        }
        set {
            if (value == "") {
                suffix_img.set_visible (false);
            } else {
                suffix_img.set_visible (true);
                suffix_img.set_from_icon_name (value);
            }
        }
    }

    /**
     * The prefix icon.
     */
    private string? _prefix_icon;
    public string? prefix_icon {
        get {
            return _prefix_icon;
        }
        set {
            if (value == "") {
                prefix_img.set_visible (false);
            } else {
                prefix_img.set_visible (true);
                prefix_img.set_from_icon_name (value);
            }
        }
    }

    /**
     * The helper text below the TextField.
     */
    private string? _support_text;
    public string? support_text {
        get {
            return _support_text;
        }
        set {
            _support_text = value;
            if (value == "") {
                support_label.visible = false;
            } else {
                support_label.visible = true;
                support_label.label = value;
            }
        }
    }

    /**
     * The placeholder text inside the TextField.
     */
    private string? _placeholder_text;
    public string? placeholder_text {
        get {
            return _placeholder_text;
        }
        set {
            _placeholder_text = value;
            entry.placeholder_text = value;
        }
    }

    /**
     * The maximum length to start validating.
     */
    private int _max_length;
    public int max_length {
        get {
            return _max_length;
        }
        set {
            _max_length = value;
            entry.max_length = value;
        }
    }

    /**
     * Whether to show/hide the TextField.
     */
    private bool _visibility;
    public bool visibility {
        get {
            return _visibility;
        }
        set {
            _visibility = value;
            entry.visibility = value;
        }
    }

    /**
     * Creates a TextField that uses regular expression provided to check validity.
     * @param regex_arg The regular expression to use.
     */
    public TextField.from_regex (Regex regex_arg) {
        Object (regex: regex_arg);
    }

    private void check_validity () {
        is_valid = entry.get_text_length () >= min_length;

        if (is_valid && regex != null) {
            is_valid = regex.match (entry.text);
        }
    }

    construct {
        is_search = false;
        is_outline = false;
        visibility = true;

        empty_title = new Gtk.Label (placeholder_text);
        empty_title.visible = false;
        empty_title.halign = Gtk.Align.START;
        empty_title.margin_start = 16;
        empty_title.margin_top = 6;
        empty_title.add_css_class ("placeholder");

        entry.activates_default = true;
        entry.margin_start = 16;
        entry.vexpand = true;
        entry.valign = Gtk.Align.CENTER;

        prefix_img.set_visible (false);

        suffix_img.margin_end = 12;
        suffix_img.set_visible (false);

        support_label = new Gtk.Label (support_text);
        support_label.halign = Gtk.Align.START;
        support_label.visible = false;
        support_label.margin_start = 16;
        support_label.add_css_class ("caption");
        support_label.add_css_class ("dim-label");

        var entry_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        entry_box.hexpand = true;
        entry_box.append (empty_title);
        entry_box.append (entry);

        row_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        row_box.append (prefix_img);
        row_box.append (entry_box);
        row_box.append (suffix_img);
        row_box.add_css_class ("text-field");

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 4);
        main_box.append (row_box);
        main_box.append (support_label);

        main_box.set_parent (this);

        this.activatable = false;

        notify["max-length"].connect (() => {
            entry.max_length = max_length;
        });
        notify["visibility"].connect (() => {
            entry.visibility = visibility;
        });

        entry.changed.connect (() => {
            if (needs_validation)
                check_validity ();

            if (placeholder_text == null) {
                empty_title.label = "";
                empty_title.visible = false;
                empty_title.remove_css_class ("caption");
                entry.placeholder_text = placeholder_text;
            } else {
                if (entry.text != "") {
                    empty_title.label = placeholder_text;
                    empty_title.add_css_class ("caption");
                    entry.placeholder_text = "";
                    empty_title.visible = true;
                } else {
                    empty_title.label = "";
                    empty_title.visible = false;
                    empty_title.remove_css_class ("caption");
                    entry.placeholder_text = placeholder_text;
                }
            }
        });

        entry.changed.connect_after (() => {
            if (needs_validation) {
                if (entry.text == "") {
                    _suffix_icon = "";
                    row_box.remove_css_class ("tf-error");
                    row_box.remove_css_class ("tf-success");
                    entry.overflow = Gtk.Overflow.HIDDEN;
                } else if (is_valid) {
                    _suffix_icon = "process-completed-symbolic";
                    row_box.remove_css_class ("tf-error");
                    row_box.add_css_class ("tf-success");
                    entry.overflow = Gtk.Overflow.HIDDEN;
                } else {
                    _suffix_icon = "process-error-symbolic";
                    row_box.add_css_class ("tf-error");
                    row_box.remove_css_class ("tf-success");
                    entry.overflow = Gtk.Overflow.HIDDEN;
                }
            } else {
                entry.overflow = Gtk.Overflow.HIDDEN;
            }
        });
    }
}