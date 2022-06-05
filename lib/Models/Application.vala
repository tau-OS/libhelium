public class He.Application : Gtk.Application {
  private void init () {
    // He.init ();
    // Ensure that the app has the basics
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
    Gtk.Settings.get_for_display(Gdk.Display.get_default()).gtk_theme_name = "Empty";

    var icon_theme = Gtk.IconTheme.get_for_display (Gdk.Display.get_default());
    icon_theme.set_theme_name ("Hydrogen");
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
      init ();
    });
  }
}