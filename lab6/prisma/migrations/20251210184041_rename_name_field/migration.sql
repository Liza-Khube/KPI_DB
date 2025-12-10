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
