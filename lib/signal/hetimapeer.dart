part of hetima_cl;

//
//
//
class HetimaPeer {
  SignalClient mClient = null;
  core.List<PeerInfo> mPeerInfoList = new core.List();
  core.String mId = Uuid.createUUID();
  
  HetimaPeer() {
        
  }

  async.Future connect() {
   // mClient.addEventListener(observer)
    return mClient.connect();
  }

  core.String get id => mId;

  void joinNetwork() {
    
  }

  core.List<PeerInfo> getPeerList() {
    
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
    core.print("onreceive to="+to+"from="+from+"type="+type+",data="+data.substring(0,10));
    super.onReceive(caller, to, from, type, data);
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

  core.String get uuid => _uuid;

  core.int get status => _status;
  
  void set staus(core.int v) {
    _status = v;
  }
}