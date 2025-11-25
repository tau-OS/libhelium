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
[GtkTemplate (ui = "/com/fyralabs/Helium1/Demo/groupedbutton.ui")]
public class Demo.GroupedButton : He.Bin {
    [GtkChild]
    private unowned Gtk.Box grouped_box;

    construct {
        // Small grouped button - text formatting
        var grouped_small = new He.GroupedButton.with_size (He.GroupedButtonSize.SMALL);
        var btn_bold = new He.Button ("format-text-bold-symbolic", "");
        btn_bold.is_fill = true;
        btn_bold.toggle_mode = true;
        var btn_italic = new He.Button ("format-text-italic-symbolic", "");
        btn_italic.is_fill = true;
        btn_italic.toggle_mode = true;
        var btn_underline = new He.Button ("format-text-underline-symbolic", "");
        btn_underline.is_fill = true;
        btn_underline.toggle_mode = true;
        var btn_strike = new He.Button ("format-text-strikethrough-symbolic", "");
        btn_strike.is_fill = true;
        btn_strike.toggle_mode = true;
        grouped_small.add_widget (btn_bold);
        grouped_small.add_widget (btn_italic);
        grouped_small.add_widget (btn_underline);
        grouped_small.add_widget (btn_strike);
        grouped_box.append (grouped_small);

        // Medium grouped button - view mode
        var grouped_medium = new He.GroupedButton.with_size (He.GroupedButtonSize.MEDIUM);
        var btn_grid = new He.Button ("view-grid-symbolic", "");
        btn_grid.is_fill = true;
        btn_grid.toggle_mode = true;
        btn_grid.active = true;
        var btn_list = new He.Button ("view-list-symbolic", "");
        btn_list.is_fill = true;
        btn_list.toggle_mode = true;
        grouped_medium.add_widget (btn_grid);
        grouped_medium.add_widget (btn_list);
        grouped_box.append (grouped_medium);

        // Large grouped button
        var grouped_large = new He.GroupedButton.with_size (He.GroupedButtonSize.LARGE);
        var btn_prev = new He.Button ("go-previous-symbolic", "");
        btn_prev.is_fill = true;
        var btn_play = new He.Button ("media-playback-start-symbolic", "");
        btn_play.is_fill = true;
        var btn_next = new He.Button ("go-next-symbolic", "");
        btn_next.is_fill = true;
        grouped_large.add_widget (btn_prev);
        grouped_large.add_widget (btn_play);
        grouped_large.add_widget (btn_next);
        grouped_box.append (grouped_large);

        // Segmented style - calendar view
        var grouped_segmented = new He.GroupedButton.with_size (He.GroupedButtonSize.MEDIUM);
        grouped_segmented.segmented = true;
        var seg_day = new He.Button ("", "Day");
        seg_day.is_fill = true;
        seg_day.toggle_mode = true;
        seg_day.active = true;
        var seg_week = new He.Button ("", "Week");
        seg_week.is_fill = true;
        seg_week.toggle_mode = true;
        var seg_month = new He.Button ("", "Month");
        seg_month.is_fill = true;
        seg_month.toggle_mode = true;
        var seg_year = new He.Button ("", "Year");
        seg_year.is_fill = true;
        seg_year.toggle_mode = true;
        grouped_segmented.add_widget (seg_day);
        grouped_segmented.add_widget (seg_week);
        grouped_segmented.add_widget (seg_month);
        grouped_segmented.add_widget (seg_year);
        grouped_box.append (grouped_segmented);
    }
}
