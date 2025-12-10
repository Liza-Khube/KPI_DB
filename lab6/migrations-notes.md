# Міграції схем за допомогою Prisma ORM

## 1. Міграція: `add-service-table`

Опис: Додано нову модель `service`, яка відповідає за послуги, надані під час прийому у ветеринарній клініці. Поле `name` має обмеження `@unique` через неможливість існування двох однакових послуг. Створено зв'язок "один-до-багатьох" між моделями `service` та `appointment` відповідно.

Додані зміни в `schema.prisma`:

```
// Додана нова модель
model service {
  service_id      Int      @id @default(autoincrement())
  name            String   @unique @db.VarChar(32)
  description     String
  room            Int
  appointment     appointment[]
}

// Доданий атрибут service_id та його зв'язок з моделлю service
model appointment {
  appointment_id Int                 @id @default(autoincrement())
  reason         String?
  price          Decimal             @default(200) @db.Decimal(10, 2)
  status         appointment_status
  result         appointment_result?
  med_notes      String?
  pet_id         Int
  slot_id        Int                 @unique
  service_id     Int
  pet            pet                 @relation(fields: [pet_id], references: [pet_id], onDelete: NoAction, onUpdate: NoAction)
  slot           slot                @relation(fields: [slot_id], references: [slot_id], onDelete: NoAction, onUpdate: NoAction)
  service        service             @relation(fields: [service_id], references: [service_id], onDelete: NoAction, onUpdate: NoAction)
  diagnosis      diagnosis[]
}
```

Згенерований файл `migration.sql`:

```
/*
  Warnings:

  - Added the required column `service_id` to the `appointment` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "appointment" ADD COLUMN     "service_id" INTEGER NOT NULL;

-- CreateTable
CREATE TABLE "service" (
    "service_id" SERIAL NOT NULL,
    "name" VARCHAR(32) NOT NULL,
    "description" TEXT NOT NULL,
    "room" INTEGER NOT NULL,

    CONSTRAINT "service_pkey" PRIMARY KEY ("service_id")
);

-- CreateIndex
CREATE UNIQUE INDEX "service_name_key" ON "service"("name");

-- AddForeignKey
ALTER TABLE "appointment" ADD CONSTRAINT "appointment_service_id_fkey" FOREIGN KEY ("service_id") REFERENCES "service"("service_id") ON DELETE NO ACTION ON UPDATE NO ACTION;
```

---

## 2. Міграція: `add-price-field`

Опис: Додано нове поле price до моделі `service`, яке описує ціну за надану послугу (якщо ветеринар не захоче її оновити в процесі чи завершенні прийому).

Додані зміни в `schema.prisma`:

```
model service {
  service_id      Int             @id @default(autoincrement())
  name            String          @unique @db.VarChar(32)
  description     String
  price           Decimal         @db.Decimal(10, 2)
  room            Int
  appointment     appointment[]
}
```

Згенерований файл `migration.sql`:

```
/*
  Warnings:

  - Added the required column `price` to the `service` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "service" ADD COLUMN     "price" DECIMAL(10,2) NOT NULL;
```

---

## 3. Міграція: `drop-price-field`

Опис: Видалено поле `price` з моделі `appointment` у зв'язку з надлишковістю - ідентичне поле вже існує в моделі `service`, на яку посилається модель `appointment `з допомогою поля `service_id`.

Додані зміни в `schema.prisma`:

```
model appointment {
  appointment_id Int                 @id @default(autoincrement())
  reason         String?
  status         appointment_status
  result         appointment_result?
  med_notes      String?
  pet_id         Int
  slot_id        Int                 @unique
  service_id     Int
  pet            pet                 @relation(fields: [pet_id], references: [pet_id], onDelete: NoAction, onUpdate: NoAction)
  slot           slot                @relation(fields: [slot_id], references: [slot_id], onDelete: NoAction, onUpdate: NoAction)
  service        service             @relation(fields: [service_id], references: [service_id], onDelete: NoAction, onUpdate: NoAction)
  diagnosis      diagnosis[]
}
```

Згенерований файл `migration.sql`:

```
/*
  Warnings:

  - You are about to drop the column `price` on the `appointment` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "appointment" DROP COLUMN "price";
```

---

## 4. Міграція: `rename-name-field`

Опис: Перейменовано поле `name` у моделі `service` у зв'язку з незрозумілістю призначення цього поля (тип послуги). Тому нова назва поля тепер `type`.

Додані зміни в `schema.prisma`:

```
model service {
  service_id      Int             @id @default(autoincrement())
  type            String          @unique @db.VarChar(32)
  description     String
  price           Decimal         @db.Decimal(10, 2)
  room            Int
  appointment     appointment[]
}
```

Згенерований файл `migration.sql`:

```
/*
  Warnings:

  - You are about to drop the column `name` on the `service` table. All the data in the column will be lost.
  - A unique constraint covering the columns `[type]` on the table `service` will be added. If there are existing duplicate values, this will fail.
  - Added the required column `type` to the `service` table without a default value. This is not possible if the table is not empty.

*/
-- DropIndex
DROP INDEX "service_name_key";

-- AlterTable
ALTER TABLE "service" DROP COLUMN "name",
ADD COLUMN     "type" VARCHAR(32) NOT NULL;

-- CreateIndex
CREATE UNIQUE INDEX "service_type_key" ON "service"("type");
```

---

## 5. Докази змін на Prisma Studio

Опис: Створено по одному запису в моделях `service` та `appointment` для перевірки міграцій

- Створений запис для `service`. Він підтверджує створену таблицю `service` (міграція `add-service-table`), додане поле `price `(міграція `add-price-field`) і перейменоване поле `name `на `type `(міграція `rename-name-field`):

  ![1765396778514](image/migrations/1765396778514.png)

- Створений запис для `appointment`. Він підтверджує додане поле `service_id `з посиланням на таблицю `service `(міграція `add-service-table`) і відсутність (відповідно видаленого) поля `price` (міграція `drop-price-field`):

  ![1765397032752](image/migrations-notes/1765397032752.png)
