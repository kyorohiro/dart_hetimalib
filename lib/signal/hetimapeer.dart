part of hetima_cl;

//
//
//
class HetimaPeer {
  void joinNetwork() {
    
  }

  core.List<PeerInfo> getPeerList() {
    
  }
}

class PeerInfo {
  static core.int NONE         = 0;
  static core.int CONNECTING   = 1;
  static core.int CONNECTED    = 2;
  static core.int DISCONNECTED = 3;

  Caller caller = null;
  core.String _uuid = null;
  core.int _status = NONE;
  SignalClient relayClient = null;
  Caller relayCaller = null;

  PeerInfo(core.String uuid) {
    _uuid = uuid;
  }

  core.String get uuid {
    return _uuid;
  }

  core.int get status {
    return _status;
  }
  
  void set staus(core.int v) {
    _status = v;
  }
}