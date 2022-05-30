int main (string[] argv) {
    // Create a new application
    var app = new He.Application ();
    app.activate.connect (() => {
        // Create a new window
        var window = new Gtk.ApplicationWindow (app);

        // Create a new button
        var button = new He.FillButton ("Testing");

        // When the button is clicked, close the window
        button.clicked.connect (() => {
            button.color = He.Colors.NONE;
            //window.close ();
        });
        window.set_child (button);
        window.present ();
    });

    return app.run (argv);
}

