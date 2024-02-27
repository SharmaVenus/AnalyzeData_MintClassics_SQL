use mintClassicsDB

---------------------------------------
-- To analyze the total sales as per each product code, evaluate which products are mostly ordered.

select  productcode , sum(quantityOrdered) as quantity_ordered 
from orderdetails 
group by productcode 

---------------------------------------
--  total inventory available in each warehouse 
SELECT warehouseName, sum(quantityInStock) AS stockquantity FROM products
INNER JOIN warehouses ON products.warehousecode= warehouses.warehousecode
GROUP BY warehouseName
ORDER BY stockquantity DESC;

---------------------------------------
--  total available stock for each product in warehouse

select warehousename,productname , sum(quantityInStock) as Avail_stock 
from products inner join warehouses on products.warehouseCode = warehouses.warehouseCode 
group by warehousename, productname
order by Avail_stock asc ;

----------------------------------------
-- Total stock in each warehouse based on product line 


select warehousename,productline  , sum(quantityInStock) as Avail_stock 
from products inner join warehouses on products.warehouseCode = warehouses.warehouseCode 
group by productline, warehousename
order by Avail_stock desc ;

----------------------------------------

-- finding products with low inventory and high orders. Shortage of inventory 
SELECT warehouseName, productName, productLine, sum(quantityordered) AS stockordered ,sum(quantityInStock) as stockquantity ,
sum(p.quantityInstock) - sum(o.quantityOrdered) as differenceInStock from products p
INNER JOIN
  orderdetails o ON o.productCode= p.productCode
INNER JOIN 
  warehouses ON warehouses.warehouseCode=p.warehouseCode
GROUP BY 
  warehouseName,productName,productLine
having sum(p.quantityInstock) - sum(o.quantityOrdered) <0
ORDER BY 
  stockquantity DESC;



----------------------------------------
-- finding products with low inventory and high orders. Shortage of inventory 

with cte as (
          select p.productcode , p.productname, p.warehouseCode, sum(p.quantityInstock) as avail_stock, sum(o.quantityOrdered) as quantity_ordered , 
sum(p.quantityInstock) - sum(o.quantityOrdered) as differenceInStock 
from
  products as p
left join 
  orderdetails as o on p.productCode = o.productCode 
group by 
  p.productCode , p.productname, p.warehouseCode
having sum(p.quantityInstock) - sum(o.quantityOrdered) < 0 
) 

select productCode , productName , w.warehouseName, avail_stock, quantity_ordered, differenceInStock

from cte left join warehouses w on cte.warehouseCode = w.warehouseCode;
----------------------------------------
-- to find the products with highest sales 


select p.productCode,p.productName, sum(od.quantityOrdered) as Total_Sales,
   sum(p.QuantityInStock) as TotalInventory
from 
   products p
inner join 
    orderdetails od 
 on
   od.productCode = p.productCode 
group by p.productCode,p.productName
order by Total_Sales desc 

----------------------------------------
-- Performance of various product lines can be compared? 
--Which products are the most successful, and which ones need improvement or removal?

select p.productline, sum(od.quantityOrdered) as Total_Sales,
   sum(pr.QuantityInStock) as TotalInventory,
   sum(od.priceEach*od.quantityOrdered) as TotalRevenue 
from
products pr 
  left join
productlines p
on p.productLine = pr.productLine 
left join orderdetails od 
on od.productCode = pr.productCode
group by p.productline
order by TotalRevenue desc
 
----------------------------------------
--this query helps you obtain a list of products with the highest purchase prices, accompanied by the total 
--quantity of products ordered for each of these products.

select 
 p.productname,
 p.buyprice,
 sum(od.quantityordered)  as totalOrdered
from products p 
left join 
orderdetails od on p.productcode = od.productCode
group by 
  p.productname, p.buyprice
order by
  p.buyPrice desc;


-----------------------------------------
--Who are the customers contributing the most to sales? How can sales efforts be focused on these valuable customers?


select 
   c.customerNumber, customername, count(o.ordernumber) as TotalOrdersPlacedbyCustomer 
from 
   customers c 
left join 
   orders o 
   on c.customerNumber = o.customerNumber
group by c.customerNumber,customername 
order by TotalOrdersPlacedbyCustomer desc 

-----------------------------------------
-- the total sales amount associated with each employee.

select 
  e.employeeNumber,e.firstName ,e.lastName, e.jobtitle, sum(od.priceEach*od.quantityOrdered) as TotalSales
from
  employees e  
left join customers c 
  on e.employeeNumber = c.salesRepEmployeeNumber
left join 
orders o 
  on o.customerNumber = c.customerNumber
left join 
orderdetails od 
  on od.orderNumber = o.orderNumber
group by   e.employeeNumber,e.firstName ,e.lastName, e.jobtitle
order by TotalSales desc ;

---------------------------------------
-- To analyse and find customers with their payment history

select c.customerNumber, c.customerName, p.paymentDate, p.amount as amountPaid
from customers c 
left join 
    payments p
	on c.customerNumber = p.customerNumber
order by 
  amountPaid desc;

------------------------------------------
-- to analyze customers credit limit and payment status,
--evaluate credit risk that needs attention, and manage the company’s cash flow.

select 
   c.customerNumber,c.customerName, c.creditLimit, sum(p.amount) as totalPayments, 
   (sum(p.amount) - sum(c.creditLimit) )as CreditDifference
   from 
 customers c 
left join 
  payments p 
on c.customerNumber = p.customerNumber 
group by   c.customerNumber,c.customerName, c.creditLimit 
having  sum(p.amount)  < c.creditLimit
order by totalPayments asc 
   









