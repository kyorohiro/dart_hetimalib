import 'package:unittest/unittest.dart' as unit;
import 'package:hetima/hetima.dart' as hetima;
import 'dart:async' as async;

void main() {
  hetima.HetiTest test = new hetima.HetiTest("tt");
///*
  unit.test("arraybuilder: init", () {
    hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
    unit.expect(0, builder.size());
    unit.expect(0, builder.toList().length);
    unit.expect("", builder.toText());
  });

  unit.test("arraybuilder: senario", () {
    hetima.ArrayBuilder builder = new hetima.ArrayBuilder();
    builder.appendString("abc");
    unit.expect("abc", builder.toText());
    unit.expect(3, builder.toList().length);
    builder.appendString("abc");
    unit.expect("abcabc", builder.toText());
    unit.expect(6, builder.toList().length);
  });

  unit.test("arraybuilder: big/little", () {
    {
      List<int> ret = hetima.ByteOrder.parseLongByte(0xFF, hetima.ByteOrder.BYTEORDER_BIG_ENDIAN);
      unit.expect(ret[0], 0x00);
      unit.expect(ret[1], 0x00);
      unit.expect(ret[2], 0x00);
      unit.expect(ret[3], 0x00);
      unit.expect(ret[4], 0x00);
      unit.expect(ret[5], 0x00);
      unit.expect(ret[6], 0x00);
      unit.expect(ret[7], 0xFF);
      int v = hetima.ByteOrder.parseLong(ret, 0, hetima.ByteOrder.BYTEORDER_BIG_ENDIAN);
      unit.expect(v, 0xFF);
    }
    {
      List<int> ret = hetima.ByteOrder.parseIntByte(0xFF, hetima.ByteOrder.BYTEORDER_BIG_ENDIAN);
      unit.expect(ret[0], 0x00);
      unit.expect(ret[1], 0x00);
      unit.expect(ret[2], 0x00);
      unit.expect(ret[3], 0xFF);
      int v = hetima.ByteOrder.parseInt(ret, 0, hetima.ByteOrder.BYTEORDER_BIG_ENDIAN);
      unit.expect(v, 0xFF);
    }
    {
      List<int> ret = hetima.ByteOrder.parseShortByte(0xFF, hetima.ByteOrder.BYTEORDER_BIG_ENDIAN);
      unit.expect(ret[0], 0x00);
      unit.expect(ret[1], 0xFF);
      int v = hetima.ByteOrder.parseShort(ret, 0, hetima.ByteOrder.BYTEORDER_BIG_ENDIAN);
      unit.expect(v, 0xFF);
    }
  });

}
