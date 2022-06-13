/**
* An ApplicationWindow is a Window for holding the main content of an application.
*/
public class He.ApplicationWindow : He.Window, GLib.ActionGroup, GLib.ActionMap, Gtk.Buildable {
    /**
    * Creates a new ApplicationWindow.
    * @param application The application associated with this window.
    */
    public ApplicationWindow (He.Application app) {
        Object (application: app);
    }

    construct {
    }
}
