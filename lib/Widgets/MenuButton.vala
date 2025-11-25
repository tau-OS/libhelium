namespace He {

    /* --- Enums --- */

    public enum MenuStyle {
        DEFAULT,
        BUBBLE
    }

    public enum MenuVisual {
        DEFAULT,
        VIBRANT
    }

    /* --- Data Models --- */

    public class Item : Object {
        public string label { get; set; }
        public string? description { get; set; }
        public string? icon_name { get; set; }
        public string? shortcut { get; set; }

        public GLib.Callback? callback { get; set; }
        public string? action_name { get; set; }
        public Variant? action_target { get; set; }

        public signal void activated();

        /**
         * Standard Item with GAction support.
         * Usage: new He.Item("Label", "app.action", "icon-name", "Ctrl+X")
         */
        public Item(string label, string? action_name = null, string? icon_name = null, string? shortcut = null) {
            this.label = label;
            this.action_name = action_name;
            this.icon_name = icon_name;
            this.shortcut = shortcut;
        }

        /**
         * Item with a closure/callback.
         * Usage: new He.Item.closure("Label", () => { ... }, "icon-name")
         */
        public Item.closure(string label, GLib.Callback callback, string? icon_name = null, string? shortcut = null) {
            this.label = label;
            this.callback = callback;
            this.icon_name = icon_name;
            this.shortcut = shortcut;
        }

        /**
         * Item with a description (subtitle).
         * Usage: new He.Item.detail("Label", "Description text", "app.action")
         */
        public Item.detail(string label, string description, string? action_name = null, string? icon_name = null) {
            this.label = label;
            this.description = description;
            this.action_name = action_name;
            this.icon_name = icon_name;
        }
    }

    public class Section : Object {
        public string? title { get; set; }
        public GenericArray<Item> items { get; private set; }

        /**
         * Creates a section with a list of items.
         * Usage: new He.Section("Title", { item1, item2 })
         */
        public Section(string? title = null, Item[]? items = null) {
            this.title = title;
            this.items = new GenericArray<Item>();
            if (items != null) {
                foreach (var item in items) {
                    this.items.add(item);
                }
            }
        }

        public void add(Item item) {
            this.items.add(item);
        }
    }

    /* --- Components --- */

    public class MenuButton : Gtk.Widget {

        // --- Internal MenuButton (composition) ---
        private Gtk.MenuButton _button;

        // --- Properties ---
        private MenuStyle _menu_style = MenuStyle.DEFAULT;
        public MenuStyle menu_style {
            get { return _menu_style; }
            set { _menu_style = value; rebuild_menu(); }
        }

        private MenuVisual _visual_style = MenuVisual.DEFAULT;
        public MenuVisual visual_style {
            get { return _visual_style; }
            set { _visual_style = value; update_visuals(); }
        }

        private GLib.MenuModel? _menu_model = null;
        public GLib.MenuModel? menu_model {
            get { return _menu_model; }
            set {
                _menu_model = value;
                if (_menu_model != null) load_from_model(_menu_model);
            }
        }

        // Expose common Gtk.MenuButton properties
        public string icon_name {
            get { return _button.icon_name; }
            set { _button.icon_name = value; }
        }

        public string? label {
            get { return _button.label; }
            set { _button.label = value; }
        }

        public Gtk.Widget? child {
            get { return _button.child; }
            set { _button.child = value; }
        }

        public Gtk.Popover? popover {
            get { return _button.popover; }
            set { _button.popover = value; }
        }

        private GenericArray<Section> _sections;

        // --- Internal UI ---
        private Gtk.Popover _popover;
        private Gtk.Box _main_container;

        static construct {
            set_layout_manager_type(typeof(Gtk.BinLayout));
        }

        construct {
            _sections = new GenericArray<Section>();

            _button = new Gtk.MenuButton();
            _button.set_halign(Gtk.Align.CENTER);
            _button.get_first_child().add_css_class ("disclosure-button");
            _button.get_first_child().remove_css_class ("image-button");
            _button.get_first_child().remove_css_class ("toggle");
            _button.set_parent(this);

            _popover = new Gtk.Popover();
            _popover.autohide = true;
            _popover.has_arrow = false;
            _popover.add_css_class("menu-content");

            _main_container = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            _popover.set_child(_main_container);

            _button.popover = _popover;
            _button.icon_name = "open-menu-symbolic";

        }

        ~MenuButton() {
            _button.unparent();
        }

        /* --- Public API: Declarative Structure --- */

        /**
         * Sets the menu content using a declarative array of sections.
         * Usage:
         * menu.set_layout({
         * new He.Section("Header", { ... }),
         * new He.Section(null, { ... })
         * });
         */
        public void set_layout(Section[] sections) {
            _sections = new GenericArray<Section>();
            foreach (var s in sections) {
                _sections.add(s);
            }
            rebuild_menu();
        }

        /**
         * Legacy imperative method: Adds a single section.
         */
        public void add_section(Section section) {
            _sections.add(section);
            rebuild_menu();
        }

        /* --- Internal: GMenuModel Import --- */

        private void load_from_model(GLib.MenuModel model) {
            _sections = new GenericArray<Section>();

            int n_items = model.get_n_items();
            if (n_items == 0) { rebuild_menu(); return; }

            bool is_section_list = false;
            var link = model.get_item_link(0, GLib.Menu.LINK_SECTION);
            if (link != null) is_section_list = true;

            if (is_section_list) {
                for (int i = 0; i < n_items; i++) {
                    string? label = null;
                    model.get_item_attribute(i, GLib.Menu.ATTRIBUTE_LABEL, "s", out label);

                    var section_model = model.get_item_link(i, GLib.Menu.LINK_SECTION);
                    if (section_model != null) {
                        var sec = new Section(label);
                        fill_section_from_model(sec, section_model);
                        _sections.add(sec);
                    }
                }
            } else {
                var sec = new Section(null);
                fill_section_from_model(sec, model);
                _sections.add(sec);
            }
            rebuild_menu();
        }

        private void fill_section_from_model(Section sec, GLib.MenuModel model) {
            int n = model.get_n_items();
            for (int i = 0; i < n; i++) {
                string? label = null;
                string? icon = null;
                string? action = null;

                model.get_item_attribute(i, GLib.Menu.ATTRIBUTE_LABEL, "s", out label);
                model.get_item_attribute(i, "icon", "s", out icon);
                model.get_item_attribute(i, GLib.Menu.ATTRIBUTE_ACTION, "s", out action);

                if (label == null) label = "Unlabeled";

                var item = new Item(label, action, icon, null);

                Variant? target = model.get_item_attribute_value(i, GLib.Menu.ATTRIBUTE_TARGET, null);
                item.action_target = target;

                sec.add(item);
            }
        }

        /* --- Internal: Layout & Rendering --- */

        private void rebuild_menu() {
            Gtk.Widget? child = _main_container.get_first_child();
            while (child != null) {
                _main_container.remove(child);
                child = _main_container.get_first_child();
            }

            // Clear style classes before rebuilding
            _popover.remove_css_class("bubble");

            if (_menu_style == MenuStyle.DEFAULT) {
                build_default_layout();
            } else {
                build_bubble_layout();
            }
        }

        private void build_default_layout() {
            _main_container.spacing = 6;
            _main_container.margin_top = 6;
            _main_container.margin_bottom = 6;
            _main_container.margin_start = 6;
            _main_container.margin_end = 6;

            for (int i = 0; i < _sections.length; i++) {
                var section = _sections[i];

                if (section.title != null) {
                    var label = new Gtk.Label(section.title);
                    label.add_css_class("heading");
                    label.halign = Gtk.Align.START;
                    label.margin_start = 12;
                    label.margin_bottom = 6;
                    label.margin_top = (i > 0) ? 6 : 0;
                    _main_container.append(label);
                }

                for (int j = 0; j < section.items.length; j++) {
                    var item = section.items[j];
                    var row = create_entry_row(item);
                    _main_container.append(row);
                }

                if (i < _sections.length - 1) {
                    // Assumes He.Divider is available globally or within namespace
                    _main_container.append(new Divider());
                }
            }
        }

        private void build_bubble_layout() {
            _main_container.spacing = 6;
            _main_container.margin_top = 6;
            _main_container.margin_bottom = 6;
            _main_container.margin_start = 6;
            _main_container.margin_end = 6;

            _popover.add_css_class("bubble");

            for (int i = 0; i < _sections.length; i++) {
                var section = _sections[i];

                var bubble = new Gtk.ListBox();
                bubble.selection_mode = Gtk.SelectionMode.NONE;

                if (section.title != null) {
                    var header_row = new Gtk.ListBoxRow();
                    header_row.activatable = false;
                    header_row.selectable = false;
                    header_row.add_css_class("header");
                    var h_lbl = new Gtk.Label(section.title);
                    h_lbl.add_css_class("heading");
                    h_lbl.halign = Gtk.Align.START;
                    h_lbl.margin_start = 12;
                    h_lbl.margin_top = 8;
                    h_lbl.margin_bottom = 8;
                    header_row.set_child(h_lbl);
                    bubble.append(header_row);
                }

                for (int j = 0; j < section.items.length; j++) {
                    var item = section.items[j];
                    var row = new Gtk.ListBoxRow();
                    row.activatable = true;
                    row.selectable = false;
                    row.set_child(create_entry_row(item));
                    bubble.append(row);
                }

                _main_container.append(bubble);
            }
        }

        private Gtk.Widget create_entry_row(Item item) {
            var button = new Gtk.Button();
            button.add_css_class("textual-button");
            button.has_frame = false;

            var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 12);
            box.margin_start = 12;
            box.margin_end = 12;
            box.margin_top = 8;
            box.margin_bottom = 8;

            if (item.icon_name != null) {
                var icon = new Gtk.Image.from_icon_name(item.icon_name);
                icon.pixel_size = 18;
                box.append(icon);
            }

            var text_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 2);
            text_box.valign = Gtk.Align.CENTER;
            text_box.hexpand = true;

            var lbl = new Gtk.Label(item.label);
            lbl.halign = Gtk.Align.START;
            lbl.add_css_class("body");
            text_box.append(lbl);

            if (item.description != null) {
                var desc = new Gtk.Label(item.description);
                desc.halign = Gtk.Align.START;
                desc.add_css_class("caption");
                desc.add_css_class("dim-label");
                text_box.append(desc);
            }
            box.append(text_box);

            if (item.shortcut != null) {
                var sc = new Gtk.Label(item.shortcut);
                sc.add_css_class("accelerator");
                sc.halign = Gtk.Align.END;
                box.append(sc);
            }

            button.child = box;

            button.clicked.connect(() => {
                _popover.popdown();
                item.activated();

                if (item.callback != null) {
                    item.callback();
                }

                if (item.action_name != null) {
                    _button.activate_action_variant(item.action_name, item.action_target);
                }
            });

            return button;
        }

        private void update_visuals() {
            if (_visual_style == MenuVisual.VIBRANT) {
                _popover.add_css_class("vibrant");
            } else {
                _popover.remove_css_class("vibrant");
            }
        }
    }
}
