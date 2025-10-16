INSERT INTO contact_data (email, phone) -- owner_contact_data
VALUES
  ('alex.pidbereznyi@gmail.com', '+380971234627'),
  ('oleg.v@gmail.com', '+380671112233'),
  ('maryna.s@gmail.com', '+380998887766'),
  ('kostya.shevchuk@gmail.com', '+380635554433'),
  ('pavlo.honchar999@gmail.com', '+380962436758');

INSERT INTO owner (name, surname, contact_data_id)
VALUES
  ('Alex', 'Pidbereznyi', 1),
  ('Oleg', 'Vivcharenko', 2),
  ('Maryna', 'Shevchenko', 3),
  ('Kostyantyn', 'Shevchuk', 4),
  ('Pavlo', 'Honchar', 5);
  
INSERT INTO pet (name, date_of_birth, species, breed, gender, owner_id)
VALUES 
  ('Lukash', '2019-09-10', 'cat', 'scottish straight', 'male', 1),
  ('Vatson', '2024-03-01', 'dog', 'dachshund', 'male', 1),
  ('Reks', '2018-05-20', 'dog', 'shepherd', 'male', 2),
  ('Matylda', '2024-06-25', 'snake', 'rainbow boa', 'female', 3),
  ('Bonia', '2020-11-15', 'cat', 'sphynx', 'female', 4),
  ('Snizhynka', '2023-01-10', 'cat', 'maine coon', 'female', 4);

INSERT INTO pet (name, date_of_birth, species, gender, owner_id)
VALUES ('Barbos', '2017-12-03', 'dog', 'male', 5);

INSERT INTO contact_data (email, phone) -- vet_contact_data
VALUES
  ('andrii.komirenko@gmail.com', '+380983653210'),
  ('olena.denysiuk@gmail.com', '+380671234578'),
  ('kseniia.b@gmail.com', '+380972436780'),
  ('victor.dem@gmail.com', '+380673475411');

INSERT INTO vet (name, surname, specialisation, is_active, contact_data_id, experience)
VALUES
  ('Andrii', 'Komirenko', 'Dermatology', TRUE, 6, 15),
  ('Kseniia', 'Bondarenko', 'Therapy', TRUE, 8, 3);

INSERT INTO vet (name, surname, specialisation, is_active, contact_data_id)
VALUES
  ('Olena', 'Denysiuk', 'Surgery', TRUE, 7),
  ('Victor', 'Demydenko', 'Surgery', FALSE, 9);

INSERT INTO schedule_template (day_of_week, start_time, end_time, slot_duration, vet_id)
VALUES
  ('monday', '09:00', '17:00', 30, 3),    
  ('tuesday', '10:00', '18:00', 30, 3),   
  ('thursday', '09:00', '16:00', 30, 3),
  ('friday', '08:30', '16:30', 30, 3),
  ('monday', '09:00', '16:00', 15, 4),    
  ('tuesday', '09:00', '16:00', 15, 4),   
  ('wednesday', '09:00', '16:00', 15, 4),   
  ('thursday', '09:00', '16:00', 15, 4),
  ('friday', '09:00', '16:00', 15, 4),
  ('monday', '12:00', '18:00', 60, 5),    
  ('thursday', '12:00', '18:00', 60, 5),
  ('tuesday', '10:00', '14:00', 60, 6),    
  ('wednesday', '10:00', '14:00', 60, 6);

INSERT INTO slot (date, start_time, end_time, is_booked, vet_id)
VALUES
  ('2025-10-21', '10:00', '10:30', FALSE, 3),
  ('2025-10-21', '10:30', '11:00', FALSE, 3),
  ('2025-10-21', '17:30', '18:00', TRUE, 3),
  ('2025-10-24', '08:30', '09:00', TRUE, 3),
  ('2025-10-20', '09:00', '09:15', TRUE, 4),
  ('2025-10-20', '09:15', '09:30', FALSE, 4),
  ('2025-10-20', '09:30', '09:45', FALSE, 4),
  ('2025-10-21', '09:45', '10:00', TRUE, 4),
  ('2025-10-20', '12:00', '13:00', TRUE, 5),
  ('2025-10-20', '13:00', '14:00', FALSE, 5),
  ('2025-10-23', '13:00', '14:00', FALSE, 5),
  ('2025-10-23', '17:00', '18:00', TRUE, 5);

INSERT INTO appointment (reason, price, status, result, med_notes, pet_id, vet_id, slot_id)
VALUES
  ('My dog had red points on his legs.', '200', 'completed', 'diagnosed', 'Your dog has vasculitis; look at the diagnosis.', 4, 3, 3),
  ('Sterilization.', '1000', 'completed', 'healthy', 'Everything went fine!', 8, 5, 9);

INSERT INTO appointment (price, status, result, med_notes, pet_id, vet_id, slot_id)
VALUES
  ('100', 'completed', 'healthy', 'Everything is ok!', 9, 4, 5),
  ('150', 'completed', 'recovered', 'The cat is no longer suffering from ascariasis.', 7, 4, 8);

INSERT INTO appointment (reason, price, status, pet_id, vet_id, slot_id)
VALUES
  ('Cat scratched his skin near the neck.', '200', 'scheduled', 3, 3, 4),
  ('Neutering.', '1500', 'in progress', 5, 5, 12);

INSERT INTO diagnosis (illness, description, is_active, appointment_id)
VALUES
  ('Vasculitis (Idiopathic)', 'Presence of petechiae (pinpoint red spots). Strictly administer the prescribed corticosteroids and immunosuppressants to control the vasculitis inflammation. Ensure diligent topical care for skin lesions, especially on ear and tail tips, and complete all diagnostics to identify the underlying cause.', TRUE, 1),
  ('Feline Ascariasis (Roundworms)', 'The cat has successfully completed the full deworming protocol and is now clear of parasites.', FALSE, 4);