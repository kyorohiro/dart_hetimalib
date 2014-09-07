part of hetima;

class UPnpDeviceInfo {
  static final String KEY_ST = "ST";
  static final String KEY_USN = "USN";
  static final String KEY_LOCATION = "Location";
  static final String KEY_OPT = "OPT";
  static final String KEY_01_NLS = "01-NLS";
  static final String KEY_CACHE_CONTROL = "Cache-Control";
  static final String KEY_SERVER = "Server";
  static final String KEY_EXT = "Ext";

  Map<String, String> _headerMap = {};
  List<String> _serviceList = [];
  HetiSocketBuilder socketBuilder;

  UPnpDeviceInfo(List<HetiHttpResponseHeaderField> headerField, HetiSocketBuilder builder) {
    socketBuilder = builder;
    for (HetiHttpResponseHeaderField header in headerField) {
      if (header.fieldName != null) {
        _headerMap[header.fieldName] = header.fieldValue;
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

    for (String k in _headerMap.keys) {
      if (k == null) {
        continue;
      }
      if (k.toLowerCase() == key.toLowerCase()) {
        return _headerMap[k];
      }
    }
    return defaultValue;
  }

  bool operator ==(Object other) {
    if (!(other is UPnpDeviceInfo)) {
      return false;
    }
    UPnpDeviceInfo otherAs = other as UPnpDeviceInfo;
    if (this._headerMap.keys.length != otherAs._headerMap.keys.length) {
      return false;
    }
    for (String k in this._headerMap.keys) {
      if (!otherAs._headerMap.containsKey(k)) {
        return false;
      }
      if (otherAs._headerMap[k] != this._headerMap[k]) {
        return false;
      }
    }
    return true;
  }

  void addService(String service) {
    _serviceList.add(service);
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
