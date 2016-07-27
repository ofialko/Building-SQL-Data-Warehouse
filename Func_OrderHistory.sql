
use DigitalIX;
GO

CREATE FUNCTION dbo.OrderHistory(@custID int)
RETURNS TABLE
AS
RETURN
    SELECT o.DateOrdered as [Date], 
		   o.OrderID as [Order number], 
		   s.[Status] as [Status],
		   o.QtyOrdered*p.RRP as [Total Price]
    FROM [DigitalIX].[order].[order] as o join  [DigitalIX].[order].[statuses] as s
	 on o.StatusID = s.StatusID join [DigitalIX].prod.product as p
	 on o.ProductID = p.ProductID
    WHERE CustomerID = @custID