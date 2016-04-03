import netP5.*;
import oscP5.*;

import controlP5.*;

import processing.serial.*;

// SERIAL CONNECTION
int SERIAL_PORT_NO =  0;
int SERIAL_BAUDRATE = 9600;

// Sensor naming
int NUMBER_OF_INPUT_VALUES = 1;
String[] sensorNames= {"left-shoulder", "right-shoulder", 
  "left-arm", "right-arm", "left-leg", "right-leg", "spine"};

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
/* 
 false: values will be limited to their callibrated value
 true: will adjust the callibration values (min,max) when new extrams come in
 */
boolean rangeAdjust = false;

//NOT FOR EDIT, ESSENTIAL OBJECTS 
Serial serial;
OscP5 osc;
ControlP5 cp5;
OscForward toAudio, toVisuals;
Sensor[] sensors = new Sensor[NUMBER_OF_INPUT_VALUES];

//
boolean logAllMsgs;

void setup() {
  size(800, 700);
  setupSerial();
  setupSensors();
  setupOSCForward();
  setupGui();
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
  forward(""+(int)(noise(frameCount*0.01f)*1024));
}

void keyPressed() {
  if (key == 'c') {
    callibrate =  !callibrate;
  } else if (key == '1') {
    toAudio.active = !toAudio.active;
  } else if (key == '2') {
    toVisuals.active = !toVisuals.active;
  }
}

void setupSerial() {
  int si = 0;
  for (String serial : Serial.list()) {
    println((si++), serial);
  }
  //serial =
  //new Serial(this, Serial.list()[SERIAL_PORT_NO], SERIAL_BAUDRATE);
}

void setupSensors() {
  for (int i=0; i < NUMBER_OF_INPUT_VALUES; i++) {
    sensors[i] = new Sensor(sensorNames[i]);
  }
}

void setupOSCForward() {
  osc = new OscP5(this, 6000); 
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

void forward(String message) {
  String[] list = split(message, ',');
  int numberOfValues = list.length;
  //int[] serialValues = new int[NUMBER_OF_INPUT_VALUES];
  if (numberOfValues != NUMBER_OF_INPUT_VALUES) {
    println("number of incoming values("+numberOfValues+") doesn't match NUMBER_OF_INPUT_VALUES: "+NUMBER_OF_INPUT_VALUES+". Remaining values will be 0");
  }
  for (int i=0; i < NUMBER_OF_INPUT_VALUES; i++) {
    try {
      if (i < numberOfValues) {
        Sensor sensor = sensors[i];
        sensor.value = Integer.valueOf(list[i]);
        if (callibrate) {
          sensor.adjust();
          // println(sensor.range.min,sensor.range.max);
          // println( java.util.Arrays.toString(Range.class.getMethods()));
          getRangeInCtrl("a", i).setLowValue((int)sensor.range.min);
          getRangeInCtrl("a", i).setHighValue((int)sensor.range.max);
        }
      } else {
        sensors[i].value = 0;
      }
    } 
    catch(NumberFormatException exc) {
      println("Couldn't parse: "+list[i]+ " setting it to 0");
      sensors[i].value = 0;
    }
  }
  toAudio.process();
  toVisuals.process();
}