class He.Application : Gtk.Application {
  private void init_style_providers() {
    var light = new Gtk.CssProvider();
    light.load_from_resource("/co/tauos/helium/gtk.css");
    
    var dark = new Gtk.CssProvider();
    dark.load_from_resource("/co/tauos/helium/gtk-dark.css");
    
    Gtk.StyleContext.add_provider_for_display(Gdk.Display.get_default (), dark, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
  }

  construct {
    this.startup.connect(() => {
      init_style_providers();
    });
  }
}

