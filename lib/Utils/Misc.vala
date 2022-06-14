/**
 * Miscellaneous functions
 */
namespace He.Misc {
  /**
   * An useful method for finding an ancestor of a given widget.
   * @param widget The widget to find the ancestor of.
   */
  public T find_ancestor_of_type<T> (Gtk.Widget? widget) {
    while ((widget = widget.get_parent ()) != null) {
      if (widget.get_type ().is_a (typeof (T)))
        return (T) widget;
    }

    return null;
  }
}