public class He.Application : Gtk.Application {
  private void init () {
    // He.init ();
    // Ensure that the app has the basics (Gtk and theming) initialized.
    Gtk.init ();
    init_style_providers();
    
    // Ensure all classes listed here are available for use.
    // Remove only if the class is not needed anymore.
    typeof (He.AppBar).ensure ();
    typeof (He.ApplicationWindow).ensure ();
    typeof (He.Badge).ensure ();
    typeof (He.BottomBar).ensure ();
    typeof (He.Button).ensure ();
    typeof (He.Chip).ensure ();
    typeof (He.Colors).ensure ();
    typeof (He.ContentBlock).ensure ();
    typeof (He.ContentBlockImage).ensure ();
    typeof (He.ContentBlockImageCluster).ensure ();
    typeof (He.ContentList).ensure ();
    typeof (He.Desktop).ensure ();
    typeof (He.Dialog).ensure ();
    typeof (He.DisclosureButton).ensure ();
    typeof (He.EmptyPage).ensure ();
    typeof (He.FillButton).ensure ();
    typeof (He.IconicButton).ensure ();
    typeof (He.MiniContentBlock).ensure ();
    typeof (He.ModifierBadge).ensure ();
    typeof (He.OutlineButton).ensure ();
    typeof (He.OverlayButton).ensure ();
    typeof (He.PillButton).ensure ();
    typeof (He.SideBar).ensure ();
    typeof (He.TextButton).ensure ();
    typeof (He.TintButton).ensure ();
    typeof (He.Toast).ensure ();
    typeof (He.View).ensure ();
    typeof (He.ViewAux).ensure ();
    typeof (He.ViewMono).ensure ();
    typeof (He.ViewDual).ensure ();
    typeof (He.ViewSubTitle).ensure ();
    typeof (He.ViewSwitcher).ensure ();
    typeof (He.ViewTitle).ensure ();
    typeof (He.WelcomeScreen).ensure ();
    typeof (He.Window).ensure ();
  }
  
  private void init_style_providers() {
    // Setup the platform gtk theme, cursor theme and the default icon theme.

    // Gdk.Display.get_default() isn't instantiable, so we can't use it multiple times. Make a variable for it.
    var gdk_display = Gdk.Display.get_default();
    Gtk.Settings.get_for_display(gdk_display).gtk_theme_name = "Empty";
    Gtk.Settings.get_for_display(gdk_display).gtk_icon_theme_name = "Hydrogen";
    Gtk.Settings.get_for_display(gdk_display).gtk_cursor_theme_name = "Hydrogen";

    // Setup the dark preference theme loading
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

    /**
     * Load the custom css of the application (if any.)
     *
     * This is useful for overriding the base theme. For example,
     * to override the default theme of the He.Application, you
     * can create a file called style.css (or style-dark.css) in the 
     * application's data folder, and gresource it. This file will
     * be loaded by the application. The file name is based on the
     * color scheme preference. For example, if the user prefers the
     * dark color scheme, the file name is style-dark.css.
     */
    var base_path = this.get_resource_base_path ();
    if (base_path == null) return;

    string base_uri = "resource://" + base_path;
    File base_file = File.new_for_uri (base_uri);
    
    var base_provider = new Gtk.CssProvider ();

    init_provider_from_file (base_provider, base_file.get_child ("style.css"));
    init_provider_from_file (base_provider, base_file.get_child ("style-dark.css"));
    
    if (base_style_provider != null)
    this.get_style_context ().add_provider_for_display (gdk_display,
                              base_provider,
                              999);
  }

  private void init_provider_from_file (Gtk.CssProvider provider, File file) {
    if (file.query_exists (null)) {
      var provider_from_file = new Gtk.CssProvider ();
      provider_from_file.load_from_file (file);
    }
  }

  construct {
    this.startup.connect(() => {
      init ();
    });
  }
}
