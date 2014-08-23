import 'package:unittest/unittest.dart' as unit;
import 'package:hetima/hetima.dart' as hetima;
import 'dart:typed_data' as type;
import 'dart:convert' as convert;

void main() {

  hetima.HetiTest test = new hetima.HetiTest("t");

  {
    hetima.HetiTestTicket ticket = test.test("a", 3000);
    Map<String, String> map = hetima.HttpUrlDecoder.queryMap("/announce");
    ticket.assertTrue("", 0==map.length);
    ticket.fin();
  }
  {
    hetima.HetiTestTicket ticket = test.test("b", 3000);
    Map<String, String> map = hetima.HttpUrlDecoder.queryMap("/announce?xxx=ccc");
    ticket.assertTrue("1:"+map.length.toString(), 1==map.length);
    ticket.assertTrue("2:", "ccc"==map["xxx"]);
    ticket.fin();
  }

  {
    hetima.HetiTestTicket ticket = test.test("c", 3000);
    Map<String, String> map = hetima.HttpUrlDecoder.queryMap("/announce?xxx=ccc&ddd=xxx");
    ticket.assertTrue("1:"+map.length.toString(), 2==map.length);
    ticket.assertTrue("2:", "ccc"==map["xxx"]);
    ticket.assertTrue("3:", "xxx"==map["ddd"]);
    ticket.fin();
  }

  {
    hetima.HetiTestTicket ticket = test.test("d", 3000);
    Map<String, String> map = hetima.HttpUrlDecoder.queryMap("/announce?xxx=ccc&ddd=x?x");
    ticket.assertTrue("1:"+map.length.toString(), 2==map.length);
    ticket.assertTrue("2:", "ccc"==map["xxx"]);
    ticket.assertTrue("3:", "x?x"==map["ddd"]);
    ticket.fin();
  }
}
