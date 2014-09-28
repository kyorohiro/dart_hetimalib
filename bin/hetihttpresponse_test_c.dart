import 'package:unittest/unittest.dart' as unit;
import 'package:hetima/hetima.dart' as hetima;
import 'dart:async' as async;

void main() {
  hetima.HetiTest test = new hetima.HetiTest("tt");
  {
    hetima.HetiTestTicket ticket = test.test("request-line", 3000);
    String v = "";
    new async.Future.sync(() {
      hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
      hetima.EasyParser parser = new hetima.EasyParser(builder);
      async.Future<hetima.HetiRequestLine> ret = hetima.HetiHttpResponse.decodeRequestLine(parser);
      builder.appendString("GET /xxx/yy/zz HTTP/1.1\r\n");
      return ret;
    }).then((hetima.HetiRequestLine v) {
      ticket.assertTrue("a0", "GET" == v.method);
      ticket.assertTrue("a1", "HTTP/1.1" == v.httpVersion);
      ticket.assertTrue("a2", "/xxx/yy/zz" == v.requestTarget);
      ticket.fin();
    });
  }

}
