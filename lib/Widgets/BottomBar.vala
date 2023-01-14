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
 * A BottomBar is a toolbar made to make actions on content more visible.
 * It may have up to 5 actions on each side.
 * It has title and description labels, which can be part of a menu's label.
 */
public class He.BottomBar : He.Bin, Gtk.Buildable {
  private Gtk.Box box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
  private Gtk.Box left_fmenu_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 18);
  private Gtk.Box right_fmenu_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 18);

  private Gtk.Box left_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 18);
  private Gtk.Box center_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
  private Gtk.Box right_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 18);

  private Gtk.Label title_label = new Gtk.Label ("");
  private Gtk.Label description_label = new Gtk.Label ("");

  private Gtk.MenuButton menu = new Gtk.MenuButton ();
  private Gtk.MenuButton fold_menu = new Gtk.MenuButton ();

  private Gtk.Popover fmenu = new Gtk.Popover ();
  private Gtk.Box fmenu_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
  private Gtk.Box fmenu_box_l = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
  private Gtk.Box fmenu_box_r = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
  private Gtk.Separator fmenu_separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
  private Gtk.Image fmenu_image = new Gtk.Image ();
  private Gee.HashMap<Gtk.Widget, Gtk.Widget> button_to_mbutton = new Gee.HashMap<Gtk.Widget, Gtk.Widget> ();

  /**
   * The title of the bottom bar.
   */
  public string title {
    get { return title_label.get_text (); }
    set { title_label.set_text (value); }
  }

  /**
   * The description of the bottom bar.
   */
  public string description {
    get { return description_label.get_text (); }
    set { description_label.set_text (value); }
  }

  /**
   * The menu_model of the bottom bar.
   * If a menu_model is set, show it on the center widget of the bottom bar.
   */
  public GLib.MenuModel menu_model {
    get { 
        return menu.get_menu_model ();
    }
    set { 
      menu.set_menu_model (value);

      if (value != null) {
        if (this.center_box != null) {
          var childs = this.center_box.get_first_child ();
          while (childs != null) {
            childs.unparent ();
            childs = this.center_box.get_first_child ();
          }
        }

        center_box.append (menu);

        var menu_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        menu_box.append (title_label);
        menu_box.append (description_label);

        var menu_image = new Gtk.Image ();
        menu_image.set_from_icon_name ("pan-up-symbolic");
        menu_image.set_pixel_size (10);

        var menu_arrow_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
        menu_arrow_box.append (menu_box);
        menu_arrow_box.append (menu_image);

        menu.set_child (menu_arrow_box);
        menu.set_direction (Gtk.ArrowType.UP);
        menu.halign = Gtk.Align.CENTER;
        menu.valign = Gtk.Align.CENTER;
        menu.add_css_class ("flat");
      } else {
        this.center_box.remove (menu);
        this.center_box.append(title_label);
        this.center_box.append(description_label);
      }
    }
  }

  private Gtk.Widget create_menu_button(Gtk.Widget child) {
    var child_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
    var child_image = new Gtk.Image ();
    child_image.set_from_icon_name (((Gtk.Button)child).get_icon_name ());
    var child_label = new Gtk.Label (child.get_tooltip_text ());
    child_box.append (child_image);
    child_box.append (child_label);

    var child_button = new Gtk.Button ();
    child_button.add_css_class ("flat");
    child_button.set_child (child_box);

    return child_button;
  }

  /**
   * Whether to collapse actions into a menu.
   */
  private bool _collapse_actions;
  public bool collapse_actions {
    get { return _collapse_actions; }
    set {
      // TODO: Refactor this thing
      _collapse_actions = value;

      if (_collapse_actions) {
        this.box.remove(left_box);
        this.box.prepend(left_fmenu_box);

        this.box.remove(right_box);
        this.box.append(right_fmenu_box);
      } else {
        this.box.remove(left_fmenu_box);
        this.box.prepend(left_box);

        this.box.remove(right_fmenu_box);
        this.box.append(right_box);
      }
    }
  }

  /**
   * An enum to define the position of the bottom bar actions.
   */
  public enum Position {
    LEFT,
    RIGHT,
  }

  /**
   * Add a child to the bottombar, should only be used in the context of a UI or Blueprint file. There should be no need to use this method in code.
   */
  public new void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
      if (type == "left") {
        this.append_button((He.IconicButton)child, Position.LEFT);
      } else if (type == "right") {
        this.append_button((He.IconicButton)child, Position.RIGHT);
      } else {
        this.append_button((He.IconicButton)child, Position.LEFT);
      }
  }

  /**
   * Create a new bottom bar.
   * @param title The title of the bottom bar.
   * @param description The description of the bottom bar.
   */
  public BottomBar.with_details (string title, string description) {
    base ();
    this.title = title;
    this.description = description;
  }

  /**
   * Create a new bottom bar.
   */
  public BottomBar () {
  	base ();
  }

  static construct {
    set_layout_manager_type (typeof (Gtk.BoxLayout));
  }
  
  construct {
    this.title_label.add_css_class ("title");
    this.description_label.add_css_class ("dim-label");
    this.add_css_class ("bottom-bar");

    this.center_box.homogeneous = true;
    this.center_box.hexpand = true;
    this.center_box.margin_start = this.center_box.margin_end = 18;
    this.center_box.append(title_label);
    this.center_box.append(description_label);

    box.append(left_box);
    box.append(center_box);
    box.append(right_box);

    fold_menu.set_direction (Gtk.ArrowType.UP);
    fold_menu.halign = Gtk.Align.CENTER;
    fold_menu.valign = Gtk.Align.CENTER;
    fold_menu.add_css_class ("flat");

    fmenu_image.set_from_icon_name ("view-more-symbolic");
    fmenu_image.set_pixel_size (16);
    fold_menu.set_child (fmenu_image);

    fmenu_box.append (fmenu_box_l);
    fmenu_box.append (fmenu_separator);
    fmenu_box.append (fmenu_box_r);

    fmenu.set_child (fmenu_box);
    fold_menu.set_popover (fmenu);

    left_fmenu_box.append(fold_menu);

    box.set_parent (this);
  }

  /**
   * Add an action to the bottom bar on the end of the bar.
   * @param icon The iconicbutton of the action.
   * @param position The position of the action.
   */
  public void append_button(He.IconicButton icon, Position position) {
    var box = position == Position.LEFT ? left_box : right_box;
    var fmenu_box = position == Position.LEFT ? fmenu_box_l : fmenu_box_r;

    var menu_button = create_menu_button(icon);

    box.append(icon);
    fmenu_box.append(menu_button);

    button_to_mbutton[icon] = menu_button;
  }

  /**
   * Add an action to the bottom bar on the start of the bar.
   * @param icon The iconicbutton of the action.
   * @param position The position of the action.
   */
  public void prepend_button(He.IconicButton icon, Position position) {
    var box = position == Position.LEFT ? left_box : right_box;
    var fmenu_box = position == Position.LEFT ? fmenu_box_l : fmenu_box_r;

    var menu_button = create_menu_button(icon);

    box.prepend(icon);
    fmenu_box.prepend(menu_button);

    button_to_mbutton[icon] = menu_button;
  }

  /**
   * Remove an action of the bottom bar.
   * @param icon The iconicbutton of the action.
   * @param position The position of the action.
   */
  public void remove_button(He.IconicButton icon, Position position) {
    var box = position == Position.LEFT ? left_box : right_box;
    var fmenu_box = position == Position.LEFT ? fmenu_box_l : fmenu_box_r;

    box.remove(icon);
    fmenu_box.remove(button_to_mbutton[icon]);
    button_to_mbutton.unset(icon);
  }

  /**
   * Insert an action after another action.
   * @param icon The iconicbutton of the action.
   * @param after The iconicbutton of the action after which the action is.
   * @param position The position of the action.
   */
  public void insert_button_after(He.IconicButton icon, He.IconicButton after, Position position) {
    var box = position == Position.LEFT ? left_box : right_box;
    var fmenu_box = position == Position.LEFT ? fmenu_box_l : fmenu_box_r;

    var menu_button = create_menu_button(icon);

    box.insert_child_after(icon, after);
    fmenu_box.insert_child_after(menu_button, button_to_mbutton[after]);

    button_to_mbutton[icon] = menu_button;
  }

  /**
   * Reorder an action based on another action.
   * @param icon The iconicbutton of the action.
   * @param sibling The iconicbutton of the action after which the action is.
   * @param position The position of the action.
   *
     * @since 1.0
     */
  public void reorder_button_after(He.IconicButton icon, He.IconicButton sibling, Position position) {
    var box = position == Position.LEFT ? left_box : right_box;
    var fmenu_box = position == Position.LEFT ? fmenu_box_l : fmenu_box_r;

    create_menu_button(icon);

    box.reorder_child_after(icon, sibling);
    fmenu_box.reorder_child_after(button_to_mbutton[icon], button_to_mbutton[sibling]);
  }
}

