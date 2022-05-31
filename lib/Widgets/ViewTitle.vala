class He.ViewTitle : Gtk.Box {
	public ViewTitle (string title) {
		var label = new Gtk.Label ("");
	
		label.xalign = 0;
		label.add_css_class ("view-title");
		label.set_label (title);
		label.margin_top = 6;
		label.margin_start = label.margin_end = 18;
		label.margin_bottom = 12;
		
		this.append (label);
	}
}
