class OscForward {

  boolean active = true;
  NetAddress remoteAddress;

  final SensorForward forwards[] = new SensorForward[NUMBER_OF_INPUT_VALUES];
  String messageTag;

  OscForward(String ipAddress, int port, String messageTag) {
    this.messageTag = messageTag;
    for (int i=0; i < NUMBER_OF_INPUT_VALUES; i++) {
      forwards[i] = new SensorForward(sensors[i], new Range());
    }
    // osc
    remoteAddress = new NetAddress(ipAddress, port);
  }

  void process() {
    if (!active) 
      return;
    OscMessage msg = new OscMessage("/test");
    for (SensorForward forward : forwards) {
      float value = forward.getValue();
      if (value != Float.NaN) {
        msg.add(value);
        //println(forward.sensor.value, value);
      }
    }
    osc.send(msg,remoteAddress);
  }
}