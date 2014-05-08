part of hetima_cl;

class SignalClient {
  static core.int NULL = -1;
  static core.int CONNECTING = 0;// The connection is not yet open.
  static core.int OPEN = 1;// The connection is open and ready to communicate.
  static core.int CLOSING = 2;// The connection is in the process of closing.
  static core.int CLOSED = 3;// The connection is closed or couldn't be opened.

  core.String _websocketUrl = "ws://localhost:8082/websocket";
  html.WebSocket _websocket;

  async.Future connect() {
    async.Completer<html.Event> _connectWork = new async.Completer();

    _websocket = new html.WebSocket(_websocketUrl);
    _websocket.binaryType = "arraybuffer";
    _websocket.onOpen.listen((html.Event e) {
      onOpen(e);
      _connectWork.complete(e);
    });
    _websocket.onMessage.listen(onMessage);
    _websocket.onError.listen(onError);
    _websocket.onClose.listen(onClose);
    return _connectWork.future;
  }

  void onMessage(html.MessageEvent e) {
    core.print("type=" + e.type + "," + e.data.runtimeType.toString());
    if (e is core.String) {
      core.print("data=" + e.data);
    } else if (e.data is data.Uint8List) {
      data.Uint8List buffer = e.data;
      onReceiveSignalMessage(Bencode.decode(buffer));
    }
  }

  void onReceiveSignalMessage(core.Map message) {
    core.print("receive signal message" + convert.JSON.encode(message));

    if (convert.UTF8.decode(message["action"]) == "join") {
      if (convert.UTF8.decode(message["mode"]) == "response") {
        core.List peersAsBytes = message["peers"];
        core.List<core.String> peers = new core.List();
        for (core.int i = 0; i < peersAsBytes.length; i++) {
          peers.add(convert.UTF8.decode(peersAsBytes[i]));
          core.print("" + convert.UTF8.decode(peersAsBytes[i]));
        }

        notifyUpdatePeer(peers);
      } else {
        core.print("" + convert.UTF8.decode(message["from"]));
        core.List<core.String> peers = new core.List();
        peers.add(convert.UTF8.decode(message["from"]));
        notifyUpdatePeer(peers);
      }
    }
    else if (convert.UTF8.decode(message["action"]) == "pack") {
      core.String to = convert.UTF8.decode(message["to"]);
      core.String from = convert.UTF8.decode(message["from"]);
      notifyOnReceivePackage(to, from, message["pack"]);
    }
  }

  core.int getState() {
    if (_websocket == null) {
      return -1;
    }
    return _websocket.readyState;
  }
  void onOpen(html.Event e) {
  }
  void onClose(html.CloseEvent e) {
  }
  void onError(html.Event e) {
  }
  void send() {
  }

  void sendJoin(core.String id) {
    var pack = {};
    pack["action"] = "join";
    pack["mode"] = "broadcast";
    pack["id"] = id;
    sendObject(pack);
  }


  void unicastPackage(core.String to, core.String from, core.Map pack) {
    var package = {};
    package["action"] = "pack";
    package["mode"] = "unicast";
    package["pack"] = pack;
    package["to"] = to;
    package["from"] = from;
    sendObject(package);
  }

  void sendObject(core.Map pack) {
    data.Uint8List buffer8 = Bencode.encode(pack);
    _websocket.sendByteBuffer(buffer8.buffer);
  }

  void sendBuffer(data.ByteBuffer buffer) {
    _websocket.sendByteBuffer(buffer);
  }

  void sendText(core.String message) {
    _websocket.sendString(message);
  }

  core.List<SignalClientListener> _observer = new core.List();
  void addEventListener(SignalClientListener observer) {
    _observer.add(observer);
  }

  void notifyUpdatePeer(core.List<core.String> peers) {
    for (SignalClientListener l in _observer) {
      l.updatePeer(peers);
    }
  }
 
  void notifyOnReceivePackage(
    core.String to, core.String from, core.Map pack) {
    for (SignalClientListener l in _observer) {
      l.onReceivePackage(to, from, pack);
    }
  }
}

class SignalClientListener {
  void updatePeer(core.List<core.String> uuidList) {
  }
  void onReceivePackage(core.String to, core.String from, core.Map pack) {
  }
}
