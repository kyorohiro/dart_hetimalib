part of hetima;

class TorrentFileCreator {
  String announce = "http://127.0.0.1:6969";
  String name = "name";
  int piececSize = 16 * 1024;

  async.Future<TorrentFileCreatorResult> createFromSingleFile(HetimaFile target) {
    async.Completer<TorrentFileCreatorResult> ret = new async.Completer();
    TorrentFileHelper helper = new TorrentFileHelper();
    helper.createPieceHash(target, piececSize).then((CreatePieceHashResult r) {
      Map file = {};
      Map info = {};
      file[TorrentFile.KEY_ANNOUNCE] = announce;
      file[TorrentFile.KEY_INFO] = info;
      info[TorrentFile.KEY_PIECE_LENGTH] = piececSize;
      info[TorrentFile.KEY_LENGTH] = r.pieceBuffer.size();
      info[TorrentFile.KEY_PIECE] = r.pieceBuffer.toUint8List();
      TorrentFileCreatorResult result = new TorrentFileCreatorResult(TorrentFileCreatorResult.OK);
      result.torrentFile = new TorrentFile.torentmap(file);
      ret.complete(result);
    });
    return ret.future;
  }

}

class TorrentFileCreatorResult {
  static final OK = 1;
  static final NG = -1;
  int status = NG;
  TorrentFile torrentFile = null;
  TorrentFileCreatorResult(int nextStatus) {
    status = nextStatus;
  }
}

class TorrentFileHelper {

  async.Future<CreatePieceHashResult> createPieceHash(HetimaFile file, int pieceLength) {
    async.Completer<CreatePieceHashResult> compleater = new async.Completer();
    CreatePieceHashResult result = new CreatePieceHashResult();
    result.pieceLength = pieceLength;
    result.targetFile = file;
    _createPieceHash(compleater, result);
    return compleater.future;
  }

  void _createPieceHash(async.Completer<CreatePieceHashResult> compleater, CreatePieceHashResult result) {
    int start = result._tmpStart;
    int end = result._tmpStart + result.pieceLength;
    result.targetFile.getLength().then((int length) {
      if (end > length) {
        end = length;
      }
      result.targetFile.read(start, end).then((ReadResult e) {
        crypto.SHA1 sha1 = new crypto.SHA1();
        sha1.add(e.buffer.sublist(start, end));
        result.add(sha1.close());
        result._tmpStart = end;
        if (end == length) {
          compleater.complete(result);
        } else {
          _createPieceHash(compleater, result);
        }
      });
    });
  }
}

class CreatePieceHashResult {
  int _tmpStart = 0;
  int pieceLength = 0;
  ArrayBuilder pieceBuffer = new ArrayBuilder();
  HetimaFile targetFile = null;

  void add(List<int> data) {
    pieceBuffer.appendIntList(data, 0, data.length);
  }
}
