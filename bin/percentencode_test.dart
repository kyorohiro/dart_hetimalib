import 'package:unittest/unittest.dart' as unit;
import 'dart:async' as async;
import 'package:hetima/hetima.dart';
import 'dart:convert' as convert;

void main() {
  unit.test("ps", () {
    List<int> v = convert.UTF8.encode("hello");
    String encode = PercentEncode.encode(v);
    unit.expect(encode, "%68%65%6C%6C%6F");

    List<int> decode = PercentEncode.decode(encode).toList();
    unit.expect(convert.UTF8.decode(decode), "hello");
  });
}
