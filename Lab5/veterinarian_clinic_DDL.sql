CREATE TYPE gender_type AS ENUM ('male', 'female');

CREATE TYPE appointment_status AS ENUM ('scheduled', 'in progress', 'completed');

CREATE TYPE appointment_result AS ENUM ('healthy', 'diagnosed', 'recovered');

CREATE TYPE days_of_week AS ENUM ('monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday');

CREATE TABLE IF NOT EXISTS contact_data
(
  contact_data_id SERIAL PRIMARY KEY,
  email VARCHAR(32) UNIQUE NOT NULL,
  phone VARCHAR(32) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS owner
(
  owner_id SERIAL PRIMARY KEY,
  name VARCHAR(32) NOT NULL,
  surname VARCHAR(32) NOT NULL,
  contact_data_id INTEGER UNIQUE NOT NULL REFERENCES contact_data(contact_data_id) 
);

CREATE TABLE IF NOT EXISTS species
(
  species_id SERIAL PRIMARY KEY,
  name VARCHAR(32) NOT NULL
);

CREATE TABLE IF NOT EXISTS breed
(
  breed_id SERIAL PRIMARY KEY,
  name VARCHAR(32) NOT NULL DEFAULT 'unpedigreed',
  species_id INTEGER NOT NULL REFERENCES species(species_id),
  UNIQUE(species_id, name)
);

CREATE TABLE IF NOT EXISTS pet
(
  pet_id SERIAL PRIMARY KEY,
  name VARCHAR(32) NOT NULL,
  date_of_birth DATE NOT NULL,
  gender gender_type NOT NULL,
  breed_id INTEGER NOT NULL REFERENCES breed(breed_id),
  owner_id INTEGER NOT NULL REFERENCES owner(owner_id)
);

CREATE TABLE IF NOT EXISTS vet
(
  vet_id SERIAL PRIMARY KEY,
  name VARCHAR(32) NOT NULL,
  surname VARCHAR(32) NOT NULL,
  experience SMALLINT CHECK(experience >= 0),
  specialisation VARCHAR(32) NOT NULL,
  is_active BOOLEAN NOT NULL,
  contact_data_id INTEGER UNIQUE NOT NULL REFERENCES contact_data(contact_data_id) 
);

CREATE TABLE IF NOT EXISTS schedule_template
(
  template_id SERIAL PRIMARY KEY,
  day_of_week days_of_week NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  slot_duration SMALLINT NOT NULL CHECK(slot_duration >= 15), -- minutes
  vet_id INTEGER NOT NULL REFERENCES vet(vet_id),
  UNIQUE(vet_id, day_of_week),
  CHECK(end_time > start_time)
);

CREATE TABLE IF NOT EXISTS slot
(
  slot_id SERIAL PRIMARY KEY,
  date DATE NOT NULL,
  start_time TIME NOT NULL,
  vet_id INTEGER NOT NULL REFERENCES vet(vet_id),
  UNIQUE(vet_id, date, start_time),
  CHECK(end_time > start_time)
);

CREATE TABLE IF NOT EXISTS appointment
(
  appointment_id SERIAL PRIMARY KEY,
  reason TEXT,
  price NUMERIC(10, 2) NOT NULL DEFAULT 200,
  status appointment_status NOT NULL,
  result appointment_result,
  med_notes TEXT,
  pet_id INTEGER NOT NULL REFERENCES pet(pet_id),
  slot_id INTEGER UNIQUE NOT NULL REFERENCES slot(slot_id),
  
  CONSTRAINT is_appointment_completed CHECK
  (
    (status = 'completed' AND result IS NOT NULL AND med_notes IS NOT NULL)
    OR
    (status <> 'completed' AND result IS NULL AND med_notes IS NULL)
  )
);

CREATE TABLE IF NOT EXISTS diagnosis
(
  diagnosis_id SERIAL PRIMARY KEY,
  illness VARCHAR(48) NOT NULL,
  description TEXT NOT NULL,
  is_active BOOLEAN NOT NULL,
  appointment_id INTEGER NOT NULL REFERENCES appointment(appointment_id),
  UNIQUE(appointment_id, illness)
);