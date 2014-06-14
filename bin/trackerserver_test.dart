import 'package:unittest/unittest.dart';
import 'dart:async' as async;
import 'package:hetima/hetima_sv.dart';
import 'package:hetima/hetima.dart';

void main() {
  print("---");
  Tracker tracker = new Tracker("127.0.0.1", 6969);
  tracker.start();
}
