namespace He.Ensor {
  public class Accent : Object {
    public Gdk.Pixbuf? pixbuf { get; construct set; }
    public unowned GLib.List<int> accent_list { get; set; }
    
    GLib.List<int> accent_from_pixels (uint8[] pixels) {
      if (pixbuf != null) {
        var celebi = new He.QuantizerCelebi ();
        var res = celebi.quantize ((int[]) pixels, 128);
        var score = new He.Score ();
        this.accent_list = score.score (res);
      } else {
        this.accent_list = null;
      }
      
      return this.accent_list.copy ();
    }

    public async GLib.List<int> accent_from_pixels_async (Gdk.Pixbuf? pixbuf) {
      SourceFunc callback = accent_from_pixels_async.callback;
      GLib.List<int> result = null;

      owned ThreadFunc<bool> run = () => {
        result = accent_from_pixels (pixbuf.get_pixels_with_length ());
        Idle.add((owned) callback);
        return true;
      };
      new Thread<bool>("ensor-process", run);
      
      yield;
    }
  }
}
