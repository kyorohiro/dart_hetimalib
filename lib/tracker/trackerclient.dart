part of hetima;

class TrackerClient {
  TrackerUrl trackerUrl = new TrackerUrl();
  String get trackerHost => trackerUrl.trackerHost;
  void set trackerHost(String host) {
    trackerUrl.trackerHost = host;
  }
  int get trackerPort => 6969;
  void set trackerPort(int port) {
    trackerUrl.trackerPort = port;
  }
  int get peerport => trackerUrl.port;
  void set peerport(int port) {
    trackerUrl.trackerPort = port;
  }
  String get path => trackerUrl.path;
  void set path(String path) {
    trackerUrl.path = path;
  }
  String get event => trackerUrl.event;
  void set event(String event) {
    trackerUrl.event = event;
  }
  String get peerID => trackerUrl.peerID;
  void set peerID(String peerID) {
    trackerUrl.peerID = peerID;
  }

  String get infoHash => trackerUrl.infoHashValue;

  void set infoHash(String infoHash) {
    trackerUrl.infoHashValue = infoHash;
  }
  String get header => trackerUrl.toHeader();
  HetiSocketBuilder _socketBuilder = null;

  TrackerClient(HetiSocketBuilder builder) {
    _socketBuilder = builder;
  }

  async.Future<RequestResult> request() {
    async.Completer<RequestResult> completer = new async.Completer();

    HetiHttpClient currentClient = new HetiHttpClient(_socketBuilder);
    print("--[A0]-" + trackerHost + "," + trackerPort.toString() + "," + path + header);
    currentClient.connect(trackerHost, trackerPort).then((int state) {
      Map<String, String> t = {};
      t["Connection"] = "close";
      return currentClient.get(path, t);
    }).then((HetiHttpClientResponse response){
      return TrackerResponse.createFromContent(response.body).then((TrackerResponse trackerResponse) {
        completer.complete(new RequestResult(trackerResponse, RequestResult.OK));
      });
    }).catchError((e) {
      completer.complete(new RequestResult(null, RequestResult.ERROR));
      print("##er end");
    }).whenComplete(() {
      currentClient.close();
      print("###done end");
    });
    return completer.future;
  }
}

class RequestResult {
  int code = 0;
  static final int OK = 0;
  static final int ERROR = -1;
  TrackerResponse response = null;
  RequestResult(TrackerResponse _respose, int _code) {
    code = _code;
    response = _respose;
  }
}
