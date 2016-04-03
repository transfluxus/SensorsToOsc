class Sensor {

  String name;
  Range range;
  int value;

  Sensor(String name) {
    this.name = name;
    this.range = new Range(510, 520);
  }

  float getNormValue() {
    return range.norm(value);
  }

  void callibrate() {
    range.dynamic = true;
  }

  void adjust() {
    range.adjustRange(value);
    if (range.dynamic) 
      range.dynamic = false;
  }

  JSONObject getJSONObject() {
    return range.getJSONObject();
  }
}

enum ForwardStyle {
  NO, RAW, NORM, MAP
};

class SensorForward {

  Sensor sensor;
  // Range toRange;
  RangeMap rangeMap;
  ForwardStyle style = ForwardStyle.RAW;

  SensorForward(Sensor sensor, Range toRange) {
    this.sensor = sensor;
    this.rangeMap = new RangeMap(sensor.range, toRange);
  }

  float getValue() {
    switch (style) {
    case NO:
      return  Float.NaN;
    case NORM:
      return sensor.getNormValue();
    case MAP:
    println("map:"+sensor.value,rangeMap.in,rangeMap.out);
      return rangeMap.rMap(sensor.value);
    case RAW:
    default:
      return sensor.value;
    }
  }

  void setStyle(int selection) {
    style = ForwardStyle.values()[selection];
  }

  JSONObject getJSONObject() {
    JSONObject json = new  JSONObject ();
    json.setInt("style", (int) style.ordinal());
    json.setJSONObject("toRange", rangeMap.out.getJSONObject());

    return json;
  }
}