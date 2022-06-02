public class He.ContentBlockImage : Gtk.Widget, Gtk.Buildable {
    private string _file;
    private int _requested_height;
    private int _requested_width;

    public string file {
        get {
            return _file;
        }
        set {
            _file = value;

            var css_provider = new Gtk.CssProvider ();
            css_provider.load_from_data (".content-block-image { background-image: url('%s'); background-size: cover; }".printf(_file).data);
            var context = this.get_style_context ();
            context.add_provider (css_provider, 69);
        }
    }

    public int requested_height {
        get {
            return _requested_height;
        }
        set {
            _requested_height = value;
            this.set_size_request (this.requested_width == 0 ? -1 : this.requested_width, value);
        }
    }

    public int requested_width {
        get {
            return _requested_width;
        }
        set {
            _requested_width = value;
            this.set_size_request (value, this.requested_height == 0 ? -1 : this.requested_height);
        }
    }

    construct {
        this.requested_width = -1; 
        this.requested_height = 300; 
        this.add_css_class("content-block-image");
    }

    ContentBlockImage(string file) {
        this.file = file;
    }
}