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
[GtkTemplate (ui = "/com/fyralabs/Helium1/Demo/progressbar.ui")]
public class Demo.ProgressBar : He.Bin {
    [GtkChild]
    private unowned Gtk.Box progressbar_box;
    [GtkChild]
    private unowned Gtk.Label progress_label;
    [GtkChild]
    private unowned He.Slider progress_slider;

    private He.ProgressBar standard_progress;
    private He.ProgressBar wavy_progress;
    private He.ProgressBar osd_progress;

    construct {
        // Standard ProgressBar
        standard_progress = new He.ProgressBar ();
        standard_progress.progress = 0.5;
        standard_progress.hexpand = true;
        progressbar_box.append (standard_progress);

        // Wavy ProgressBar
        wavy_progress = new He.ProgressBar ();
        wavy_progress.progress = 0.3;
        wavy_progress.is_wavy = true;
        wavy_progress.animate = true;
        wavy_progress.hexpand = true;
        progressbar_box.append (wavy_progress);

        // OSD ProgressBar
        osd_progress = new He.ProgressBar ();
        osd_progress.progress = 0.7;
        osd_progress.is_osd = true;
        osd_progress.hexpand = true;
        progressbar_box.append (osd_progress);

        // Setup slider to control progress
        progress_slider.set_range (0, 100);
        progress_slider.value = 50;
        progress_slider.hexpand = true;
        progress_slider.value_changed.connect (() => {
            double val = progress_slider.value / 100.0;
            standard_progress.progress = val;
            wavy_progress.progress = val;
            osd_progress.progress = val;
            progress_label.label = "Progress: %.0f%%".printf (progress_slider.value);
        });
    }
}
