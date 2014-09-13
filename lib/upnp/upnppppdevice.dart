part of hetima;

class UPnpPPPDevice {
  static final String KEY_SOAPACTION = "SOAPACTION";
  static final String VALUE_PORT_MAPPING_PROTOCOL_UDP = "UDP";
  static final String VALUE_PORT_MAPPING_PROTOCOL_TCP = "TCP";
  static final int VALUE_ENABLE = 1;
  static final int VALUE_DISABLE = 0;

  UPnpDeviceInfo _base = null;
  String _serviceName = "WANPPPConnection";

  UPnpPPPDevice(UPnpDeviceInfo base) {
    _base = base;

    String st = _base.getValue(UPnpDeviceInfo.KEY_ST, "WANIPConnection");
    if (st.contains("WANIPConnection")) {
      _serviceName = "WANIPConnection";
    }
  }

  async.Future<UPnpGetGenericPortMappingResponse> requestGetGenericPortMapping(int newPortMappingIndex) {
    async.Completer<String> completer = new async.Completer();

    String requestBody = """<?xml version="1.0"?><SOAP-ENV:Envelope xmlns:SOAP-ENV:="http://schemas.xmlsoap.org/soap/envelope/" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><SOAP-ENV:Body><m:GetGenericPortMappingEntry xmlns:m="urn:schemas-upnp-org:service:${_serviceName}:1"><NewPortMappingIndex>${newPortMappingIndex}</NewPortMappingIndex></m:GetGenericPortMappingEntry></SOAP-ENV:Body></SOAP-ENV:Envelope>""";
    String headerValue = """\"urn:schemas-upnp-org:service:${_serviceName}:1#GetGenericPortMappingEntry\"""";

    request(headerValue, requestBody).then((UPnpPPPDeviceRequestResponse response) {
      completer.complete(new UPnpGetGenericPortMappingResponse(response));
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }

  /**
   * return resultCode. if success then. return 200. ;
   */
  async.Future<int> requestAddPortMapping(int newExternalPort, String newProtocol, int newInternalPort, String newInternalClient, int newEnabled, String newPortMappingDescription, int newLeaseDuration) {
    async.Completer<int> completer = new async.Completer();

    String headerValue = """\"urn:schemas-upnp-org:service:${_serviceName}:1#AddPortMapping\"""";
    String requestBody = """<?xml version="1.0"?><SOAP-ENV:Envelope xmlns:SOAP-ENV:="http://schemas.xmlsoap.org/soap/envelope/" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><SOAP-ENV:Body><m:AddPortMapping xmlns:m="urn:schemas-upnp-org:service:${_serviceName}:1">""" + """<NewRemoteHost></NewRemoteHost><NewExternalPort>${newExternalPort}</NewExternalPort><NewProtocol>${newProtocol}</NewProtocol><NewInternalPort>${newInternalPort}</NewInternalPort><NewInternalClient>${newInternalClient}</NewInternalClient><NewEnabled>${newEnabled}</NewEnabled><NewPortMappingDescription>${newPortMappingDescription}</NewPortMappingDescription><NewLeaseDuration>${newLeaseDuration}</NewLeaseDuration></m:AddPortMapping></SOAP-ENV:Body></SOAP-ENV:Envelope>""";

    request(headerValue, requestBody).then((UPnpPPPDeviceRequestResponse response) {
      if (response.resultCode == 200) {
        completer.complete(response.resultCode);
      } else {
        completer.complete(response.resultCode * -1);
      }
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }

  async.Future<int> requestDeletePortMapping(int newExternalPort, String newProtocol) {
    async.Completer<int> completer = new async.Completer();

    String requestBody = """<?xml version=\"1.0\"?><SOAP-ENV:Envelope xmlns:SOAP-ENV:=\"http://schemas.xmlsoap.org/soap/envelope/\" SOAP-ENV:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\"><SOAP-ENV:Body><m:DeletePortMapping xmlns:m=\"urn:schemas-upnp-org:service:${_serviceName}:1\">""" + """<NewRemoteHost></NewRemoteHost><NewExternalPort>${newExternalPort}</NewExternalPort><NewProtocol>${newProtocol}</NewProtocol></m:DeletePortMapping></SOAP-ENV:Body></SOAP-ENV:Envelope>""";
    String headerValue = """\"urn:schemas-upnp-org:service:${_serviceName}:1#DeletePortMapping\"""";
    request(headerValue, requestBody).then((UPnpPPPDeviceRequestResponse response) {
      if (response.resultCode == 200) {
        completer.complete(response.resultCode);
      } else {
        completer.complete(response.resultCode * -1);
      }
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }

  async.Future<String> requestGetExternalIPAddress() {
    async.Completer<String> completer = new async.Completer();

    String headerValue = """\"urn:schemas-upnp-org:service:${_serviceName}:1#GetExternalIPAddress\"""";
    String requestBody = """<?xml version="1.0"?><SOAP-ENV:Envelope xmlns:SOAP-ENV:="http://schemas.xmlsoap.org/soap/envelope/" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><SOAP-ENV:Body><m:GetExternalIPAddress xmlns:m="urn:schemas-upnp-org:service:${_serviceName}:1"></m:GetExternalIPAddress></SOAP-ENV:Body></SOAP-ENV:Envelope>""";

    request(headerValue, requestBody).then((UPnpPPPDeviceRequestResponse response) {
      xml.XmlDocument document = xml.parse(response.body);
      Iterable<xml.XmlElement> elements = document.findAllElements("NewExternalIPAddress");
      if (elements.length > 0) {
        completer.complete(elements.first.text);
      } else {
        completer.complete("");
      }
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }

  async.Future<UPnpPPPDeviceRequestResponse> request(String soapAction, String body) {
    async.Completer<UPnpPPPDeviceRequestResponse> completer = new async.Completer();
    HetiSocket socket = _base.getSocketBuilder().createClient();
    String location = _base.getValue(UPnpDeviceInfo.KEY_LOCATION, "");
    if ("" == location) {
      completer.completeError({});
      return completer.future;
    }
    HetiHttpClient client = new HetiHttpClient(_base.getSocketBuilder());
    HttpUrl url = HttpUrlDecoder.decodeUrl(location);
    client.connect(url.host, url.port).then((int v) {
      return client.post(url.host, convert.UTF8.encode(body), {
        KEY_SOAPACTION: soapAction
      });
    }).then((HetiHttpClientResponse response) {
      return response.body.onFin().then((bool v) {
        return response.body.getLength();
      }).then((int length) {
        return response.body.getByteFuture(0, length);
      }).then((List<int> body) {
        print(convert.UTF8.decode(body));
        completer.complete(new UPnpPPPDeviceRequestResponse(response.message.line.statusCode, convert.UTF8.decode(body)));
      });
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }
}

class UPnpPPPDeviceRequestResponse {
  UPnpPPPDeviceRequestResponse(int _resultCode, String _body) {
    body = _body;
    resultCode = _resultCode;
  }
  String body;
  int resultCode;
}

class UPnpGetGenericPortMappingResponse {
  static final String KEY_NewRemoteHost = "NewRemoteHost";
  static final String KEY_NewExternalPort = "NewExternalPort";
  static final String KEY_NewProtocol = "NewProtocol";
  static final String KEY_NewInternalPort = "NewInternalPort";
  static final String KEY_NewInternalClient = "NewInternalClient";
  static final String KEY_NewEnabled = "NewEnabled";
  static final String KEY_NewPortMappingDescription = "NewPortMappingDescription";
  static final String KEY_NewLeaseDuration = "NewLeaseDuration";

  UPnpPPPDeviceRequestResponse _response = null;
  UPnpGetGenericPortMappingResponse(UPnpPPPDeviceRequestResponse response) {
    _response = response;
  }
  
  int get resultCode => _response.resultCode;

  String getValue(String key, String defaultValue) {
    if(_response.resultCode != 200) {
      return defaultValue;
    }
    xml.XmlDocument document = xml.parse(_response.body);
    Iterable<xml.XmlElement> elements = document.findElements("NewRemoteHost");
    if(elements == null || elements.length <=0) {
      return defaultValue;
    }
    return elements.first.text;
  }

  @override
  String toString(){
    return _response.body.toString();
  }
}
