import 'package:unittest/unittest.dart' as unit;
import 'package:hetima/hetima.dart' as hetima;
import 'dart:typed_data' as type;
import 'dart:convert' as convert;

void main() {

  hetima.HetiTest test = new hetima.HetiTest("t");

  {
    hetima.HetiTestTicket ticket = test.test("number", 3000);
    type.Uint8List out = hetima.Bencode.encode(1024);
    unit.expect("i1024e", convert.UTF8.decode(out.toList()));
    hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
    hetima.EasyParser parser = new hetima.EasyParser(builder);
    hetima.HetiBencode.decode(parser).then((Object o) {
      int v = o;
      ticket.assertTrue("v=" + v.toString(), v == 1024);
    }).whenComplete(() {
      ticket.fin();
    });
    builder.appendUint8List(out, 0, out.length);
  }

  {
    hetima.HetiTestTicket ticket = test.test("string", 3000);
    type.Uint8List out = hetima.Bencode.encode("hetimatan");
    hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
    hetima.EasyParser parser = new hetima.EasyParser(builder);

    hetima.HetiBdecoder decoder = new hetima.HetiBdecoder();
    decoder.decodeString(parser).then((Object o) {
      String v = o;
      ticket.assertTrue("v=" + v.toString(), v == "hetimatan");
    }).whenComplete(() {
      ticket.fin();
    });
    builder.appendUint8List(out, 0, out.length);
  }

  {
    hetima.HetiTestTicket ticket = test.test("list", 3000);
    List l = new List();
    l.add("test");
    l.add(1024);
    type.Uint8List out = hetima.Bencode.encode(l);
    unit.expect("l4:testi1024ee", convert.UTF8.decode(out.toList()));

    hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
    hetima.EasyParser parser = new hetima.EasyParser(builder);
    hetima.HetiBdecoder decoder = new hetima.HetiBdecoder();
    decoder.decodeList(parser).then((List<Object> o) {
      ticket.assertTrue("v1=" + o[0].toString(), convert.UTF8.decode(o[0]) == "test");
      ticket.assertTrue("v2=" + o[1].toString(), o[1] == 1024);
    }).catchError((e) {

    }).whenComplete(() {
      ticket.fin();
    });
    builder.appendUint8List(out, 0, out.length);
  }

  {
    hetima.HetiTestTicket ticket = test.test("dictionary", 3000);

    Map<String, Object> m = new Map();
    m["test"] = "test";
    m["value"] = 1024;
    type.Uint8List out = hetima.Bencode.encode(m);
    unit.expect("d4:test4:test5:valuei1024ee", convert.UTF8.decode(out.toList()));

    hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
    hetima.EasyParser parser = new hetima.EasyParser(builder);
    hetima.HetiBdecoder decoder = new hetima.HetiBdecoder();
    decoder.decodeDiction(parser).then((Map dict) {
      ticket.assertTrue("" + dict["test"].toString(), convert.UTF8.decode(dict["test"]) == "test");
      ticket.assertTrue("" + dict["value"].toString(), dict["value"] == 1024);
    }).catchError((e) {

    }).whenComplete(() {
      ticket.fin();
    });
    builder.appendUint8List(out, 0, out.length);
  }
}
