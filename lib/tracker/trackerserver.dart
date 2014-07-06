part of hetima_sv;

class TrackerServer {
  String address;
  int port;
  io.HttpServer _server = null;

  List<TrackerPeerManager> _peerManagerList = new List();
  TrackerServer(String _address, int _port) {
    address = _address;
    port = _port;
  }

  void add(String hash) {
    //
    List<int>infoHash = PercentEncode.decode(hash);
    bool isManaged = false;
    for(TrackerPeerManager m in _peerManagerList) {
      if(m.isManagedInfoHash(infoHash)) {
        isManaged = true;
      }
    }

    if(isManaged == true) {
      return;
    }

    TrackerPeerManager peerManager = new TrackerPeerManager(infoHash);
    _peerManagerList.add(peerManager);
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
      Map<String, String> parameter = request.uri.queryParameters;
      String portAsString = parameter[TrackerUrl.KEY_PORT];
      String eventAsString = parameter[TrackerUrl.KEY_EVENT];
      String infoHashAsString = parameter[TrackerUrl.KEY_INFO_HASH];
      String peeridAsString = parameter[TrackerUrl.KEY_PEER_ID];
      String downloadedAsString = parameter[TrackerUrl.KEY_DOWNLOADED];
      String uploadedAsString = parameter[TrackerUrl.KEY_UPLOADED];
      String leftAsString = parameter[TrackerUrl.KEY_LEFT];
      List<int> infoHash = PercentEncode.decode(infoHashAsString);
      TrackerPeerManager manager = find(infoHash); 
      io.InternetAddress addressAsInet = request.connectionInfo.remoteAddress;
      String address = addressAsInet.address;
      List<int> ip = addressAsInet.rawAddress;
      if (null == manager) {
        // unmanaged torrent data
        Map <String, Object> errorResponse = new Map();
        errorResponse[TrackerResponse.KEY_FAILURE_REASON] = "unmanaged torrent data";
        request.response.add(Bencode.encode(errorResponse).toList());
      } else {
        // managed torrent data
        manager.update(new TrackerRequest.fromMap(parameter, address, ip));
        type.Uint8List buffer = Bencode.encode(manager.createResponse().createResponse(false));
        request.response.add(buffer.toList());
      }
    } finally {
      request.response.close();
    }
  }

  TrackerPeerManager find(List<int> infoHash) {
    for (TrackerPeerManager l in _peerManagerList) {
      if (l.isManagedInfoHash(infoHash)) {
        return l;
      }
    }
    return null;
  }
}


class StopResult {
}
class StartResult {
}