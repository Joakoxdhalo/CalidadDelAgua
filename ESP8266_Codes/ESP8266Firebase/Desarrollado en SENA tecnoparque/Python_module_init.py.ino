//
// Copyright 2015 Google Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

// FirebaseDemo_ESP8266 is a sample that demo the different functions
// of the FirebaseArduino API.

#include <ESP8266WiFi.h>
#include <FirebaseArduino.h>

// Set these to run example.
#define FIREBASE_HOST "tu-agua.firebaseio.com"
#define FIREBASE_AUTH "UyyCE5PpVt2puS5DnMQuQH4xUzDhqgZWq5YEP2wo"
#define WIFI_SSID "Redmi"
#define WIFI_PASSWORD "1016093109"

// Constants:-
const byte Sensor = A0;// Connect the sensor's Po output to analogue pin 0.
// Variables:-
float PhValue;
float NivelValue;

void setup() {
  Serial.begin(9600);

  // connect to wifi.
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("connecting");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(500);
  }
  Serial.println();
  Serial.print("connected: ");
  Serial.println(WiFi.localIP());
  
  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
}

int n = 0;

void loop() {
  digitalWrite(D2,LOW);
  digitalWrite(D1,LOW);
  digitalWrite(D0,LOW);
  PhValue = (1023 - analogRead(Sensor)) / 73.07;
  Serial.print(PhValue);
  // set value
  Firebase.setFloat("PhValue: ", PhValue + 0.37);
  // handle error
  if (Firebase.failed()) {
      Serial.print("setting /number failed:");
      Serial.println(Firebase.error());  
      return;
  }
  delay(1000);
    // get value 
  Serial.print("PhValue: ");
  Serial.println(Firebase.getFloat("PhValue"));
  delay(1000);
  // remove value
  Firebase.remove("PhValue");
  delay(1000);
  digitalWrite(D2,HIGH);
  NivelValue = analogRead(Sensor);
  Serial.print(NivelValue);
  // set value
  Firebase.setFloat("NivelValue: ", NivelValue);
  // handle error
  if (Firebase.failed()) {
      Serial.print("setting /number failed:");
      Serial.println(Firebase.error());  
      return;
  }
    // get value 
  Serial.print("NivelValue: ");
  Serial.println(Firebase.getFloat("NivelValue"));
  delay(1000);
  // remove value
  Firebase.remove("NivelValue");
  delay(1000);
}
