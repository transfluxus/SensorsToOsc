public class Range {

  private float min, max;
  boolean dynamic;

  Range() {
    this(0, 1, false);
  }

  Range(float min, float max) {
    this(min, max, false);
  }

  Range(float min, float max, boolean dynamic) {
    this.min = min;
    this.max = max;
    this.dynamic = dynamic;
  }

  void adjustRange(float val) {
    //   println("ad",val,min,max);
    if (dynamic) { 
      if (val < min) 
        min = val;
      else if (val > max) {
        max = val;
      }
    }
    // println(min,max);
  }

  String toString() {
    return "min: "+min +" max: "+max + (dynamic ? " /dyn":"");
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
    println(min,max);
    return json;
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