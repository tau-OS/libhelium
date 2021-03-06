/*
* Copyright (c) 2022 Fyra Labs
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/

namespace He {
    private void init () {
        Gdk.Display display = Gdk.Display.get_default ();

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
        typeof (He.Latch).ensure ();
        typeof (He.LatchLayout).ensure ();
        typeof (He.MiniContentBlock).ensure ();
        typeof (He.ModifierBadge).ensure ();
        typeof (He.OutlineButton).ensure ();
        typeof (He.OverlayButton).ensure ();
        typeof (He.PillButton).ensure ();
        typeof (He.SideBar).ensure ();
        typeof (He.SettingsPage).ensure ();
        typeof (He.SettingsWindow).ensure ();
        typeof (He.Tab).ensure ();
        typeof (He.TabPage).ensure ();
        typeof (He.TabSwitcher).ensure ();
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
        Gtk.Settings.get_for_display(display).gtk_theme_name        = "Empty";
        Gtk.Settings.get_for_display(display).gtk_icon_theme_name   = "Hydrogen";
        Gtk.Settings.get_for_display(display).gtk_cursor_theme_name = "Hydrogen";
        Gtk.Settings.get_for_display(display).gtk_font_name         = "Manrope 10";
    }
}
