boolean printForward;

int AUDIO = 0;
int VISUALS = 1;


class OscForward {

  boolean active = true;
  NetAddress remoteAddress;
  //int type;
  //int port; // for json storing

  final SensorForward forwards[] = new SensorForward[NUMBER_OF_INPUT_VALUES];
  String messageTag;
  int remap[] = new int[NUMBER_OF_INPUT_VALUES];
  boolean doRemap = false;

  OscForward(String ipAddress, int port, String messageTag) {
    this.messageTag = messageTag;
    setupFWs();
    remoteAddress = new NetAddress(ipAddress, port);
  }

  OscForward(JSONObject json) {
    this.messageTag = json.getString("MessageTag");
    setupFWs();
    remoteAddress = new NetAddress(json.getString("ip"), json.getInt("port"));
    active = json.getBoolean("active");
    doRemap = json.getBoolean("doRemap");
    if (doRemap) {
      JSONArray jsonReMap = json.getJSONArray("remap");
      int[] remapAr = new int[NUMBER_OF_INPUT_VALUES]; 
      for (int i= 0; i < NUMBER_OF_INPUT_VALUES; i++) {
        remapAr[i] = jsonReMap.getInt(i);
      }
    }
  }

  void setupFWs() {
    for (int i=0; i < NUMBER_OF_INPUT_VALUES; i++) {
      forwards[i] = new SensorForward(i, sensors[i], new Range());
    }
  }

  void process() {
    if (!active) 
      return;
    OscMessage msg = new OscMessage(messageTag);
    float[] vals = new float[NUMBER_OF_INPUT_VALUES];
 /*   for (int i=0; i < NUMBER_OF_INPUT_VALUES; i++) {
      float value = forwards[i].getValue();
      if (value != Float.NaN) {
        if (doRemap)
          vals[remap[i]] = value;
          else
          vals[i] = value;
        if (printForward)
          println(forward.sensor.value(), value+"(s:"+forward.style+")");
      }
    } */
    if (doRemap) {
      int i=0;
      for (SensorForward forward : forwards) {
        float value = forward.getValue();
        if (value != Float.NaN) {
          vals[remap[i++]] = value;
          if (printForward)
            println(forward.sensor.value(), value+"(s:"+forward.style+")");
        }
      }
    } else {
      int i = 0;
      for (SensorForward forward : forwards) {
        float value = forward.getValue();
        if (value != Float.NaN) {
          vals[i++] = value;
          if (printForward)
            println(forward.sensor.value(), value+"(s:"+forward.style+")");
        }
      }
    }
    for (int i=0; i < NUMBER_OF_INPUT_VALUES; i++) {
      float value = vals[i];
      if (value != Float.NaN) {
        msg.add(value);
        /*  if (printForward)
         println(forward.sensor.value(), value+"(s:"+forward.style+")"); */
      }
    }
    osc.send(msg, remoteAddress);
    // countOut(type);
  }

  // for All forwards
  JSONObject getJSONObject() {
    JSONObject json = new JSONObject();
    json.setBoolean("active", active);
    JSONArray forwardsJSON = new JSONArray();
    for (int i=0; i < forwards.length; i++) {
      forwardsJSON.setJSONObject(i, forwards[i].getJSONObject());
    }
    json.setJSONArray("forwards", forwardsJSON);
    //json.setString("
    //json.setString("ip",remoteAddress.getHostAddress());
    return json;
  }

  void fromJSON(JSONObject json, String outShort) {
    this.active =  json.getBoolean("active");
    JSONArray ar = json.getJSONArray("forwards");
    for (int i=0; i < forwards.length; i++) {
      forwards[i].fromJSON(ar.getJSONObject(i), outShort);
    }
  }

  void remap(int[] rem) {
    println("setting remap");
    doRemap = true;
    remap = rem;
  }
}