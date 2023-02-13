GLib.List<int> accent_from_pixels (uint8[] pixels) {
  var celebi = new He.QuantizerCelebi ();
  var result = celebi.quantize ((int[])pixels, 128);
  var score = new He.Score ();
  return score.score (result);
}

async GLib.List<int> accent_from_pixels_async (uint8[] pixels) {
  SourceFunc callback = accent_from_pixels_async.callback;
  GLib.List<int> result = null;

  ThreadFunc<bool> run = () => {
      result = accent_from_pixels (pixels);
      Idle.add((owned) callback);
      return true;
  };
  new Thread<bool>("ensor-process", run);

  yield;
  return result.copy ();
}
