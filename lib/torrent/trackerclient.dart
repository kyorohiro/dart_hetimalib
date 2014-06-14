part of hetima_sv;

class TrackerClient
{
  TrackerUrl trackerUrl = new TrackerUrl();
  String get trackerHost => trackerUrl.trackerHost;
  int get trackerPort => 6969;
  int get peerport => trackerUrl.port;
  String get path => trackerUrl.path;
  String get event => trackerUrl.event;
  String get peerID => trackerUrl.peerID;
  String get infoHash => trackerUrl.infoHashValue;

  String get header => trackerUrl.toHeader();

  async.Future<RequestResult> request() {
    io.HttpClient client = new io.HttpClient();
    client.get(trackerHost, trackerPort, path+header)
    .then((io.HttpClientRequest request){
      request.done.then((io.HttpClientResponse response){
        //
      });
    });
    return null;
  }
}

class RequestResult 
{
  
}
