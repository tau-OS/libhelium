namespace He.Ensor {
  public class Accent : Object {
    public Gdk.Pixbuf? pixbuf { get; construct set; }
    
    private async GLib.List<int> accent_from_pixels (uint8[] pixels) {
      GLib.List<int> res = null;
      var celebi = new He.QuantizerCelebi ();
      var result = yield celebi.quantize ((int[]) pixels, 128);
      var score = new He.Score ();
      res = yield score.score (result);
      
      yield;
      return res.copy_deep ((a) => a);
    }

    public async GLib.List<int> accent_from_pixels_async (Gdk.Pixbuf? pixbuf) {
      GLib.List<int> result = null;
      result = yield accent_from_pixels (pixbuf.get_pixels_with_length ());
      
      yield;
      return result.copy_deep ((a) => a);
    }
  }
}
