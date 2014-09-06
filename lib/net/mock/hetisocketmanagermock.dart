part of hetima;
class HetiSocketBuilderMock extends HetiSocketBuilder {
  HetiSocket createClient() {
    return null;
  }

  async.Future<HetiServerSocket> startServer(String address, int port) {
    return null;
  }

  HetiUdpSocket createUdpClient() {
    return null;
  }
}

class HetiSocketManagerMock {
  static HetiSocketManagerMock _sinst = new HetiSocketManagerMock();

  static HetiSocketManagerMock getInstance() {
    return _sinst;
  }
  
  List<HetiSocketMock> _map = new List();
  void addHetiSocket(HetiSocketMock socket) {
    if(_map.contains(socket)){
      _map.remove(socket);
    }
    _map.add(socket);
  }
  
  void removeHetiSocket(HetiSocketMock socket) {
    _map.remove(socket.id);
  }

  HetiSocketMock getFromAddress(String host, int port) {
    for(HetiSocketMock s in _map) {
      if(s.localAddress == host && s.localPort == port) {
        return s;
      }
    }
    return null;
  }
}

class HetiSocketMock extends HetiSocket {
  static int _id = 0;

  String id = "";
  String remoteAddress = "";
  int remotePort = 0; 
  String localAddress = "";
  int localPort = 0;
  async.StreamController _controller = new async.StreamController();
  
  HetiSocketMock() {
    id = (_id++).toString();
  }

  @override
  async.Future<HetiSocket> connect(String peerAddress, int peerPort) {
    async.Completer<HetiSocket> completer = new async.Completer();
    HetiSocket socket = new HetiSocketMock();
    completer.complete(socket);
    return completer.future;
  }

  @override
  async.Stream<HetiReceiveInfo> onReceive() {
    return _controller.stream;
  }

  @override
  async.Future<HetiSendInfo> send(List<int> data) {
    HetiSocketManagerMock.getInstance();
  }
}
