#include <Arduino.h>

HardwareSerial mySerial(PA10, PA9);  // RX, TX

// --- Стики ---
const int LX = PA0;
const int LY = PA1;
const int RX = PA2;
const int RY = PA3;

// --- Кнопки (порядок фиксированный, индексы 0..11) ---
const int NUM_BTN = 17;
const int btnPins[NUM_BTN] = {
  PB2, PB1, PB0, PA7, PA6, PA5, PA4, PB3, PB4, PB5, PB12, PB13,
  PB9, PB8, PB7, PB6, PA15
};

// центры стиков
int cLX = 2048, cLY = 2048, cRX = 2048, cRY = 2048;

void setup() {
  pinMode(LX, INPUT_ANALOG);
  pinMode(LY, INPUT_ANALOG);
  pinMode(RX, INPUT_ANALOG);
  pinMode(RY, INPUT_ANALOG);

  for (int i = 0; i < NUM_BTN; i++) {
    pinMode(btnPins[i], INPUT_PULLUP);
  }

  mySerial.begin(115200);

  // автокалибровка центра — не трогай стики ~1 сек после старта
  long sLX = 0, sLY = 0, sRX = 0, sRY = 0;
  const int N = 200;
  for (int i = 0; i < N; i++) {
    sLX += analogRead(LX);
    sLY += analogRead(LY);
    sRX += analogRead(RX);
    sRY += analogRead(RY);
    delay(3);
  }
  cLX = sLX / N;  cLY = sLY / N;
  cRX = sRX / N;  cRY = sRY / N;
}

void loop() {
  int lx = analogRead(LX) - cLX;
  int ly = analogRead(LY) - cLY;
  int rx = analogRead(RX) - cRX;
  int ry = analogRead(RY) - cRY;

  // Формат: LX,LY,RX,RY,b0,b1,...,b11\n
  mySerial.print(lx); mySerial.print(",");
  mySerial.print(ly); mySerial.print(",");
  mySerial.print(rx); mySerial.print(",");
  mySerial.print(ry);

  for (int i = 0; i < NUM_BTN; i++) {
    int v = (digitalRead(btnPins[i]) == LOW) ? 1 : 0;  // PULLUP: нажато = LOW
    mySerial.print(",");
    mySerial.print(v);
  }
  mySerial.println();

  delay(10);  // ~100 Гц
}
