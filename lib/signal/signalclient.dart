part of hetima_cl;

class SignalClient
{
  static core.int NULL = -1;
  static core.int CONNECTING = 0;// The connection is not yet open.
  static core.int OPEN = 1;// The connection is open and ready to communicate.
  static core.int CLOSING = 2;// The connection is in the process of closing.
  static core.int CLOSED = 3;// The connection is closed or couldn't be opened.
  
  core.String _websocketUrl = "ws://localhost:8082/websocket";
  html.WebSocket _websocket;

  void init() {
    _websocket = new html.WebSocket(_websocketUrl);
    _websocket.binaryType = "arraybuffer";
    _websocket.onOpen.listen(onOpen);
    _websocket.onMessage.listen(onMessage);
    _websocket.onError.listen(onError);
    _websocket.onClose.listen(onClose);
  }

  void onMessage(html.MessageEvent e) {
    core.print("type="+e.type+","+e.data.runtimeType.toString());
    if(e is core.String) {
      core.print("data="+e.data);      
    }
    else if(e.data is data.Uint8List) {
      data.Uint8List buffer = e.data;
      onReceiveSignalMessage(Bencode.decode(buffer));
    }
  }

  void onReceiveSignalMessage(core.Map message) {
    core.print("receive signal message"+convert.JSON.encode(message));
    
    if(convert.UTF8.decode(message["action"]) == "join") {
      if(convert.UTF8.decode(message["mode"]) == "response") {
        core.List peers = message["peers"];
        for(core.int i=0;i<peers.length;i++) {
          core.print(""+convert.UTF8.decode(peers[i]));
        }
      } else {
        core.print(""+convert.UTF8.decode(message["from"]));
      }
    }
  }

  core.int getState() {
    if(_websocket == null) {
      return -1;
    }
    return _websocket.readyState;
  }
  void onOpen(html.Event e) {
  }
  void onClose(html.CloseEvent e) {
  }
  void onError(html.Event e) {
  }
  void send() {
  }

  void sendJoin(core.String id) {
    var pack = {};
    pack["action"] = "join";
    pack["mode"] = "broadcast";
    pack["id"] = id;
    _websocket.sendByteBuffer(Bencode.encode(pack).buffer);
  }

  void sendBuffer(data.ByteBuffer buffer){
    _websocket.sendByteBuffer(buffer);
  }

  void sendText(core.String message) {
    _websocket.sendString(message);   
  }

}