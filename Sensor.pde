class Sensor {

  String name;
  Range range;
  int value;
  boolean callibrate;
  boolean initCallibration;

  Sensor(String name) {
    this.name = name;
    this.range = new Range(510, 520);
  }

  float getNormValue() {
    return range.norm(value);
  }

  void callibrate(boolean start) {
    callibrate = start;
    initCallibration = start;
  }

  void adjust() {
    //println("ra");
    range.adjustRange(value);
    if (initCallibration) {
      range.set(value);
      initCallibration = false;
    }
  }

  JSONObject getJSONObject() {
    return range.getJSONObject();
  }

  void fromJSON(JSONObject json) {
    range.fromJSON(json);
   // println(range.min, range.max);
  }
}