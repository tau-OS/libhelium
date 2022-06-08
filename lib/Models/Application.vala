public class He.Application : Gtk.Application {
  private Gtk.CssProvider light = new Gtk.CssProvider ();
  private Gtk.CssProvider dark = new Gtk.CssProvider ();
  private He.Desktop desktop = new He.Desktop ();

  private void init () {
    // Ensure that the app has Gtk initialized.
    Gtk.init ();

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

    // Setup the platform gtk theme, cursor theme and the default icon theme.
    Gtk.Settings.get_for_display(Gdk.Display.get_default()).gtk_theme_name = "Empty";
    Gtk.Settings.get_for_display(Gdk.Display.get_default()).gtk_icon_theme_name = "Hydrogen";
    Gtk.Settings.get_for_display(Gdk.Display.get_default()).gtk_cursor_theme_name = "Hydrogen";
  }
  
  private void init_style_providers () {
    // Setup the dark preference theme loading
    light.load_from_resource ("/co/tauos/helium/gtk.css");
    dark.load_from_resource ("/co/tauos/helium/gtk-dark.css");

    if (desktop.prefers_color_scheme == He.Desktop.ColorScheme.DARK) {
      style_provider_set_enabled (dark, true);
      style_provider_set_enabled (light, false);
    } else {
      style_provider_set_enabled (light, true);
      style_provider_set_enabled (dark, false);
    }
    
    desktop.notify["prefers-color-scheme"].connect (() => {
      if (desktop.prefers_color_scheme == He.Desktop.ColorScheme.DARK) {
        style_provider_set_enabled (dark, true);
        style_provider_set_enabled (light, false);
      } else {
        style_provider_set_enabled (light, true);
        style_provider_set_enabled (dark, false);
      }
    });
  }

  private void init_app_providers () {
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
    var base_path = get_resource_base_path ();
    if (base_path == null) {
        return;
    }

    string base_uri = "resource://" + base_path;
    File base_file = File.new_for_uri (base_uri);
    Gtk.CssProvider base_provider;
    init_provider_from_file (out base_provider, base_file.get_child ("style.css"));
    init_provider_from_file (out base_provider, base_file.get_child ("style-dark.css"));
    
    if (base_provider != null) {
        style_provider_set_enabled (base_provider, true);
    }
  }
  
  private void style_provider_set_enabled (Gtk.CssProvider provider, bool enabled) {
    Gdk.Display display = Gdk.Display.get_default ();

    if (display == null)
      return;

    if (enabled) {
      Gtk.StyleContext.add_provider_for_display (display, provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
    } else {
      Gtk.StyleContext.remove_provider_for_display (display, provider);
    }
  }

  private void init_provider_from_file (out Gtk.StyleProvider provider, File file) {
    if (file.query_exists ()) {
        return;
    }

    provider = new Gtk.CssProvider ();
    provider.load_from_file (file);
 }
  
  protected override void startup () {
    base.startup ();
    init ();
    init_style_providers ();
    init_app_providers ();
  }
}
