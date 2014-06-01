import 'package:unittest/unittest.dart' as unit;
import 'package:hetima/hetima.dart' as hetima;
import '01_torrentfile_cl_test.dart' as torrentfilecl_test;
import '00_hetimafile_cl_test.dart' as hetimafilecl_test;


void main() {
  print("start test");
  torrentfilecl_test.test_bencode();
  hetimafilecl_test.test_bencode();
}

