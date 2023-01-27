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
 public class He.TextField : He.Bin {
    /**
     * Whether or not text is considered valid input
     */
    public bool is_valid { get; set; default = false; }
    public bool needs_validation { get; set; default = false; }
    public int min_length { get; set; default = 0; }
    public string support_text { get; set; default = null; }
    public Regex regex { get; construct set; default = null; }
    
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
    
    private bool _visibility;
    public bool visibility { 
      get {
         return _visibility;
      }
      set {
         _visibility = value;
         this.visible = value;
      }
    }
    
    private Gtk.Entry entry = new Gtk.Entry ();
    private Gtk.Label support_label;
    
    public signal void changed (); 

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
        entry.activates_default = true;
        entry.add_css_class ("text-field");
        
        support_label = new Gtk.Label (support_text);
        support_label.add_css_class ("caption");
        support_label.add_css_class ("dim-label");
        
        if(support_text == null) {
            support_label.visible = false;
        } else {
            support_label.visible = true;
        }

        changed.connect (() => {
           entry.changed.connect (() => {
               if (needs_validation)
                   check_validity ();
           });
        });

        entry.changed.connect_after (() => {
            if (needs_validation) {
                if (entry.text == "") {
                    entry.secondary_icon_name = null;
                    entry.remove_css_class ("tf-error");
                    entry.remove_css_class ("tf-success");
                } else if (is_valid) {
                    entry.secondary_icon_name = "process-completed-symbolic";
                    entry.remove_css_class ("tf-error");
                    entry.add_css_class ("tf-success");
                } else {
                    entry.secondary_icon_name = "process-error-symbolic";
                    entry.add_css_class ("tf-error");
                    entry.remove_css_class ("tf-success");
                }
            }
        });

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 4);
        main_box.hexpand = true;
        main_box.append(entry);
        main_box.append(support_label);
        
        main_box.set_parent (this);
        on_changed ();
        
        notify["placeholder-text"].connect (() => {
            entry.placeholder_text = placeholder_text;
        });
        notify["max-length"].connect (() => {
            entry.max_length = max_length;
        });
        notify["visibility"].connect (() => {
            this.visible = visibility;
        });
    }
    
    private void on_changed () {
       changed ();
    }
}
