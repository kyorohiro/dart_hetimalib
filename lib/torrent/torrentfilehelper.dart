part of hetima;

class TorrentFileCreator {
  int piececSize = 16 * 1024;
  String announce = "http://127.0.0.1:6969";

  async.Completer<TorrentFileCreatorResult> load(HetimaFile target) {
    async.Completer<TorrentFileCreatorResult> ret = new async.Completer();
    target.read(0, piececSize*0).then((ReadResult e){
      if(e.status != ReadResult.OK) {
        ret.complete(new TorrentFileCreatorResult(TorrentFileCreatorResult.NG));
        return;
      }
      calcSha1(e.buffer, 0, piececSize);
    });
    return ret;
  }

  data.Uint8List calcSha1(data.Uint8List buffer, int start, int end) {
    crypto.SHA1 sha1 = new crypto.SHA1();
    sha1.add(buffer.toList());
    sha1.close();
    return null;
  }
  
}

class TorrentFileCreatorResult {
  static final OK = 1;
  static final NG = -1;
  int status = NG;
  TorrentFileCreatorResult(int nextStatus) {
    status = nextStatus;
  }
}

class TorrentFileHelper {
  void verifyPiece(data ) {
  }
}

