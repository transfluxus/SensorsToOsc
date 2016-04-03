
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
    //sensors[i].fromJSON(main.getJSONArray("sensors").getJSONObject(i));
    controlP5.Range r = getRangeInCtrl("a", i);
    sensors[i].fromJSON(main.getJSONArray("sensors").getJSONObject(i));
    //println(sensors[i].range.min, sensors[i].range.max);
    r.setBroadcast(false);
    r.setLowValue(sensors[i].range.min);
    r.setHighValue(sensors[i].range.max);
    r.setBroadcast(true);
  }

  toAudio.fromJSON(main.getJSONObject("audio"));
  pauseGUIFW = false;
}