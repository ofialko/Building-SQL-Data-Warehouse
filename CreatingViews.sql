use DigitalIX;
GO

create view Orders_on_backorder
as
select c.Email as [Customer Email], 
       c.HomeAddress as [Address], c.City as City, c.Country as Country,
	   o.DateOrdered as [Order Date], o.OrderID as [Order Number] 
from [order].[order] as o join cust.customers as c
	on o.CustomerID = c.CustomerID
where o.StatusID = 2; -- 2 corresponds to "Backorder"

GO

create view Products_on_backorder
as
select p.ProductName as [Product Name], sum(o.QtyOrdered) as [Quantity Ordered]
from [order].[order] as o join prod.product	as p
 on o.ProductID = p.ProductID
where o.StatusID = 2 
group by p.ProductID, p.ProductName  
