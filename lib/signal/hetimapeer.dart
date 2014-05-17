part of hetima_cl;

//
//
//
class HetimaPeer {
  SignalClient mClient = null;
  core.List<PeerInfo> mPeerInfoList = new core.List();
  core.String _mMyId = Uuid.createUUID();
  AdapterCallerExpectedSignalClient _mAdapterSignalClient;
  DirectCommand _mAdapterResponser;

  async.StreamController<core.List<core.String>> _mSignalFindPeer = new async.StreamController.broadcast();
  async.StreamController<MessageInfo> _mCallerReceiveMessage = new async.StreamController.broadcast();
  async.StreamController<StatusChangeInfo> _mStatusChange = new async.StreamController.broadcast();
  async.StreamController<RelayPackageInfo> _mRelayPackage = new async.StreamController.broadcast();

  HetimaPeer() {
    core.print("--new HetimaPeer :");
    mClient = new SignalClient();
    _mAdapterSignalClient = new AdapterCallerExpectedSignalClient(this, mClient);
    _mAdapterResponser = new DirectCommand(this);
  }

  void connectJoinServer() {
    core.print("--connectJoinServer :");
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
    core.print("--connectPeer :" + uuid);
    PeerInfo peerInfo = findPeerFromList(uuid);
    if (peerInfo == null || peerInfo.caller != null) {
      return;
    }
    peerInfo.caller = createCaller(uuid, _mAdapterSignalClient);
    peerInfo.caller.connect().createOffer();
  }

  void sendMessage(core.String uuid, core.String message) {
    core.print("--sendMessage :" + uuid + "." + message);
    PeerInfo peerInfo = findPeerFromList(uuid);
    if (peerInfo == null || peerInfo.caller == null) {
      return;
    }
    peerInfo.caller.sendText(message);
  }

  async.Stream<core.List<core.String>> onFindPeer() => _mSignalFindPeer.stream;
  async.Stream<MessageInfo> onMessage() => _mCallerReceiveMessage.stream;
  async.Stream<StatusChangeInfo> onStatusChange() => _mStatusChange.stream;
  async.Stream<RelayPackageInfo> onRelayPackage() => _mRelayPackage.stream;


  core.int get status => mClient.getState();
  core.String get id => _mMyId;

  void joinNetwork() {
    core.print("--joinNetwork :");
    if (mClient == null || mClient.getState() == SignalClient.CLOSED || mClient.getState() == SignalClient.CLOSING) {
      mClient = new SignalClient();
    }
    if (mClient.getState() != SignalClient.CONNECTING) {
      mClient.connect();
    }
  }

  core.List<PeerInfo> getPeerList() {
    core.print("--getPeerList :");
    return mPeerInfoList;
  }

  PeerInfo findPeerFromList(core.String uuid) {
    core.print("-[hetimapeer]-findPeerFromList :" + uuid);
    for (core.int i = 0; i < mPeerInfoList.length; i++) {
      if (mPeerInfoList[i].uuid == uuid) {
        return mPeerInfoList[i];
      }
    }
    return null;
  }

  void addPeerInfo(PeerInfo info) {
    core.print("-[hetimapeer]-addPeerInfo :m=" + info.uuid);
    mPeerInfoList.add(info);
  }
  PeerInfo getConnectedPeerInfo(core.String uuid) {
    core.print("--getConnectedPeerInfo :" + uuid);
    PeerInfo targetPeer = findPeerFromList(uuid);
    if (targetPeer == null) {
      targetPeer = new PeerInfo(uuid);
      addPeerInfo(targetPeer);
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
      core.print("xxxxxxxxxxxxxxx findnode =" + uuid);
      if (uuid != _mMyId && null == findPeerFromList(uuid)) {
        PeerInfo peerInfo = new PeerInfo(uuid);
        addPeerInfo(peerInfo);
        peerInfo.relayClient = client;
        peerInfo.relayCaller = caller;
        adduuid.add(uuid);
      } else if (null != findPeerFromList(uuid)) {
        PeerInfo peerInfo = findPeerFromList(uuid);
        peerInfo.relayCaller = caller;
        peerInfo.relayClient = client;

      }
    }
    _mSignalFindPeer.add(adduuid);
  }

  Caller createCaller(core.String targetUUID, CallerExpectSignalClient esclient) {
    core.print("--createCaller :t=" + targetUUID+",m="+_mMyId);
    Caller ret = new Caller(_mMyId);
    ret.setSignalClient(esclient);
    ret.setTarget(targetUUID);
    ret.onReceiveMessage().listen((MessageInfo info) {
      _mCallerReceiveMessage.add(info);
    });
    ret.onReceiveMessage().listen(_mAdapterResponser.onReceiveMessage);

    ret.onStatusChange().listen((core.String s) {
      core.print("statuschange:" + s);
      _mStatusChange.add(new StatusChangeInfo(s));
    });
    return ret;
  }

  void requestFindNode(core.String toUuid, core.String target) {
    core.print("--requestFindNode :" + toUuid + "," + target);
    _mAdapterResponser.requestFindNode(toUuid, target);
  }

  void requestRelayPackage(core.String relayUuid, core.String toUuid, core.Map pack) {
    core.print("-[hetimapeer]-requestRelayPackage :" + toUuid + "," + relayUuid + "," + convert.JSON.encode(pack).length.toString());
    _mAdapterResponser.requestUnicastPackage(toUuid, relayUuid, this.id, pack);
  }

  void requestRelayConnectPeer(core.String relayUuid, core.String toUuid) {
    core.print("-[hetimapeer]-requestRelayConnectPeer :" + toUuid + "," + relayUuid);
    PeerInfo peerInfo = findPeerFromList(toUuid);
    if (peerInfo == null || peerInfo.caller == null) {
      core.print("--not found");
      return;
    }
    AdapterCESCCaller cescaller = new AdapterCESCCaller(this, relayUuid);
    peerInfo.caller = createCaller(toUuid, cescaller);
    peerInfo.caller.onReceiveMessage().listen(cescaller.onReceiveMessageFromCaller);
    peerInfo.caller.connect().createOffer();
  }

}


class StatusChangeInfo {
  core.String status = "";
  StatusChangeInfo(core.String s) {
    status = s;
  }
}

class RelayPackageInfo {
  core.Map pack;
  RelayPackageInfo(core.Map p) {
    pack = p;
  }
}
