part of hetima;

class Caller {
  html.RtcPeerConnection _connection = null;
  html.RtcDataChannel _datachannel = null;
  core.String _myuuid;
  core.String _targetuuid;
  SignalCient _signalclient;
  core.List<CallerEventListener> _obseverList = new core.List();

  core.Map _stuninfo = {
    "iceServers": [{
        "url": "stun:stun.l.google.com:19302"
      }]
  };
  core.Map _mediainfo = {
    'optional': [{
        'RtpDataChannels': true
      }]
  };

  Caller(core.String uuid) {
    _myuuid = uuid;
  }

  Caller setTarget(uuid) {
    _targetuuid = uuid;
    return this;
  }

  Caller setSignalClient(SignalCient signalclient) {
    _signalclient = signalclient;
    return this;
  }

  Caller addEventListener(CallerEventListener listener) {
    _obseverList.add(listener);
    return this;
  }

  Caller removeEventListener(CallerEventListener listener) {
    _obseverList.remove(listener);
    return this;
  }

  Caller init() {
    return this;
  }

  Caller connect() {
    _connection = new html.RtcPeerConnection(_stuninfo, _mediainfo);
    _connection.onIceCandidate.listen(_onIceCandidate);
    _connection.onDataChannel.listen(_onDataChannel);
    _datachannel = _connection.createDataChannel("message");
    _setChannelEvent(_datachannel);
  }

  ///
  ///
  ///
  void createOffer() {
    core.print("create offer");
    _connection.createOffer()
    .then(_onOffer)
    .then(_onError);
  }

  ///
  ///
  ///
  void createAnswer() {
    core.print("create answer");
    _connection.createAnswer()
    .then(_onAnswer)
    .then(_onError);
  }

  ///
  ///
  ///
  void sendMessage(data.ByteBuffer message) {
    _datachannel.sendByteBuffer(message);
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

  void _setLocalSdp(html.RtcSessionDescription description) {
    _connection.setLocalDescription(description)
    .then(_onSuccessLocalSdp);//.then(_onError);
  }

  void _onIceCandidate(html.RtcIceCandidateEvent event) {
    if (event.candidate == null) {
      core.print("fin onIceCandidate");
    }
  }

  void _onSuccessLocalSdp(dynamic) {
      core.print("sucess set loca sdp¥n" + 
          _connection.localDescription.sdp
          +"¥n");
      // send offer
      // send answer
      if(_signalclient != null) {
        _signalclient.send(this, _targetuuid, _myuuid, 
            _connection.localDescription.type,
            _connection.localDescription.sdp);
      }
  }

  void _onOffer(html.RtcSessionDescription sdp) {
    core.print("onOffer"+sdp.toString());
    _setLocalSdp(sdp);
  }
  void _onAnswer(html.RtcSessionDescription sdp) {
    core.print("onAnswer"+sdp.toString());
    _setLocalSdp(sdp);
  }

  void _onError(html.Event event) {
    core.print("onerror "+event.toString());
  }

  void _onDataChannel(html.RtcDataChannelEvent event) {
    _datachannel = event.channel;
    _setChannelEvent(_datachannel);
  }

  void _onDataChannelReceiveMessage(html.MessageEvent event) {
    core.print("onReceiveMessage");
  }

  void _onDataChannelOpen(html.Event event) {
    core.print("onOpen");
  }

  void _onDataChannelError(html.Event event) {
    core.print("onError"+event.toString());
  }

  void _onDataChannelClose(html.Event event) {
    core.print("onClose");
  }

  void _setChannelEvent(html.RtcDataChannel channel) {
    channel.onMessage.listen(_onDataChannelReceiveMessage);
    channel.onOpen.listen(_onDataChannelOpen);
    channel.onError.listen(_onDataChannelError);
    channel.onClose.listen(_onDataChannelClose);
  }
}

class CallerEventListener {
  void onIceCandidate(html.RtcIceCandidateEvent event) {
    ;
  }
}

//
//
//
class SignalCient {
  void send(Caller caller, core.String toUUid, core.String from, core.String type, core.String data) {
    ;
  }
  void onReceive(Caller caller, core.String type, core.String data) {
    switch (type) {
      case "answer":
      case "offer":
        caller.setRemoteSDP(type, data);
        break;
      case "ice":
        break;
    }
  }
}
