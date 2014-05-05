part of hetima_sv;

class SignalServer {
  core.String _address = "localhost";
  core.int port = 8082;
  io.HttpServer _server;
  core.List<io.WebSocket> _temporaryConnectionList = new core.List();
  core.Map<core.String,io.WebSocket> _connectionList = new core.Map();

  void start() {
    io.HttpServer.bind(_address, port).then((io.HttpServer server){
      server.listen(onListen);
    });//.catchError((){onError("bind error");});
  }

  void onListen(io.HttpRequest request){
    if(io.WebSocketTransformer.isUpgradeRequest(request)) {
      io.WebSocketTransformer.upgrade(request).then(onConnect);
    } else {
      request.response.statusCode = io.HttpStatus.FORBIDDEN;
      request.response.write("this server support websocket only");
      request.response.close();
    }
  }

  void onConnect(io.WebSocket socket) {
    core.print("connect");
    _temporaryConnectionList.add(socket);
    socket.listen((dynmics){
      core.print("receive:"+dynmics);
    },
    onDone:(){onWsDone(socket,"done");});
//    onError:(){onWsDone(socket, "error");});
    //*/
  }

  void onWsDone(io.WebSocket socket, core.String message) {
    core.print(message); 
    _temporaryConnectionList.remove(socket);
  }

  void onError(core.String message) {
    core.print(message); 
  }
}