namespace He.Ensor {
  public class Accent : Object {
    public async GLib.List<int> accent_from_pixels_async (Gdk.Pixbuf? pixbuf) {
      GLib.List<int> res = null;
      var celebi = new He.QuantizerCelebi ();
      var result = yield celebi.quantize ((int[]) pixbuf.get_pixels_with_length (), 128);
      var score = new He.Score ();
      res = score.score (result);
      
      yield;
      return res.copy_deep ((a) => a);
    }
  }
}
