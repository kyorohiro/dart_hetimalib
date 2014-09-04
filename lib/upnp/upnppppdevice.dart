part of hetima;

class UPnpPPPDevice {
  String KEY_SOAPACTION = "SOAPACTION";
  String VALUE_GET_EXTERNAL_IP_ADDRESS = """\"urn:schemas-upnp-org:service:WANPPPConnection:1#GetExternalIPAddress\"""";
  String VALUE_ADD_PORT_MAPPING = """\"urn:schemas-upnp-org:service:WANPPPConnection:1#AddPortMapping\"""";
  String VALUE_DELETE_PORT_MAPPING = """\"urn:schemas-upnp-org:service:WANPPPConnection:1#DeletePortMapping\"""";
  String VALUE_GET_GENERIC_PORT_MAPPING = """"\"urn:schemas-upnp-org:service:WANPPPConnection:1#GetGenericPortMappingEntry\"""";
  String BODY_GET_EXTERNAL_IP_ADDRESS = """<?xml version="1.0"?><SOAP-ENV:Envelope xmlns:SOAP-ENV:="http://schemas.xmlsoap.org/soap/envelope/" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><SOAP-ENV:Body><m:GetExternalIPAddress xmlns:m="urn:schemas-upnp-org:service:WANPPPConnection:1"></m:GetExternalIPAddress></SOAP-ENV:Body></SOAP-ENV:Envelope>""";
  String BODY_ADD_PORT_MAPPING = """<?xml version="1.0"?><SOAP-ENV:Envelope xmlns:SOAP-ENV:="http://schemas.xmlsoap.org/soap/envelope/" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><SOAP-ENV:Body><m:AddPortMapping xmlns:m="urn:schemas-upnp-org:service:WANPPPConnection:1"><NewRemoteHost></NewRemoteHost><NewExternalPort>newExternalPort</NewExternalPort><NewProtocol>newProtocol</NewProtocol><NewInternalPort>newInternalPort</NewInternalPort><NewInternalClient>newInternalClient</NewInternalClient><NewEnabled>1</NewEnabled><NewPortMappingDescription>newPortMappingDescription</NewPortMappingDescription><NewLeaseDuration>newLeaseDuration</NewLeaseDuration></m:AddPortMapping></SOAP-ENV:Body></SOAP-ENV:Envelope>""";
  String BODY_DELETE_PORT_MAPPING = """<?xml version=\"1.0\"?><SOAP-ENV:Envelope xmlns:SOAP-ENV:=\"http://schemas.xmlsoap.org/soap/envelope/\" SOAP-ENV:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\"><SOAP-ENV:Body><m:DeletePortMapping xmlns:m=\"urn:schemas-upnp-org:service:WANPPPConnection:1\"><NewRemoteHost></NewRemoteHost><NewExternalPort>newExternalPort</NewExternalPort><NewProtocol>newProtocol</NewProtocol></m:DeletePortMapping></SOAP-ENV:Body></SOAP-ENV:Envelope>""";
  String BODY_GET_GENERIC_PORT_MAPPING  = """<?xml version="1.0"?><SOAP-ENV:Envelope xmlns:SOAP-ENV:="http://schemas.xmlsoap.org/soap/envelope/" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><SOAP-ENV:Body><m:GetGenericPortMappingEntry xmlns:m="urn:schemas-upnp-org:service:WANPPPConnection:1"><NewPortMappingIndex>newPortMappingIndex</NewPortMappingIndex></m:GetGenericPortMappingEntry></SOAP-ENV:Body></SOAP-ENV:Envelope>""";
  UPnpDeviceInfo _base = null;
  UPnpPPPDevice(UPnpDeviceInfo base) {
    _base = base;
    String st = _base.getValue(UPnpDeviceInfo.KEY_ST, "WANIPConnection");
    if (st.contains("WANIPConnection")) {
      VALUE_GET_EXTERNAL_IP_ADDRESS.replaceAll("WANPPPConnection", "WANIPConnection");
      VALUE_ADD_PORT_MAPPING.replaceAll("WANPPPConnection", "WANIPConnection");
      VALUE_DELETE_PORT_MAPPING.replaceAll("WANPPPConnection", "WANIPConnection");
      BODY_GET_EXTERNAL_IP_ADDRESS.replaceAll("WANPPPConnection", "WANIPConnection");
      BODY_ADD_PORT_MAPPING.replaceAll("WANPPPConnection", "WANIPConnection");
      BODY_DELETE_PORT_MAPPING.replaceAll("WANPPPConnection", "WANIPConnection");
    }
  }

  async.Future<String> requestGetGenericPortMapping(int newPortMappingIndex) {
    async.Completer<String> completer = new async.Completer();
    String requestBody = BODY_GET_GENERIC_PORT_MAPPING
        .replaceAll("newPortMappingIndex", newPortMappingIndex.toString());

    request(VALUE_DELETE_PORT_MAPPING, requestBody).then((UPnpPPPDeviceRequestResult response) {
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }

  async.Future<String> requestAddPortMapping(int newExternalPort, String newProtocol, int NewInternalPort, String NewInternalClient, int NewEnable, int NewPortMappingDescription, int NewLeaseDuration) {
    async.Completer<String> completer = new async.Completer();
    String requestBody = BODY_ADD_PORT_MAPPING
        .replaceAll("newExternalPort", newExternalPort.toString())
        .replaceAll("newProtocol", newProtocol.toString())
        .replaceAll("newInternalPort", NewInternalPort.toString())
        .replaceAll("newInternalClient", NewInternalClient.toString())
        .replaceAll("newEnabled", NewEnable.toString())
        .replaceAll("newPortMappingDescription", NewPortMappingDescription.toString())
        .replaceAll("newLeaseDuration", NewLeaseDuration.toString());

    request(VALUE_ADD_PORT_MAPPING, requestBody).then((UPnpPPPDeviceRequestResult response) {
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }

  async.Future<String> requestDeletePortMapping(int newExternalPort, String newProtocol) {
    async.Completer<String> completer = new async.Completer();
    String requestBody = BODY_DELETE_PORT_MAPPING
        .replaceAll("newExternalPort", newExternalPort.toString())
        .replaceAll("newProtocol", newProtocol.toString());
    request(VALUE_DELETE_PORT_MAPPING, requestBody).then((UPnpPPPDeviceRequestResult response) {
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }

  async.Future<String> requestGetExternalIPAddress() {
    async.Completer<String> completer = new async.Completer();
    request(VALUE_GET_EXTERNAL_IP_ADDRESS, BODY_GET_EXTERNAL_IP_ADDRESS).then((UPnpPPPDeviceRequestResult response) {
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

  async.Future<UPnpPPPDeviceRequestResult> request(String soapAction, String body) {
    async.Completer<UPnpPPPDeviceRequestResult> completer = new async.Completer();
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
        completer.complete(new UPnpPPPDeviceRequestResult(response.message.line.statusCode, convert.UTF8.decode(body)));
      });
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }
}

class UPnpPPPDeviceRequestResult {
  UPnpPPPDeviceRequestResult(int _resultCode, String _body) {
    body = _body;
    resultCode = _resultCode;
  }
  String body;
  int resultCode;
}
