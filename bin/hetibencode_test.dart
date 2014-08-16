import 'package:unittest/unittest.dart' as unit;
import 'package:hetima/hetima.dart' as hetima;
import 'dart:typed_data' as type;
import 'dart:convert' as convert;

void main() {

  hetima.HetiTest test  = new hetima.HetiTest("t");
  {
    hetima.HetiTestTicket ticket = test.test("number", 3000);
    type.Uint8List out = hetima.Bencode.encode(1024);
    unit.expect("i1024e", convert.UTF8.decode(out.toList()));
    hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
    hetima.EasyParser parser = new hetima.EasyParser(builder);
    hetima.HetiBencode.decode(parser).then((Object o){
      int v = o;
      ticket.assertTrue("v="+v.toString(), v == 1024);
    }).whenComplete((){
      ticket.fin();
    });
    builder.appendUint8List(out, 0,out.length);
  }
}
