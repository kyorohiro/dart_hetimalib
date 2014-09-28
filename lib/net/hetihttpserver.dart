part of hetima;

class HetiHttpServer {

  async.StreamController _controllerOnNewRequest = new async.StreamController.broadcast();
  HetiSocketBuilder _builder;
  HetiSocket socket = null;
  String host;
  int port;
  HetiServerSocket _serverSocket = null;
  HetiHttpServer._internal(HetiServerSocket s) {
    _serverSocket = s;
  }

  static async.Future<HetiHttpServer> bind(HetiSocketBuilder builder, String address, int port) {
    async.Completer<HetiHttpServer> completer = new async.Completer();
    builder.startServer(address, port).then((HetiServerSocket serverSocket){
      completer.complete(new HetiHttpServer._internal(serverSocket));
      serverSocket.onAccept().listen((HetiSocket socket){
        EasyParser parser = new EasyParser(socket.buffer);
        
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
  
}