namespace He.Ensor {
  public class Accent : Object {
    public Gdk.Pixbuf? pixbuf { get; construct set; }
    public unowned GLib.List<int> accent_list { get; set; }
    
    public Accent.from_pixbuf (Gdk.Pixbuf pixbuf) {
      Object (pixbuf: pixbuf);
    }

    public async void accent_from_pixels_async () {
      if (pixbuf != null) {
        var celebi = new He.QuantizerCelebi ();
        var res = celebi.quantize ((int[]) pixbuf.get_pixels_with_length (), 128);
        var score = new He.Score ();
        this.accent_list = score.score (res);
      } else {
        this.accent_list = null;
      }
    }
  }
}
