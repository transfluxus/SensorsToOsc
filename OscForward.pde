boolean printForward;

class OscForward {

  boolean active = true;
  NetAddress remoteAddress;
  //int port; // for json storing

  final SensorForward forwards[] = new SensorForward[NUMBER_OF_INPUT_VALUES];
  String messageTag;

  OscForward(String ipAddress, int port, String messageTag) {
    this.messageTag = messageTag;
    for (int i=0; i < NUMBER_OF_INPUT_VALUES; i++) {
      forwards[i] = new SensorForward(i, sensors[i], new Range());
    }
    // osc
    // this.port = port; 
    remoteAddress = new NetAddress(ipAddress, port);
  }

  void process() {
    if (!active) 
      return;
    OscMessage msg = new OscMessage(messageTag);
    for (SensorForward forward : forwards) {
      float value = forward.getValue();
      if (value != Float.NaN) {
        msg.add(value);
        if (printForward)
          println(forward.sensor.value, value+"(s:"+forward.style+")");
      }
    }
    osc.send(msg, remoteAddress);
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

  void fromJSON(JSONObject json) {
    this.active =  json.getBoolean("active");
    JSONArray ar = json.getJSONArray("forwards");
    for (int i=0; i < forwards.length; i++) {
      forwards[i].fromJSON(ar.getJSONObject(i));
    }
  }
}