#include <Arduino.h>
#include <time.h>
#include "date.h"

static char timestamp[25];

void syncTime() {
    configTime(0, 0, "pool.ntp.org"); // I'm using UTC, will adjust time on Grafana
    while (time(nullptr) < 100000) {
        delay(500);
    }
    Serial.println("Date sync done.\n");
}

char* getTimestamp() {
    time_t now = time(nullptr);
    strftime(timestamp, sizeof(timestamp), "%Y-%m-%dT%H:%M:%SZ", gmtime(&now));
    return timestamp;
}