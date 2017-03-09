#include <Servo.h>
#include <stdlib.h>
#include <string.h>
#include "helpers.h"

Servo servo;
const uint8_t servoPin = 9;
const uint8_t servoMin = 0;
const uint8_t servoMax = 20;
uint8_t servoValue = 0;

const uint8_t potPin = 0;
const uint8_t potMin = 0;
const uint16_t potMax = 990;
uint16_t potValue = 0;

float splitPct = 0.5;
float curve = 4.0;

void setup() {
  Serial.begin(9600);
  servo.attach(servoPin);
  servo.write(0);
  Serial.print("start: ");
  Serial.println(millis());
}

uint16_t servoFunc(uint16_t input) {
  const uint16_t splitPoint = potMax * splitPct;
  if (input < splitPoint) {
    return lincurve(input, 0, splitPoint, servoMin, servoMax, curve);
  }
  return lincurve(input, splitPoint, potMax, servoMax, servoMin, -curve);
}

void loop() {
  // update splitPct and curve vars
  if (Serial.available() > 0) {
    const uint8_t bufSize = 100;
    char buffer[bufSize];

    Serial.readBytesUntil("\n", buffer, bufSize);

    const char *splitToken = strtok(buffer, ",");
    splitPct = constrain(strtod(splitToken, NULL), 0.0, 1.0);

    const char *curveToken = strtok(NULL, "");
    curve = strtod(curveToken, NULL);
  }

  // IO
  potValue = min(analogRead(potPin), potMax);
  servoValue = servoFunc(potValue);
  servo.write(servoValue);

  // Logging
  Serial.print(millis());
  Serial.print(", ");
  Serial.print(linlin(potValue, potMin, potMax, 0.0, 1.0));
  Serial.print(", ");
  Serial.println(linlin(servoValue, servoMin, servoMax, 0.0, 1.0));
}
