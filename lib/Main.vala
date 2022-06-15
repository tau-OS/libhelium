namespace He {
    private void init () {
        // Ensure that the app has Gtk initialized.
        Gtk.init ();
    
        // Ensure all classes listed here are available for use.
        // Remove only if the class is not needed anymore.
        typeof (He.Application).ensure ();
        typeof (He.AboutWindow).ensure ();
        typeof (He.Album).ensure ();
        typeof (He.AlbumPage).ensure ();
        typeof (He.AlbumPageInterface).ensure ();
        typeof (He.AppBar).ensure ();
        typeof (He.ApplicationWindow).ensure ();
        typeof (He.Badge).ensure ();
        typeof (He.Bin).ensure ();
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
        typeof (He.ViewDual).ensure ();
        typeof (He.ViewMono).ensure ();
        typeof (He.ViewSubTitle).ensure ();
        typeof (He.ViewSwitcher).ensure ();
        typeof (He.ViewTitle).ensure ();
        typeof (He.WelcomeScreen).ensure ();
        typeof (He.Window).ensure ();
    
        // Setup the platform gtk theme, cursor theme and the default icon theme.
        Gtk.Settings.get_for_display(Gdk.Display.get_default()).gtk_theme_name = "Empty";
        Gtk.Settings.get_for_display(Gdk.Display.get_default()).gtk_icon_theme_name = "Hydrogen";
        Gtk.Settings.get_for_display(Gdk.Display.get_default()).gtk_cursor_theme_name = "Hydrogen";
        Gtk.Settings.get_for_display(Gdk.Display.get_default()).gtk_font_name = "Manrope";
    }
}
