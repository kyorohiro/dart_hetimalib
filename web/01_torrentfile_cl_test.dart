import 'package:unittest/unittest.dart' as unit;
import 'package:hetima/hetima.dart' as hetima;
import 'package:hetima/hetima_cl.dart' as hetima_cl;
import 'dart:typed_data' as type;
import 'dart:convert' as convert;
import 'dart:html' as html;
import 'dart:async' as async;

void main() {
  {
    bool testable = false;
    new async.Future.sync(() {
      hetima_cl.HetimaFileGet file = new hetima_cl.HetimaFileGet("testdata/1k.txt.torrent");
      return file.getLength().then((int length) {
        return file.read(0, length);
      });
    }).then((hetima.ReadResult result) {
      hetima.TorrentFile f = new hetima.TorrentFile.loadTorrentFileBuffer(result.buffer);
      unit.test("001 1k.txt.torrent", () {
        unit.expect("http://127.0.0.1:6969/announce", f.announce);
        unit.expect("1k.txt", f.info.name);
        unit.expect(1, f.info.files.path.length);
        unit.expect("1k.txt", f.info.files.path[0].pathAsString);
        unit.expect(1024, f.info.files.path[0].length);
      });
    });
  }
  {
    bool testable = false;
    new async.Future.sync(() {
      hetima_cl.HetimaFileGet file = new hetima_cl.HetimaFileGet("testdata/1kb.torrent");
      return file.getLength().then((int length) {
        return file.read(0, length);
      });
    }).then((hetima.ReadResult result) {
      hetima.TorrentFile f = new hetima.TorrentFile.loadTorrentFileBuffer(result.buffer);
      unit.test("002 1kb.torrent", () {
        unit.expect("http://127.0.0.1:6969/announce", f.announce);
        unit.expect("1kb", f.info.name);
        unit.expect(2, f.info.files.path.length);
        unit.expect("1k_b.txt", f.info.files.path[0].pathAsString);
        unit.expect(1024, f.info.files.path[0].length);
        unit.expect("1k.txt", f.info.files.path[1].pathAsString);
        unit.expect(1024, f.info.files.path[1].length);
      });
    });
  }

  {
    hetima_cl.HetimaFileGet file = new hetima_cl.HetimaFileGet("testdata/1kb/1k.txt");
    hetima.TorrentPieceHashCreator h = new hetima.TorrentPieceHashCreator();
    (new async.Future.sync(() {
      return h.createPieceHash(file, 16 * 1024);
    })).then((hetima.CreatePieceHashResult r) {
      unit.test("004 hetimafile get ss", () {
        List<int> expect = [196, 42, 125, 9, 64, 47, 78, 143, 209, 15, 188, 87, 124, 199, 203, 157, 198, 52, 62, 142];
        unit.expect(20, r.pieceBuffer.size());
        for (int i = 0; i < r.pieceBuffer.size(); i++) {
          unit.expect(expect[i], r.pieceBuffer.toList()[i]);
        }
      });
    });
  }

  {
    hetima.TorrentPieceHashCreator h = new hetima.TorrentPieceHashCreator();
    hetima_cl.HetimaFileGet file001 = new hetima_cl.HetimaFileGet("testdata/1kb/1k_b.txt");
    hetima_cl.HetimaFileGet file002 = new hetima_cl.HetimaFileGet("testdata/1kb/1k.txt");
    (new async.Future.sync(() {
      return file001.getBlob().then((html.Blob b1) {
        return file002.getBlob().then((html.Blob b2) {
          hetima_cl.HetimaFileBlob file = new hetima_cl.HetimaFileBlob(new html.Blob([b1, b2]));
          return h.createPieceHash(file, 16 * 1024);
        });
      });
    })).then((hetima.CreatePieceHashResult r) {
      unit.test("005 hetimafile get double", () {
        List<int> expect = [149, 96, 47, 41, 153, 193, 171, 203, 165, 128, 108, 193, 118, 11, 175, 49, 229, 27, 231, 149];
        unit.expect(20, r.pieceBuffer.size());
        for (int i = 0; i < r.pieceBuffer.size(); i++) {
          unit.expect(expect[i], r.pieceBuffer.toList()[i]);
        }
      });
    });
  }
  {
    hetima_cl.HetimaFileGet file = new hetima_cl.HetimaFileGet("testdata/1kb/1k.txt");
    hetima.TorrentFileCreator c = new hetima.TorrentFileCreator();
    c.name = "1k.txt";
    c.announce = "http://www.example.com/tracker:6969";
    (new async.Future.sync(() {
      return c.createFromSingleFile(file);
    })).then((hetima.TorrentFileCreatorResult e) {
      e.torrentFile;
      List<int> expect = [196, 42, 125, 9, 64, 47, 78, 143, 209, 15, 188, 87, 124, 199, 203, 157, 198, 52, 62, 142];
      unit.test("006 create torrent", () {
        unit.expect(20, e.torrentFile.info.piece.length);
        for (int i = 0; i < e.torrentFile.info.piece.length; i++) {
          unit.expect(expect[i], e.torrentFile.info.piece[i]);
        }
        unit.expect(16 * 1024, e.torrentFile.info.piece_length);
        unit.expect("http://www.example.com/tracker:6969", e.torrentFile.announce);
        unit.expect(1, e.torrentFile.info.files.size);
        unit.expect(1024, e.torrentFile.info.files.path[0].length);
        unit.expect("1k.txt", e.torrentFile.info.files.path[0].pathAsString);
      });
    });
  }
}
