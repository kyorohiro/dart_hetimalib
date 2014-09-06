part of hetima;

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