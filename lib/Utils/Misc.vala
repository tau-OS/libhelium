namespace He.Misc {
  public T find_ancestor_of_type<T> (Gtk.Widget? widget) {
    while ((widget = widget.get_parent ()) != null) {
      if (widget.get_type ().is_a (typeof (T)))
        return (T) widget;
    }

    return null;
  }
}