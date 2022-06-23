/*
 * Copyright (C) 2022 Fyra Labs
 * Copyright (C) 2018 Purism SPC
 *
 * The following code is a derivative work of the code from the libadwaita project, 
 * which is licensed LGPLv2. This code is relicensed to the terms of GPLv3 while keeping
 * the original attribution.
 *
 */

/**
 * A Latch is a widget that can be used to make its child grow up to a maximum specified size.
 */
public class He.Latch : Gtk.Widget, Gtk.Buildable, Gtk.Orientable, Gtk.Scrollable {
    /**
     * Sets the tightness of the latch.
     */
    private int _tightening_threshold;
    public int tightening_threshold { 
        get {
            He.LatchLayout layout = (He.LatchLayout)this.get_layout_manager ();
            return layout.tightening_threshold;
        }
        set {
            _tightening_threshold = value;

            He.LatchLayout layout = (He.LatchLayout)this.get_layout_manager ();
            layout.tightening_threshold = value;
        }
    }

    /**
     * Sets the maximum size of the latch.
     */
    private int _maximum_size;
    public int maximum_size { 
        get {
            He.LatchLayout layout = (He.LatchLayout)this.get_layout_manager ();
            return layout.maximum_size;
        }
        set {
            _maximum_size = value;

            He.LatchLayout layout = (He.LatchLayout)this.get_layout_manager ();
            layout.maximum_size = value;
        }
    }

    /**
     * The orientation of the Latch.
     */
    private Gtk.Orientation _orientation;
    public Gtk.Orientation orientation {
        get { return _orientation; }
        set {
            _orientation = value;

            He.LatchLayout layout = (He.LatchLayout)this.get_layout_manager ();
            layout.orientation = value;
        }
    }

    /**
     * The child widget of the Latch.
     */
    private Gtk.Widget _child;
    public Gtk.Widget child {
        set {
            if (_child != null) {
                _child.unparent();
            }

            _child = value;
            _child.set_parent(this);
        }

        get {
            return _child;
        }
    }

    public Gtk.Adjustment vadjustment { get; construct set; }
    public Gtk.Adjustment hadjustment { get; construct set; }
    public Gtk.ScrollablePolicy hscroll_policy { get; set; }
    public Gtk.ScrollablePolicy vscroll_policy { get; set; }

    static construct {
        set_layout_manager_type (typeof (He.LatchLayout));
    }

    construct {
        this.tightening_threshold = 400;
        this.maximum_size = 600;
    }

    /**
     * Add a child to the latch, should only be used in the context of a UI or Blueprint file. There should be no need to use this method in code.
     *
 * @since 1.0
 */
     public new void add_child (Gtk.Builder builder, GLib.Object child, string? type) {
        this.child = (Gtk.Widget)child;
    }
}