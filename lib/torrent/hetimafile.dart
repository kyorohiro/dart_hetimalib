part of hetima;

abstract class HetimaFile {
  List<String> path = new List();
  async.Completer<WriteResult> write();
  async.Completer<ReadResult> read(int start, int end);
}

class WriteResult {
}

class ReadResult {
}