#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

# Create tables
$PSQL "
CREATE TABLE IF NOT EXISTS customers (
  customer_id SERIAL PRIMARY KEY,
  phone VARCHAR(50) UNIQUE NOT NULL,
  name VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS services (
  service_id SERIAL PRIMARY KEY,
  name VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS appointments (
  appointment_id SERIAL PRIMARY KEY,
  customer_id INT NOT NULL REFERENCES customers(customer_id),
  service_id INT NOT NULL REFERENCES services(service_id),
  time VARCHAR(50) NOT NULL
);
" > /dev/null

# Insert record's
SERVICES_COUNT=$($PSQL "SELECT COUNT(*) FROM services;")

if [[ $SERVICES_COUNT -eq 0 ]]
then
  $PSQL "
    INSERT INTO services(name) VALUES
    ('cut'),
    ('color'),
    ('perm'),
    ('style'),
    ('trim');
  " > /dev/null
fi

