/**
 * A BottomBar is a toolbar made to make actions on content more visible.
 * It may have up to 5 actions on each side.
 * It has title and description labels, which can be part of a menu's label.
 */
public class He.BottomBar : He.Bin, Gtk.Buildable {
  private Gtk.Box left_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 18);
  private Gtk.Box center_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
  private Gtk.Box right_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 18);

  private Gtk.Label title_label = new Gtk.Label (null);
  private Gtk.Label description_label = new Gtk.Label (null);

  private Gtk.MenuButton menu = new Gtk.MenuButton ();

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
  public void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
      if (strcmp (type, "left") == 0) {
        left_box.append ((Gtk.Widget)child);
      } else if (strcmp (type, "right") == 0) {
        right_box.append ((Gtk.Widget)child);
      } else {
        left_box.append ((Gtk.Widget)child);
      }
  }

  /**
   * Create a new bottom bar.
   * @param title The title of the bottom bar.
   * @param description The description of the bottom bar.
   */
  public BottomBar(string title, string description) {
    this.title = title;
    this.description = description;
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

    var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
    box.append(left_box);
    box.append(center_box);
    box.append(right_box);

    box.set_parent (this);
  }

  /**
   * Add an action to the bottom bar on the end of the bar.
   * @param icon The iconicbutton of the action.
   * @param position The position of the action.
   */
  public void append_button(He.IconicButton icon, Position position) {
    var box = position == Position.LEFT ? left_box : right_box;
    box.append(icon);
  }

  /**
   * Add an action to the bottom bar on the start of the bar.
   * @param icon The iconicbutton of the action.
   * @param position The position of the action.
   */
  public void prepend_button(He.IconicButton icon, Position position) {
    var box = position == Position.LEFT ? left_box : right_box;
    box.prepend(icon);
  }

  /**
   * Remove an action of the bottom bar.
   * @param icon The iconicbutton of the action.
   * @param position The position of the action.
   */
  public void remove_button(He.IconicButton icon, Position position) {
    var box = position == Position.LEFT ? left_box : right_box;
    box.remove(icon);
  }

  /**
   * Insert an action after another action.
   * @param icon The iconicbutton of the action.
   * @param after The iconicbutton of the action after which the action is.
   * @param position The position of the action.
   */
  public void insert_button_after(He.IconicButton icon, He.IconicButton after, Position position) {
    var box = position == Position.LEFT ? left_box : right_box;
    box.insert_child_after(icon, after);
  }

  /**
   * Reorder an action based on another action.
   * @param icon The iconicbutton of the action.
   * @param after The iconicbutton of the action after which the action is.
   * @param position The position of the action.
   */
  public void reorder_button_after(He.IconicButton icon, He.IconicButton after, Position position) {
    var box = position == Position.LEFT ? left_box : right_box;
    box.insert_child_after(icon, after);
  }
}
