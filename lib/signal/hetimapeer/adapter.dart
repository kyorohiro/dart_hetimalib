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



class AdapterPeerDirectCommand {
  HetimaPeer _mPeer = null;
  AdapterPeerDirectCommand(HetimaPeer peer) {
    _mPeer = peer;
  }

  void requestFindNode(core.String toUuid, core.String target) {
    core.print("--cc");
    PeerInfo peerinfo = _mPeer.findPeerFromList(toUuid);
    if (peerinfo == null || peerinfo.caller == null) {
      core.print("--ee");
      return;
    }
    core.Map pack = {};
    pack["m"] = "request";
    pack["a"] = "findnode";
    pack["v"] = target;
    peerinfo.caller.sendPack(pack);
    core.print("--dd");
  }

  void handleFindnode(MessageInfo message) {
    if (convert.UTF8.decode(message.pack["a"]) != "findnode") {
      return;
    }
    if (convert.UTF8.decode(message.pack["m"]) == "request") {
      core.print("xxxxxxxxxxxxxxx findnode -001");
      core.Map pack = {};
      pack["m"] = "response";
      pack["a"] = "findnode";
      core.List peers = pack["v"] = new core.List<core.String>();
      core.List<PeerInfo> infos = _mPeer.getPeerList();
      for (core.int i = 0; i < infos.length; i++) {
        if (infos[i].status == Caller.RTC_ICE_STATE_CONNECTED || infos[i].status == Caller.RTC_ICE_STATE_COMPLEDTED) {
          peers.add(infos[i].uuid);
        }
      }
      message.caller.sendPack(pack);
    } else {
      core.print("xxxxxxxxxxxxxxx findnode nnnn");
      core.List<core.String> uuidList = new core.List();
      core.List<data.Int8List> cashList = message.pack["v"];
      for (core.int i = 0; i < cashList.length; i++) {
        uuidList.add(convert.UTF8.decode(cashList[i]));
      }
      _mPeer.onFindPeerF(uuidList, null, message.caller);
    }
  }

  void requestUnicastPackage(core.String toUuid, core.String relayUuid, core.Map p) {
    core.print("--cc1");
    PeerInfo peerinfo = _mPeer.findPeerFromList(relayUuid);
    if (peerinfo == null || peerinfo.caller == null) {
      core.print("--ee");
      return;
    }
    core.Map pack = {};
    pack["m"] = "request";
    pack["a"] = "unicast";
    pack["v"] = p;
    pack["t"] = toUuid;
    pack["r"] = relayUuid;
    peerinfo.caller.sendPack(pack);
    core.print("--dd1");
  }

  void handleUnicastPackage(MessageInfo message) {
     if (convert.UTF8.decode(message.pack["a"]) != "unicast") {
       return;
     }
     core.print("xxxxxxxxxxxxxxx request unicast nnnn");

     if (convert.UTF8.decode(message.pack["m"]) == "request") {
       if(convert.UTF8.decode(message.pack["t"]) == _mPeer.id) {
         core.print("xxxxxxxxxxxxxxx sdfsdfasdfad[E]");
         return;
       }
       core.print("xxxxxxxxxxxxxxx request unicast ---------------------[A]");
       core.String toUuid = convert.UTF8.decode(message.pack["t"]);
       PeerInfo info = _mPeer.findPeerFromList(toUuid);
       if(info == null) {
         core.print("xxxxxxxxxxxxxxx sdfsdfasdfad[E] null");         
       }
       info.caller.sendPack(message.pack);
     } else {
       core.print("xxxxxxxxxxxxxxx request unicast ---------------------[B]");
     }
     
   }
  
  void onReceiveMessageFromSignalServer(MessageInfo message) {
    if ("map" == message.type) {
      core.String action = convert.UTF8.decode(message.pack["a"]);
      if (action == "findnode") {
        handleFindnode(message);
      } 
      else if(action == "unicast") {
        handleUnicastPackage(message);
      }
    }
    /*
    else {
      pack["m"] = "request";
      pack["a"] = "unicast";
      pack["v"] = pack;
      pack["t"] = toUuid;
      pack["r"] = relayUuid;
    }*/
  }
}
