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

// Sensor naming
String[] sensorNames= {"left-shoulder", "right-shoulder", 
  "left-arm", "right-arm", "left-leg"};//, "right-leg", "spine"};

// OSC SETTINGS FOR THE AUDIO/VISUALS
String AUDIO_IP_ADDRESS = "";
String VISUALS_IP_ADDRESS = "";
int  AUDIO_PORT = 6000;
int VISUALS_PORT = 6000;
String AUDIO_MSG_TAG = "/dance";
String VISUALS_MSG_TAG = "/dance";
// OTHER SETTINGS


//boolean NORMALIZE_ALL = false; // normalizing 


// CALLIBRATE with key:c
boolean callibrate = false;
boolean showVals  =false;
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
OscForward toAudio, toVisuals;
Sensor[] sensors = new Sensor[NUMBER_OF_INPUT_VALUES];

//
boolean logAllMsgs;

void setup() {
  size(1000, 700);
  setupSerial();
  setupSensors();
  setupOSCForward();
  setupGui();
  frameRate(20);
}

void draw() {
  background(0);
  fill(255);
  if (callibrate) {
    text("CAL", 10, height-20);
  } 
  if (toAudio.active) {
    text(">A", width-60, height-20);
  } 
  if (toVisuals.active) {
    text(">V", width-40, height-20);
  } 
  if (showVals) {
    pushMatrix();
    translate(700, 100);
    text("Sensor", 0, 0);
    text("> Audio", 80, 0);
    text("> Visuals", 160, 0);
    for (int i=0; i < sensors.length; i++) {
      pushMatrix();
      translate(0, (i+1)*25);
      text(sensors[i].value, 0, 0);
      if (toAudio.active) 
        text(nf(toAudio.forwards[i].value,2,3), 80, 0);
      if (toVisuals.active) 
        text(toVisuals.forwards[i].value, 160, 0);
      popMatrix();
    }
    popMatrix();
  }
  rndOSCVals();
}

void rndOSCVals() {
  int vals[] = new int[NUMBER_OF_INPUT_VALUES];
  for (int i=0; i < NUMBER_OF_INPUT_VALUES; i++) {
    vals[i] = (int)(noise(i*3+frameCount*0.01f)*1024);
  }
  process(vals);
}

void keyPressed() {
  if (key == 'c') {
    callibrate =  !callibrate;
    cp5.getController("callibrate").setValue(callibrate ? 1 : 0);
  } else if (key == '1') {
    toAudio.active = !toAudio.active;
  } else if (key == '2') {
    toVisuals.active = !toVisuals.active;
  } else if (key== 'l') {
    printForward = !printForward;
  } else if (key == 'h') {
    switchGuiHide();
  }
}

void setupSerial() {
  if (!startSerial) {
    int si = 0;
    for (String serial : Serial.list()) {
      println((si++), serial);
    }
    serial = new Serial(this, Serial.list()[SERIAL_PORT_NO], SERIAL_BAUDRATE);
  }
}

void setupSensors() {
  for (int i=0; i < NUMBER_OF_INPUT_VALUES; i++) {
    sensors[i] = new Sensor(sensorNames[i]);
  }
}

void setupOSCForward() {
  osc = new OscP5(this, LISTEN_PORT); 
  toAudio = new OscForward(AUDIO_IP_ADDRESS, AUDIO_PORT, AUDIO_MSG_TAG);
  toVisuals = new OscForward(VISUALS_IP_ADDRESS, VISUALS_PORT, VISUALS_MSG_TAG);
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
    int le = msg.addrPattern().length();
    int[] vals = new int[le];
    for (int i=0; i < le; i++) {
      vals[i] =  msg.get(i).intValue();
    }
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
      sensors[i].value = 0;
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
      sensor.value = vals[i];
      if (sensor.callibrate) {
        sensor.adjust();
        getRangeInCtrl("a", i).setRangeValues((int)sensor.range.min, (int)sensor.range.max);
        getRangeInCtrl("v", i).setRangeValues((int)sensor.range.min, (int)sensor.range.max);
      }
    } else {
      sensors[i].value = 0;
    }
  }
  pauseGUIFW = false;
  /* for (int i=0; i < NUMBER_OF_INPUT_VALUES; i++) {
   getRangeInCtrl("a", i).update();
   }*/
  //
  /*  for (int i=0; i < NUMBER_OF_INPUT_VALUES; i++) {
   getRangeInCtrl("a", i).update();
   } */
  //getRangeInCtrl("a", i).setHighValue((int)sensor.range.max);
  // getRangeInCtrl("v", i).setLowValue((int)sensor.range.min);
  // getRangeInCtrl("v", i).setHighValue((int)sensor.range.max);
  toAudio.process();
  toVisuals.process();
}