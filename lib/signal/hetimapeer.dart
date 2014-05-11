part of hetima_cl;

//
//
//
class HetimaPeer {
  SignalClient mClient = null;
  core.List<PeerInfo> mPeerInfoList = new core.List();
  core.String _mMyId = Uuid.createUUID();
  AdapterSignalClient _mAdapterSignalClient;

  async.StreamController<core.List<core.String>> _mSignalFindPeer = new async.StreamController.broadcast();
  async.StreamController<MessageInfo> _mCallerReceiveMessage = new async.StreamController.broadcast();

  HetimaPeer() {
    mClient = new SignalClient();
    _mAdapterSignalClient = new AdapterSignalClient(mClient);
  }

  void connectJoinServer() {
    if (mClient.getState() == SignalClient.CLOSED) {
      mClient = new SignalClient();
    }
    mClient.onFindPeer().listen(onFindPeerFromSignalServer);
    mClient.onReceiveMessage().listen(_onReceiveMessageFromSignalServer);

    mClient.connect().then((html.Event e) {
      mClient.sendJoin(_mMyId);
    });
  }

  void connectPeer(core.String uuid) {
    PeerInfo peerInfo = findPeerFromList(uuid);
    if (peerInfo == null || peerInfo.caller != null) {
      return;
    }
    peerInfo.caller = _createCaller(uuid, _mAdapterSignalClient);
    peerInfo.caller.connect().createOffer();
  }

  void sendMessage(core.String uuid, core.String message) {
    PeerInfo peerInfo = findPeerFromList(uuid);
    if (peerInfo == null || peerInfo.caller == null) {
      return;
    }
    peerInfo.caller.sendText(message);
  }

  async.Stream<core.List<core.String>> onFindPeer() {
    return _mSignalFindPeer.stream;
  }

  async.Stream<MessageInfo> onMessage() {
    return _mCallerReceiveMessage.stream;
  }

  core.int get status => mClient.getState();
  core.String get id => _mMyId;

  void joinNetwork() {
    if (mClient == null || mClient.getState() == SignalClient.CLOSED || mClient.getState() == SignalClient.CLOSING) {
      mClient = new SignalClient();
    }
    if (mClient.getState() != SignalClient.CONNECTING) {
      mClient.connect();
    }
  }

  core.List<PeerInfo> getPeerList() {
    return mPeerInfoList;
  }

  PeerInfo findPeerFromList(core.String uuid) {
    for (core.int i = 0; i < mPeerInfoList.length; i++) {
      if (mPeerInfoList[i].uuid == uuid) {
        return mPeerInfoList[i];
      }
    }
    return null;
  }

  void onFindPeerFromSignalServer(core.List<core.String> uuidList) {
    core.print("find peer from server :" + uuidList.length.toString());
    core.List<core.String> adduuid = new core.List();
    for (core.String uuid in uuidList) {
      if(uuid != _mMyId && null == findPeerFromList(uuid)) {
        mPeerInfoList.add(new PeerInfo(uuid));
        adduuid.add(uuid);
      }
    }
    _mSignalFindPeer.add(adduuid);
  }

  void _onReceiveMessageFromSignalServer(SignalMessageInfo message) {
    core.Map pack = message.pack;
    core.String to = message.to;
    core.String from = message.from;
    core.print("receive message from server :to=" + to + ",from=" + from + ",type=" + convert.UTF8.decode(pack["type"]));
    if (convert.UTF8.decode(pack["action"]) != "caller") {
      return;
    }
    core.String type = convert.UTF8.decode(pack["type"]);
    core.String data = convert.UTF8.decode(pack["data"]);
    PeerInfo targetPeer = findPeerFromList(from);
    if (targetPeer == null) {
      targetPeer = new PeerInfo(from);
      mPeerInfoList.add(targetPeer);
    }
    if (targetPeer.caller == null) {
      targetPeer.caller = _createCaller(from, _mAdapterSignalClient);
      targetPeer.caller.connect();
    }
    _mAdapterSignalClient.onReceive(targetPeer.caller, to, from, type, data);
  }

  Caller _createCaller(core.String targetUUID, CallerExpectSignalClient esclient) {
    Caller ret = new Caller(_mMyId);
    ret.setSignalClient(esclient);
    ret.setTarget(targetUUID);
    ret.onReceiveMessage().listen((MessageInfo info) {
      _mCallerReceiveMessage.add(info);
    });
    return ret;
  }
}

class AdapterSignalClient extends CallerExpectSignalClient {
  SignalClient _mClient = null;
  AdapterSignalClient(SignalClient client) {
    _mClient = client;
  }

  set client(SignalClient c) {
    _mClient = c;
  }

  void send(Caller caller, core.String to, core.String from, core.String type, core.String data) {
    core.print("signal client send");
    var pack = {};
    pack["action"] = "caller";
    pack["type"] = type;
    pack["data"] = data;
    _mClient.unicastPackage(to, from, pack);
  }

  void onReceive(Caller caller, core.String to, core.String from, core.String type, core.String data) {
    core.print("onreceive to=" + to + "from=" + from + "type=" + type + ",data=" + data.substring(0, 10));
    super.onReceive(caller, to, from, type, data);
  }
}

class PeerInfo {
  static core.int NONE = 0;
  static core.int CONNECTING = 1;
  static core.int CONNECTED = 2;
  static core.int DISCONNECTED = 3;

  Caller caller = null;
  core.String _uuid = null;
  core.int _status = NONE;
  SignalClient _relayClient = null;
  Caller _relayCaller = null;

  PeerInfo(core.String uuid) {
    _uuid = uuid;
  }
  core.String get uuid => _uuid;
  core.int get status {
    if(caller == null) {
      return Caller.STATE_ZERO;
    }
    return caller.status;
  }
  set relayClient(SignalClient client) {
    _relayClient = client;
  }

  set relayCaller(Caller caller) {
    _relayCaller = caller;
  }

}
