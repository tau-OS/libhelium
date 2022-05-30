class He.Application : Gtk.Application {
  construct {
    var light = new Gtk.CssProvider();
    light.load_from_resource("/co/tauos/helium/gtk.css");
    Gtk.StyleContext.add_provider_for_display(Gdk.Display.get_default (), light, Gtk.STYLE_PROVIDER_PRIORITY_THEME);
  }
}
