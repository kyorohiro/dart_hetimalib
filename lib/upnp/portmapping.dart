part of hetima;

class UpnpDeviceSearcher {

  static String SSDP_ADDRESS = "239.255.255.250";
  static int SSDP_PORT = 1900;
  static String SSDP_M_SEARCH = """M-SEARCH * HTTP/1.1\r\n""" + """MX: 3\r\n""" + """HOST: 239.255.255.250:1900\r\n""" + """MAN: "ssdp:discover"\r\n""" + """ST: upnp:rootdevice\r\n""" + """\r\n""";
  static String SSDP_M_SEARCH_WANPPPConnection = """M-SEARCH * HTTP/1.1\r\n""" + """MX: 3\r\n""" + """HOST: 239.255.255.250:1900\r\n""" + """MAN: "ssdp:discover"\r\n""" + """ST: urn:schemas-upnp-org:service:WANPPPConnection:1\r\n""" + """\r\n""";
  static String SSDP_M_SEARCH_WANIPConnection = """M-SEARCH * HTTP/1.1\r\n""" + """MX: 3\r\n""" + """HOST: 239.255.255.250:1900\r\n""" + """MAN: "ssdp:discover"\r\n""" + """ST: urn:schemas-upnp-org:service:WANIPConnection:1\r\n""" + """\r\n""";

  List<UPnpDeviceInfo> deviceInfoList = new List();
  HetiUdpSocket _socket = null;
  async.StreamController<UPnpDeviceInfo> _streamer = new async.StreamController();
  HetiSocketBuilder _socketBuilder = null;

  UpnpDeviceSearcher(HetiSocketBuilder builder) {
    _socketBuilder = builder;
  }

  async.Future<int> init() {
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
    UpnpDeviceSearcher ret = new UpnpDeviceSearcher(builder);
    ret.init().then((int v) {
      completer.complete(ret);
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }

  async.Stream<UPnpDeviceInfo> onReceive() {
    return _streamer.stream;
  }

  void searchWanPPPDevice() {
    _socket.send(convert.UTF8.encode(SSDP_M_SEARCH_WANPPPConnection), SSDP_ADDRESS, SSDP_PORT).then((HetiUdpSendInfo iii) {
      print("###send[A]=" + iii.resultCode.toString());
    }).then((d) {
      return _socket.send(convert.UTF8.encode(SSDP_M_SEARCH_WANIPConnection), SSDP_ADDRESS, SSDP_PORT);
    }).then((HetiUdpSendInfo iii) {
      print("###send[B]=" + iii.resultCode.toString());
    }).catchError((e) {
    });
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

class UPnpPPPDevice {
  String KEY = "SOAPACTION";
  String VALUE = """\"urn:schemas-upnp-org:service:WANPPPConnection:1#GetExternalIPAddress\"""";
  String BODY = """<?xml version="1.0"?><SOAP-ENV:Envelope xmlns:SOAP-ENV:="http://schemas.xmlsoap.org/soap/envelope/" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><SOAP-ENV:Body><m:GetExternalIPAddress xmlns:m="urn:schemas-upnp-org:service:WANPPPConnection:1"></m:GetExternalIPAddress></SOAP-ENV:Body></SOAP-ENV:Envelope>""";

  UPnpDeviceInfo _base = null;
  UPnpPPPDevice(UPnpDeviceInfo base) {
    _base = base;
  }

  async.Future<GetExternalIPAddressResult> requestGetExternalIPAddress() {
    async.Completer<GetExternalIPAddressResult> completer = new async.Completer();
    HetiSocket socket = _base.getSocketBuilder().createClient();
    String location = _base.getValue(UPnpDeviceInfo.KEY_LOCATION, "");
    if ("" == location) {
      completer.completeError({});
      return completer.future;
    }

    HetiHttpClient client = new HetiHttpClient(_base.getSocketBuilder());
    HttpUrl url = HttpUrlDecoder.decodeUrl(location);
    client.connect(url.host, url.port).then((int v) {
      return client.post(url.host, convert.UTF8.encode(BODY), {
        KEY: VALUE
      });
    }).then((HetiHttpClientResponse response) {
      return response.body.onFin().then((bool v) {
        return response.body.getLength();
      }).then((int length) {
        return response.body.getByteFuture(0, length);
      }).then((List<int> body) {
        print(convert.UTF8.decode(body));
      });
    }).catchError((e) {
      completer.completeError(e);
    });

    return completer.future;
  }
}
class GetExternalIPAddressResult {

}
class UPnpDeviceInfo {
  static String KEY_ST = "ST";
  static String KEY_USN = "USN";
  static String KEY_LOCATION = "Location";
  static String KEY_OPT = "OPT";
  static String KEY_01_NLS = "01-NLS";
  static String KEY_CACHE_CONTROL = "Cache-Control";
  static String KEY_SERVER = "Server";
  static String KEY_EXT = "Ext";
  Map<String, String> _map = {};
  List<String> _service = [];
  HetiSocketBuilder socketBuilder;
  UPnpDeviceInfo(List<HetiHttpResponseHeaderField> headerField, HetiSocketBuilder builder) {
    socketBuilder = builder;
    for (HetiHttpResponseHeaderField header in headerField) {
      if (header.fieldName != null) {
        _map[header.fieldName] = header.fieldValue;
      }
    }
  }

  HetiSocketBuilder getSocketBuilder() {
    return socketBuilder;
  }

  String getValue(String key, String defaultValue) {
    if (key == null) {
      return defaultValue;
    }

    for (String k in _map.keys) {
      if (k == null) {
        continue;
      }
      if (k.toLowerCase() == key.toLowerCase()) {
        return _map[k];
      }
    }
    return defaultValue;
  }

  bool operator ==(Object other) {
    if (!(other is UPnpDeviceInfo)) {
      return false;
    }
    UPnpDeviceInfo otherAs = other as UPnpDeviceInfo;
    if (this._map.keys.length != otherAs._map.keys.length) {
      return false;
    }
    for (String k in this._map.keys) {
      if (!otherAs._map.containsKey(k)) {
        return false;
      }
      if (otherAs._map[k] != this._map[k]) {
        return false;
      }
    }
    return true;
  }

  void addService(String service) {
    _service.add(service);
  }

  async.Future<int> extractService() {
    async.Completer completer = new async.Completer();
    requestServiceList().then((String serviceXml) {
      print("" + serviceXml);
      xml.XmlDocument document = xml.parse(serviceXml);
      Iterable<xml.XmlElement> elements = document.findAllElements("serviceType");
      for (xml.XmlElement element in elements) {
        addService(element.text);
      }
      completer.complete(0);
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }

  async.Future<String> requestServiceList() {
    async.Completer<String> completer = new async.Completer();
    String location = getValue(UPnpDeviceInfo.KEY_LOCATION, "");
    if (location == "" || location == null) {
      completer.completeError({});
      return completer.future;
    }

    HetiHttpClient client = new HetiHttpClient(socketBuilder);
    HttpUrl url = HttpUrlDecoder.decodeUrl(location);
    client.connect(url.host, url.port).then((int d) {
      return client.get(url.path);
    }).then((HetiHttpClientResponse res) {
      HetiHttpResponseHeaderField field = res.message.find(RfcTable.HEADER_FIELD_CONTENT_LENGTH);
      return res.body.onFin().then((b) {
        return res.body.getLength().then((int length) {
          return res.body.getByteFuture(0, length).then((List<int> v) {
            completer.complete(convert.UTF8.decode(v));
          });
        });
      });
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }
}
