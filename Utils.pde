
long lastMeassureTime;
int messageCount;
int lastFullCount;
int audioOut, visualsOut;

void count() {
  long now = millis();
  if (now - lastMeassureTime > 1000) {
    lastFullCount = messageCount;
    //println( messageCount, audioOut, visualsOut);
    messageCount = 0;
    audioOut = 0;
    visualsOut = 0;
    lastMeassureTime = now;
  }
  messageCount++;
}

/*void countOut(int type) {
 if (type == AUDIO)
 audioOut++;
 else 
 visualsOut++;
 }*/



boolean readConfig() {
  JSONObject main = loadJSONObject("config.json");
  boolean useIt = main.getBoolean("useThis");
  if (!useIt)
    return false;
  //
  JSONArray sensorsJSON = main.getJSONArray("sensors");
  flipInput = main.getBoolean("flip");
  //
  NUMBER_OF_INPUT_VALUES = sensorsJSON.size();
  sensorNames = new String[NUMBER_OF_INPUT_VALUES];
  sensors = new Sensor[NUMBER_OF_INPUT_VALUES];
  for (int i = 0; i < NUMBER_OF_INPUT_VALUES; i++) {
    sensorNames[i] = sensorsJSON.getString(i); 
    sensors[i] = new Sensor(sensorNames[i], i);
  }
  //
  osc = new OscP5(this, main.getInt("listenPort")); 
  toAudio = new OscForward(main.getJSONObject("audio"));
  toVisuals = new OscForward(main.getJSONObject("visuals"));
  toRecorder = new OscForward(main.getJSONObject("record"));

  return true;
}

void reloadNetworkDestinations() {
  JSONObject main = loadJSONObject("config.json");
  toAudio.resetNetowk(main.getJSONObject("audio"));
  toVisuals.resetNetowk(main.getJSONObject("visuals"));
}