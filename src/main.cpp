// Copyright (c) 2026 Valter Simes
// Licensed under the PolyForm Noncommercial License 1.0.0
// See LICENSE file at the repo root for full terms.

#include <Arduino.h>
#include <DHT.h>
#include <Wire.h>
#include <BH1750.h>
#include <WiFi.h>
#include <PubSubClient.h>
#include <esp_sleep.h>
#include "date.h"

// TLS check
#if USE_TLS
    #include <WiFiClientSecure.h>
    #include "aws_root_ca.h"
    WiFiClientSecure wifiClient;
    const int MQTT_PORT = 8883;
#else
    WiFiClient wifiClient;
    const int MQTT_PORT = 1883;
#endif

// Broker
const char* DEVICE_ID = "yuyo_01";

// Sensors
#define DHT_PIN D2
#define DHT_TYPE DHT22
#define SOIL_STRAWBERRY A0
#define SOIL_CHILI A1

DHT tempHumSensor(DHT_PIN, DHT_TYPE);
BH1750 lightSensor;
PubSubClient mqtt(wifiClient);

// Publish schedule
const uint64_t SLEEP_DURATION = 5 * 60 * 1000000;

void sleepAndRetry(const char* reason) {
    Serial.printf("%s. Sleeping 5 min...\n", reason);
    esp_sleep_enable_timer_wakeup(SLEEP_DURATION);
    esp_deep_sleep_start();
}

void connectWiFi() {
  Serial.println("Connecting to Wifi...");
  WiFi.begin(WIFI_SSID, WIFI_PASS);
  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 20) {
      delay(500);
      Serial.print(".");
      attempts++;
  }
  if (WiFi.status() != WL_CONNECTED) {
      sleepAndRetry("WiFi failed");
  }
  Serial.printf("Wifi Connected!\n");
}

void connectBroker() {
  int attempts = 0;
  while (!mqtt.connected() && attempts < 5) {
    Serial.println("Connecting to Broker...");
    if (mqtt.connect(DEVICE_ID, MQTT_USER, MQTT_PASS)) {
      Serial.println("Broker Connected!");
      return;
    }
      Serial.printf("Failed, rc=%d, retrying\n", mqtt.state());
      delay(5000);
      attempts++;
    }
  if (!mqtt.connected()) {
    sleepAndRetry("Broker failed");
  }
}

void setup() {
  Serial.begin(115200);
  delay(2000);
  Serial.println("Starting...");

  tempHumSensor.begin();
  Wire.begin();
  lightSensor.begin(BH1750::CONTINUOUS_HIGH_RES_MODE);
  Serial.println("Sensors ready");

  connectWiFi();
  syncTime();
  #if USE_TLS
      wifiClient.setCACert(AWS_ROOT_CA);
  #endif
  mqtt.setServer(MQTT_HOST, MQTT_PORT);
  connectBroker();
}

void loop() {
    // Read sensors
    float temp = tempHumSensor.readTemperature();
    float hum = tempHumSensor.readHumidity();
    float lux = lightSensor.readLightLevel();
    int soilStrawberry = analogRead(SOIL_STRAWBERRY);
    int soilChili = analogRead(SOIL_CHILI);

    // Check readings
    if (temp < -15 || temp > 50 || hum < 0 || hum > 100) {
        Serial.println("Invalid reading, skipping");
        sleepAndRetry("Bad sensor data");
    }

    char payload[300];
    char topic[64];

    snprintf(payload, sizeof(payload),
        "{\"device\":\"%s\",\"timestamp\":\"%s\",\"temp\":%.1f,"
        "\"humidity\":%.1f,\"lux\":%.1f,\"soil_strawberry\":%d,\"soil_chili\":%d}",
        DEVICE_ID, getTimestamp(), temp, hum, lux, soilStrawberry, soilChili);

    snprintf(topic, sizeof(topic), "farm/%s/sensors", DEVICE_ID);
    mqtt.publish(topic, payload);
    Serial.printf("Published to %s\n", topic);

    Serial.println("Sleeping 5 min...");
    esp_sleep_enable_timer_wakeup(SLEEP_DURATION);
    esp_deep_sleep_start();
}