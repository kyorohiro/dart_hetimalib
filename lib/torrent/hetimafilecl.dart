part of hetima_cl;

class HetimaFileCl extends HetimaFile
{
  html.Blob _mBlob;

  HetimaFileCl(bl) {
    _mBlob = bl;
  }

  async.Future<WriteResult> write() {
    return new async.Completer<WriteResult>().future;
  }

  core.int get length {
    return _mBlob.size;
  }

  async.Future<ReadResult> read(core.int start, core.int end) {
    async.Completer<ReadResult> ret = new async.Completer<ReadResult>();
    html.FileReader reader = new html.FileReader();
    reader.onLoad.listen((html.ProgressEvent e){
      ret.complete(new ReadResult(ReadResult.OK, reader.result));
    });
    reader.onError.listen((html.Event e){
      ret.complete(new ReadResult(ReadResult.NG, null));      
    });
    reader.onAbort.listen((html.ProgressEvent e){
      ret.complete(new ReadResult(ReadResult.NG, null));
    });
    reader.readAsArrayBuffer(_mBlob.slice(start, end));
    return ret.future;
  }

}