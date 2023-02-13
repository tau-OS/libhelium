namespace He.Ensor {
  public class Accent : Object {
    public Gdk.Pixbuf? pixbuf { get; construct set; }
    public unowned GLib.List<int> accent_list { get; set; }
    
    public Accent.from_pixbuf (Gdk.Pixbuf pixbuf) {
      Object (pixbuf: pixbuf);
    }
  
    GLib.List<int> accent_from_pixels (uint8[] pixels) {
      var celebi = new He.QuantizerCelebi ();
      var result = celebi.quantize ((int[])pixels, 128);
      var score = new He.Score ();
      return score.score (result);
    }

    public async void accent_from_pixels_async () {
      if (pixbuf != null) {
        SourceFunc callback = accent_from_pixels_async.callback;
        GLib.List<int> result = null;

        ThreadFunc<bool> run = () => {
          result = accent_from_pixels (pixbuf.get_pixels_with_length ());
          Idle.add((owned) callback);
          return true;
        };
        new Thread<bool>("ensor-process", run);

        yield;
        accent_list = result.copy ();
      } else {
        accent_list = null;
      }
    }
  }
}
