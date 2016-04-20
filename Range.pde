public class Range {

  private float min, max;
  int index;

  Range() {
    this(0, 1);
  }

  Range(float min, float max) {
    this.min = min;
    this.max = max;
  }

  void set(float val) {
    min = val;
    max = val;
  }

  void adjustRange(float val) {
    if (val < min) {
      min = val;
      getRangeInCtrl("a", index).setRangeValues((int)min, (int)max);
      getRangeInCtrl("v", index).setRangeValues((int)min, (int)max);
    } else if (val > max) {
      max = val;
      getRangeInCtrl("a", index).setRangeValues((int)min, (int)max);
      getRangeInCtrl("v", index).setRangeValues((int)min, (int)max);
    }
  }

  String toString() {
    return "min: "+min +" max: "+max;
  }

  float norm(float value) {
    return map(value, min, max, 0, 1);
  }

  float[] getAr() {
    return new float[] {min, max };
  }

  JSONObject getJSONObject() {
    JSONObject json = new JSONObject();
    json.setFloat("min", min);
    json.setFloat("max", max);
    //println(min, max);
    return json;
  }

  void fromJSON(JSONObject json) {
    min = json.getFloat("min");
    max = json.getFloat("max");
  }
}

public class RangeMap {

  Range in, out;

  RangeMap(Range in, Range out) {
    this.in = in;
    this.out = out;
  }

  float rMap(float val) {
    //println(val);
    in.adjustRange(val);
    return map(val, in.min, in.max, out.min, out.max);
  }
}