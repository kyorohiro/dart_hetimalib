part of hetima;
class HetiSocketBuilderSimulator extends HetiSocketBuilder {
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

class HetiSocketManager {
  static HetiSocketManager _sinst = new HetiSocketManager();

  HetiSocketManager getInstance() {
    return _sinst;
  }
  
  List<HetiSocketSimulator> _map = new List();
  void addHetiSocket(HetiSocketSimulator socket) {
    if(_map.contains(socket)){
      _map.remove(socket);
    }
    _map.add(socket);
  }
  
  void removeHetiSocket(HetiSocketSimulator socket) {
    _map.remove(socket.id);
  }

  HetiSocketSimulator getFromAddress(String host, int port) {
    for(HetiSocketSimulator s in _map) {
      if(s.remoteAddress == host && s.remotePort == port) {
        return s;
      }
    }
    return null;
  }
}

class HetiSocketSimulator extends HetiSocket {
  static int _id = 0;

  String id = "";
  String remoteAddress = "";
  int remotePort = 0; 
  async.StreamController _controller = new async.StreamController();
  
  HetiSocketSimulator() {
    id = (_id++).toString();
  }

  @override
  async.Future<HetiSocket> connect(String peerAddress, int peerPort) {
    async.Completer<HetiSocket> completer = new async.Completer();
    HetiSocket socket = new HetiSocketSimulator();
    completer.complete(socket);
    return completer.future;
  }

  @override
  async.Stream<HetiReceiveInfo> onReceive() {
    return _controller.stream;
  }

  @override
  async.Future<HetiSendInfo> send(List<int> data) {
    
  }
}
