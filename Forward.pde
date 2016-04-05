enum ForwardStyle {
  NO, RAW, NORM, MAP
};

class SensorForward {

  final int index;
  Sensor sensor;
  // Range toRange;
  RangeMap rangeMap;
  ForwardStyle style = ForwardStyle.RAW;

  SensorForward(int index, Sensor sensor, Range toRange) {
    this.index = index;
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
      // println("map:"+sensor.value,rangeMap.in,rangeMap.out);
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

  void fromJSON(JSONObject json,String outShort) {
    style = ForwardStyle.values()[json.getInt("style")];
    RadioButton radio = (RadioButton) cp5.getGroup("sensor-"+outShort+"-"+index);

    int styleI = json.getInt("style");
    style = ForwardStyle.values()[styleI];

    java.util.List<Toggle> items = radio.getItems();
    items.get(styleI).setValue(true);

    controlP5.Range r = getRangeOutCtrl(outShort, index);
    rangeMap.out.fromJSON(json.getJSONObject("toRange"));
    r.setBroadcast(false);
    r.setLowValue(rangeMap.out.min);
    r.setHighValue( rangeMap.out.max);
    r.setBroadcast(true);
  }
}