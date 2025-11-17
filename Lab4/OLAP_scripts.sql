-- Частина 1: запити, що містять агрегаційні функції (SUM, AVG, COUNT, MIN, MAX, GROUP BY)

-- 1) Кількість усіх доступних слотів
SELECT COUNT(*) AS free_slots FROM slot
WHERE is_booked = FALSE;

-- 2) Середня ціна за прийоми
SELECT ROUND(AVG(price), 2) AS avg_price FROM appointment;

-- 3) Кількість домашніх улюбленців у кожного власника 
SELECT (o.name || ' ' || o.surname) AS owner_name, COUNT(p.pet_id) AS pets FROM owner o
				LEFT JOIN pet p ON o.owner_id = p.owner_id 
GROUP BY o.owner_id
ORDER BY pets DESC;

-- 4) Порахуйте загальний дохід клініки за днями (сума price для призначених дат слотів).
SELECT s.date, SUM(a.price) AS daily_revenue FROM appointment a
				INNER JOIN slot s USING(slot_id)
WHERE a.status = 'completed' AND s.date >= '2025-10-01'
GROUP BY s.date
HAVING SUM(a.price) >= 1000
ORDER BY s.date DESC;


-- Частина 2: запити, що використовують різні типи джоінів (INNER JOIN, LEFT JOIN, RIGHT JOIN, FULL JOIN, CROSS JOIN)

-- 1) Показати перший та останній слот з показом їхнього початку за день, урахувавши, що слот вільний і лікар працює, а досвід ветеринаря >= 3
SELECT (v.name || ' ' || v.surname) AS vet_name, v.experience AS vet_experience, v.specialisation AS vet_specialisation, 
MIN(s.start_time) AS min_start_time, MAX(s.start_time) AS max_start_time, s.date FROM slot s
				INNER JOIN vet v USING(vet_id) 
				INNER JOIN schedule_template st USING(vet_id)
WHERE s.is_booked = FALSE AND v.is_active = TRUE
GROUP BY v.vet_id, s.date
HAVING v.experience >= 3
ORDER BY s.date ASC, min_start_time ASC;

-- 2) Вивести список прийомів за жовтень 2025 року з та без діагнозів
SELECT s.date, s.start_time, s.end_time, p.name AS pet_name, p.species, (o.name || ' ' || o.surname) AS owner_name, -- appointment_data
		(v.name || ' ' || v.surname) AS vet_name, v.specialisation, a.status, a.result, 
		a.med_notes, d.illness, d.description, d.is_active FROM appointment a 
				INNER JOIN slot s ON a.slot_id = s.slot_id
				LEFT JOIN diagnosis d ON a.appointment_id = d.appointment_id
        INNER JOIN pet p ON a.pet_id = p.pet_id
        INNER JOIN vet v ON a.vet_id = v.vet_id
        INNER JOIN owner o ON p.owner_id = o.owner_id
WHERE s.date >= '2025-10-01' AND s.date < '2025-11-01'
ORDER BY illness DESC NULLS LAST, s.date ASC, start_time ASC;

-- 3) Вивести прийоми та слоти, у яких є або немає прийому
SELECT s.date, s.start_time, s.end_time, a.status, s.is_booked FROM appointment a 
				RIGHT JOIN slot s ON a.slot_id = s.slot_id
WHERE s.date >= '2025-10-01' AND s.date < '2025-11-01'
ORDER BY status DESC NULLS FIRST, s.date ASC, start_time ASC;


-- Частина 3: запити з використанням підзапитів (вибірка з підзапитом у SELECT, WHERE або HAVING)

-- 1) Вивести ім'я та прізвища ветеринарів, чий досвід більший або рівний за середній досвід ветеринарів у всій клініці
SELECT (name || ' ' || surname) AS vet_name, experience FROM vet
WHERE experience >= (SELECT AVG(experience) AS avg_experience FROM vet)
ORDER BY experience DESC;

-- 2) Для кожної тварини вивести останню дату її прийому, використовуючи підзапит для пошуку останньої дати
SELECT p.pet_id, p.name AS pet_name, (SELECT MAX(s.date)
        									FROM appointment a
        									INNER JOIN slot s ON a.slot_id = s.slot_id
        									WHERE a.pet_id = p.pet_id
       										) AS last_appointment_date
FROM pet p
ORDER BY last_appointment_date DESC NULLS LAST;

-- 3) Визначити середню, мінімальну та максимальну ціни за завершені прийоми для кожного ветеринара, 
--    вказавши кількість завершених прийомів для кожного ветеринара
SELECT v.vet_id, (v.name || ' ' || v.surname) AS vet_name, ROUND(AVG(completed_appointments.price), 2) AS avg_price,  
				MIN(completed_appointments.price) AS min_price, MAX(completed_appointments.price) AS max_price, COUNT(completed_appointments.appointment_id) AS total_completed_appointments FROM vet v
				INNER JOIN (
        				SELECT a.appointment_id, a.vet_id, a.price FROM appointment a
								INNER JOIN slot s USING(slot_id)
        				WHERE a.status = 'completed'
    		) AS completed_appointments ON v.vet_id = completed_appointments.vet_id
GROUP BY v.vet_id
ORDER BY avg_price DESC, total_completed_appointments DESC;