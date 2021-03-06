part of hetima;

class HetiHttpServer {

  async.StreamController _controllerOnNewRequest = new async.StreamController.broadcast();
  HetiSocketBuilder _builder;
  String host;
  int port;
  HetiServerSocket _serverSocket = null;
  HetiHttpServer._internal(HetiServerSocket s) {
    _serverSocket = s;
  }

  void close() {
    if(_serverSocket != null) {
      _serverSocket.close();
      _serverSocket = null;
      _controllerOnNewRequest.close();
      _controllerOnNewRequest = null;
    }
  }
  static async.Future<HetiHttpServer> bind(HetiSocketBuilder builder, String address, int port) {
    async.Completer<HetiHttpServer> completer = new async.Completer();
    builder.startServer(address, port).then((HetiServerSocket serverSocket){
      HetiHttpServer server = new HetiHttpServer._internal(serverSocket);
      completer.complete(server);
      serverSocket.onAccept().listen((HetiSocket socket){
        EasyParser parser = new EasyParser(socket.buffer);
        HetiHttpResponse.decodeRequestMessage(parser).then((HetiHttpRequestMessageWithoutBody body){
          HetiHttpServerRequest request = new HetiHttpServerRequest();
          request.socket = socket;
          request.info = body;
          server._controllerOnNewRequest.add(request);
        });
      });
    }).catchError((e){
      completer.completeError(e);
    });
    return completer.future;
  }

  async.Stream<HetiHttpServerRequest> onNewRequest() {
    return _controllerOnNewRequest.stream;
  }
}

class HetiHttpServerRequest
{
  HetiSocket socket;
  HetiHttpRequestMessageWithoutBody info;
}