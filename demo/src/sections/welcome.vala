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
[GtkTemplate (ui = "/com/fyralabs/Helium1/Demo/welcome.ui")]
public class Demo.Welcome : He.Bin {
    [GtkChild]
    private unowned He.EmptyPage empty_page;

    construct {
        empty_page.action_button.visible = false;
    }
}