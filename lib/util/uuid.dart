part of hetima;

class Uuid 
{
  static math.Random _random = new math.Random();
  static core.String createUUID() {
    return s4()+s4()+"-"+s4()+"-"+s4()+"-"+s4()+"-"+s4()+s4()+s4();;
  }
  static core.String s4() {
    return (_random.nextInt(0xFFFF)).toRadixString(16);
  }
}