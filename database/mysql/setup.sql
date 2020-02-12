CREATE DATABASE DemoExpenses;

USE DemoExpenses;

CREATE TABLE expense_item (
  id binary(16) PRIMARY KEY NOT NULL,
  name VARCHAR(255) NOT NULL,
  trip_id VARCHAR(255) NULL,
  cost DECIMAL(13, 4) NULL,
  currency VARCHAR(255) NULL,
  date DATE NULL,
  reimbursable BOOLEAN NULL
);