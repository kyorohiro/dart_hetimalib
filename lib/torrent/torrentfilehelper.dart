part of hetima;

class TorrentFileCreator {
  int piececSize = 16 * 1024;
  String announce = "http://127.0.0.1:6969";

  async.Completer<TorrentFileCreatorResult> createFromSingleFile(
      HetimaFile target, String name) {
    TorrentFile file = new TorrentFile.nullobject();
    async.Completer<TorrentFileCreatorResult> ret = new async.Completer();    
    target.getLength().then((int length){
      file.info.files.path.add(new TorrentFileFile([name], length));
    }).then((d){
      target.read(0, piececSize * 0).then((ReadResult e) {
        
      });
    });
    return ret;
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

  async.Future<CreatePieceHashResult> createPieceHash(HetimaFile file, int pieceLength) {
    async.Completer<CreatePieceHashResult> compleater = new async.Completer();
    CreatePieceHashResult result = new CreatePieceHashResult();
    result.pieceLength = pieceLength;
    result.file = file;
    _createPieceHash(compleater, result);
    return compleater.future;
  }

  void _createPieceHash(async.Completer<CreatePieceHashResult> compleater, CreatePieceHashResult result) {
    int start = result.start;
    int end = result.start + result.pieceLength;
    result.file.getLength().then((int length) {
      if (end > length) {
        end = length;
      }
      result.file.read(start, end).then((ReadResult e) {
        crypto.SHA1 sha1 = new crypto.SHA1();
        sha1.add(e.buffer.sublist(start,end));
        result.add(sha1.close());
        result.start = end;
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
  ArrayBuilder b = new ArrayBuilder();
  int start = 0;
  int pieceLength = 0;
  HetimaFile file = null;
  void add(List<int> data) {
    b.appendIntList(data, 0, data.length);
  }
}
