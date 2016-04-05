
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
    controlP5.Range ra = getRangeInCtrl("a", i);
    controlP5.Range rv = getRangeInCtrl("v", i);
    ra.setBroadcast(false);
    rv.setBroadcast(false);
    sensors[i].fromJSON(main.getJSONArray("sensors").getJSONObject(i));
    //println(sensors[i].range.min, sensors[i].range.max);
    ra.setLowValue(sensors[i].range.min);
    ra.setHighValue(sensors[i].range.max);
    rv.setLowValue(sensors[i].range.min);
    rv.setHighValue(sensors[i].range.max);
  }

  toAudio.fromJSON(main.getJSONObject("audio"),"a");
  toVisuals.fromJSON(main.getJSONObject("visuals"),"v");
  pauseGUIFW = false;
}