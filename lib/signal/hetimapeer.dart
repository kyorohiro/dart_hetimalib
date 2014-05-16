part of hetima_cl;

//
//
//
class HetimaPeer {
  SignalClient mClient = null;
  core.List<PeerInfo> mPeerInfoList = new core.List();
  core.String _mMyId = Uuid.createUUID();
  AdapterCallerExpectedSignalClient _mAdapterSignalClient;
  AdapterPeerDirectCommand _mAdapterResponser;

  async.StreamController<core.List<core.String>> _mSignalFindPeer = new async.StreamController.broadcast();
  async.StreamController<MessageInfo> _mCallerReceiveMessage = new async.StreamController.broadcast();
  async.StreamController<StatusChangeInfo> _mStatusChange = new async.StreamController.broadcast();

  HetimaPeer() {
    mClient = new SignalClient();
    _mAdapterSignalClient = new AdapterCallerExpectedSignalClient(this, mClient);
    _mAdapterResponser = new AdapterPeerDirectCommand(this);
  }

  void connectJoinServer() {
    if (mClient.getState() == SignalClient.CLOSED) {
      mClient = new SignalClient();
    }
    mClient.onFindPeer().listen((core.List<core.String> uuidList) {
      onFindPeerF(uuidList, mClient, null);
    });
    mClient.onReceiveMessage().listen(_mAdapterSignalClient.onReceiveMessageFromSignalServer);

    mClient.connect().then((html.Event e) {
      mClient.sendJoin(_mMyId);
    });
  }

  void connectPeer(core.String uuid) {
    PeerInfo peerInfo = findPeerFromList(uuid);
    if (peerInfo == null || peerInfo.caller != null) {
      return;
    }
    peerInfo.caller = createCaller(uuid, _mAdapterSignalClient);
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

  async.Stream<StatusChangeInfo> onStatusChange() {
    return _mStatusChange.stream;
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
    core.print("--mm");
    for (core.int i = 0; i < mPeerInfoList.length; i++) {
      core.print("--mfff");
      if (mPeerInfoList[i].uuid == uuid) {
        core.print("--mdd");
        return mPeerInfoList[i];
      }
    }
    core.print("--nn");
    return null;
  }

  PeerInfo getConnectedPeerInfo(core.String uuid) {
    PeerInfo targetPeer = findPeerFromList(uuid);
    if (targetPeer == null) {
      targetPeer = new PeerInfo(uuid);
      mPeerInfoList.add(targetPeer);
    }
    if (targetPeer.caller == null) {
      targetPeer.caller = createCaller(uuid, _mAdapterSignalClient);
      targetPeer.caller.connect();
    }
    return targetPeer;
  }

  void onFindPeerF(core.List<core.String> uuidList, SignalClient client, Caller caller) {
    core.print("find peer from server :" + uuidList.length.toString());
    core.List<core.String> adduuid = new core.List();
    for (core.String uuid in uuidList) {
      core.print("xxxxxxxxxxxxxxx findnode ="+uuid);
      if (uuid != _mMyId && null == findPeerFromList(uuid)) {
        PeerInfo peerInfo = new PeerInfo(uuid);
        mPeerInfoList.add(peerInfo);
        peerInfo.relayClient = client;
        peerInfo.relayCaller = caller;
        adduuid.add(uuid);
      } else if(null != findPeerFromList(uuid)) {
        PeerInfo peerInfo = findPeerFromList(uuid);
        peerInfo.relayCaller = caller;
        peerInfo.relayClient = client;
                
      }
    }
    _mSignalFindPeer.add(adduuid);
  }

  Caller createCaller(core.String targetUUID, CallerExpectSignalClient esclient) {
    Caller ret = new Caller(_mMyId);
    ret.setSignalClient(esclient);
    ret.setTarget(targetUUID);
    ret.onReceiveMessage().listen((MessageInfo info) {
      _mCallerReceiveMessage.add(info);
    });
    ret.onReceiveMessage().listen(_mAdapterResponser.onReceiveMessageFromSignalServer);

    ret.onStatusChange().listen((core.String s) {
      core.print("statuschange:" + s);
      _mStatusChange.add(new StatusChangeInfo(s));
    });
    return ret;
  }

  void requestFindNode(core.String toUuid, core.String target) {
    core.print("--aa");
    _mAdapterResponser.requestFindNode(toUuid, target);
    core.print("--bb");
  }
  void requestRelayPackage(core.String relayUuid, core.String toUuid, core.Map pack) {
    _mAdapterResponser.requestUnicastPackage(toUuid, relayUuid, pack);
  }
}


class StatusChangeInfo {
  core.String status = "";
  StatusChangeInfo(core.String s) {
    status = s;
  }
}


