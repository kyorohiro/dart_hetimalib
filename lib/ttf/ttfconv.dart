part of hetima;


class TTFConv {
  static String glyf2svg(TTFTableHead head, TTFTableGlyf tableGlyf, int index) {
    int max = head.yMax;
    TTFGlyf g = tableGlyf.glyfs[index];
    int currentPts = 0;
    int startPts = 0;
    List<String> pathArray = new List();

    int currentPointX = 0;
    int currentPointY = 0;
    int prevPointX = 0;
    int prevPointY = 0;
    bool isOnCurve = false;
    bool isOnCurvePrev = false;

    for(int i=0;i<g.endPtsOfContours.length;i++) {
      print("i=${i} currentPath=${currentPts} e=${g.endPtsOfContours[i]}\n");
      for(;currentPts < g.endPtsOfContours[i]+1;currentPts++) {
        String path = "";
        if(g.xCoordinates.length <= currentPts) {
          continue;
        }
        {
          currentPointX = g.xCoordinates[currentPts];
          currentPointY = g.yCoordinates[currentPts];
          isOnCurve = ((g.flags[currentPts]&1)!=0);
        }
        if(currentPts == startPts) {
          int index = g.endPtsOfContours[i];
          prevPointX = g.xCoordinates[index];
          prevPointY = g.yCoordinates[index];
          isOnCurvePrev = ((g.flags[index]&1)!=0);
        } else {
          int index = currentPts-1;
          prevPointX = g.xCoordinates[index];
          prevPointY = g.yCoordinates[index];
          isOnCurvePrev = ((g.flags[index]&1)!=0);
        }

        int midPointX = (prevPointX + currentPointX) ~/2;
        int midPointY = (prevPointY + currentPointY) ~/2;
        if(startPts == currentPts) {
          if(isOnCurve == true) {
            path += """M ${currentPointX},${max-1*currentPointY}""";
          } else {
            path += """M ${midPointX},${max-1*midPointY} Q${currentPointX},${max-1*currentPointY}""";
          }          
        } else {
          if(isOnCurvePrev == true && isOnCurve == true) {
            path += """L """;
          } else if(isOnCurve == false && isOnCurvePrev == false) {
            path += """${midPointX},${max-1*midPointY} """;
          } else if(isOnCurve == false){
            path += """Q """;
          }
          path += """${currentPointX},${max-1*currentPointY} """;
        }
        pathArray.add(path);
      } //for
      if(isOnCurve == false && startPts < g.xCoordinates.length) {
        if(isOnCurve == true) {
          String path = """${g.xCoordinates[startPts]},${max-1*g.yCoordinates[startPts]}""";
          pathArray.add(path);
        } else {
          int midPointX = (currentPointX + g.xCoordinates[startPts])~/2;
          int midPointY = (currentPointY + g.yCoordinates[startPts])~/2;
          String path = """${midPointX},${max-1*midPointY}""";
          pathArray.add(path);
        }
      }
      pathArray.add("Z");
      startPts = g.endPtsOfContours[i] + 1;
    } //for i
    return pathArray.join(" ");
  }
}

