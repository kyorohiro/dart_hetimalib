part of hetima;

class TrackerPeerManager {
  List<int> _managdInfoHash = new List();
  List<int> get managedInfoHash => _managdInfoHash;
  int interval = 60;

  TrackerPeerManager(List<int> infoHash) {
    _managdInfoHash = infoHash.toList();
  }

  bool isManagedInfoHash(List<int> infoHash) {
    if(infoHash == null) {
      return false;
    }
    if(_managdInfoHash.length != infoHash.length) {
      return false;
    }
    for(int i=0;i<_managdInfoHash.length;i++) {
      if(infoHash[i] != _managdInfoHash[i]) {
        return false;
      }
    }
    return true;
  }

  List<PeerAddress> managedPeerAddress = new List();
  void update(TrackerRequest request) {
    if(!isManagedInfoHash(request.infoHash)) {
      return;
    }
    managedPeerAddress.add(new PeerAddress(request.peerId,
        request.address, request.ip, request.port));
  }

  TrackerResponse createResponse() {
    TrackerResponse response = new TrackerResponse();
    response.interval = this.interval;
    
    for(int i=0;i<50&&i<managedPeerAddress.length;i++) {
      response.peers.add(managedPeerAddress[i]);
    }

    return response;
  }
}

class TrackerRequest {

  String portAsString = "";
  String eventAsString = "";
  String infoHashAsString = "";
  String peeridAsString = "";
  String downloadedAsString = "";
  String uploadedAsString = "";
  String leftAsString = "";
  String address = "";
  List<int> ip = null;

  TrackerRequest.fromMap(Map<String, String> parameter, String _address, List<int> _ip) {
    portAsString = parameter[TrackerUrl.KEY_PORT];
    eventAsString = parameter[TrackerUrl.KEY_EVENT];
    infoHashAsString = parameter[TrackerUrl.KEY_INFO_HASH];
    peeridAsString = parameter[TrackerUrl.KEY_PEER_ID];
    downloadedAsString = parameter[TrackerUrl.KEY_DOWNLOADED];
    uploadedAsString = parameter[TrackerUrl.KEY_UPLOADED];
    leftAsString = parameter[TrackerUrl.KEY_LEFT];
    address = _address;
    ip = new List.from(_ip);
  }
  
  List<int> get infoHash => PercentEncode.decode(infoHashAsString).toList();
  List<int> get peerId => PercentEncode.decode(peeridAsString).toList();
  int get port => int.parse(portAsString);
}
