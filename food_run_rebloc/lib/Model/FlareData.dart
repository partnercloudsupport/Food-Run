class FlareData {
  static final FlareInfo runningMan =
      FlareInfo(filename: "assets/RunningMan.flr", animation: "Run");
}

class FlareInfo {
  final String filename;
  final String animation;
  FlareInfo({this.filename, this.animation});
}
