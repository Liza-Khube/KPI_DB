INSERT INTO contact_data (email, phone) -- owner.contact_data
VALUES
  ('vasyl.ch@gmail.com', '+380982356878');

INSERT INTO owner (name, surname, contact_data_id)
VALUES
  ('Vasyl', 'Cherevko', 10);
  
INSERT INTO pet (name, date_of_birth, species, breed, gender, owner_id)
VALUES 
 ('No_name', '2024-07-16', 'guinea pig', 'couy', 'female', 6),
 ('Draco', '2021-04-21', 'iguana', 'iguana', 'male', 3);

INSERT INTO pet (name, date_of_birth, species, gender, owner_id)
VALUES 
  ('Ratatouille', '2025-03-01', 'rat', 'male', 6);

INSERT INTO contact_data (email, phone) -- vet.contact_data
VALUES
  ('bohdan.zhura@gmail.com', '+380962501540');

INSERT INTO vet (name, surname, specialisation, is_active, contact_data_id, experience)
VALUES
  ('Bohdan', 'Zhuravskyi', 'Therapy', TRUE, 11, 18);

INSERT INTO schedule_template (day_of_week, start_time, end_time, slot_duration, vet_id)
VALUES
  ('thursday', '08:00', '16:00', 15, 7),
  ('friday', '08:00', '16:00', 15, 7);

INSERT INTO slot (date, start_time, end_time, is_booked, vet_id)
VALUES
  ('2025-10-23', '13:00', '13:15', TRUE, 7),
  ('2025-10-23', '13:15', '13:30', FALSE, 7),
  ('2025-10-24', '08:00', '08:15', TRUE, 7),
  ('2025-10-24', '08:15', '08:30', FALSE, 7),
  ('2025-10-30', '08:00', '08:15', FALSE, 7),
  ('2025-10-30', '08:15', '08:30', FALSE, 7),
  ('2025-10-30', '08:30', '08:45', FALSE, 7);

UPDATE pet 
SET name = 'Snizhok', date_of_birth = '2025-07-17'
WHERE pet_id = 10;

SELECT pet_id, p.name AS pet_name, date_of_birth, species, breed, gender, CONCAT(o.name, ' ', o.surname) AS owner_name, -- pet_owner_start
phone AS owner_phone, email AS owner_email FROM pet p
    INNER JOIN owner o ON p.owner_id = o.owner_id
    INNER JOIN contact_data cd ON cd.contact_data_id = o.contact_data_id
ORDER BY o.owner_id ASC, owner_name ASC;

SELECT vet_id, CONCAT(v.name, ' ', v.surname) AS vet_name, is_active, specialisation, experience, phone, email FROM vet v -- vet_start
    INNER JOIN contact_data cd ON cd.contact_data_id = v.contact_data_id

SELECT slot_id, date, start_time, end_time, is_booked, CONCAT(v.name, ' ', v.surname) AS vet_name FROM slot s -- slot_start
    INNER JOIN vet v ON v.vet_id = s.vet_id
ORDER BY date ASC, start_time ASC

INSERT INTO appointment (status, result, med_notes, pet_id, vet_id, slot_id)
VALUES
  ('completed', 'healthy', 'Everything is ok!', 10, 7, 13);

INSERT INTO appointment (reason, price, status, pet_id, vet_id, slot_id)
VALUES
  ('My rat is limping!', '300', 'scheduled', 12, 7, 15);

SELECT appointment_id, date, start_time, status, result, med_notes, pet_id, a.slot_id, a.vet_id FROM appointment a -- appointment_first_change
    INNER JOIN slot s ON a.slot_id = s.slot_id
WHERE appointment_id IN (6, 9)
ORDER BY date ASC, start_time ASC;

UPDATE appointment
SET status = 'completed', result = 'healthy', med_notes = 'Neutering went fine. No complications have been found'
WHERE appointment_id = 6;

UPDATE appointment
SET status = 'in progress'
WHERE appointment_id = 9;

SELECT appointment_id, date, start_time, status, result, med_notes, pet_id, a.slot_id, a.vet_id FROM appointment a -- appointment_second_change
    INNER JOIN slot s ON a.slot_id = s.slot_id
WHERE date IN ('2025-10-23', '2025-10-24')
ORDER BY date ASC, start_time ASC;

UPDATE appointment
SET status = 'completed', result = 'diagnosed', med_notes = 'Suspected soft tissue injury or pododermatitis'
WHERE appointment_id = 9

INSERT INTO diagnosis (illness, description, is_active, appointment_id)
VALUES
  ('Susp. soft tissue inj/pododerm.', 'A severe soft tissue injury is the presumptive diagnosis based on acute pain and non-weight bearing. However, since a non-displaced fracture cannot be excluded by physical exam alone, an immediate X-ray is mandatory to confirm or rule out bony involvement and guide proper treatment.', TRUE, 9);

UPDATE vet
SET is_active = FALSE
WHERE vet_id = 7;

DELETE FROM slot
WHERE vet_id = 7 AND date > '2025-10-24';

DELETE FROM pet
WHERE species = 'iguana';

-- Conclusive SELECTs

SELECT pet_id, p.name AS pet_name, date_of_birth, species, breed, gender, CONCAT(o.name, ' ', o.surname) AS owner_name, -- pet_owner
phone AS owner_phone, email AS owner_email FROM pet p
    INNER JOIN owner o ON p.owner_id = o.owner_id
    INNER JOIN contact_data cd ON cd.contact_data_id = o.contact_data_id
ORDER BY o.owner_id ASC, owner_name ASC;

SELECT vet_id, CONCAT(v.name, ' ', v.surname) AS vet_name, is_active, specialisation, experience, phone, email FROM vet v -- vet
    INNER JOIN contact_data cd ON cd.contact_data_id = v.contact_data_id

SELECT st.vet_id, day_of_week, start_time, end_time, slot_duration, CONCAT(v.name, ' ', v.surname) AS vet_name, is_active FROM schedule_template st -- schedule_template
    RIGHT JOIN vet v ON st.vet_id = v.vet_id

SELECT slot_id, date, start_time, end_time, is_booked, CONCAT(v.name, ' ', v.surname) AS vet_name FROM slot s -- slot
    INNER JOIN vet v ON v.vet_id = s.vet_id
ORDER BY date ASC, start_time ASC

SELECT a.appointment_id, date, start_time, end_time, p.name AS pet_name, species, breed, CONCAT(o.name, ' ', o.surname) AS owner_name, -- appointment_data
		CONCAT(v.name, ' ', v.surname) AS vet_name, specialisation, status, result, 
		med_notes, illness, description, d.is_active FROM appointment a 
				INNER JOIN slot s ON a.slot_id = s.slot_id
				LEFT JOIN diagnosis d ON a.appointment_id = d.appointment_id
        INNER JOIN pet p ON a.pet_id = p.pet_id
        INNER JOIN vet v ON a.vet_id = v.vet_id
        INNER JOIN owner o ON p.owner_id = o.owner_id
WHERE illness IS NOT NULL
ORDER BY date ASC, start_time ASC;