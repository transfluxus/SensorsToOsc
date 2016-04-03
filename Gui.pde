boolean init = true;

int yBaseHeight = 60;
int sensorYMargin = 60;

void setupGui() {
  cp5 = new ControlP5(this);

  cp5.addBang("saveJSON")
    .setPosition(300, 10)
    .setSize(50, 20)
    .setLabel("save");


  Group audioGroup = cp5.addGroup("Audio")
    .setPosition(10, 20)
    .setBackgroundHeight(100)
    .setSize(100, 1)
    .setBackgroundColor(color(255, 50))
    .close();

  cp5.addToggle("doForwardTo_Audio")
    .setPosition(150, 20)
    .setSize(50, 20)
    .setLabel("> Audio")
    .setGroup(audioGroup);

  for (int i=0; i < NUMBER_OF_INPUT_VALUES; i++) {

    cp5.addTextlabel(sensorNames[i])
      .setText(sensorNames[i])
      .setPosition(15, yBaseHeight - 25 + i * sensorYMargin)
      .setGroup(audioGroup)
      //.setColorValue(0xffffff0)
      .setFont(createFont("Arial", 16))
      ;

    cp5.addToggle("callibrate-"+i)
      .setPosition(10, yBaseHeight + i * sensorYMargin)
      .setSize(30, 20)
      .setLabel("callibrate")
      .setGroup(audioGroup);

    createRange("range-in-a-", i, audioGroup, 50);

    createRadio("sensor-a-", i, audioGroup, 250);

    createRange("range-out-a-", i, audioGroup, 450);
  }

  // VISUALS
  Group visualsGroup = cp5.addGroup("Visuals")
    .setPosition(20, 600)
    .setSize(100, 20)
    .setBackgroundHeight(100)
    .setBackgroundColor(color(255, 50))
    .close();

  cp5.addToggle("doForwardTo_Visuals")
    .setPosition(10, 10)
    .setSize(50, 20)
    .setLabel("> Visuals")
    .setGroup(visualsGroup);

  init = false;
}

void controlEvent(ControlEvent event) {
  println("e");
  if (init)
    return;
  String name = event.getName();
  println(name);
  if (name.startsWith("sensor")) {
    String[] edit =  name.split("-");
    int index = Integer.valueOf(edit[2]);
    String sendTo = edit[1];
    RadioButton radio = (RadioButton)event.getGroup();
    int selection=0;
    for (int i=0; i<event.getGroup().getArrayValue().length; i++) {
      if ((int)event.getGroup().getArrayValue()[i] == 1) {
        selection = i;
        break;
      }
    }
    configSensor(getSensorForward(sendTo, index), selection);
  } else if (name.startsWith("range")) {
    String[] edit =  name.split("-");
    boolean directionIn = edit[1].equals("in"); // else out 
    String sendTo = edit[2];
    int index = Integer.valueOf(edit[3]);
    Controller<Range> r = (Controller<Range>)(event.getController());
    float min  = r.getArrayValue(0);
    float max  = r.getArrayValue(1);
    if (directionIn) 
      configInRange(getSensorForward(sendTo, index), min, max);
    else 
    configOutRange(getSensorForward(sendTo, index), min, max);
  } else if (name.startsWith("callibrate")) {
    String[] edit =  name.split("-");
    int index = Integer.valueOf(edit[1]);
    sensors[index].callibrate();
  } else if (name.equals("save")) {
    saveJSON();
  }
}

void createRadio(String preName, int index, Group g, int xPos) {
  RadioButton radio =  cp5.addRadioButton(preName+index)
    .setPosition(xPos, yBaseHeight + index * sensorYMargin)
    .setSize(20, 20)
    .setColorForeground(color(120))
    .setColorActive(color(255))
    .setColorLabel(color(255))
    .setItemsPerRow(5)
    .setSpacingColumn(30)
    .addItem(index+"no", 1)
    .addItem(index+"raw", 2)
    .addItem(index+"norm", 3)
    .addItem(index+"map", 4)
    .activate(1)
    .setNoneSelectedAllowed(false)
    .setGroup(g);

  radio.getItem(0).setLabel("no");
  radio.getItem(1).setLabel("raw");
  radio.getItem(2).setLabel("norm");
  radio.getItem(3).setLabel("map");
}

void createRange(String preName, int index, Group g, int xPos) {
  controlP5.Range r= cp5.addRange(preName+index)
    // disable broadcasting since setRange and setRangeValues will trigger an event
    .setBroadcast(false) 
    .setPosition(xPos, yBaseHeight + index * sensorYMargin)
    .setSize(180, 20)
    .setHandleSize(5)
    .setRange(0, 1023)
    .setRangeValues(512, 513)
    // after the initialization we turn broadcast back on again
    .setBroadcast(false)
    .setColorForeground(color(255, 40))
    .setColorBackground(color(255, 40))  
    .setLabel("")
    .setGroup(g);
}

SensorForward getSensorForward(String sendTo, int index) {
  //cp5.getController(
  if (sendTo.equals("a")) {
    return  toAudio.forwards[index];
  } else if (sendTo.equals("v")) {
    return toVisuals.forwards[index];
  } else {
    println("EXCEPTION: getSensorForward");
    return null;
  }
}

void configSensor(SensorForward forward, int selection) {
  forward.setStyle(selection);
}

void configInRange(SensorForward forward, float min, float max) {
  forward.sensor.range.min = min;
  forward.sensor.range.max = max;
}

void configOutRange(SensorForward forward, float min, float max) {
  forward.rangeMap.out.min = min;
  forward.rangeMap.out.max = max;
  println("r.o");
}

controlP5.Range getRangeInCtrl(String to, int index) {
  return (controlP5.Range) cp5.getController("range-in-"+to+"-"+index).update();
}