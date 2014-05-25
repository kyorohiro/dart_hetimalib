part of hetima_cl;

class HetimaFileCl extends HetimaFile
{
  html.Blob _mBlob;

  HetimaFileCl(bl) {
    _mBlob = bl;
  }
  async.Completer<WriteResult> write() {    
    return new async.Completer<WriteResult>();
  }

  async.Completer<ReadResult> read(core.int start, core.int end) {
    async.Completer<ReadResult> ret = new async.Completer<ReadResult>();
    html.FileReader reader = new html.FileReader();
    reader.onLoad.listen((html.ProgressEvent e){
      ret.complete(new ReadResult());
    });
    reader.onError.listen((html.Event e){
      ret.complete(new ReadResult());      
    });
    reader.onAbort.listen((html.ProgressEvent e){
      ret.complete(new ReadResult());
    });
    reader.readAsArrayBuffer(_mBlob.slice(start, end));
    return ret;
  }

}