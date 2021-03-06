part of hetima;

class UpnpDeviceSearcher {

  static String SSDP_ADDRESS = "239.255.255.250";
  static int SSDP_PORT = 1900;
  static String SSDP_M_SEARCH = """M-SEARCH * HTTP/1.1\r\n""" + """MX: 3\r\n""" + """HOST: 239.255.255.250:1900\r\n""" + """MAN: "ssdp:discover"\r\n""" + """ST: upnp:rootdevice\r\n""" + """\r\n""";
  static String SSDP_M_SEARCH_WANPPPConnectionV1 = """M-SEARCH * HTTP/1.1\r\n""" + """MX: 3\r\n""" + """HOST: 239.255.255.250:1900\r\n""" + """MAN: "ssdp:discover"\r\n""" + """ST: urn:schemas-upnp-org:service:WANPPPConnection:1\r\n""" + """\r\n""";
  static String SSDP_M_SEARCH_WANIPConnectionV1 = """M-SEARCH * HTTP/1.1\r\n""" + """MX: 3\r\n""" + """HOST: 239.255.255.250:1900\r\n""" + """MAN: "ssdp:discover"\r\n""" + """ST: urn:schemas-upnp-org:service:WANIPConnection:1\r\n""" + """\r\n""";
  static String SSDP_M_SEARCH_WANIPConnectionV2 = """M-SEARCH * HTTP/1.1\r\n""" + """MX: 3\r\n""" + """HOST: 239.255.255.250:1900\r\n""" + """MAN: "ssdp:discover"\r\n""" + """ST: urn:schemas-upnp-org:service:WANIPConnection:2\r\n""" + """\r\n""";

  List<UPnpDeviceInfo> deviceInfoList = new List();
  HetiUdpSocket _socket = null;
  async.StreamController<UPnpDeviceInfo> _streamer = new async.StreamController.broadcast();
  HetiSocketBuilder _socketBuilder = null;


  UpnpDeviceSearcher._internal(HetiSocketBuilder builder) {
    _socketBuilder = builder;
  }

  async.Future<int> _init() {
    _socket = _socketBuilder.createUdpClient();
    _socket.onReceive().listen((HetiReceiveUdpInfo info) {
      print("########");
      print("" + convert.UTF8.decode(info.data));
      print("########");
      extractDeviceInfoFromUdpResponse(info.data);
    });
    return _socket.bind("0.0.0.0", 0);
  }

  async.Future<int> close() {
    return _socket.close();
  }

  static async.Future<UpnpDeviceSearcher> createInstance(HetiSocketBuilder builder) {
    async.Completer<UpnpDeviceSearcher> completer = new async.Completer();
    UpnpDeviceSearcher ret = new UpnpDeviceSearcher._internal(builder);
    ret._init().then((int v) {
      completer.complete(ret);
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }

  async.Stream<UPnpDeviceInfo> onReceive() {
    return _streamer.stream;
  }

  async.Future<int> searchWanPPPDevice() {
    async.Completer completer = new async.Completer();

    _socket.send(convert.UTF8.encode(SSDP_M_SEARCH_WANPPPConnectionV1), SSDP_ADDRESS, SSDP_PORT).then((HetiUdpSendInfo iii) {
      print("###send[A]=" + iii.resultCode.toString());
    }).then((d) {
      return _socket.send(convert.UTF8.encode(SSDP_M_SEARCH_WANIPConnectionV1), SSDP_ADDRESS, SSDP_PORT);
    }).then((HetiUdpSendInfo iii) {
      print("###send[B]=" + iii.resultCode.toString());
      return _socket.send(convert.UTF8.encode(SSDP_M_SEARCH_WANIPConnectionV2), SSDP_ADDRESS, SSDP_PORT);
    }).then((HetiUdpSendInfo iii) {
      print("###send[C]=" + iii.resultCode.toString());
    }).catchError((e) {
      completer.completeError(e);
    });

    new async.Future.delayed(new Duration(seconds: 4), () {
      completer.complete(0);
    });
    return completer.future;
  }

  void extractDeviceInfoFromUdpResponse(List<int> buffer) {
    ArrayBuilder builder = new ArrayBuilder();
    EasyParser parser = new EasyParser(builder);
    builder.appendIntList(buffer, 0, buffer.length);
    HetiHttpResponse.decodeHttpMessage(parser).then((HetiHttpMessageWithoutBody message) {
      UPnpDeviceInfo info = new UPnpDeviceInfo(message.headerField, _socketBuilder);
      if (!deviceInfoList.contains(info)) {
        deviceInfoList.add(info);
        info.extractService().then((int v) {
          _streamer.add(info);
        });
      }
    });
  }

}
