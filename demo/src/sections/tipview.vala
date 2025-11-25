/*
 * Copyright (c) 2024 Fyra Labs
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
 *
 */
[GtkTemplate (ui = "/com/fyralabs/Helium1/Demo/tipview.ui")]
public class Demo.TipView : He.Bin {
    [GtkChild]
    private unowned Gtk.Box tips_box;
    [GtkChild]
    private unowned He.Button reset_btn;

    private He.TipView tip1;
    private He.TipView tip2;
    private He.TipView tip3;

    construct {
        // Tip with action button
        var tip_data1 = new He.Tip (
            "Welcome",
            "starred-symbolic",
            "Get started by exploring the features of this app.",
            "Learn More"
        );

        tip1 = new He.TipView (tip_data1, He.TipViewStyle.POPUP);
        tip1.button.clicked.connect (() => {
            tip1.visible = false;
        });
        tips_box.append (tip1);

        // Tip without action button
        var tip_data2 = new He.Tip (
            "Pro Tip",
            "lightbulb-symbolic",
            "You can use keyboard shortcuts to navigate faster.",
            null
        );

        tip2 = new He.TipView (tip_data2, He.TipViewStyle.POPUP);
        tips_box.append (tip2);

        // Another tip style
        var tip_data3 = new He.Tip (
            "Did You Know?",
            "help-info-symbolic",
            "Double-click items to open them quickly.",
            "Got It"
        );

        tip3 = new He.TipView (tip_data3, He.TipViewStyle.POPUP);
        tip3.button.clicked.connect (() => {
            tip3.visible = false;
        });
        tips_box.append (tip3);

        // Reset button
        reset_btn.clicked.connect (() => {
            tip1.visible = true;
            tip2.visible = true;
            tip3.visible = true;
        });
    }
}
