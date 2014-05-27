part of hetima_cl;

class HetimaFileBlob extends HetimaFile
{
  html.Blob _mBlob;

  HetimaFileBlob(bl) {
    _mBlob = bl;
  }

  async.Future<WriteResult> write() {
    return null;
  }

  async.Future<core.int> getLength() { 
    async.Completer<core.int>ret = new async.Completer(); 
    ret.complete(_mBlob.size);
    return ret.future;
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

class HetimaFileGet extends HetimaFile
{
  
  html.Blob _mBlob = null;
  core.String _mPath = "";

  HetimaFileGet(core.String path) {
    _mPath = path;
  }

  async.Future<WriteResult> write() {
    return new async.Completer<WriteResult>().future;
  }

  async.Future<html.Blob> getBlob() {    
    async.Completer<html.Blob>ret = new async.Completer(); 
    html.HttpRequest request = new html.HttpRequest();
    request.responseType = "blob";
    request.open("GET", _mPath);
    request.onLoad.listen((html.ProgressEvent e) {
      _mBlob = request.response;
      ret.complete(request.response);
    });
    request.send();
    return ret.future;
  }

  async.Future<core.int> getLength() {    
    async.Completer<core.int>ret = new async.Completer(); 
    if(_mBlob == null) {
      getBlob().then((html.Blob b){
         ret.complete(b.size);
      });
    } else {
      ret.complete(_mBlob.size);
    }
    return ret.future;
  }

  async.Future<ReadResult> read(core.int start, core.int end) {
    async.Completer<ReadResult> ret = new async.Completer<ReadResult>();
    if(_mBlob != null) {
      return readBase(ret, start, end);
    } else {
      html.HttpRequest request = new html.HttpRequest();
      request.responseType = "blob";
      request.open("GET", "testdata/1kb.torrent");
      request.onLoad.listen((html.ProgressEvent e) {
        readBase(ret, start, end);
      });
      return ret.future;
    }
  }

  async.Future<ReadResult> readBase( async.Completer<ReadResult> ret, core.int start, core.int end) {
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