part of hetima_cl;

class Caller {
  static final core.int STATE_ZERO  = 0;
  static final core.int STATE_OPEN  = 1;
  static final core.int STATE_CLOSE = 2;

  static final core.String RTC_ICE_STATE_NEW = "new";
  //The ICE Agent is gathering addresses and/or waiting for remote candidates to be supplied.
  //http://dev.w3.org/2011/webrtc/editor/webrtc.html#idl-def-RTCIceConnectionState
  static final core.String RTC_ICE_STATE_CHECKING = "checking";
  //The ICE Agent has received remote candidates on at least one component, and is checking candidate pairs but has not yet found a connection. In addition to checking, it may also still be gathering.
  //http://dev.w3.org/2011/webrtc/editor/webrtc.html#idl-def-RTCIceConnectionState
  static final core.String RTC_ICE_STATE_CONNECTED = "connected";
  //The ICE Agent has found a usable connection for all components but is still checking other candidate pairs to see if there is a better connection. It may also still be gathering.
  //http://dev.w3.org/2011/webrtc/editor/webrtc.html#idl-def-RTCIceConnectionState
  static final core.String RTC_ICE_STATE_COMPLEDTED = "completed";
  //The ICE Agent has finished gathering and checking and found a connection for all components. Open issue: it is not clear how the non controlling ICE side knows it is in the state.
  //http://dev.w3.org/2011/webrtc/editor/webrtc.html#idl-def-RTCIceConnectionState
  static final core.String RTC_ICE_STATE_FAILED = "failed";
  //The ICE Agent is finished checking all candidate pairs and failed to find a connection for at least one component. Connections may have been found for some components.
  //http://dev.w3.org/2011/webrtc/editor/webrtc.html#idl-def-RTCIceConnectionState
  static final core.String RTC_ICE_STATE_DISCONNECTE = "disconnected";
  // Liveness checks have failed for one or more components. This is more aggressive than failed, and may trigger intermittently (and resolve itself without action) on a flaky network
  //http://dev.w3.org/2011/webrtc/editor/webrtc.html#idl-def-RTCIceConnectionState.
  static final core.String RTC_ICE_STATE_CLOSED = "closed";
  //The ICE Agent has shut down and is no longer responding to STUN requests.
  //http://dev.w3.org/2011/webrtc/editor/webrtc.html#idl-def-RTCIceConnectionState

  html.RtcPeerConnection _connection = null;
  html.RtcDataChannel _datachannel = null;
  core.String _myuuid;
  core.String _targetuuid;
  CallerExpectSignalClient _signalclient;
  core.int _status = 0;

  core.Map _stuninfo = {
    "iceServers": [{
        "url": "stun:stun.l.google.com:19302"
      }]
  };
  /*
   * http://stackoverflow.com/questions/21585681/send-image-data-over-rtc-data-channel
   * 
  core.Map _mediainfo = {
    'optional': [{
        'RtpDataChannels': true
      }]
  };*/
  core.Map _mediainfo = {
    'optional': []
  };

  Caller(core.String uuid) {
    _myuuid = uuid;
  }

  Caller setTarget(uuid) {
    _targetuuid = uuid;
    return this;
  }

  Caller setSignalClient(CallerExpectSignalClient signalclient) {
    _signalclient = signalclient;
    return this;
  }

  async.StreamController<MessageInfo> _onReceiveStreamController = new async.StreamController.broadcast();
  async.Stream<MessageInfo> onReceiveMessage() {
    return _onReceiveStreamController.stream;    
  }

  Caller init() {
    return this;
  }

  Caller connect() {
    _connection = new html.RtcPeerConnection(_stuninfo, _mediainfo);
    _connection.onIceCandidate.listen(_onIceCandidate);
    _connection.onDataChannel.listen(_onDataChannel);
    _connection.onAddStream.listen((html.MediaStreamEvent e){    core.print("#####[ww]#########onAddStream###");});
    _connection.onIceConnectionStateChange.listen((html.Event e){core.print("#####[ww]#########onIceConnectionStateChange###"
        +_connection.iceConnectionState+","+_connection.signalingState +","+_connection.iceGatheringState);});
    _connection.onNegotiationNeeded.listen((html.Event e){ 
      core.print("#####[ww]#########onNegotiationNeeded###"+_connection.iceConnectionState+","+_connection.signalingState);
      //createOffer();
    });
    _connection.onSignalingStateChange.listen((html.Event e){    core.print("#####[ww]#########onSignalingStateChange###"+_connection.iceConnectionState+","+_connection.signalingState);});
    _datachannel = _connection.createDataChannel("message");
    _datachannel.binaryType = "arraybuffer";
    _setChannelEvent(_datachannel);
    return this;
  }

  async.Completer<core.String> _taskDone = new  async.Completer();
  ///
  ///
  ///
  async.Future<core.String> createOffer() {
    core.print("#caller#create offer");
    _connection.createOffer()
    .then(_onOffer)
    .catchError((){_onError("create offer");});
    return _taskDone.future;
  }

  ///
  ///
  ///
  async.Future<core.String> createAnswer() {
    core.print("#caller#create answer");
    _connection.createAnswer()
    .then(_onAnswer)
    .catchError((){_onError("create answer");});
    return _taskDone.future;
  }

  ///
  ///
  ///
  void setRemoteSDP(core.String type, core.String sdp) {
    html.RtcSessionDescription rsd = new html.RtcSessionDescription();
    rsd.sdp = sdp;
    rsd.type = type;
    _connection.setRemoteDescription(rsd);
  }

  ///
  ///
  get status => _status;

  void _setLocalSdp(html.RtcSessionDescription description) {
    _connection.setLocalDescription(description)
    .then(_onSuccessLocalSdp);//.then(_onError);
  }

  void _onIceCandidate(html.RtcIceCandidateEvent event) {
    if (event.candidate == null) {
      core.print("fin onIceCandidate");
    }
    else {
     if(_signalclient != null) {
       core.print("---caller#send : ice");
        _signalclient.send(this, _targetuuid, _myuuid, 
            "ice",convert.JSON.encode(IceTransfer.iceObj2Map(event.candidate)));
      }
    }
  }

  void _onSuccessLocalSdp(dynamic) {
      core.print("sucess set loca sdp¥n" + 
          _connection.localDescription.sdp.toString().substring(0,10)
          +"¥n");
      // send offer
      // send answer
      if(_signalclient != null) {
        core.print("---caller#send sdp : "+_connection.localDescription.type);
        _signalclient.send(this, _targetuuid, _myuuid, 
            _connection.localDescription.type,
            _connection.localDescription.sdp);
      }
  }

  void _onOffer(html.RtcSessionDescription sdp) {
    core.print("onOffer"+sdp.toString());
    _setLocalSdp(sdp);
    if(!_taskDone.isCompleted) {
      _taskDone.complete("ok offer");
    }
  }
  void _onAnswer(html.RtcSessionDescription sdp) {
    core.print("onAnswer"+sdp.toString());
    _setLocalSdp(sdp);
    if(!_taskDone.isCompleted) {
      _taskDone.complete("ok answer");
    }
  }

  void _onError(core.String event) {
    core.print("onerror "+event.toString());
    if(!_taskDone.isCompleted) {
      _taskDone.complete("error");
    }
  }

  void _onDataChannel(html.RtcDataChannelEvent event) {
    _datachannel = event.channel;
    _setChannelEvent(_datachannel);
  }

  //
  // sent text message
  //
  void sendText(core.String text) {
    //_datachannel.sendString(text);
    core.Map pack = {};
    pack["action"] = "direct";
    pack["type"] = "text";
    pack["content"] = text;
    _datachannel.sendByteBuffer(Bencode.encode(pack).buffer);
  }

  //
  // send pack
  //
  void sendPack(core.Map pack) {
    core.Map pack = {};
    pack["action"] = "pack";
    pack["type"] = "map";
    pack["content"] = pack;
    _datachannel.sendByteBuffer(Bencode.encode(pack).buffer);
    
  }
  void _onDataChannelReceiveMessage(html.MessageEvent event) {
    core.print("onReceiveMessage :" + event.data.runtimeType.toString());
    if(event.data is data.ByteBuffer) {
      core.print("###000");
      data.ByteBuffer bbuffer = event.data;
      data.Uint8List buffer = new data.Uint8List.view(bbuffer);
      core.Map pack = Bencode.decode(buffer);
      if(convert.UTF8.decode(pack["type"]) == "text") {
        _onReceiveStreamController.add(new MessageInfo(
            _targetuuid,
            "text", 
            convert.UTF8.decode(pack["content"])
        ));
      }
    }
    else if(event.data is data.Uint8List) {
      core.print("###001");
      data.Uint8List buffer = event.data;
      core.Map pack = Bencode.decode(buffer);
      if(convert.UTF8.decode(pack["type"]) == "text") {
        _onReceiveStreamController.add(new MessageInfo(
            _targetuuid,
            "text", 
            convert.UTF8.decode(pack["content"])
        ));
      }
    }
  }

  void _onDataChannelOpen(html.Event event) {
    core.print("onOpenDataChannel:");
    _status = Caller.STATE_OPEN;
  }

  void _onDataChannelError(html.Event event) {
    core.print("onErrorDataChannel:"+event.toString());
    _status = Caller.STATE_CLOSE;
  }

  void _onDataChannelClose(html.Event event) {
    core.print("onCloseDataChannel:");
    _status = Caller.STATE_CLOSE;
  }

  void _setChannelEvent(html.RtcDataChannel channel) {
    channel.onMessage.listen(_onDataChannelReceiveMessage);
    channel.onOpen.listen(_onDataChannelOpen);
    channel.onError.listen(_onDataChannelError);
    channel.onClose.listen(_onDataChannelClose);
  }

  void addIceCandidate(html.RtcIceCandidate candidate) {
    _connection.addIceCandidate(candidate, (){
      core.print("add ice ok");
    }, (core.String e){
      core.print("add ice ng"+e.toString());
    });
  }

}


class IceTransfer {
  static core.Map iceObj2Map(html.RtcIceCandidate candidate) {
    core.Map ret = {
       'candidate':candidate.candidate,
       'sdpMid':candidate.sdpMid,
       'sdpMLineIndex':candidate.sdpMLineIndex,
     };
    return ret;
  }
}

class MessageInfo {
  core.String _message = "";
  core.String _type = "";
  core.String _uuid = "";

  MessageInfo(core.String uuid, core.String type, core.String message) {
    _message = message; 
    _type =type;
  }
  core.String get uuid => _uuid;
  core.String get type => _type;
  core.String get message => _message;
}
//
//
//
class CallerExpectSignalClient {
  void send(Caller caller, core.String toUUid, core.String from, core.String type, core.String data) {
    ;
  }
  void onReceive(Caller caller, core.String to, core.String from, core.String type, core.String data) {
    switch (type) {
      case "answer":
      case "offer":
        core.print("##1##" + caller.toString());
        caller.setRemoteSDP(type, data);
        core.print("##2##"+data);
        if(type =="offer") {
          core.print("##3## create answer");
          caller
          .setTarget(from)
          .createAnswer();
        }
        break;
      case "ice":
        core.print("##"+data+"##");
           html.RtcIceCandidate candidate =
               new html.RtcIceCandidate(convert.JSON.decode(data));
           core.print("add ice" + candidate.candidate+","+candidate.sdpMid+","+candidate.sdpMLineIndex.toString());
           caller.addIceCandidate(candidate);
          
        break;
    }
  }
}
