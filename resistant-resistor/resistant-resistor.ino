#include <Servo.h>
#include <stdlib.h>
#include <string.h>
#include "helpers.h"

Servo servo;
const uint8_t servoPin = 9;
const uint8_t servoMin = 6;
const uint8_t servoMax = 25;
uint8_t servoValue = 0;

const uint8_t potPin = 0;
const uint8_t potMin = 40;
const uint16_t potMax = 1023;
uint16_t potValue = 0;

uint16_t splitPct = 50;
int16_t curve = 4;

void setup() {
  Serial.begin(9600);
  servo.attach(servoPin);
  servo.write(0);
  Serial.print("start: ");
  Serial.println(millis());
}

uint16_t servoFunc(uint16_t input, uint16_t splitPct) {
  const double split = (double(splitPct) / 100.0);
  const double norm = linlin(input, potMin, potMax, 0.0, 1.0, true);

  if (splitPct == 100) {
    return lincurve(norm, 0, 1.0, servoMin, servoMax, curve);
  }
  if (splitPct == 0) {
    return lincurve(norm, 0, 1.0, servoMax, servoMin, -curve);
  }

  if (norm < split) {
    return lincurve(norm, 0, split, servoMin, servoMax, curve);
  }

  return lincurve(norm, split, 1.0, servoMax, servoMin, -curve);
}

void loop() {
  // update splitPct and curve vars
  if (Serial.available() > 0) {
    const uint8_t bufSize = 100;
    char buffer[bufSize];

    Serial.readBytesUntil("\n", buffer, bufSize);

    const char *splitToken = strtok(buffer, ",");
    splitPct = constrain(strtol(splitToken, NULL, 10), 0, 100);

    const char *curveToken = strtok(NULL, "");
    curve = strtol(curveToken, NULL, 10);
  }

  // IO
  potValue = linlin(analogRead(potPin), potMin, potMax, 0, 1023, true);
  servoValue = servoFunc(potValue, splitPct);
  servo.write(servoValue);

  // Logging
  Serial.print(millis());
  Serial.print(", ");
  Serial.print(linlin(potValue, potMin, potMax, 0, 100));
  Serial.print(", ");
  Serial.println(linlin(servoValue, servoMin, servoMax, 0, 100));
}
