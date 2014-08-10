part of hetima;
class HetiHttpClient {
  HetiSocketBuilder _builder;
  HetiSocket socket = null;

  HetiHttpClient(HetiSocketBuilder builder) {
    _builder = builder;
  }

  async.Future<int> connect(String host, int port) {
    async.Completer<int> completer = new async.Completer();
    socket = _builder.createClient();
    socket.connect(host, port).then((HetiSocket socket) {
      if (socket == null) {
        completer.complete(-999);
      } else {
        completer.complete(1);
      }
    });
    return completer.future;
  }

  async.Future<HetiHttpResponse> get(String host, int port, String path) {
    ArrayBuilder builder = new ArrayBuilder();
    builder.appendString("GET" + " " + path + " " + "HTTP/1.1" + "\r\n");
    builder.appendString("Host:" + " " + host + "\r\n\r\n");
    socket.onReceive().listen((HetiReceiveInfo info) {
      String r = convert.UTF8.decode(socket.buffer.toList());
      print("\r\n######\r\n"+r+"\r\n#####\r\n");
    });
    socket.send(builder.toList()).then((HetiSendInfo info) {
      print("\r\n======"+info.resultCode.toString()+"\r\n");
    });
    return null;
  }

  void close() {
    if (socket != null) {
      socket.close();
    }
  }
}
