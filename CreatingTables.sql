-- ***************************
-- Creating database DigitalIX
-- *************************** 

USE MASTER;
GO

CREATE DATABASE [DigitalIX]
 ON  PRIMARY 
( NAME = N'DigitalIX', FILENAME = N'C:\DATA\DigitalIX.mdf' , SIZE = 5120KB , FILEGROWTH = 2048KB )
 LOG ON 
( NAME = N'DigitalIX_log', FILENAME = N'C:\DATA\Digital_log.ldf' , SIZE = 4096KB , FILEGROWTH = 10%)
GO

-- *********************************************************
-- Creating two schemas: Prod (products) and Cust(customers)
-- *********************************************************

USE [DigitalIX]
GO
create schema prod;
GO
create schema cust;
GO  
create schema [order];
GO  

-- **********************************
-- Creating tables in the prod schema
-- **********************************

USE [DigitalIX]
GO

CREATE TABLE prod.category
	(
	CategoryID int NOT NULL identity(1,1) primary key,
	CategoryName nvarchar(20) NOT NULL
	)  ON [PRIMARY]
GO

CREATE TABLE prod.subcategory
	(
	SubCategoryID int NOT NULL identity(1,1) primary key,
	CategoryID int NULL,
	SubCategoryName nvarchar(20) NOT NULL
	)  ON [PRIMARY]
GO

CREATE TABLE prod.product
	(
	ProductID int NOT NULL identity(1,1) primary key,
	SubCategoryID int NULL,
	ProductName nvarchar(50) NOT NULL,
	ProductDescription nvarchar(400) NULL,
	Price money NOT NULL,
	QTY int default 10,
	RRP as Price + Price*0.2,
	STATUS bit default 1
	)  ON [PRIMARY]
GO

ALTER TABLE prod.subcategory 
ADD CONSTRAINT FK_Category FOREIGN KEY (CategoryID) 
    REFERENCES prod.category (CategoryID) 
    ON UPDATE CASCADE
	ON DELETE CASCADE
;
GO

ALTER TABLE prod.product 
ADD CONSTRAINT FK_SubCategory FOREIGN KEY (SubCategoryID) 
    REFERENCES prod.subcategory (SubCategoryID) 
    ON UPDATE CASCADE
	ON DELETE CASCADE
;
GO


-- **********************************
-- Creating tables in the cust schema
-- **********************************

USE [DigitalIX]
GO

CREATE TABLE cust.customers
	(
	CustomerID int NOT NULL identity(1,1) primary key,
	Email    nvarchar(40) NOT NULL,
	EncryptedPw varbinary(500) NOT NULL,
	DateOfBirth  date NULL,
	HomeAddress  nvarchar(60) NULL,
	City       nvarchar(15) NULL,
	Country    nvarchar(15) NULL, 
	Telephone    nvarchar(20) NULL,
	Mobile       nvarchar(20) NULL
	)  ON [PRIMARY]
GO

ALTER TABLE cust.customers
ADD CONSTRAINT Cust_Email UNIQUE (email)
GO


USE [DigitalIX]
GO



CREATE TABLE [order].[order]	
	(
	OrderID int NOT NULL identity(1,1) primary key,
	DateOrdered  date NOT NULL,
	ProductID    int NOT NULL,
	QtyOrdered   int NOT NULL,
	CustomerID   int NOT NULL,
	CreditCardID int NOT NULL,
	Billingaddress nvarchar(60) NULL,
	BillingCity    nvarchar(15) NULL,
	BillingCountry nvarchar(15) NULL,
	Shippingaddress nvarchar(60) NOT NULL,
	ShipCity       nvarchar(15) NOT NULL,
	ShipCountry    nvarchar(15) NOT NULL,
	StatusID       int NOT NULL
	)  ON [PRIMARY]
GO


ALTER TABLE [order].[order]
ADD CONSTRAINT FK_OrderProductID FOREIGN KEY (ProductID) 
    REFERENCES prod.product (ProductID) 
    ON UPDATE CASCADE
	ON DELETE CASCADE
;
GO

ALTER TABLE [order].[order]
ADD CONSTRAINT FK_OrderCustomerID FOREIGN KEY (CustomerID) 
    REFERENCES cust.customers (CustomerID) 
    ON UPDATE CASCADE
	ON DELETE CASCADE
;
GO

CREATE TABLE [order].[creditcards]	
	(
	CreditCardID int NOT NULL identity(1,1) primary key,
	CustomerID int NOT NULL,
	EncryptedCardNumber varbinary(500) NOT NULL,
	ExpiryDate date NOT NULL,
	SecurityCode int NOT NULL
	)  ON [PRIMARY]
GO

ALTER TABLE [order].creditcards
ADD CONSTRAINT FK_Customer FOREIGN KEY (CustomerID) 
    REFERENCES cust.customers (CustomerID) 
    ON UPDATE CASCADE
	ON DELETE CASCADE
;
GO

ALTER TABLE [order].[order]
ADD CONSTRAINT FK_CreditCardID FOREIGN KEY (CreditCardID) 
    REFERENCES [order].[creditcards] (CreditCardID) 
    --ON UPDATE CASCADE
	--ON DELETE CASCADE
;
GO

CREATE TABLE [order].[statuses]	
	(
	StatusID int NOT NULL identity(1,1) primary key,
	Status nvarchar(15) NOT NULL
	)  ON [PRIMARY]
GO

ALTER TABLE [order].[order]
ADD CONSTRAINT FK_Status FOREIGN KEY (StatusID) 
    REFERENCES [order].[statuses] (StatusID) 
    ON UPDATE CASCADE
	ON DELETE CASCADE
;
GO

insert into [order].[statuses](Status)
values ('PROCESSING')	
insert into [order].[statuses](Status)
values ('BACKORDER')
insert into [order].[statuses](Status)
values ('SHIPPING')
insert into [order].[statuses](Status)
values ('DELIVERED')
insert into [order].[statuses](Status)
values ('CANCELLED')
		
use DigitalIX;
GO

CREATE TABLE cust.ShoppingCart
	(
	ProdNum int identity (1,1) primary key,
	CustomerID int NOT NULL,
	ProductID int NOT NULL,
	QTY int NOT NULL
	) ON [PRIMARY]

GO

ALTER TABLE cust.ShoppingCart
ADD CONSTRAINT FK_CustomersShopping FOREIGN KEY (CustomerID) 
    REFERENCES cust.Customers (CustomerID) 
    ON UPDATE CASCADE
	ON DELETE CASCADE
;
GO

CREATE TABLE temp	
	(
	ProductName nvarchar(50) NOT NULL,
	SubCategory nvarchar(50) NOT NULL,
	Category    nvarchar(50) NOT NULL,
	ProductDescription nvarchar(400) NOT NULL,
	Price  money NOT NULL 
	)  ON [PRIMARY]
GO	
