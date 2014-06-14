part of hetima_sv;

class Tracker {
  String address;
  int port;
  io.HttpServer _server = null;
  List<PeerList> _list = new List();

  Tracker(String _address, int _port) {
    address = _address;
    port = _port;
  }

  void add(String hash) {
    PeerList peerlist = new PeerList(hash);
    if(!_list.contains(peerlist)){
      _list.add(new PeerList(hash));
    }
  }

  async.Future<StartResult> start() {
    async.Completer<StartResult> c = new async.Completer();
    io.HttpServer.bind(address, port).then((io.HttpServer server){
      _server = server;
      server.listen(onListen);
      c.complete(new StartResult());
    })
    .catchError((e){
      c.complete(new StartResult());
    });
    return c.future;
  }

  async.Future<StopResult> stop() {
    async.Completer<StopResult> c = new async.Completer();
    _server.close(force:true).then((e){      
    });
    return c.future;
  }

  void onListen(io.HttpRequest request) {
      request.response.statusCode = io.HttpStatus.FORBIDDEN;
      request.response.write("this server support websocket only");
      request.response.close();
  }
}

class PeerList {
  String _hash = "";
  PeerList(hash) {
    _hash = hash;
  }

  operator == (PeerList peerlist) {
   return (_hash == peerlist._hash);
  }

  String get hash => _hash;
}

class StopResult {  
}
class StartResult {  
}