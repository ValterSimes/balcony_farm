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
#include <U8g2lib.h>
#include "driver/rtc_io.h"

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
#define BUTTON_PIN_GPIO (gpio_num_t)digitalPinToGPIONumber(D3)

DHT tempHumSensor(DHT_PIN, DHT_TYPE);
BH1750 lightSensor;
PubSubClient mqtt(wifiClient);

//Display
U8G2_SSD1306_128X64_NONAME_F_HW_I2C display(U8G2_R3, U8X8_PIN_NONE);

// Publish schedule
const uint64_t SLEEP_DURATION = 5 * 60 * 1000000;

void sleepAndRetry(const char* reason) {
    Serial.printf("%s. Sleeping 5 min...\n", reason);
    esp_sleep_enable_timer_wakeup(SLEEP_DURATION);

    rtc_gpio_pulldown_en(BUTTON_PIN_GPIO);
    rtc_gpio_pullup_dis(BUTTON_PIN_GPIO);
    esp_sleep_enable_ext0_wakeup(BUTTON_PIN_GPIO, 1);

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

void readSensors(float &temp, float &hum, float &lux, int &soilStrawberry, int &soilChili, float &voltage, int &bat) {
  temp = tempHumSensor.readTemperature();
  hum = tempHumSensor.readHumidity();
  lux = lightSensor.readLightLevel();
  soilStrawberry = analogRead(SOIL_STRAWBERRY);
  soilChili = analogRead(SOIL_CHILI);
  voltage = analogRead(A2) * 2.0 * 3.3 / 4095.0;
  bat = constrain(map(voltage * 100, 300, 420, 0, 100), 0, 100);
}

void showDisplay(float temp, float hum, float lux, int soilStrawberry, int soilChili, float voltage, int bat) {
  display.setPowerSave(0);
  display.clearBuffer();
  display.setFont(u8g2_font_7x14B_tr);
  display.drawStr(0, 14, "YUYO_01");
  display.drawLine(0, 18, 64, 18);
  display.setFont(u8g2_font_6x10_tr);
  char line[32];
  snprintf(line, sizeof(line), "T: %.1fC", temp);
  display.drawStr(0, 32, line);
  snprintf(line, sizeof(line), "H: %.0f%%", hum);
  display.drawStr(0, 44, line);
  snprintf(line, sizeof(line), "L: %.0f", lux);
  display.drawStr(0, 56, line);
  snprintf(line, sizeof(line), "S1: %d", soilStrawberry);
  display.drawStr(0, 68, line);
  snprintf(line, sizeof(line), "S2: %d", soilChili);
  display.drawStr(0, 80, line);
  snprintf(line, sizeof(line), "B: %d%%", bat);
  display.drawStr(0, 92, line);
  display.sendBuffer();
}

void setup() {
  Serial.begin(115200);
  delay(2000);
  Serial.println("Starting...");

  tempHumSensor.begin();
  Wire.begin();
  lightSensor.begin(BH1750::CONTINUOUS_HIGH_RES_MODE);
  Serial.println("Sensors ready");

  esp_sleep_wakeup_cause_t wakeReason = esp_sleep_get_wakeup_cause();
  if (wakeReason == ESP_SLEEP_WAKEUP_EXT0) {
    Serial.println("Button press");
    display.begin();
    float temp, hum, lux, voltage;
    int soilStrawberry, soilChili, bat;
    readSensors(temp, hum, lux, soilStrawberry, soilChili, voltage, bat);
    showDisplay(temp, hum, lux, soilStrawberry, soilChili, voltage, bat);
    delay(15000);
    display.setPowerSave(1);
    sleepAndRetry("Display done");
  }

  Serial.println("Wake: timer / boot");
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
    float temp, hum, lux, voltage;
    int soilStrawberry, soilChili, bat;
    readSensors(temp, hum, lux, soilStrawberry, soilChili, voltage, bat);

    // Post metrics
    char payload[310];
    char topic[64];

    snprintf(payload, sizeof(payload),
        "{\"device\":\"%s\",\"timestamp\":\"%s\",\"temp\":%.1f,"
        "\"humidity\":%.1f,\"lux\":%.1f,\"soil_strawberry\":%d,\"soil_chili\":%d,\"bat\":%d}",
        DEVICE_ID, getTimestamp(), temp, hum, lux, soilStrawberry, soilChili, bat);

    snprintf(topic, sizeof(topic), "farm/%s/sensors", DEVICE_ID);
    mqtt.publish(topic, payload);
    Serial.printf(payload);
    Serial.printf("Published to %s\n", topic);

    sleepAndRetry("Cycle complete");
}