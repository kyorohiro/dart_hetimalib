part of hetima_sv;

class TrackerClient
{
  String host = "127.0.0.1";
  int port = 6969;
  String path = "/announce";

  async.Future<RequestResult> request() {
    io.HttpClient client = new io.HttpClient();
    client.get(host, port, path)
    .then((io.HttpClientRequest request){
      request.done.then((io.HttpClientResponse response){
        //
      });
    });
  }
}

class RequestResult 
{
  
}
