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