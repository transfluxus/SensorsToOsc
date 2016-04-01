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

  void adjust() {
    range.adjustRange(value);
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
      return rangeMap.rMap(sensor.value);
    case RAW:
    default:
      return sensor.value;
    }
  }

  void setStyle(int selection) {
    style = ForwardStyle.values()[selection];
  }
}