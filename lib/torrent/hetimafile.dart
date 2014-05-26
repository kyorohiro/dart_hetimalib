part of hetima;

abstract class HetimaFile {
  int length;
  List<String> path = new List();
  async.Future<WriteResult> write();
  async.Future<ReadResult> read(int start, int end);
}

class WriteResult {
}

class ReadResult {
  static final OK = 1;
  static final NG = -1;
  int status = NG;
  data.Uint8List buffer;
  ReadResult(int _status, data.Uint8List _buffer) {
    status = _status;
    buffer = _buffer;
  }
}