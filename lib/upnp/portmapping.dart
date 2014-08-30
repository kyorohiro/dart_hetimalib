part of hetima;

class UpnpPortMapping {

  static String SSDP_ADDRESS = "239.255.255.250";
  static int SSDP_PORT = 1900;
  static String SSDP_M_SEARCH = 
      """M-SEARCH * HTTP/1.1\r\n""" + 
      """MX: 3\r\n""" + 
      """HOST: 239.255.255.250:1900\r\n""" + 
      """MAN: "ssdp:discover"\r\n""" + 
      """ST: upnp:rootdevice\r\n""" + 
      """\r\n""";

  static String SSDP_M_SEARCH_WANPPPConnection = 
      """M-SEARCH * HTTP/1.1\r\n""" + 
      """MX: 3\r\n""" + 
      """HOST: 239.255.255.250:1900\r\n""" + 
      """MAN: "ssdp:discover"\r\n""" + 
      """ST: urn:schemas-upnp-org:service:WANPPPConnection:1\r\n""" + 
      """\r\n""";

  static String SSDP_M_SEARCH_WANIPConnection = 
      """M-SEARCH * HTTP/1.1\r\n""" + 
      """MX: 3\r\n""" + 
      """HOST: 239.255.255.250:1900\r\n""" + 
      """MAN: "ssdp:discover"\r\n""" + 
      """ST: urn:schemas-upnp-org:service:WANIPConnection:1\r\n""" + 
      """\r\n""";

  List<String> locationList = new List();
  HetiUdpSocket socket = null;
  
  HetiSocketBuilder _socketBuilder = null;
  UpnpPortMapping(HetiSocketBuilder builder) {
    _socketBuilder = builder;
  }

  void init() {
    socket = _socketBuilder.createUdpClient();
    socket.bind("0.0.0.0", 0);
    socket.onReceive().listen(_onReceive);
  }

  void _onReceive(HetiReceiveUdpInfo info) {
    print("########");
    print("" + convert.UTF8.decode(info.data));
    print("########");
    _extractLocation(info.data);
  }

  void searchWanPPPDevice() {
    socket.send(convert.UTF8.encode(SSDP_M_SEARCH_WANPPPConnection), SSDP_ADDRESS, SSDP_PORT).then((HetiUdpSendInfo iii) {
      print("###send=" + iii.resultCode.toString());
    }).then((d) {
      return socket.send(convert.UTF8.encode(SSDP_M_SEARCH_WANIPConnection), SSDP_ADDRESS, SSDP_PORT);
    }).catchError((e){      
    });
  }

  void _extractLocation(List<int> buffer) {
    ArrayBuilder builder = new ArrayBuilder();
    EasyParser parser = new EasyParser(builder);
    builder.appendIntList(buffer, 0, buffer.length);
    HetiHttpResponse.decodeHttpMessage(parser).then((HetiHttpMessageWithoutBody message) {
      print("===");
      for (HetiHttpResponseHeaderField field in message.headerField) {
        print("name:" + field.fieldName + "=value:" + field.fieldValue);
      }
      print("===");
      HetiHttpResponseHeaderField f = message.find("location");
      if (f != null) {
        if (!locationList.contains(f.fieldValue)) {
          locationList.add(f.fieldValue);
        }

      }
    });
  }



  void extractService() {
    for (String location in locationList) {
      HetiHttpClient client = new HetiHttpClient(_socketBuilder);
      HttpUrl url = HttpUrlDecoder.decodeUrl(location);
      client.connect(url.host, url.port).then((int d) {
        {
          client.get(url.path).then((HetiHttpClientResponse res) {

            print("##LENGTH" + location + ": length = " + res.message.contentLength.toString());
            HetiHttpResponseHeaderField field = res.message.find(RfcTable.HEADER_FIELD_CONTENT_LENGTH);
            return res.body.onFin().then((b) {
              print("++++++" + location + "+++++");
              return res.body.getLength().then((int length) {
                return res.body.getByteFuture(0, length).then((List<int> v) {
                  print("#####==" + location);
                  print("" + convert.UTF8.decode(v));
                  print("####");
                });
              });
            });
          }).catchError((e) {
            print("##err SDFSDf");
          });
        }
      });
    }
  }
}
