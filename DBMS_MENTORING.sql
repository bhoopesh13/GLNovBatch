/*3. Write a query to display a table with customer Id, Name, Connection_Type and No_Of
Cylinders ordered from orders table. */
use LPG;
select C.Name, C.Connection_Type, Q.No_of_cylinders from Cust_Details as C inner
join
(select Cust_Id, sum(Quantity) as no_of_cylinders from orders where status = 'ordered'
group by cust_Id)
as Q on C.Id = Q.cust_id;

/* 4. Display one customer from each product category who purchased maximum no of
cylinders with Connection_Type, Cust_Id, Name and Quantity purchased.*/

select Z.Cust_id, Z.name, Z.Connection_Type, Z.no_of_cylinders from 
(select Q.Cust_id, Q.name, Q.Connection_Type, Q.no_of_cylinders,
	row_number() OVER(Partition by  Q.Connection_Type ORDER by Q.no_of_cylinders desc) AS MAX_CYD_ROW from 
(select C.Id as Cust_Id, C.Name, P.no_of_cylinders, C.Connection_Type from
Cust_Details as C inner join
(select Cust_Id, sum(Quantity) as no_of_cylinders from orders where status = 'ordered'
group by cust_Id)
as P on P.Cust_Id = C.Id)
as Q) as Z where Z.MAX_CYD_ROW = 1;
/* 5. Display Customer Id, Successfully_Delivered and value of customer based on purchase
of cylinders using SQL Case Statement.
when Successfully_Delivered >= 8 then 'Highly Valued'
when Successfully_Delivered between 5 and 7 then 'Moderately Valued'
Else 'Low Valued' */

select Cust_Id, Successfully_Delivered,
Case
when Successfully_Delivered >= 8 then 'Highly Valued'
when Successfully_Delivered between 5 and 7 then 'Moderately Valued'
Else 'Low Valued'
End as Value from
(select O.Cust_Id, sum(O.Quantity) as Successfully_Delivered from Orders as O inner
join
(select Order_Id from billing_details where delivery_status = 'Delivered')
as P on P.Order_Id = O.Id group by Cust_Id)
as Q;

/* 6. Display Customer Id, Name, Order_Id, Inv_Id, Delivery Date of all deliveries received by
customer for all customers */

select C.Id as Cust_Id, C.Name, Delivery_Date from cust_details as C inner join (
select cust_id, Delivery_Date from
(select O.id, O.cust_id, D.Inv_Id, D.Delivery_Date from orders as O inner join
(select Inv_Id, Order_Id, date as Delivery_Date from billing_details where
Delivery_Status = 'Delivered')
as D on O.id = D.Order_id)

as P)
as Q on Q.cust_id = C.Id order by Cust_Id;


/* 7. Find the amount paid by the customer for every delivery taken for all customers with
following details Customer_Id, Name, Order_Id, Order_Date, Inv_Id, Delivery_Date,
Connection_Type and Price. */

select Q.Customer_Id, Q.Name, Q.Order_Id, Q.Order_Date, Q.Inv_Id, Q.Delivery_Date,
Q.Connection_Type, Pricing.Price from Pricing inner join
(select C.Id as Customer_Id, C.Name, P.Order_Id, P.Order_Date, P.Inv_Id,
P.Delivery_Date, C.Connection_Type, monthname(Delivery_Date) as month,
year(Delivery_Date) as Year from cust_details as C inner join
(select O.Id as Order_Id, O.date as Order_Date, O.Cust_Id, D.Inv_Id, D.Delivery_Date
from orders as O inner join
(select Inv_Id, Order_Id, date as Delivery_Date from billing_details where
Delivery_Status = 'Delivered')
as D on D.Order_Id = O.Id)
as P on P.Cust_Id = C.Id)
as Q on Q.Month = Pricing.Month and Q.Year = Pricing.Year and Q.Connection_Type =
Pricing.Type order by Customer_Id;

/* 8. Create an SQL Stored Procedure “PriceOfCurrentMonth” to Identify the Price of all
Products in the Current Month with Product_Type, Month, Year and Price in table. */

call priceofthemonth();

select * from Pricing where (Month, Year) In (select monthname(curdate()) as Month,
year(curdate()) as Year);


/*9. Find Last Delivery Date from billing_details table of every customer and display
customer Id and Name, Last_Delivery_Date and Quantity using Joins.
(Note that the date in billing_details will act as last delivery date) 
ERRRRRORRRRR
*/

select C.Id as Cust_Id, C.Name, Q.Last_Delivery_Date, Q.Quantity from cust_details as
C inner join
(select cust_id, max(Delivery_Date) as Last_Delivery_Date, Quantity from
(select O.id, O.cust_id, O.Quantity,D.Delivery_Date from orders as O inner join
(select Order_Id, date as Delivery_Date from billing_details where Delivery_Status =
'Delivered')
as D on O.id = D.Order_id)
as P group by (cust_id))
as Q on Q.cust_id = C.Id
order by cust_id;

/* 10. Display customer Id, Name, undelivered date and reason for undelivery using joins. */

select C.Id as Cust_Id, C.Name, R.Cancelled_Bill_Date, R.Reason from cust_details as
C inner join
(select cust_id, Cancelled_Bill_Date, Reason from orders as O inner join

(select B.order_id, P.Date as Cancelled_Bill_Date, P.Reason from billing_details as B
inner join
(select * from cancelled_bills)
as P on P.Inv_Id = B.Inv_Id)
as Q on Q.order_id = O.Id)
as R on R.cust_id = C.Id;

/* 11. Display customer Id, Name, Date and reason for Cancelled Orders of all cancellations
made by all customers. */

select C.Id, C.Name, R.Cancelled_Order_Date, R.Reason from cust_details as C inner
join
(select O.cust_id, Q.Cancelled_Order_Date, Q.Reason from orders as O inner join
(select O.Id, P.Date as Cancelled_Order_Date, P.Reason from orders as O inner join
(select * from cancelled_orders)
as P on P.Order_Id = O.Id)
as Q on Q.Id = O.Id)
as R on R.cust_id = C.Id;