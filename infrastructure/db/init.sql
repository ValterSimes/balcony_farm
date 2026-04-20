CREATE TABLE sensor_readings (
    time             TIMESTAMPTZ NOT NULL,
    device           TEXT NOT NULL,
    temp             DOUBLE PRECISION,
    humidity         DOUBLE PRECISION,
    lux              DOUBLE PRECISION,
    soil_strawberry  INTEGER,
    soil_chili       INTEGER
);

SELECT create_hypertable('sensor_readings', 'time');