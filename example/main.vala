int main (string[] argv) {
    // Create a new application
    var app = new Gtk.Application ("com.tauos.libhelium-example",
                                   GLib.ApplicationFlags.FLAGS_NONE);
    var desktop = new He.Desktop();
    if (desktop.prefers_color_scheme == He.Desktop.ColorScheme.DARK) {
        print("Dark!");
    };

    app.activate.connect (() => {
        var window = new Gtk.ApplicationWindow (app);

        var fill_btn = new He.FillButton ("Fill");
        fill_btn.clicked.connect (() => {
            fill_btn.color = He.Colors.RED;
        });

        var tint_btn = new He.TintButton ("Tint");
        tint_btn.clicked.connect (() => {
            tint_btn.color = He.Colors.GREEN;
        });

		var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);
		box.hexpand = false;
		box.margin_top = box.margin_start = box.margin_end = box.margin_bottom = 18;
		box.append (fill_btn);
		box.append (tint_btn);

        window.set_child (box);
        window.set_title ("Helium Demo");
        window.set_size_request (360, 360);
        window.present ();

        desktop.notify["prefers-color-scheme"].connect (() => {
    		Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = desktop.prefers_color_scheme == He.Desktop.ColorScheme.DARK;
		});
    });

    return app.run (argv);
}
