# Lab5: Functional dependencies and normalization

---

## Частина 1: Функціональні залежності початкових таблиць

---

### 1) contact_data

PK: `contact_data_id`, AK: `email, phone`

FD:

- `contact_data_id -> email, phone`
- `email -> contact_data_id, phone`
- `phone -> contact_data_id, email`

### 2) owner

PK: `owner_id`, AK: `contact_data_id`

FD:

- `owner_id -> name, surname, contact_data_id`
- `contact_data_id -> owner_id, name, surname`

### 3) pet

PK: `pet_id`

FD:

- `pet_id -> name, date_of_birth, species, breed, gender, owner_id`
- `species -> breed`

### 4) vet

PK: `vet_id`, AK: `contact_data_id`

FD:

- `vet_id -> name, surname, experience, specialisation, is_active, contact_data_id`
- `contact_data_id -> vet_id, name, surname, experience, specialisation, is_active`

### 5) schedule_template

PK: `template_id`, СAK: `(vet_id, day_of_week)`

FD:

- `template_id -> day_of_week, start_time, end_time, slot_duration, vet_id`
- `(vet_id, day_of_week) -> template_id, start_time, end_time, slot_duration `

### 6) slot

PK: `slot_id`

FD:

- `slot_id -> date, start_time, end_time, is_booked, vet_id`

### 7) appointment

PK: `appointment_id`, AK: `slot_id`

FD:

- `appointment_id -> reason, price, status, result, med_notes, pet_id, vet_id, slot_id`
- `slot_id -> appointment_id, reason, price, status, result, med_notes, pet_id, vet_id`

### 8) diagnosis

PK: `diagnosis_id`, AK: `slot_id`

FD:

- `diagnosis_id -> illness, description, is_active, appointment_id`

---

## Частина 2: Нормальні форми

---

### 1) Перша нормальна форма (1NF)

Таблиця перебуває у 1NF, якщо:

- Всі атрибути таблиці є неподільними (містять лише одне значення).

* Кожен рядок є унікальним (має PK).
* Порядок рядків у таблиці не важливий.
* Кожна колонка містить значення лише одного типу.

Перевірка: усі таблиці належать до першої нормальної форми (1NF)

### 2) Друга нормальна форма (2NF)

Таблиця перебуває у 2NF, якщо:

- Задовільняються всі вимоги 1NF (перебуває в першій нормальній формі)
- Усі неключові атрибути повністю функціонально залежні від первинного ключа.

Перевірка: усі таблиці належать до другої нормальної форми (2NF)

### 3) Третя нормальна форма (3NF)

Таблиця перебуває у 3NF, якщо:

- Задовільняються всі вимоги 2NF (перебуває в другій нормальній формі)
- Відсутні тринзитивні залежності - жоден з неключових атрибутів не залежить від іншого неключового атрибуту..

Перевірка: усі таблиці належать до третьої нормальної форми (3NF), ОКРІМ таблиці pet.

---

## Частина 3: Виправлення нормальних форм

---

### 1) pet

Таблиця перебуває в другій нормальній формі.

Для того, щоб вона стала перебувати в третій нормальній формі (3NF), потрібно позбутися транзитивних залежностей (тут це залежність `pet_id -> species -> breed`). Для цього винесемо два атрибути та створимо дві таблиці `species` та `breed`:

#### а) species (new)

```
CREATE TABLE IF NOT EXISTS species
(
  species_id SERIAL PRIMARY KEY,
  name VARCHAR(32) NOT NULL
);
```

PK: `species_id`

FD: `species_id -> name`

#### б) breed (new)

```
CREATE TABLE IF NOT EXISTS breed
(
  breed_id SERIAL PRIMARY KEY,
  name VARCHAR(32),
  species_id INTEGER NOT NULL REFERENCES species(species_id),
  UNIQUE(species_id, name)
);
```

PK: `breed_id`

FD:

- `breed_id -> name, species_id`
- `(species_id, name) -> breed_id`

### в) pet (updated)

```
CREATE TABLE IF NOT EXISTS pet
(
  pet_id SERIAL PRIMARY KEY,
  name VARCHAR(32) NOT NULL,
  date_of_birth DATE NOT NULL,
  gender gender_type NOT NULL,
  breed_id INTEGER NOT NULL REFERENCES breed(breed_id),
  owner_id INTEGER NOT NULL REFERENCES owner(owner_id)
);
```

PK: `pet_id`

FD: `pet_id -> name, date_of_birth, gender, breed_id, owner_id`

---

## Частина 4: Виправлення надлишковості, аномалій та неточностей

---

### 1) slot

#### а) Надлишковість часу слота

При додаванні рядків не потрібно вказувати кінець прийому - для клієнта головне знати, коли слот починається, а тривалість береться з таблиці `schedule_template`. Тому видалимо зайвий атрибут `end_time`:

```
CREATE TABLE IF NOT EXISTS slot
(
  slot_id SERIAL PRIMARY KEY,
  date DATE NOT NULL,
  start_time TIME NOT NULL,
  is_booked BOOLEAN NOT NULL DEFAULT FALSE,
  vet_id INTEGER NOT NULL REFERENCES vet(vet_id),
  CHECK(end_time > start_time)
);
```

#### б) Унікальність слота

При додаванні рядків не може бути однакових слотів - слотів на однакову дату та час до одного ветеринара.

Додамо для цього `UNIQUE`

```
CREATE TABLE IF NOT EXISTS slot
(
  slot_id SERIAL PRIMARY KEY,
  date DATE NOT NULL,
  start_time TIME NOT NULL,
  is_booked BOOLEAN NOT NULL DEFAULT FALSE,
  vet_id INTEGER NOT NULL REFERENCES vet(vet_id),
  UNIQUE(vet_id, date, start_time),
  CHECK(end_time > start_time)
);
```

#### в) Зайнятість слота

При записанні на прийом атрибут `is_booked` у `slot` є надлишковим: видалення цього атрибуту запобіжить аномаліям оновлення та видалення. Якщо система не встигне обробити зайнятість слоту після реєстрації на прийом, то це можна спричинити помилки в слотах. Щоб перевіряти зайнятість слоту, просто робитимемо `slot s LEFT JOIN appointment a` або `FULL JOIN` з фільтрацією `WHERE a.appointment_id IS NULL` для визначення незайнятих слотів (відповідно для зайнятих потрібно просто зробити `INNER JOIN`).

```
CREATE TABLE IF NOT EXISTS slot
(
  slot_id SERIAL PRIMARY KEY,
  date DATE NOT NULL,
  start_time TIME NOT NULL,
  vet_id INTEGER NOT NULL REFERENCES vet(vet_id),
  UNIQUE(vet_id, date, start_time),
  CHECK(end_time > start_time)
);
```

---

### 2) diagnosis

#### а) Накладання діагнозів

При створенні `diagnosis` до `appointment` (2+) потрібно врахувати, що може бути декілька діагнозів до одного прийому, проте вони мають бути різними (хвороба не може повторюватися).

Для цього додамо `UNIQUE`

```
CREATE TABLE IF NOT EXISTS diagnosis
(
  diagnosis_id SERIAL PRIMARY KEY,
  illness VARCHAR(48) NOT NULL,
  description TEXT NOT NULL,
  is_active BOOLEAN NOT NULL,
  appointment_id INTEGER NOT NULL REFERENCES appointment(appointment_id),
  UNIQUE(appointment_id, illness)
);
```

---

### 3) appointment

#### а) Надлишковість `vet_id` у `appointment`

Зайвий атрибут `vet_id` у таблиці `appointment` (до нього можна доступитися через `INNER JOIN slot`)

```
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
```

---

## Частина 5: SQL scripts

```
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
```

---

## Частина 6: Alter table scripts

```
-- pet`s species and breed
ALTER TABLE pet
    ADD COLUMN breed_id INTEGER REFERENCES breed(breed_id);
    DROP COLUMN IF EXISTS species,
    DROP COLUMN IS EXISTS breed;

-- new inserts

ALTER TABLE pet
    ALTER COLUMN breed_id SET NOT NULL;

-- slot
ALTER TABLE slot
    DROP COLUMN IF EXISTS is_booked,
    DROP COLUMN IF EXISTS end_time,
    ADD UNIQUE (vet_id, date, start_time);

-- diagnosis
ALTER TABLE diagnosis
    ADD UNIQUE(appointment_id, illness);

-- appointment
ALTER TABLE appointment
    DROP CONSTRAINT appointment_vet_id_fkey,
    DROP COLUMN vet_id;
```

---

## Частина 7: DML scripts

```
INSERT INTO species (name)
VALUES 
  ('cat'),
  ('dog'),
  ('snake'),
  ('guinea pig'),
  ('rat');

INSERT INTO breed (name, species_id)
VALUES 
  ('scottish straight', 1),
  ('dachshund', 2),
  ('shepherd', 2),
  ('rainbow boa', 3),
  ('sphynx', 1),
  ('maine coon', 1),
  ('couy', 4);

INSERT INTO breed (species_id)
VALUES (2), (5);

UPDATE pet
SET breed_id = 1
WHERE pet_id = 3;

UPDATE pet
SET breed_id = 2
WHERE pet_id = 4;

UPDATE pet
SET breed_id = 3
WHERE pet_id = 5;

UPDATE pet
SET breed_id = 4
WHERE pet_id = 6;

UPDATE pet
SET breed_id = 5
WHERE pet_id = 7;

UPDATE pet
SET breed_id = 6
WHERE pet_id = 8;

UPDATE pet
SET breed_id = 8
WHERE pet_id = 9;

UPDATE pet
SET breed_id = 7
WHERE pet_id = 10;

UPDATE pet
SET breed_id = 9
WHERE pet_id = 12;
```

---
