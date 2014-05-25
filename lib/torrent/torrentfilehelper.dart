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

  async.Future<VerifyPieceResult> verifyPiece(HetimaFile file, int pieceLength) {
    async.Completer<VerifyPieceResult> compleater = new async.Completer();
    VerifyPieceResult result = new VerifyPieceResult();
    result.pieceLength = pieceLength;
    createPiece(compleater, result);
    return compleater.future;
  }

  void createPiece(async.Completer<VerifyPieceResult> compleater, VerifyPieceResult result) {
    int start = result.start;
    int end = result.start + result.pieceLength;

    if(end> result.file.length) {
      end = result.file.length;
    }
    result.file.read(start, end).then((ReadResult e){
      crypto.SHA1 sha1 = new crypto.SHA1();
      sha1.add(e.buffer.toList());
      result.add(sha1.close());
      result.start = end;
      if(end == result.file.length) {
        compleater.complete(result);
      }
      else {
        createPiece(compleater, result);
      }
    });
  }  
}

class VerifyPieceResult 
{
  ArrayBuilder b = new ArrayBuilder();
  int start = 0;
  int pieceLength = 0;
  HetimaFile file = null;
  void add(List<int> data) {
    b.appendIntList(data, 0, data.length);
  }
}

