part of hetima_cl;

//
//
//
class HetimaPeer {
  SignalClient mClient = null;
  core.List<PeerInfo> mPeerInfoList = new core.List();
  core.String mId = Uuid.createUUID();
  AdapterSignalClient mAdapter;

  HetimaPeer() {

  }

  async.Future connect() {
    mClient.onFindPeer().listen(onFindPeerFromSignalServer);
    mClient.onReceiveMessage().listen(onReceiveMessageFromSignalServer);
    mAdapter = new AdapterSignalClient(mClient);
    return mClient.connect();
  }

  core.String get id => mId;

  void joinNetwork() {
    if (mClient == null 
        || mClient.getState() == SignalClient.CLOSED 
        || mClient.getState() == SignalClient.CLOSING) {
      mClient = new SignalClient();
    }
    if (mClient.getState() != SignalClient.CONNECTING) {
      mClient.connect();
    }
  }

  core.List<PeerInfo> getPeerList() {
    return null;
  }

  PeerInfo findPeerList(core.String uuid) {
    for(core.int i=0;i<mPeerInfoList.length;i++) {
      if(mPeerInfoList[i].uuid == uuid) {
        return mPeerInfoList[i];
      }
    }
    return null;
  }

  void onFindPeerFromSignalServer(core.List<core.String> uuidList) {
    for(core.String uuid in uuidList) {
      if(mPeerInfoList.contains(uuid) != false && uuid != mId) {
        mPeerInfoList.add(new PeerInfo(uuid));
      }
    }
  }

  void onReceiveMessageFromSignalServer(SignalMessageInfo message) {
    core.Map pack = message.pack;
    core.String to = message.to;
    core.String from = message.from;

    if (convert.UTF8.decode(pack["action"]) != "caller") {
      return;
    }
    core.String type = convert.UTF8.decode(pack["type"]);
    core.String data = convert.UTF8.decode(pack["data"]);
    PeerInfo targetPeer = findPeerList(to);
    if(targetPeer != null && targetPeer.caller != null) {
      mAdapter.onReceive(targetPeer.caller, to, from, type, data);
    }
  }
}

class AdapterSignalClient extends CallerExpectSignalClient {
  SignalClient _mClient = null;
  AdapterSignalClient(SignalClient client) {
    _mClient = client;
  }

  void send(Caller caller, core.String to, core.String from, core.String type, core.String data) {
    core.print("signal client send");
    {
      var pack = {};
      pack["action"] = "caller";
      pack["type"] = type;
      pack["data"] = data;
      _mClient.unicastPackage(to, from, pack);
    }
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
  SignalClient relayClient = null;
  Caller relayCaller = null;

  PeerInfo(core.String uuid) {
    _uuid = uuid;
  }

  core.String get uuid => _uuid;

  core.int get status => _status;

  void set staus(core.int v) {
    _status = v;
  }
}
