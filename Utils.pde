
long lastMeassureTime;
int messageCount;
int audioOut, visualsOut;

void count() {
  long now = millis();
  if (now - lastMeassureTime > 1000) {
    println( messageCount,audioOut,visualsOut);
    messageCount = 0;
    audioOut = 0;
    visualsOut = 0;
    lastMeassureTime = now;
  }
  messageCount++;
}

void countOut(int type) {
  if (type == AUDIO)
    audioOut++;
  else 
  visualsOut++;
}