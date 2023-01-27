/*
* Copyright (c) 2022 Fyra Labs
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/

/**
 * TextField is a {@link Gtk.Entry} subclass that is meant to be used in
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
 public class He.TextField : Gtk.Entry {
    /**
     * Whether or not text is considered valid input
     */
    public bool is_valid { get; set; default = false; }
    public int min_length { get; set; default = 0; }
    public Regex regex { get; construct set; default = null; }

    public TextField.from_regex (Regex regex_arg) {
        Object (regex: regex_arg);
    }

    private void check_validity () {
        is_valid = get_text_length () >= min_length;

        if (is_valid && regex != null) {
            is_valid = regex.match (text);
        }
    }

    construct {
        activates_default = true;
        add_css_class ("text-field");

        changed.connect (() => {
            check_validity ();
        });

        changed.connect_after (() => {
            if (text == "") {
                secondary_icon_name = null;
                remove_css_class ("tf-error");
                remove_css_class ("tf-success");
            } else if (is_valid) {
                secondary_icon_name = "process-completed-symbolic";
                remove_css_class ("tf-error");
                add_css_class ("tf-success");
            } else {
                secondary_icon_name = "process-error-symbolic";
                add_css_class ("tf-error");
            }
        });
    }
}