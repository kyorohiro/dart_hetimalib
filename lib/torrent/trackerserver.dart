part of hetima_sv;

class TrackerServer {
  String address;
  int port;
  io.HttpServer _server = null;
  List<PeerList> _list = new List();

  TrackerServer(String _address, int _port) {
    address = _address;
    port = _port;
  }

  void add(String hash) {
    PeerList peerlist = new PeerList(hash);
    if (!_list.contains(peerlist)) {
      _list.add(new PeerList(hash));
    }
  }

  async.Future<StartResult> start() {
    async.Completer<StartResult> c = new async.Completer();
    io.HttpServer.bind(address, port).then((io.HttpServer server) {
      _server = server;
      server.listen(onListen);
      c.complete(new StartResult());
    }).catchError((e) {
      c.complete(new StartResult());
    });
    return c.future;
  }

  async.Future<StopResult> stop() {
    async.Completer<StopResult> c = new async.Completer();
    _server.close(force: true).then((e) {
    });
    return c.future;
  }

  void onListen(io.HttpRequest request) {
    request.response.statusCode = io.HttpStatus.OK;
    try {
      request.connectionInfo.remoteAddress;
      Map<String, String> parameter = request.uri.queryParameters;
      String portAsString = parameter[TrackerUrl.KEY_PORT];
      String eventAsString = parameter[TrackerUrl.KEY_EVENT];
      String infoHashAsString = parameter[TrackerUrl.KEY_INFO_HASH];
      String peeridAsString = parameter[TrackerUrl.KEY_PEER_ID];
      String downloadedAsString = parameter[TrackerUrl.KEY_DOWNLOADED];
      String uploadedAsString = parameter[TrackerUrl.KEY_UPLOADED];
      String leftAsString = parameter[TrackerUrl.KEY_LEFT];
      if (null == find(infoHashAsString)) {
        request.response.write("d5:errore");
      } else {
        request.response.write("d2:oke");
      }
    } finally {
      request.response.close();
    }
  }

  PeerList find(String infoHash) {
    for (PeerList l in _list) {
      if (l.isManagedInfo(infoHash)) {
        return l;
      }
    }
    return null;
  }
}

class PeerList {
  String _hash = "";
  PeerList(hash) {
    _hash = hash;
  }

  operator ==(PeerList peerlist) {
    return (_hash == peerlist._hash);
  }

  bool isManagedInfo(String infoHash) {
    return _hash == infoHash;
  }

  String get hash => _hash;
}

class StopResult {
}
class StartResult {
}

class PeerAddressCreator {
  static async.Future<PeerAddress> PeerAddress(List<int>peerid, String host, int port) {
    async.Completer<PeerAddress> ret;
    io.InternetAddress.lookup(host).then((List<io.InternetAddress> adds){
      if(adds.length == 0) {
        ret.complete(null);        
      } else {
        ret.complete(new PeerAddress(peerid, host, adds[0], port));
      }
    });
    return ret.future;
  }
}
