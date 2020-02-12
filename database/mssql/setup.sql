CREATE DATABASE DemoExpenses;
GO
USE DemoExpenses;
GO
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='ExpenseItems' and xtype='U')
  CREATE TABLE ExpenseItems(
    Id varchar(255) PRIMARY KEY NOT NULL,
    Name varchar(255) NOT NULL,
    TripId varchar(255) NULL,
    Cost money NULL,
    Currency varchar(255) NULL,
    Date date NULL,
    Reimbursable bit NULL
  );
GO