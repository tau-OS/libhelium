namespace He {
    class AppBar : Gtk.Box {
        private bool flat { get; set; }

        public AppBar (bool flat) {
        	var title = new Gtk.HeaderBar ();
        	title.hexpand = true;

        	// Remove default gtk title here because HIG
        	var title_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        	title.set_title_widget (title_box);

        	this.flat = flat;

        	if (flat) {
        		title.add_css_class ("flat");
        	} else {
        		title.remove_css_class ("flat");
        	}

        	this.append (title);
        }
    }
}
