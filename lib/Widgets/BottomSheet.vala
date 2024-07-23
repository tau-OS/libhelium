public class He.BottomSheet : Gtk.Widget {
    private const int TOP_MARGIN = 64;

    public signal void hidden ();

    private Gtk.Widget dimming;
    private Gtk.Widget handle;
    private Gtk.Box sheet_bin;
    private He.ViewTitle title_label;
    private He.SpringAnimation animation;

    private Gtk.Widget? _sheet;
    public Gtk.Widget? sheet {
        get { return _sheet; }
        set {
            if (sheet == value)
                return;

            _sheet = value;

            sheet_bin.append (sheet);
        }
    }

    private string? _title;
    public string? title {
        get { return _title; }
        set {
            if (title == value)
                return;

            _title = value;

            title_label.label = title;
        }
    }

    private bool _show_sheet;
    public bool show_sheet {
        get { return _show_sheet; }
        set {
            if (show_sheet == value)
                return;

            _show_sheet = value;

            animation.latch = !show_sheet;
            animation.value_from = animation.avalue;
            animation.value_to = show_sheet ? 1 : 0;
            animation.play ();
        }
    }

    private bool _show_handle;
    public bool show_handle {
        get { return _show_handle; }
        set {
            if (show_handle == value)
                return;

            _show_handle = value;
            handle.visible = value;
        }
    }

    private int _preferred_sheet_height;
    public int preferred_sheet_height {
        get { return _preferred_sheet_height; }
        set {
            if (preferred_sheet_height == value)
                return;

            _preferred_sheet_height = value;

            if (animation.avalue > 0)
                queue_allocate ();
        }
    }

    construct {
        dimming = new He.Bin ();
        dimming.opacity = 0;
        dimming.set_child_visible (false);
        dimming.add_css_class ("dimming");
        dimming.set_parent (this);

        sheet_bin = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        sheet_bin.set_child_visible (false);
        sheet_bin.halign = Gtk.Align.CENTER;
        sheet_bin.set_parent (this);

        handle = new He.Bin ();
        handle.visible = false;
        handle.can_focus = false;
        handle.can_target = false;
        handle.add_css_class ("drag-handle");
        handle.add_css_class ("large-radius");

        var cancel_button = new Gtk.Button ();
        cancel_button.set_icon_name ("window-close-symbolic");
        cancel_button.halign = Gtk.Align.START;
        cancel_button.add_css_class ("circular");
        cancel_button.set_tooltip_text (_("Cancel"));
        title_label = new He.ViewTitle ();
        title_label.hexpand = true;
        var header_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
        header_box.append (cancel_button);
        header_box.append (title_label);

        var header_wh = new Gtk.WindowHandle ();
        header_wh.set_child (header_box);

        var handle_wh = new Gtk.WindowHandle ();
        handle_wh.add_css_class ("drag-handle-container");
        handle_wh.set_child (handle);

        var divider = new He.Divider ();

        sheet_bin.prepend (divider);
        sheet_bin.prepend (header_wh);
        sheet_bin.prepend (handle_wh);

        cancel_button.clicked.connect (close_sheet);

        animation = new He.SpringAnimation (
                                            this,
                                            0,
                                            1,
                                            new He.SpringParams (0.8, 1, 200),
                                            new He.CallbackAnimationTarget ((value) => {
            dimming.opacity = value.clamp (0, 1);
            dimming.set_child_visible (value > 0);
            sheet_bin.set_child_visible (value > 0);
            queue_allocate ();
        })
        );
        animation.done.connect (() => {
            queue_allocate ();

            if (animation.avalue < 0.5) {
                dimming.set_child_visible (false);
                sheet_bin.set_child_visible (false);

                hidden ();
            }
        });
        animation.epsilon = 0.001;
    }

    private void close_sheet () {
        show_sheet = false;
    }

    protected override void dispose () {
        if (dimming != null) {
            dimming.unparent ();
            dimming = null;
        }

        if (sheet_bin != null) {
            sheet_bin.unparent ();
            sheet_bin = null;
        }

        base.dispose ();
    }

    protected override bool contains (double x, double y) {
        return false;
    }

    protected override void measure (Gtk.Orientation orientation,
                                     int for_size,
                                     out int min,
                                     out int nat,
                                     out int min_baseline,
                                     out int nat_baseline) {
        int sheet_min, sheet_nat;
        int dimming_min, dimming_nat;
        int handle_min, handle_nat;
        min = nat = 0;

        sheet_bin.measure (orientation, for_size, out sheet_min, out sheet_nat, null, null);
        dimming.measure (orientation, for_size, out dimming_min, out dimming_nat, null, null);

        if (handle != null) {
            handle.measure(orientation, for_size, out handle_min, out handle_nat, null, null);
        }

        if (orientation == HORIZONTAL) {
            min = int.max (dimming_min, sheet_min);
            nat = int.max (dimming_nat, sheet_nat);
        } else {
            min = int.max (dimming_min, sheet_min + TOP_MARGIN);
            nat = int.max (dimming_nat, sheet_nat + TOP_MARGIN);
        }
        min_baseline = nat_baseline = -1;
    }

    protected override void size_allocate (int width, int height, int baseline) {
        if (!sheet_bin.get_child_visible ())
            return;

        dimming.allocate (width, height, baseline, null);

        int sheet_height, min_sheet_height;

        if (preferred_sheet_height < 0) {
            sheet_bin.measure (VERTICAL, -1, out min_sheet_height, out sheet_height, null, null);
        } else {
            sheet_bin.measure (VERTICAL, -1, out min_sheet_height, null, null, null);
            sheet_height = preferred_sheet_height;
        }

        sheet_height = int.max (sheet_height, min_sheet_height);
        sheet_height = int.min (sheet_height, height - TOP_MARGIN);

        int offset_rounded = (int) Math.round (animation.avalue * sheet_height);

        var t = new Gsk.Transform ();

        if (width <= 396) { // Mobile size (360) + accounting for sheet horizontal margins (18+18)
            t = t.translate ({ 0, height - offset_rounded });
            sheet_bin.add_css_class ("bottom-sheet");
            sheet_bin.remove_css_class ("dialog-sheet");
            handle.visible = show_handle;
        } else {
            t = t.translate ({ 0, (height - offset_rounded) / 2 });
            sheet_bin.add_css_class ("dialog-sheet");
            sheet_bin.remove_css_class ("bottom-sheet");
            handle.visible = false;
        }

        sheet_height = int.max (sheet_height, offset_rounded);

        sheet_bin.allocate (width, sheet_height, baseline, t);

        if (handle != null) {
            int handle_width = 0, handle_height = 0, handle_x;

            handle.measure(Gtk.Orientation.HORIZONTAL, -1, null, out handle_width, null, null);
            handle.measure(Gtk.Orientation.VERTICAL, -1, null, out handle_height, null, null);

            handle_width = (int)Math.fmin (handle_width, width);
            handle_height = (int)Math.fmin (handle_height, height);

            handle_x = (int)Math.round (((width - handle_width) - 36) / 2); // accounting for sheet horizontal margins (18+18)

            var t2 = new Gsk.Transform ();

            t2 = t2.translate ({handle_x, 0});

            handle.allocate(handle_width, handle_height, baseline, t2);
        }
    }
}
