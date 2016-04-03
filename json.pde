
void saveJSON() {

  JSONArray sensorsJSON = new JSONArray();
  for (int i = 0; i < sensors.length; i++) {
    sensorsJSON.setJSONObject(i, sensors[i].getJSONObject());
  }

  JSONObject audio = toAudio.getJSONObject();
  
  //JSONObject visuals = new JSONObject();

  JSONObject main = new JSONObject();
  main.setJSONArray("sensors", sensorsJSON);


  main.setJSONObject("audio", audio);
 // main.setJSONObject("visuals", visuals);

  saveJSONObject(main, "data/settings.json");
  println("JSON stored");
}