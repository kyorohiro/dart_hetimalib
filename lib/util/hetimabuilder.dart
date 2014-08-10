part of hetima;

abstract class HetimaBuilder {
  async.Future<List<int>> getByteFuture(int index, int length);
  bool immutable = false;
}