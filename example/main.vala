int main (string[] argv) {
    // Create a new application
    var app = new He.Application ();
    app.activate.connect (() => {
        var window = new Gtk.ApplicationWindow (app);

        var fill_btn = new He.FillButton ("Fill");
        fill_btn.clicked.connect (() => {
            fill_btn.color = He.Colors.RED;
        });

        var tint_btn = new He.TintButton ("Tint");
        tint_btn.clicked.connect (() => {
            tint_btn.color = He.Colors.ORANGE;
        });
        
        var outline_btn = new He.OutlineButton ("Outline");
        outline_btn.clicked.connect (() => {
            outline_btn.color = He.Colors.YELLOW;
        });

        var text_btn = new He.TextButton ("Text");
        text_btn.clicked.connect (() => {
            text_btn.color = He.Colors.BLUE;
        });
        
        var pill_btn = new He.PillButton ("Pill");
        pill_btn.clicked.connect (() => {
            pill_btn.color = He.Colors.INDIGO;
        });

        var disclosure_btn = new He.DisclosureButton ("list-add-symbolic");

        var iconic_button = new He.IconicButton ("list-add-symbolic");

        var overlay_btn = new He.OverlayButton("list-add-symbolic", "nya!", "list-add-symbolic");
        overlay_btn.secondary_color = He.Colors.PURPLE;

        overlay_btn.clicked.connect (() => {
            overlay_btn.color = He.Colors.PURPLE;
        });

        overlay_btn.secondary_clicked.connect (() => {
            overlay_btn.secondary_color = He.Colors.BLUE;
        });

        var viewtitle = new He.ViewTitle ("Helium Demo");

		var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
		box.append (viewtitle);
		
		var btn_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);
		btn_box.vexpand = true;
		btn_box.margin_start = btn_box.margin_end = btn_box.margin_bottom = 18;
		btn_box.append (fill_btn);
		btn_box.append (tint_btn);
		btn_box.append (outline_btn);
		btn_box.append (text_btn);
		btn_box.append (pill_btn);
        btn_box.append (iconic_button);
        btn_box.append (disclosure_btn);
		
		box.append (btn_box);
        
        overlay_btn.child = box;

        var iconic_button_1 = new He.IconicButton ("list-add-symbolic");
        var iconic_button_2 = new He.IconicButton ("list-add-symbolic");

        var iconic_button_3 = new He.IconicButton ("list-add-symbolic");
		
        var bottom_bar = new He.BottomBar ("Example", "Nekos are cute!");
        bottom_bar.append_button (iconic_button_1, He.BottomBar.Position.LEFT);
        bottom_bar.append_button (iconic_button_2, He.BottomBar.Position.LEFT);

        bottom_bar.append_button (iconic_button_3, He.BottomBar.Position.RIGHT);


        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.append(overlay_btn);
        main_box.append(bottom_bar);

		var title = new He.AppBar (true);

        window.set_child (main_box);
        window.set_size_request (360, 360);
        window.set_titlebar (title);
        window.present ();
    });

    return app.run (argv);
}
