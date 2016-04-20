boolean init = true;

int yBaseHeight = 60;
int sensorYMargin = 60;

boolean pauseGUIFW;

void switchGuiHide() {
  if (cp5.isVisible()) {
    cp5.hide();
    surface.setSize(400, 300);
  } else {
    cp5.show();
    surface.setSize(1000, 700);
  }
}

void setupGui() {
  cp5 = new ControlP5(this);

  int toggleXShift = 60;
  int toggleX = 30;

  cp5.addToggle("callibrate")
    .setPosition(30, 10)
    .setSize(50, 20)
    .setColorBackground(color(100, 100, 100));
  toggleX += toggleXShift;

  cp5.addToggle("showVals")
    .setPosition(toggleX, 10)
    .setSize(50, 20)
    .setColorBackground(color(100, 100, 100));
  toggleX += toggleXShift;

  cp5.addToggle("adjust")
    .setPosition(toggleX, 10)
    .setSize(50, 20)
    .setColorBackground(color(100, 100, 100));
  toggleX += toggleXShift;

  cp5.addToggle("flip")
    .setPosition(toggleX, 10)
    .setSize(50, 20)
    .setValue(flipInput)
    .setColorBackground(color(100, 100, 100));
  toggleX += toggleXShift;
  /*
  cp5.addToggle("record")
   .setPosition(toggleX, 10)
   .setSize(50, 20)
   .setColorBackground(color(100, 100, 100))
   .setLabel("record");
   toggleX += toggleXShift*2;
   */
  cp5.addBang("saveJSON")
    .setPosition(toggleX, 10)
    .setSize(50, 20)
    .setLabel("save");
  toggleX += toggleXShift;

  cp5.addBang("loadJSON")
    .setPosition(toggleX, 10)
    .setSize(50, 20)
    .setLabel("load");
  toggleX += toggleXShift;

  cp5.addSlider("Frequency")
    .setPosition(toggleX, 10)
    .setRange(1, 400)
    .setValue(40);


  cp5.addSlider("Beta")
    .setPosition(toggleX, 30)
    .setRange(0.01, 1)
    .setValue(1);

  toggleX += 3 * toggleXShift;

  cp5.addToggle("Filter")
    .setPosition(toggleX, 10)
    .setSize(50, 20)
    .setColorBackground(color(100, 100, 100));

  Group audioGroup = cp5.addGroup("Audio")
    //  .setPosition(10, 70)
    .setSize(100, 1)
    .setBackgroundHeight(60 + sensorYMargin * NUMBER_OF_INPUT_VALUES)
    .close();

  cp5.addToggle("doForwardTo_Audio")
    .setPosition(150, 20)
    .setSize(50, 20)
    .setLabel("> Audio")
    .changeValue(1)
    .setColorBackground(color(100, 100, 100))
    .setGroup(audioGroup);

  for (int i=0; i < NUMBER_OF_INPUT_VALUES; i++) {
    cp5.addTextlabel(sensorNames[i]+"-a")
      .setText(sensorNames[i])
      .setPosition(15, yBaseHeight - 25 + i * sensorYMargin)
      .setGroup(audioGroup)
      //.setColorValue(0xffffff0)
      .setFont(createFont("Arial", 16));

    cp5.addToggle("callibrate-"+i)
      .setPosition(10, yBaseHeight + i * sensorYMargin)
      .setSize(30, 20)
      .setLabel("callibrate")
      .setColorBackground(color(100, 100, 100))
      .setGroup(audioGroup);

    createRange("range-in-a-", i, audioGroup, 50);
    createRadio("sensor-a-", i, audioGroup, 250);
    createRange("range-out-a-", i, audioGroup, 450);
  }

  // VISUALS
  Group visualsGroup = cp5.addGroup("Visuals")
    .setPosition(10, 100)
    .setSize(100, 1)
    .close();

  cp5.addToggle("doForwardTo_Visuals")
    .setPosition(150, 20)
    .setSize(50, 20)
    .setLabel("> Visuals")
    .changeValue(1)
    .setColorBackground(color(100, 100, 100))
    .setGroup(visualsGroup);

  for (int i=0; i < NUMBER_OF_INPUT_VALUES; i++) {
    cp5.addTextlabel(sensorNames[i]+"-v")
      .setText(sensorNames[i])
      .setPosition(15, yBaseHeight - 25 + i * sensorYMargin)
      .setGroup(visualsGroup)
      //.setColorValue(0xffffff0)
      .setFont(createFont("Arial", 16));

    createRange("range-in-v-", i, visualsGroup, 50);
    createRadio("sensor-v-", i, visualsGroup, 250);
    createRange("range-out-v-", i, visualsGroup, 450);
  }

  Accordion  accordion = cp5.addAccordion("acc")
    .setPosition(10, 70)
    .setWidth(200)
    .addItem(audioGroup)
    .addItem(visualsGroup); 

  initRanges();
  init = false;
}

void controlEvent(ControlEvent event) {
  if (init || pauseGUIFW)
    return;
  //println(pauseGUIFW);
  String name = event.getName();
  //println("event:", name);
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
  } else if (name.equals("callibrate")) {
    callibrate = cp5.getController("callibrate").getValue() == 1.0;
    for (int i=0; i < NUMBER_OF_INPUT_VALUES; i++) {
      cp5.getController("callibrate-"+i).setValue(callibrate ? 1 : 0);
    }
  } else if (name.startsWith("callibrate")) {
    boolean on =  event.getController().getValue() == 1.0f;
    String[] edit =  name.split("-");
    int index = Integer.valueOf(edit[1]);
    sensors[index].callibrate(on);
    cp5.getController("range-in-a-"+index).setBroadcast(!on);
  } else if (name.equals("doForwardTo_Audio")) {
    toAudio.active = cp5.getController("doForwardTo_Audio").getValue() == 1;
  } else if (name.equals("doForwardTo_Visuals")) {
    toVisuals.active = cp5.getController("doForwardTo_Visuals").getValue() == 1;
  } else if (name.equals("showVals")) {
    showVals =  cp5.getController("showVals").getValue() == 1;
  } else if (name.equals("flip")) {
    flipInput =  cp5.getController("flip").getValue() == 1;
  } else if (name.equals("Frequency")) {
    doFilter = false;
    filter.setFrequency(cp5.getController("Frequency").getValue());
    doFilter = true;
  } else if (name.equals("Beta")) {
    filter.setBeta(cp5.getController("Beta").getValue());
  } else if (name.equals("Filter")) {
    doFilter =  cp5.getController("Filter").getValue() == 1;
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
    .addItem(preName+index+"no", 1)
    .addItem(preName+index+"raw", 2)
    .addItem(preName+index+"norm", 3)
    .addItem(preName+index+"map", 4)
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
    .setRange(0, pow(2, ANANLOG_BITS))
    .setRangeValues(0, pow(2, ANANLOG_BITS))
    // after the initialization we turn broadcast back on again
    .setBroadcast(true)
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

void initRanges() {
  for (int i=0; i <NUMBER_OF_INPUT_VALUES; i++) {
    Controller<Range> r = (Controller<Range>)  cp5.getController("range-in-a-"+i);
    float min  = r.getArrayValue(0);
    float max  = r.getArrayValue(1);
    configInRange(getSensorForward("a", i), min, max);
    // r = (Controller<Range>)  cp5.getController("range-in-v-"+i);
    configInRange(getSensorForward("v", i), min, max );

    // OUT
    r = (Controller<Range>)  cp5.getController("range-out-a-"+i);
    min  = r.getArrayValue(0);
    max  = r.getArrayValue(1);
    configOutRange(getSensorForward("a", i), min, max);
    r = (Controller<Range>)  cp5.getController("range-out-v-"+i);
    min  = r.getArrayValue(0);
    max  = r.getArrayValue(1);
    configOutRange(getSensorForward("v", i), min, max );
  }
}

void configInRange(SensorForward forward, float min, float max) {
  forward.sensor.range.min = min;
  forward.sensor.range.max = max;
  //println("ri");
}

void configOutRange(SensorForward forward, float min, float max) {
  forward.rangeMap.out.min = min;
  forward.rangeMap.out.max = max;
  //println("r.o");
}

controlP5.Range getRangeInCtrl(String to, int index) {
  return (controlP5.Range) cp5.getController("range-in-"+to+"-"+index).update();
}

controlP5.Range getRangeOutCtrl(String to, int index) {
  return (controlP5.Range) cp5.getController("range-out-"+to+"-"+index).update();
}