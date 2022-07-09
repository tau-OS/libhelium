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

/**
 * A namespace of functions for working with the Desktop Portal.
 *
     * @since 1.0
     */
namespace He.Portal {
    private const string DBUS_DESKTOP_PATH = "/org/freedesktop/portal/desktop";
    private const string DBUS_DESKTOP_NAME = "org.freedesktop.portal.Desktop";

    [DBus (name = "org.freedesktop.portal.Settings")]
    interface Settings : Object {
        public static Settings @get () throws Error {
            return Bus.get_proxy_sync (
                BusType.SESSION,
                DBUS_DESKTOP_NAME,
                DBUS_DESKTOP_PATH,
                DBusProxyFlags.NONE
            );
        }

        public abstract HashTable<string, HashTable<string, Variant>> read_all (string[] namespaces) throws DBusError, IOError;
        public abstract Variant read (string namespace, string key) throws DBusError, IOError;

        public signal void setting_changed (string namespace, string key, Variant val);
    }
}
