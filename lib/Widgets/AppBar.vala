namespace He {
    class AppBar : Gtk.Box, Gtk.Buildable {
        public Gtk.HeaderBar? title;

        private bool _flat;
        public bool flat {
            get {
                return _flat;
            }
            set {
                _flat = value;

                if (_flat) {
            		title.add_css_class ("flat");
            	} else {
            		title.remove_css_class ("flat");
            	}
            }
        }

        construct {
            title = new Gtk.HeaderBar ();
        	title.hexpand = true;

        	// Remove default gtk title here because HIG
        	var title_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        	title.set_title_widget (title_box);

        	this.append (title);
        }
    }
}
