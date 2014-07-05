part of hetima;

class TrackerUrl {
  static const String KEY_INFO_HASH = "info_hash";
  static const String KEY_PEER_ID = "peer_id";
  static const String KEY_PORT = "port";
  static const String KEY_EVENT = "event";
  static const String VALUE_EVENT_STARTED = "started";
  static const String VALUE_EVENT_STOPPED = "stopped";
  static const String VALUE_EVENT_COMPLETED = "completed";
  static const String KEY_DOWNLOADED = "downloaded";
  static const String KEY_UPLOADED = "uploaded";
  static const String KEY_LEFT = "left";

  String trackerHost = "127.0.0.1";
  int trackerPort = 6969;
  String path = "/announce";
  String scheme = "http";
  int port = 6969;

  String infoHashValue = "";
  String peerID = "";
  String event = "";
  int downloaded = 0;
  int uploaded = 0;
  int left = 0;

  void set announce(String announce) {
    HttpUrlDecoder decoder = new HttpUrlDecoder();
    HttpUrl url = decoder.decodeUrl(announce);
    path = url.host;
    scheme = url.scheme;
    path = url.path;
  }

  String toString() {
    return scheme + "://" + trackerHost + ":" + trackerPort.toString() + "" + path + toHeader();
  }

  String toHeader() {
    return "?" + KEY_INFO_HASH + "=" + infoHashValue + "&" + KEY_PORT + "=" + port.toString() + "&" + KEY_PEER_ID + "=" + peerID + "&" + KEY_EVENT + "=" + event + "&" + KEY_UPLOADED + "=" + uploaded.toString() + "&" + KEY_DOWNLOADED + "=" + downloaded.toString() + "&" + KEY_LEFT + "=" + left.toString();
  }

}

class TrackerResponse {
  static final String KEY_INTERVAL = "interval";
  static final String KEY_PEERS = "peers";
  static final String KEY_PEER_ID = "peer_id";
  static final String KEY_IP = "ip";
  static final String KEY_PORT = "port";
  int interval = 10;
  List<PeerAddress> peers = [];

  Map<String,Object> createResponse(bool isCompat) {
    Map ret = new Map();
    ret[KEY_INTERVAL] = interval;
    if (isCompat) {
      ArrayBuilder builder = new ArrayBuilder();
      //builder.appendUint8List(buffer, index, length);
    } else {
      List wpeers = ret[KEY_PEERS] = [];
      for (PeerAddress p in peers) {
        Map wpeer = {};
        wpeer[KEY_IP] = p.ipAsString;
        wpeer[KEY_PEER_ID] = p.peerIdAsString;
        wpeer[KEY_PORT] = p.port;
        wpeers.add(wpeer);
      }
    }
    return ret;
  }
}

class PeerAddress {
  List<int> peerId;
  String address;
  List<int> ip;
  int port;

  PeerAddress(List<int> _peerId, String _address, List<int> _ip, int _port) {
    peerId = new List.from(_peerId);
    address = _address;
    ip = new List.from(_ip);
    port = _port;
  }
  
  String get peerIdAsString => PercentEncode.encode(peerId);
  String get portdAsString => port.toString();
  String get ipAsString {
    return ""+ip[0].toString()+"."+ip[1].toString()
        +"."+ip[2].toString()+"."+ip[3].toString();
  }
}

class PeerIdCreator {
  static math.Random _random = new math.Random(new DateTime.now().millisecond);
  static List<int> createPeerid(String id) {
    List<int> output = new List<int>(20);
    for (int i = 0; i < 20; i++) {
      output[i] = _random.nextInt(0xFF);
    }
    List<int> idAsCode = id.codeUnits;
    for(int i=0;i<5&&i<idAsCode.length;i++) {
      output[i+1] = idAsCode[i];
    }
    return output;
  }
}
