import 'package:unittest/unittest.dart' as unit;
import 'dart:async' as async;
import 'package:hetima/hetima.dart' as hetima;

void main() {
  unit.test("http://127.0.0.1", () {
     hetima.HttpUrlDecoder decoder = new hetima.HttpUrlDecoder();
     hetima.HttpUrl url = decoder.decodeUrl("http://127.0.0.1");
     unit.expect(url.scheme, "http");
     unit.expect(url.host, "127.0.0.1");
     unit.expect(url.port, 80);
     unit.expect(url.path, "");
  });

  unit.test("127.0.0.1", () {
     hetima.HttpUrlDecoder decoder = new hetima.HttpUrlDecoder();
     hetima.HttpUrl url = decoder.decodeUrl("127.0.0.1");
     unit.expect(url, null);
  });

  unit.test("https://www.google.com:8080", () {
     hetima.HttpUrlDecoder decoder = new hetima.HttpUrlDecoder();
     hetima.HttpUrl url = decoder.decodeUrl("https://www.google.com:8080");
     unit.expect(url.scheme, "https");
     unit.expect(url.host, "www.google.com");
     unit.expect(url.port, 8080);
     unit.expect(url.path, "");
  });

  unit.test("https://google.com:18080/xxx?sdfsdf=%01%02&aasdf_", () {
     hetima.HttpUrlDecoder decoder = new hetima.HttpUrlDecoder();
     hetima.HttpUrl url = decoder.decodeUrl("https://google.com:18080/xxx?sdfsdf=%01%02&aasdf_");
     unit.expect(url.scheme, "https");
     unit.expect(url.host, "google.com");
     unit.expect(url.port, 18080);
     unit.expect(url.path, "/xxx");
     unit.expect(url.query, "sdfsdf=%01%02&aasdf_");
  });

  // todo error or return null 
  unit.test("https://google.com:18080/xxx?sdfsdf=%01%02&aasdf_あ", () {
     hetima.HttpUrlDecoder decoder = new hetima.HttpUrlDecoder();
     hetima.HttpUrl url = decoder.decodeUrl("https://google.com:18080/xxx?sdfsdf=%01%02&aasdf_あ");
     unit.expect(url.scheme, "https");
     unit.expect(url.host, "google.com");
     unit.expect(url.port, 18080);
     unit.expect(url.path, "/xxx");
     unit.expect(url.query, "sdfsdf=%01%02&aasdf_");
  });
}
