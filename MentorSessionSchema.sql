/*
	3. Write a query to display a table with customer Id, Name, Connection_Type and No_Of
Cylinders ordered from orders table.
*/

select C.Id, C.Name, C.Connection_Type, Q.No_Of_Cylinders from Cust_Details as C
inner join
(select Cust_Id, sum(Quantity) as No_Of_Cylinders from orders where status = 'ordered' 
group by Cust_id ) as Q
on C.Id = Q.Cust_Id;


/*
5. Display Customer Id, Successfully_Delivered and value of customer based on purchase
of cylinders using SQL Case Statement.
when Successfully_Delivered >= 8 then 'Highly Valued'
when Successfully_Delivered between 5 and 7 then 'Moderately Valued'
Else 'Low Valued'
*/

select Cust_Id, Successfully_Delivered,
Case
when Successfully_Delivered >= 8 then 'Highly Valued'
when Successfully_Delivered between 5 and 7 then 'Moderately Valued'
Else 'Low Valued'
End as Value from
(select O.Cust_id, sum(O.Quantity) as Successfully_Delivered from Orders as O
inner join
(select Order_Id from billing_details where delivery_status= 'Delivered') as P
on P.Order_Id = O.Id group by Cust_Id) as Q;


/*
	6. Display Customer Id, Name, Order_Id, Inv_Id, Delivery Date of all deliveries received by
customer for all customers
*/

select C.id as Cust_Id, C.Name, P.Order_Id, P.Inv_Id, P.Delivery_Date from cust_details as C
inner join
(select O.Id as Order_Id, O.cust_id, D.Inv_Id, D.Delivery_Date from orders as O
inner join
(select Inv_Id, Order_Id, date as Delivery_Date from billing_details
where Delivery_Status = 'Delivered') as D
on D.Order_Id = O.id) as P
on P.cust_id = C.id;


/*
	7. Find the amount paid by the customer for every delivery taken for all customers with
following details Customer_Id, Name, Order_Id, Order_Date, Inv_Id, Delivery_Date,
Connection_Type and Price.
*/

select P.Customer_Id, P.Name, P.Order_Id, P.Order_Date, P.Inv_Id, P.Delivery_Date,
P.Connection_Type, A.Price from Pricing as A
inner join
(select C.Id as Customer_Id, C.Name, Q.Order_Id, Q.Order_Date, Q.Inv_Id, Q.Delivery_Date,
C.Connection_Type, monthname(Delivery_Date) as month,
year(Delivery_Date) as Year from cust_details as C
inner join
(select O.Id as Order_Id, O.date as Order_Date, O.Cust_Id, D.Inv_Id, D.Delivery_Date
from orders as O
inner join
(select Inv_Id, Order_Id, date as Delivery_Date from billing_details
where Delivery_Status = 'Delivered') as D
on O.Id = D.Order_Id) as Q
on C.Id = Q.Cust_id) as P
on A.Month = P.month and A.Year = P.Year and P.Connection_Type = A.Type;


/*
	8. Create an SQL Stored Procedure “PriceOfCurrentMonth” to Identify the Price of all
Products in the Current Month with Product_Type, Month, Year and Price in table.
*/


select * from Pricing where(Month, Year) In 
(select monthname(curdate()) as Month, year(curdate()) as Year);

call priceofthemonth();


/*
	4. Display one customer from each product category who purchased maximum no of
cylinders with Connection_Type, Cust_Id, Name and Quantity purchased.

*/

select Z.Cust_Id, Z.Name, Z.Connection_Type, Z.no_of_cylinders from
(select Q.Cust_Id, Q.Name, Q.Connection_Type, Q.no_of_cylinders,
row_number() OVER(Partition By Q.Connection_Type order by Q.no_of_cylinders desc) AS MAX_CYD_ROW
from 
(select C.Id as Cust_Id, C.Name, P.no_of_cylinders, C.Connection_Type from
Cust_Details as C
inner join
(select Cust_Id, sum(Quantity) as no_of_cylinders from orders where
status = 'ordered' group by Cust_Id) as P
on P.Cust_Id = C.Id) as Q) as Z
where MAX_CYD_ROW = 1;



