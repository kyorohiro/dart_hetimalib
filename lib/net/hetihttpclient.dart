part of hetima;
class HetiHttpGet
{
  HetiSocketBuilder _builder;
  HetiSocket socket = null;
  HetiHttpGet(HetiSocketBuilder builder) {
    _builder = builder;
  }

  async.Future<int> connect(String host, int port) {
    async.Completer<int> completer = new async.Completer();
    socket = _builder.createClient();
    socket.connect(host, port).then((HetiSocket socket){
      if(socket == null) {
        completer.complete(-999);
      } else {       
        completer.complete(1);
      }
    });
    return completer.future;
  }

  async.Future<HetiHttpResponse> get(String host, int port, String path) {
    ArrayBuilder builder  = new ArrayBuilder();
    builder.appendString("GET" + " " + path + " " + "HTTP/1.1" + "\r\n");
    builder.appendString("Host:" + " " + host + "\r\n");
    socket.onReceive().listen((HetiReceiveInfo info) {
    });
    socket.send(builder.toList()).then((HetiSendInfo info){
    });
    return null;
  }
  
  void close() {
    
  }
}

class HetiHttpResponse
{
  
}