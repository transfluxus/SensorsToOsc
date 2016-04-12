
long lastMeassureTime;
int messageCount;
int audioOut, visualsOut;

void count() {
  long now = millis();
  if (now - lastMeassureTime > 1000) {
    println( messageCount, audioOut, visualsOut);
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
     osc = new OscP5(this, main.getInt("listenPort")); 
  toAudio = new OscForward(main.getJSONObject("audio"));
  toVisuals = new OscForward(main.getJSONObject("visuals"));
  toRecorder = new OscForward(main.getJSONObject("record"));

  return true;
}