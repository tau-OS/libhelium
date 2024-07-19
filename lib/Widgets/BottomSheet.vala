public class He.BottomSheet : Gtk.Widget {
    private const int TOP_MARGIN = 64;

    public signal void hidden ();

    private Gtk.Widget dimming;
    private Gtk.Box sheet_bin;
    private Gtk.Label title_label;
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

        sheet_bin = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);
        sheet_bin.set_child_visible (false);
        sheet_bin.halign = Gtk.Align.CENTER;
        sheet_bin.set_parent (this);

        var cancel_button = new Gtk.Button ();
        cancel_button.set_icon_name ("window-close-symbolic");
        cancel_button.hexpand = true;
        cancel_button.halign = Gtk.Align.END;
        cancel_button.add_css_class ("close-button");
        cancel_button.add_css_class ("circular");
        cancel_button.set_tooltip_text (_("Cancel"));
        title_label = new Gtk.Label ("");
        title_label.add_css_class ("view-title");
        var header_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        header_box.append (title_label);
        header_box.append (cancel_button);

        var header_wh = new Gtk.WindowHandle ();
        header_wh.set_child (header_box);

        sheet_bin.prepend (header_wh);

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
        min = nat = 0;

        sheet_bin.measure (orientation, for_size, out sheet_min, out sheet_nat, null, null);
        dimming.measure (orientation, for_size, out dimming_min, out dimming_nat, null, null);

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

        if (width <= 408) { // Mobile size (360) + accounting for sheet horizontal margins (24+24)
            t = t.translate ({ 0, height - offset_rounded });
            sheet_bin.add_css_class ("bottom-sheet");
            sheet_bin.remove_css_class ("dialog-sheet");
        } else {
            t = t.translate ({ 0, (height - offset_rounded) / 2 });
            sheet_bin.add_css_class ("dialog-sheet");
            sheet_bin.remove_css_class ("bottom-sheet");
        }

        sheet_height = int.max (sheet_height, offset_rounded);

        sheet_bin.allocate (width, sheet_height, baseline, t);
    }
}
