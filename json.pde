
void saveJSON() {

  JSONObject main = new JSONObject();

  JSONArray sensorsJSON = new JSONArray();
  for (int i = 0; i < sensors.length; i++) {
    sensorsJSON.setJSONObject(i, sensors[i].getJSONObject());
  }
  main.setJSONArray("sensors", sensorsJSON);

  main.setJSONObject("audio", toAudio.getJSONObject());
  main.setJSONObject("visuals", toVisuals.getJSONObject());

  saveJSONObject(main, "data/settings.json");
  println("JSON stored");
}

void loadJSON() {
  pauseGUIFW = true;
  JSONObject main = loadJSONObject("settings.json");
  //println(main);

  for (int i = 0; i < sensors.length; i++) {
    sensors[i].fromJSON(main.getJSONArray("sensors").getJSONObject(i));
  }
  updateRangesFromSensordata();
  toAudio.fromJSON(main.getJSONObject("audio"), "a");
  toVisuals.fromJSON(main.getJSONObject("visuals"), "v");
}

void updateRangesFromSensordata() {
  pauseGUIFW = true;
  for (int i = 0; i < sensors.length; i++) {
    Sensor sensor = sensors[i];
    controlP5.Range ra = getRangeInCtrl("a", i);
    controlP5.Range rv = getRangeInCtrl("v", i);
    getRangeInCtrl("a", i).setRangeValues((int)sensor.range.min, (int)sensor.range.max);
    getRangeInCtrl("v", i).setRangeValues((int)sensor.range.min, (int)sensor.range.max);
  }
  pauseGUIFW = false;
}