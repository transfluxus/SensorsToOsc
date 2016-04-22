import netP5.*;
import oscP5.*;
import controlP5.*;
import processing.serial.*;


// SERIAL CONNECTION
boolean startSerial = false;
int SERIAL_PORT_NO =  0;
int SERIAL_BAUDRATE = 115200;
// MY PORT
int LISTEN_PORT = 12000;
String addrPattern = "/sens";
// ANALOG_BITS
int ANANLOG_BITS = 12;
int maxAnalogValue = (int) pow(2, ANANLOG_BITS);

// Sensor naming
String[] sensorNames= {"left-shoulder", "right-shoulder", 
  "left-arm", "right-arm", "left-leg", "right-leg", "spine"};

// OSC SETTINGS FOR THE AUDIO/VISUALS
String AUDIO_IP_ADDRESS = "";
String VISUALS_IP_ADDRESS = "127.0.0.1";//"192.168.2.47";
int  AUDIO_PORT = 6000;
int VISUALS_PORT = 12345;
String AUDIO_MSG_TAG = "/dance";
String VISUALS_MSG_TAG = "/dance";
// 
String RECORDER_IP_ADDRESS = "";
int  RECORDER_PORT = 6000;
String RECORDER_MSG_TAG = "/dance";

// OTHER SETTINGS

// CALLIBRATE with key:c
boolean callibrate = false;
boolean adjust = false;
boolean showVals = false;
boolean createRndValue = false;
boolean showMsgCount = false;
boolean flipInput = false;
boolean takeOSCIn = true;
/* 
 false: values will be limited to their callibrated value
 true: will adjust the callibration values (min,max) when new extrams come in
 */
boolean rangeAdjust = false;

//NOT FOR EDIT, ESSENTIAL OBJECTS 
int NUMBER_OF_INPUT_VALUES = sensorNames.length;

Serial serial;
OscP5 osc;
ControlP5 cp5;
//OscForward[] forwards = new OscForward[3];
OscForward toAudio, toVisuals, toRecorder;
Sensor[] sensors = new Sensor[NUMBER_OF_INPUT_VALUES];

boolean msgReceived = false;

//
boolean logAllMsgs;

SignalFilter filter;

void setup() {
  size(1000, 700);
  setupSerial();
  setupSensors();
  setupOSCForward();
  setupGui();
  setupFilter();
  surface.setResizable(true);
  textSize(14);
}

void draw() {
  background(0);
  fill(255);
  sensorIndicator();
  printVals();
  displayVals();
  //println(frameRate);
  if (createRndValue)
    rndOSCVals();
  if (frameRate < 30) 
    println("OHO! framerate < 30"+ frameCount);
  if (msgReceived) {
    if (takeOSCIn) {
      fill(255, 0, 0);
    } else { 
      noFill();
    }
    ellipse(width-40, 40, 10, 10);
  }
  msgReceived = false;
}

void rndOSCVals() {
  int vals[] = new int[NUMBER_OF_INPUT_VALUES];
  for (int i=0; i < NUMBER_OF_INPUT_VALUES; i++) {
    vals[i] = (int)(noise(i*3+frameCount*0.01f)*maxAnalogValue);
  }
  if (mousePressed && mouseButton == RIGHT) {
    vals[0] = maxAnalogValue;
  }
  process(vals);
  text("RND", 20, height-20);
}

void keyPressed() {
  if (key == 'c') {
    callibrate =  !callibrate;
    cp5.getController("callibrate").setValue(callibrate ? 1 : 0);
  } else if (key == '1') {
    toAudio.active = !toAudio.active;
  } else if (key == '2') {
    toVisuals.active = !toVisuals.active;
  } else if (key == '3') {
    toRecorder.active =! toRecorder.active;
  } else if (key== 'l') {
    showVals = !showVals;
    cp5.getController("showVals").setValue(showVals? 1 : 0);
  } else if (key == 'h') {
    switchGuiHide();
  } else if (key == 'r') 
    createRndValue = !createRndValue;
  else if (key == 'm') 
    showMsgCount = !showMsgCount;
  else if (key == 'i') {
    println("Audio: "+toAudio.remoteAddress); 
    println("Visuals: "+toVisuals.remoteAddress);
  } else if (key == 'd') {
    // reload config json
  } else if (key == 'w') {
    takeOSCIn = !takeOSCIn;
  }
}

void setupSerial() {
  if (startSerial) {
    int si = 0;
    for (String serial : Serial.list()) {
      println((si++), serial);
    }
    serial = new Serial(this, Serial.list()[SERIAL_PORT_NO], SERIAL_BAUDRATE);
  }
}

void sensorIndicator() {
  pushMatrix();
  translate(0, height-20);
  if (callibrate) {
    text("CAL", 10, 0);
  } 
  if (toAudio.active) {
    text(">A", width-70, 0);
  } 
  if (toVisuals.active) {
    text(">V", width-50, 0);
  } 
  if (toRecorder.active) {
    text(">R", width-30, 0);
  }  
  if (showMsgCount) {
    text("msgs:"+messageCount, 50, 0);
  }
  popMatrix();
}


void printVals() {
  if (showVals) {
    pushMatrix();
    if (cp5.isVisible())
      translate(759, 100);
    else
      translate(130, 20);
    text("Sensor", 0, 0);
    text("> Audio", 70, 0);
    text("> Visuals", 150, 0);
    for (int i=0; i < sensors.length; i++) {
      pushMatrix();
      translate(0, (i+1)*25);
      text(i, -105, 0);
      text(sensors[i].name, -90, 0);
      text(sensors[i].value(), 15, 0);
      if (toAudio.active) 
        text(nf(toAudio.forwards[i].value, 2, 3), 70, 0);
      if (toVisuals.active) 
        text(toVisuals.forwards[i].value, 150, 0);
      popMatrix();
    }
    popMatrix();
  }
}

void  displayVals() {
  for (int i=0; i < NUMBER_OF_INPUT_VALUES; i++) {
    stroke(255);
    if (cp5.isVisible()) {
      float vs = cp5.getController("range-in-v-"+i).getAbsolutePosition()[0] + map(sensors[i].value, 0, maxAnalogValue, 0, 180);
      float ys = 80 + yBaseHeight + i * sensorYMargin;
      line(vs, ys, vs, ys + 30);
    } else {
      float vs = 20 + map(sensors[i].value, 0, maxAnalogValue, 0, 180);
      float ys = height - 80 + i * 10;
      line(vs, ys, vs, ys + 10);
    }
  }
  if (!cp5.isVisible()) {
    line(20, height-85, 200, height-85);
  }
}

void setupSensors() {
  if (readConfig()) 
    return;
  for (int i=0; i < NUMBER_OF_INPUT_VALUES; i++) {
    sensors[i] = new Sensor(sensorNames[i], i);
  }
}

void setupOSCForward() {
  if (readConfig()) 
    return;
  osc = new OscP5(this, LISTEN_PORT); 
  toAudio = new OscForward(AUDIO_IP_ADDRESS, AUDIO_PORT, AUDIO_MSG_TAG);

  toVisuals = new OscForward(VISUALS_IP_ADDRESS, VISUALS_PORT, VISUALS_MSG_TAG);
  toRecorder = new OscForward(RECORDER_IP_ADDRESS, RECORDER_PORT, RECORDER_MSG_TAG);
  // toAudio.type = AUDIO;
  // toVisuals.type = VISUALS;
  toRecorder.active = false;
}

String serialMessage = "";

void serialEvent(Serial port) {
  try {
    while (serial.available () > 0) {
      String read= port.readString();
      if (read.equals("\n")) {
        serialMessage = serialMessage.trim();
        if (logAllMsgs) {
          println(serialMessage);
        }
        forward(serialMessage);
        serialMessage = "";
      } else
        serialMessage += read;
    }
  } 
  catch(Exception exc) {
    println("error");
  }
}

void oscEvent(OscMessage msg) {
  if (msg.checkAddrPattern(addrPattern)==true) {
    count();    
    msgReceived = true;
    int le = msg.typetag().length();
    int[] vals = new int[le];
    for (int i=0; i < le; i++) {
      vals[i] =  msg.get(i).intValue();
    }
    if (takeOSCIn)
      process(vals);
  }
}

int[] prepareString(String msg) {
  String[] list = split(msg, ',');
  int numberOfValues = list.length;
  int[] vals = new int[numberOfValues];
  for (int i=0; i < numberOfValues; i++) {
    try {
      vals[i] =  Integer.valueOf(list[i]);
    }  
    catch(NumberFormatException exc) {
      println("Couldn't parse: "+list[i]+ " setting it to 0");
      sensors[i].value(0);
    }
  }
  return vals;
}

void forward(String message) {
  process(prepareString(message));
}


void process(int[] vals) {
  int numberOfValues = vals.length;
  //int[] serialValues = new int[NUMBER_OF_INPUT_VALUES];
  if (numberOfValues != NUMBER_OF_INPUT_VALUES) {
    println("number of incoming values("+numberOfValues+") doesn't match NUMBER_OF_INPUT_VALUES: "+NUMBER_OF_INPUT_VALUES+". Remaining values will be 0");
  }
  ///
  pauseGUIFW = true;
  for (int i=0; i < NUMBER_OF_INPUT_VALUES; i++) {
    if (i < numberOfValues) {
      Sensor sensor = sensors[i];
      sensor.value(vals[i]);
      if (sensor.callibrate) {
        sensor.adjust();
        getRangeInCtrl("a", i).setRangeValues((int)sensor.range.min, (int)sensor.range.max);
        getRangeInCtrl("v", i).setRangeValues((int)sensor.range.min, (int)sensor.range.max);
      }
    } else {
      sensors[i].value(0);
    }
  }
  applyFilter();

  pauseGUIFW = false;
  toAudio.process();
  toVisuals.process();
  toRecorder.process();
}