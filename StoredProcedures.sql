USE [DigitalIX]
GO

CREATE ASYMMETRIC KEY PassAsymKey 
    WITH ALGORITHM = RSA_2048 
    ENCRYPTION BY PASSWORD = 'Pa$$w0rd'; 
GO

CREATE PROCEDURE dbo.InsertNewCustomer
	@Email nvarchar(40),
	@Pw nvarchar(20),
	@DateOfBirth nvarchar(10),
	@Address nvarchar(60),
	@City nvarchar(15),
	@Country nvarchar(15),
	@Telephone nvarchar(20),
	@Mobile nvarchar(20)
AS
BEGIN
	SET NOCOUNT ON;
	IF exists (select * from [DigitalIX].[cust].[customers]
		       where Email = @Email) 
    begin
	     raiserror('The email address alreday in use. Please use enother one!',
		           10,1)
    end
	ELSE 
	begin
	    insert cust.customers
	    values(@Email, ENCRYPTBYASYMKEY(asymkey_id('PassAsymKey'), @pw),
		   CONVERT(date,@DateOfBirth,103),@Address,@City,@Country,@Telephone,@Mobile)
	end
END
GO


USE DigitalIX;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.authenticateCustomer
	@Email nvarchar(40),
	@pw nvarchar(20),
	@isAuthenticated bit output
AS
BEGIN
	SET NOCOUNT ON;
    declare @validPw nvarchar(20)

	select @validPw = cast(DECRYPTBYASYMKEY(ASYMKEY_ID('PassAsymKey'), Encryptedpw, N'Pa$$w0rd') as nvarchar(20))
	from DigitalIX.cust.customers
	where Email = @Email

	if (@validPw = @pw)
		set @isAuthenticated = 1
	else
		set @isAuthenticated = 0
END
GO


USE [DigitalIX]
GO

CREATE ASYMMETRIC KEY CardAsymKey 
    WITH ALGORITHM = RSA_2048 
    ENCRYPTION BY PASSWORD = 'Pa$$w0rd'; 
GO

CREATE PROCEDURE dbo.EncyptCard
	@CardNumber nvarchar(40),
    @ExpiryDate date
AS
BEGIN
	SET NOCOUNT ON;
	insert into [order].[creditcards](EncryptedCardNumber,ExpiryDate)
	values(ENCRYPTBYASYMKEY(asymkey_id('CardAsymKey'), @CardNumber),@ExpiryDate);
END
GO


CREATE PROCEDURE dbo.DecryptCard
	@CardID int,
	@CardNumber nvarchar(40) OUTPUT,
	@ExpiryDate date OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	select @CardNumber = cast(DECRYPTBYASYMKEY(ASYMKEY_ID('CardAsymKey'), EncryptedCardNumber, N'Pa$$w0rd') as nvarchar(40))
	from [order].[creditcards]
	where CreditCardID = @CardID

	select @ExpiryDate = ExpiryDate
	from [order].[creditcards]
	where CreditCardID = @CardID
END
GO


USE [DigitalIX]
GO

CREATE PROCEDURE dbo.PlaceOrder
	@CustomerID int,
	@CardNumber nvarchar(20),
	@SecurityCode int,
	@ExpiryDate nvarchar(10),
	@Billingaddress nvarchar(60),
	@BillingCity    nvarchar(15),
	@BillingCountry nvarchar(15),
	@Shipaddress nvarchar(60),
	@ShipCity    nvarchar(15),
	@ShipCountry nvarchar(15)
AS
BEGIN
	SET NOCOUNT ON;

	-- add new credit card if it does not exist
	-- & retrieve corresponding CardID
	declare @ValidCN nvarchar(20);
	declare @CardID int;

	select @validCN = cast(DECRYPTBYASYMKEY(ASYMKEY_ID('CardAsymKey'),EncryptedCardNumber, N'Pa$$w0rd') as nvarchar(20))
	from DigitalIX.[order].creditcards
	where CustomerID = @CustomerID and SecurityCode = @SecurityCode

	if @validCN = @CardNumber
	   set @CardID = (select CreditCardID  from DigitalIX.[order].creditcards
	                         where CustomerID = @CustomerID and SecurityCode = @SecurityCode) 
	else
	   begin
	     insert into DigitalIX.[order].creditcards 
			 (CustomerID,EncryptedCardNumber,ExpiryDate,SecurityCode)
    	 values(@CustomerID, ENCRYPTBYASYMKEY(asymkey_id('CardAsymKey'), @CardNumber),
			  @ExpiryDate,@SecurityCode);
		 set @CardID = (select CreditCardID  from DigitalIX.[order].creditcards
	                         where CustomerID = @CustomerID and SecurityCode = @SecurityCode)
	   end
		

	
	declare @NumOfProducts int;
	declare @ProductID int;
	declare @QTY int;
	declare @counter int;
	set @counter = 1;

	-- Retrieve num of products in the shopping cart for the customer @CustomerID
	set @NumOfProducts = (select count(*) from DigitalIX.cust.ShoppingCart
							where CustomerID = @CustomerID)
    
	
	-- Go through all products in the shopping cart
	while @counter <= @NumOfProducts
	begin 
	 --retireve ProductId and Quantity
     set @ProductID = (select d.ProductID
	                   from (select ProdNum, CustomerID, ProductID, QTY,
					   rank() over(partition by CustomerID order by ProdNum asc) as ProdRank
					   from DigitalIX.cust.ShoppingCart) as d
					   where d.ProdRank = @counter);
					  
     set @QTY       = (select d.QTY
	                   from (select ProdNum, CustomerID, ProductID, QTY,
					   rank() over(partition by CustomerID order by ProdNum asc) as ProdRank
					   from DigitalIX.cust.ShoppingCart) as d
					   where d.ProdRank = @counter); 
	 set @counter = @counter + 1; 
    -- update product quantity in the Product table
      update DigitalIX.prod.product
	  set QTY = QTY - @QTY
	  where ProductID = @ProductID

    -- Insert New Order
      insert into DigitalIX.[order].[order] 
	  (DateOrdered,ProductID,QtyOrdered,CustomerID,CreditCardID,
	   Billingaddress,BillingCity,BillingCountry, Shippingaddress, ShipCity,ShipCountry,StatusID)
	   values (GETDATE(), @ProductID, @QTY, @CustomerID, @CardID,@Billingaddress,@BillingCity,
	           @BillingCountry, @Shipaddress,@ShipCity,@ShipCountry,1)   

	end

    

END
GO