part of hetima_cl;

class AdapterCallerExpectedSignalClient extends CallerExpectSignalClient {
  SignalClient _mClient = null;
  HetimaPeer _mPeer = null;
  AdapterCallerExpectedSignalClient(HetimaPeer peer, SignalClient client) {
    _mClient = client;
    _mPeer = peer;
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

  void onReceiveMessageFromSignalServer(SignalMessageInfo message) {
    core.print("receive message from server :to=" + message.to + ",from=" + message.from + ",type=" + convert.UTF8.decode(message.pack["type"]));
    if (convert.UTF8.decode(message.pack["action"]) != "caller") {
      return;
    }
    core.String type = convert.UTF8.decode(message.pack["type"]);
    core.String data = convert.UTF8.decode(message.pack["data"]);
    PeerInfo targetPeer = _mPeer.getConnectedPeerInfo(message.from);
    onReceive(targetPeer.caller, message.to, message.from, type, data);
  }

}


class AdapterCESCCaller extends CallerExpectSignalClient {
  HetimaPeer _mPeer = null;
  core.String _mRelayUuid;

  AdapterCESCCaller(HetimaPeer peer, core.String relayUuid) {
    _mPeer = peer;
    _mRelayUuid = relayUuid;
  }

  void send(Caller caller, core.String to, core.String from, core.String type, core.String data) {
    core.print("[caller adapter] send "+to+","+from +",("+_mRelayUuid+")");
    var pack = {};
    pack["action"] = "caller";
    pack["type"] = type;
    pack["data"] = data;
    _mPeer.requestRelayPackage(_mRelayUuid, to, pack);
  }

  void onReceiveMessageFromCaller(MessageInfo message) {
    core.print("[caller adapter] receive message :to=" 
        + message.to + ",from=" + message.from + ",type=" 
        + convert.UTF8.decode(message.pack["type"])+",("+_mRelayUuid+")");
    if (convert.UTF8.decode(message.pack["action"]) != "caller") {
      return;
    }
    core.String type = convert.UTF8.decode(message.pack["type"]);
    core.String data = convert.UTF8.decode(message.pack["data"]);
    PeerInfo targetPeer = _mPeer.getConnectedPeerInfo(message.from);
    super.onReceive(targetPeer.caller, message.to, message.from, type, data);
  }

}

