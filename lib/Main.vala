/*
 * Copyright (c) 2022 Fyra Labs
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA
 */

namespace He {
    public void init () {
        // Ensure Gtk is properly initialized
        Gtk.init ();

        // Ensure all classes listed here are available for use.
        // Remove only if the class is not needed anymore.
        typeof (He.AboutWindow).ensure ();
        typeof (He.AppBar).ensure ();
        typeof (He.Application).ensure ();
        typeof (He.ApplicationWindow).ensure ();
        typeof (He.Avatar).ensure ();
        typeof (He.Badge).ensure ();
        typeof (He.Bin).ensure ();
        typeof (He.BottomBar).ensure ();
        typeof (He.BottomSheet).ensure ();
        typeof (He.Button).ensure ();
        typeof (He.ButtonContent).ensure ();
        typeof (He.Card).ensure ();
        typeof (He.Chip).ensure ();
        typeof (He.ChipGroup).ensure ();
        typeof (He.Colors).ensure ();
        typeof (He.ContentBlock).ensure ();
        typeof (He.ContentBlockImage).ensure ();
        typeof (He.ContentBlockImageCluster).ensure ();
        typeof (He.ContentList).ensure ();
        typeof (He.Contrast).ensure ();
        typeof (He.ContrastCurve).ensure ();
        typeof (He.DatePicker).ensure ();
        typeof (He.Desktop).ensure ();
        typeof (He.Dialog).ensure ();
        typeof (He.Divider).ensure ();
        typeof (He.Dropdown).ensure ();
        typeof (He.DynamicColor).ensure ();
        typeof (He.DynamicScheme).ensure ();
        typeof (He.EmptyPage).ensure ();
        typeof (He.KeyColor).ensure ();
        typeof (He.MiniContentBlock).ensure ();
        typeof (He.ModifierBadge).ensure ();
        typeof (He.NavigationRail).ensure ();
        typeof (He.NavigationSection).ensure ();
        typeof (He.OverlayButton).ensure ();
        typeof (He.ProgressBar).ensure ();
        typeof (He.Quantizer).ensure ();
        typeof (He.QuantizerCelebi).ensure ();
        typeof (He.QuantizerMap).ensure ();
        typeof (He.QuantizerMap).ensure ();
        typeof (He.QuantizerResult).ensure ();
        typeof (He.QuantizerWsmeans).ensure ();
        typeof (He.QuantizerWu).ensure ();
        typeof (He.Scheme).ensure ();
        typeof (He.Score).ensure ();
        typeof (He.SegmentedButton).ensure ();
        typeof (He.SettingsList).ensure ();
        typeof (He.SettingsPage).ensure ();
        typeof (He.SettingsRow).ensure ();
        typeof (He.SettingsWindow).ensure ();
        typeof (He.SideBar).ensure ();
        typeof (He.Slider).ensure ();
        typeof (He.Switch).ensure ();
        typeof (He.SwitchBar).ensure ();
        typeof (He.Tab).ensure ();
        typeof (He.TabPage).ensure ();
        typeof (He.TabSwitcher).ensure ();
        typeof (He.TemperatureCache).ensure ();
        typeof (He.TextField).ensure ();
        typeof (He.TimePicker).ensure ();
        typeof (He.Tip).ensure ();
        typeof (He.TipView).ensure ();
        typeof (He.TipViewStyle).ensure ();
        typeof (He.Toast).ensure ();
        typeof (He.TonalPalette).ensure ();
        typeof (He.ToneDeltaPair).ensure ();
        typeof (He.TonePolarity).ensure ();
        typeof (He.View).ensure ();
        typeof (He.ViewAux).ensure ();
        typeof (He.ViewChooser).ensure ();
        typeof (He.ViewDual).ensure ();
        typeof (He.ViewingConditions).ensure ();
        typeof (He.ViewMono).ensure ();
        typeof (He.ViewSubTitle).ensure ();
        typeof (He.ViewSwitcher).ensure ();
        typeof (He.ViewTitle).ensure ();
        typeof (He.WelcomeScreen).ensure ();
        typeof (He.Window).ensure ();

        // Setup gettext
        Intl.bindtextdomain (Config.GETTEXT_PACKAGE, Config.LOCALEDIR);
        Intl.bind_textdomain_codeset (Config.GETTEXT_PACKAGE, "UTF-8");
    }
}