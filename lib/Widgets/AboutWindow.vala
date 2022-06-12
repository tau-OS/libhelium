/**
* An AboutWindow is a window that displays information about the application.
*/
public class He.AboutWindow : He.Window {
  private He.AppBar app_bar = new He.AppBar();
  private Gtk.Overlay window_overlay = new Gtk.Overlay();
  private Gtk.Box about_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 30);
  private Gtk.Box content_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 18);
  private Gtk.Box button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 18);
  private Gtk.Box info_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);

  private Gtk.Box title_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 18);
  private Gtk.Box text_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);

  private Gtk.Label title_label = new Gtk.Label (null);

  private Gtk.Box developers_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
  private Gtk.Label developers_copyright = new Gtk.Label (null);
  private Gtk.Label developers_label = new Gtk.Label (null);

  private Gtk.Label translators_label = new Gtk.Label (null);

  private Gtk.Box license_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
  private Gtk.Label license_label = new Gtk.Label ("This program is licensed under ");
  private Gtk.LinkButton license_link = new Gtk.LinkButton ("https://hololive.moe");

  private Gtk.Image icon_image = new Gtk.Image ();

  private He.TextButton translate_app_button = new He.TextButton ("Translate App");
  private He.TintButton report_button = new He.TintButton ("Report a Problem");
  private He.FillButton more_info_button = new He.FillButton ("More Info...");

  private He.ModifierBadge version_badge = new He.ModifierBadge ("");

  /**
  * An enum of commonly used licenses to be used in AboutWindow.
  */
  public enum Licenses {
    GPLv3,
    MIT,
    MPLv2,
    UNLICENSE,
    APACHEv2,
    WTFPL,
    PROPRIETARY;

    /**
    * Returns the license url for the license.
    */
    public string get_url() {
      switch (this) {
        case Licenses.GPLv3:
          return "https://choosealicense.com/licenses/gpl-3.0";
        case Licenses.MIT:
          return "https://choosealicense.com/licenses/mit";
        case Licenses.MPLv2:
          return "https://choosealicense.com/licenses/mpl-2.0";
        case Licenses.UNLICENSE:
          return "https://choosealicense.com/licenses/unlicense";
        case Licenses.APACHEv2:
          return "https://choosealicense.com/licenses/apache-2.0";
        case Licenses.WTFPL:
          return "https://choosealicense.com/licenses/wtfpl";
        case Licenses.PROPRIETARY:
          return "https://choosealicense.com/no-permission";
        default:
          return "https://hololive.moe/";
      }
    }

    /**
    * Returns the license name for the license.
    */
    public string get_name() {
      switch (this) {
        case Licenses.GPLv3:
          return "GPLv3";
        case Licenses.MIT:
          return "MIT";
        case Licenses.MPLv2:
          return "MPLv2";
        case Licenses.UNLICENSE:
          return "Unlicense";
        case Licenses.APACHEv2:
          return "Apache License v2";
        case Licenses.WTFPL:
          return "WTFPL";
        case Licenses.PROPRIETARY:
          return "a proprietary license";
        default:
          return "Hololive";
      }
    }
  }

  private He.Colors _color;

  /**
  * The theme color of the AboutWindow.
  */
  public He.Colors color {
    get {
      return _color;
    }
    set {
      _color = value;
      translate_app_button.color = value;
      report_button.color = value;
      more_info_button.color = value;
      version_badge.color = value;
      if (_color != He.Colors.NONE) license_link.remove_css_class (_color.to_css_class());
      if (value != He.Colors.NONE) license_link.add_css_class (value.to_css_class());
    }
  }


  private Licenses _license;
  /**
  * The license shown in the AboutWindow.
  */
  public Licenses license {
    get { return _license; }
    set {
      _license = value;
      license_link.label = value.get_name();
      license_link.uri = value.get_url();
    }
  }

  /**
  * The version shown in the AboutWindow.
  */
  public string version {
    get { return version_badge.label; }
    set { version_badge.label = value; }
  }

  /**
  * The name of the application shown in the AboutWindow.
  */
  public string app_name {
    get { return title_label.get_text (); }
    set { title_label.set_text (value); }
  }

  /**
    The icon shown in the AboutWindow.
  */
  public string icon {
    get { return icon_image.get_icon_name (); }
    set { icon_image.set_from_icon_name (value); }
  }

  private string[] translators;
  /**
  * The translators shown in the AboutWindow.
  */
  public string[] translator_names {
    get { return translators; }
    set { 
      translators = value;
      translators_label.set_text ("Translated By: " + string.joinv (", ", translators));
    }
  }

  private string[] developers;
  /**
  * The developers shown in the AboutWindow.
  */
  public string[] developer_names {
    get { return developers; }
    set { 
      developers = value;
      developers_label.set_text (string.joinv (", ", developers));
    }
  }

  private int _copyright_year;
  /**
  * The copyright year shown in the AboutWindow.
  */
  public int copyright_year {
    get { return _copyright_year; }
    set {
      _copyright_year = value;
      developers_copyright.set_text ("© " + "%04d ".printf(value));
    }
  }


  /**
  * Your application's reverse-domain name.
  */
  public string app_id;
  /**
  * A URL where contributors can help translate the application.
  */
  public string translate_url;
  /**
  * A URL where users can report a problem with the application.
  */
  public string issue_url;
  /**
  * A URL where users can get more information about the application.
  */
  public string more_info_url;

  construct {
    this.set_modal(true);
    this.resizable = false;

    this.app_bar.valign = Gtk.Align.START;
    this.app_bar.show_back = false;
    this.app_bar.flat = true;

    window_overlay.add_overlay(app_bar);
    window_overlay.set_child(about_box);

    about_box.add_css_class("dialog-content");
    about_box.append(content_box);
    about_box.append(button_box);
    
    icon_image.valign = Gtk.Align.START;
    icon_image.pixel_size = 128;
    
    content_box.append(icon_image);
    content_box.append(info_box);
    
    info_box.append(title_box);
    info_box.append(text_box);
    
    version_badge.tinted = true;
    version_badge.margin_end = 18;
    title_label.add_css_class ("display");
    title_box.append(title_label);
    title_box.append(version_badge);
    
    developers_box.append(developers_copyright);
    developers_box.append(developers_label);
    
    text_box.append(developers_box);
    translators_label.xalign = 0;
    text_box.append(translators_label);
    
    license_link.remove_css_class("text-button");
    license_link.remove_css_class("link");
    license_link.add_css_class("link-button");
    license_box.append(license_label);
    license_box.append(license_link);
    
    text_box.append(license_box);

    button_box.valign = Gtk.Align.CENTER;
    button_box.homogeneous = true;
    button_box.append(translate_app_button);
    button_box.append(report_button);
    button_box.append(more_info_button);

    translate_app_button.clicked.connect(() => {
      Gtk.show_uri_full.begin(this.parent, translate_url, Gdk.CURRENT_TIME, null);
    });

    report_button.clicked.connect(() => {
      Gtk.show_uri_full.begin(this.parent, issue_url, Gdk.CURRENT_TIME, null);
    });

    more_info_button.clicked.connect(() => {
      Gtk.show_uri_full.begin(this.parent, more_info_url, Gdk.CURRENT_TIME, null);
    });

    var window_handle = new Gtk.WindowHandle ();
    window_handle.set_child (window_overlay);
    
    this.set_child(window_handle);
  }

  ~AboutWindow() {
    this.unparent();
    this.window_overlay.dispose();
  }

  /**
  * Creates a new AboutWindow.
  * @param parent The parent window.
  * @param app_name Your application's name.
  * @param app_id Your application's reverse-domain name.
  * @param version Your application's version.
  * @param icon Your application's icon.
  * @param translate_url A URL where contributors can help translate the application.
  * @param issue_url A URL where users can report a problem with the application.
  * @param more_info_url A URL where users can get more information about the application.
  * @param translators Your application's translators.
  * @param developers Your application's developers.
  * @param copyright_year Your application's copyright year.  
  * @param license Your application's license.
  * @param color The color of the AboutWindow.
  */
  public AboutWindow(
    Gtk.Window parent,
    string app_name,
    string app_id,
    string version,
    string icon,
    string translate_url,
    string issue_url,
    string more_info_url,
    string[] translators,
    string[] developers,
    int copyright_year,
    Licenses license,
    He.Colors color
  ) {
    this.parent = parent;
    this.app_name = app_name;
    this.app_id = app_id;
    this.version = version;
    this.icon = icon;
    this.translate_url = translate_url;
    this.issue_url = issue_url;
    this.more_info_url = more_info_url;
    this.translator_names = translators;
    this.developer_names = developers;
    this.copyright_year = copyright_year;
    this.license = license;
    this.color = color;
  }
}