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
