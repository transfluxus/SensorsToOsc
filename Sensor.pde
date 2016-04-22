class Sensor {

  String name;
  Range range;
  int value;
  boolean callibrate;
  boolean initCallibration;
  int index;

  Sensor(String name,int index) {
    this.name = name;
    this.range = new Range(510, 520);
    this.range.index = index;
  }

  float getNormValue() {
    return range.norm(value);
  }

  void callibrate(boolean start) {
    callibrate = start;
    initCallibration = start;
  }

  void value(int value) {
    if(value == 0) 
      return;
    if (flipInput) {
     value = maxAnalogValue - value - 1;
    }
    if (adjust) {
      range.adjustRange(value);
    }
    this.value = value;
  }

  int value() {
    return value;
  }

  void adjust() {
    range.adjustRange(value);
    if (initCallibration) {
      range.min = value;
      range.max = value+1;
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