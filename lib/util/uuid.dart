part of hetima;

class Uuid 
{
  static math.Random _random = new math.Random();
  static core.String createUUID() {
    return s4()+s4()+"-"+s4()+"-"+s4()+"-"+s4()+"-"+s4()+s4()+s4();
  }
  static core.String s4() {
    core.int a;
    return (_random.nextInt(0xFFFF)+0x10000).toRadixString(16).substring(0,4);
  }
}