/**
 * A Toast is a widget containing a quick little message for the user with an optional action button.
 */
public class He.Toast : He.Bin {
    /**
     * Emitted when the Toast is closed by activating the close button
     */
    public signal void closed ();

    /**
     * Emitted when the default action button is activated
     */
    public signal void action ();

    private Gtk.Revealer revealer;
    private Gtk.Label notification_label;
    private Gtk.Button default_action_button;
    private uint timeout_id;

    private string _label;
    /**
     * The notification text label to be displayed inside of #this
     */
    public string label {
        get {
            return _label;
        }
        set {
            if (notification_label != null) {
                notification_label.label = value;
            }
            _label = value;
        }
    }

    /**
     * The default action button label to be displayed inside of #this
     */
    private string _default_action;
    public string default_action {
        get {
            return _default_action;
        }
        set {
            if (value == "" || value == null) {
                default_action_button.visible = false;
            } else {
                default_action_button.visible = true;
            }
            default_action_button.label = value;
            _default_action = value;
        }
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BinLayout));
    }

    /**
     * Creates a new Toast.
     * @param label The title of the Toast
     */
    public Toast (string label) {
        Object (label: label);
    }

    construct {
        add_css_class ("toast-box");

        halign = Gtk.Align.CENTER;
        valign = Gtk.Align.START;
        visible = false;

        default_action_button = new He.PillButton ("") {
            visible = false,
            color = 12
        };

        var close_button = new Gtk.Button.from_icon_name ("window-close-symbolic");
        close_button.valign = Gtk.Align.CENTER;
        close_button.add_css_class ("flat");
        close_button.add_css_class ("circular");

        notification_label = new Gtk.Label (label) {
            wrap = true,
            wrap_mode = Pango.WrapMode.WORD,
            xalign = 0,
            hexpand = true
        };
        notification_label.add_css_class ("flat");

        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
        box.valign = Gtk.Align.CENTER;
        box.append (notification_label);
        box.append (default_action_button);
        box.append (close_button);

        var motion_controller = new Gtk.EventControllerMotion ();

        revealer = new Gtk.Revealer () {
            child = box
        };
        revealer.set_parent (this);

        add_controller (motion_controller);

        close_button.clicked.connect (() => {
            revealer.reveal_child = false;
            this.visible = false;
            stop_timeout ();
            closed ();
        });

        default_action_button.clicked.connect (() => {
            revealer.reveal_child = false;
            this.visible = false;
            stop_timeout ();
            action ();
        });

        motion_controller.enter.connect (() => {
            stop_timeout ();
        });

        motion_controller.leave.connect (() => {
            start_timeout ();
        });
    }

    ~Toast () {
        get_first_child ().unparent ();
    }

    private void start_timeout () {
        uint duration;

        if (default_action_button.visible) {
            duration = 3500;
        } else {
            duration = 2000;
        }

        timeout_id = GLib.Timeout.add (duration, () => {
            revealer.reveal_child = false;
            this.visible = false;
            timeout_id = 0;
            return GLib.Source.REMOVE;
        });
    }
    private void stop_timeout () {
        if (timeout_id != 0) {
            Source.remove (timeout_id);
            timeout_id = 0;
        }
    }

    /**
     * Shows the Toast.
     */
    public void send_notification () {
        if (!revealer.child_revealed) {
            revealer.reveal_child = true;
            this.visible = true;
        }
        stop_timeout ();
        start_timeout ();
    }
}