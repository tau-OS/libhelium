public class He.Application : Gtk.Application {
  private void init_style_providers() {
    Gtk.Settings.get_for_display(Gdk.Display.get_default()).gtk_theme_name = "Empty";
    Gtk.Settings.get_for_display(Gdk.Display.get_default()).gtk_icon_theme_name = "Hydrogen";
    Gtk.Settings.get_for_display(Gdk.Display.get_default()).gtk_cursor_theme_name = "Hydrogen";

    var light = new Gtk.CssProvider();
    light.load_from_resource("/co/tauos/helium/gtk.css");

    var dark = new Gtk.CssProvider();
    dark.load_from_resource("/co/tauos/helium/gtk-dark.css");

    var desktop = new He.Desktop ();
    if (desktop.prefers_color_scheme == He.Desktop.ColorScheme.DARK) {
	    Gtk.StyleContext.add_provider_for_display(Gdk.Display.get_default (), dark, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
	  } else {
		  Gtk.StyleContext.add_provider_for_display(Gdk.Display.get_default (), light, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
	  };

    desktop.notify["prefers-color-scheme"].connect (() => {
		  if (desktop.prefers_color_scheme == He.Desktop.ColorScheme.DARK) {
		    Gtk.StyleContext.add_provider_for_display(Gdk.Display.get_default (), dark, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
		  } else {
			  Gtk.StyleContext.add_provider_for_display(Gdk.Display.get_default (), light, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
		  };
	  });
  }

  construct {
    this.startup.connect(() => {
      init_style_providers();
    });
  }
}

