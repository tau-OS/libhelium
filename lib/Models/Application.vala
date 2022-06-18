/**
 * An application.
 */
public class He.Application : Gtk.Application {
  private Gtk.CssProvider light = new Gtk.CssProvider ();
  private Gtk.CssProvider dark = new Gtk.CssProvider ();
  private He.Desktop desktop = new He.Desktop ();
  
  private void init_style_providers () {
    // Setup the dark preference theme loading
    light.load_from_resource ("/co/tauos/helium/gtk.css");
    dark.load_from_resource ("/co/tauos/helium/gtk-dark.css");

    if (desktop.prefers_color_scheme == He.Desktop.ColorScheme.DARK) {
      style_provider_set_enabled (dark, true);
      style_provider_set_enabled (light, false);
      init_app_providers ();
    } else {
      style_provider_set_enabled (light, true);
      style_provider_set_enabled (dark, false);
      init_app_providers ();
    }
    
    desktop.notify["prefers-color-scheme"].connect (() => {
      if (desktop.prefers_color_scheme == He.Desktop.ColorScheme.DARK) {
        style_provider_set_enabled (dark, true);
        style_provider_set_enabled (light, false);
        init_app_providers ();
      } else {
        style_provider_set_enabled (light, true);
        style_provider_set_enabled (dark, false);
        init_app_providers ();
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
    Gtk.CssProvider base_provider = new Gtk.CssProvider ();
    
    if (base_file.get_child ("style-dark.css").query_exists (null)) {
        if (desktop.prefers_color_scheme == He.Desktop.ColorScheme.DARK) {
            init_provider_from_file (base_provider, base_file.get_child ("style-dark.css"));
        } else {
            init_provider_from_file (base_provider, base_file.get_child ("style.css"));
        }
    } else {
        warning ("Dark Styling not found. Proceeding anyway.");
    }
    
    if (base_provider != null) {
        style_provider_set_enabled (base_provider, true);
    }
  }

  private void setup_accent_color () {
    var accent_color = desktop.accent_color;
    warning ("%s", accent_color);

    var css = @"
      @define-color accent_bg_color $accent_color;
      @define-color accent_color $accent_color;
    ";
    Gtk.CssProvider provider = new Gtk.CssProvider ();
    provider.load_from_data (css.data);
    style_provider_set_enabled (provider, true);

    desktop.notify["accent-color"].connect (() => {
        var accent_colors = desktop.accent_color;
        warning ("%s", accent_colors);
    
        var csss = @"
          @define-color accent_bg_color $accent_colors;
          @define-color accent_color $accent_colors;
        ";
        var providers = new Gtk.CssProvider ();
        providers.load_from_data (csss.data);
        style_provider_set_enabled (providers, true);
    });
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

  private void init_provider_from_file (Gtk.CssProvider provider, File file) {
    if (file.query_exists (null)) {
      provider.load_from_file (file);
    }
  }
  
  protected override void startup () {
    base.startup ();
    He.init ();
    init_style_providers ();

    setup_accent_color ();
    init_app_providers ();
  }

  public Application(string? application_id, ApplicationFlags flags) {
    this.application_id = application_id;
    this.flags = flags;
  }
}
