#include <Arduino.h>

/*
  Arduiho.h runs main(){
    setup();
    while(1){
      loop();
    }
  }
*/

HardwareSerial SerialPort(PA10, PA9);  // RX, TX

//stick axes
const int LX = PA0;
const int LY = PA1;
const int RX = PA2;
const int RY = PA3;
const int baud = 115200;
//buttons
const int NUM_BTN = 15;
const int btnPins[NUM_BTN] = {
  PB1, PB0, PA7, PA6, PA5, PB3, PB4, PB5, PB12, PB13,
  PB9, PB8, PB7, PB6, PA15
};

void setup() {
  pinMode(LX, INPUT_ANALOG);
  pinMode(LY, INPUT_ANALOG);
  pinMode(RX, INPUT_ANALOG);
  pinMode(RY, INPUT_ANALOG);

  for (int i = 0; i < NUM_BTN; i++) {
    pinMode(btnPins[i], INPUT_PULLUP);
  }

  SerialPort.begin(baud);
}

void loop() {
  //  LX,LY,RX,RY,b0,b1,...,b14\n
  SerialPort.print(analogRead(LX)); 
  SerialPort.print(",");
  SerialPort.print(analogRead(LY)); 
  SerialPort.print(",");
  SerialPort.print(analogRead(RX)); 
  SerialPort.print(",");
  SerialPort.print(analogRead(RY));
  
  // read buttons state
  for (int i = 0; i < NUM_BTN; i++) {
    int v = (digitalRead(btnPins[i]) == LOW) ? 1 : 0;
    SerialPort.print(",");
    SerialPort.print(v);
  }
  SerialPort.println();

  delay(10);  // 100 Гц
}
