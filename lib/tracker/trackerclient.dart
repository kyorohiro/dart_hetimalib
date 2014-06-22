part of hetima_sv;

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

  async.Future<RequestResult> request() {
    async.Completer<RequestResult> ret = new async.Completer();
    io.HttpClient client = new io.HttpClient();
    (new async.Future.sync(() {
      print("--[A0]-" + trackerHost + "," + trackerPort.toString() + "," + path + header);
      return client.get(trackerHost, trackerPort, path + header)
      .then((io.HttpClientRequest request) {
        print("--[A1]-");
        return request.close().then((io.HttpClientResponse response) {
          print("--[A2]-");
          return response.listen((List<int> contents) {
            print("--[A3]-" + contents.runtimeType.toString());
            print("listen:" + contents.length.toString());
            print("ret:" + convert.UTF8.decode(contents));
          })
          .onDone(() {
            print("--[A4]-");
            print("done");
            ret.complete(new RequestResult());
          });
        });
      });
    })).catchError((e){
      ret.complete(new RequestResult());
      print("##er end");
    }).then((e){
      print("###done end");
    });
    return ret.future;
  }
}

class RequestResult {

}
