import 'package:unittest/unittest.dart';
import 'dart:async' as async;
import 'package:hetima/hetima.dart' as hetima;
import 'package:hetima/hetima_cl.dart' as hetima_cl;

void main() {
  
  async.Future<String> one() {
    print("one");
    return new async.Future.value("one");
  }
  ;
  async.Future<String> two() {
    print("two");
    return new async.Future.value("two");
  }
  async.Future<String> three() {
    print("three");
    return new async.Future.value("three");
  }
  async.Future<String> four() {
    print("four");
    return new async.Future.value("four");
  }

  print("1");
  one().then((_)=>two()).then((_) => three())
  .then((_)=>four()).catchError((e){
    print("error");    
  })
  .then((value) {
        print("The value is $value");
   });
//  print("2");
  new async.Future.sync((){
  one().then((_){
    throw new Error();
    return two();
  }).then((_) {
    return three();
  })
  .then((_)=>four()).catchError((e){
    print("error");    
  })
  .then((value) {
        print("The value is $value");
   });
  });
  one().then((_){
    throw new Error();
    return two();
  })
  .whenComplete((){
    print("complete");
  })
  .then((_) {
    return three();
  })
  .then((_)=>four()).catchError((e){
    print("error");    
  })
  .then((value) {
        print("The value is $value");
   });
   
  (new async.Future.sync((){
    one().then((_) {
      two().then((_) {
        throw new Error();
      });
    }).whenComplete(() {
      print("comp");
    });
  }))
  .catchError((_) {
    print("error 2");
  })
  .then((_){
    print("sync");
  })
  .catchError((_) {
    print("error 1");
  });
}
