CREATE VIEW [dbo].[AllEmployeesView]
AS
SELECT dbo.Employees.firstname, dbo.Employees.lastname, dbo.Employees.phone, dbo.Employees.email, Employeer.employee_id
FROM  dbo.Employees INNER JOIN 
dbo.Employees Employeer ON dbo.Employees.reports_to = Employeer.employee_id
GO


CREATE view [dbo].[AllCustomersView] as
SELECT
	c.customer_id,
	phone,
	street,
	Cities.name [City],
	firstname + ' ' + lastname as [Name],
	'private' as [Customer type]
FROM
	Customers c 
	inner join Cities on c.city_id = Cities.city_id
	inner join PrivateCustomers pc on c.customer_id=pc.customer_id
UNION
SELECT
	c.customer_id,
	phone,
	street,
	Cities.name as [City],
	cc.name as [Name],
	'company' as [Customer type]
FROM
	Customers c 
	inner join Cities on c.city_id = Cities.city_id
	inner join CompanyCustomers cc on c.customer_id=cc.customer_id
GO


CREATE VIEW [dbo].[MonthlyAmountOfCompanyCustomerOrdersView]
AS
SELECT Year, Month, SUM(Amount) AS Amount
FROM     dbo.AmountOfCompanyCustomerOrdersView
GROUP BY Year, Month
GO


CREATE VIEW [dbo].[AmountOfCompanyCustomerOrdersView]
AS
SELECT COUNT(*) AS Amount, YEAR(dbo.Orders.order_date) AS Year, MONTH(dbo.Orders.order_date) AS Month, DATEPART(dw, dbo.Orders.order_date) AS Day, DATEPART(hh, dbo.Orders.order_date) AS Hour
FROM     dbo.Orders INNER JOIN
                  dbo.Customers ON dbo.Customers.customer_id = dbo.Orders.customer_id INNER JOIN
                  dbo.CompanyCustomers ON dbo.CompanyCustomers.customer_id = dbo.Customers.customer_id
GROUP BY YEAR(dbo.Orders.order_date), MONTH(dbo.Orders.order_date), DATEPART(dw, dbo.Orders.order_date), DATEPART(hh, dbo.Orders.order_date)
GO


CREATE VIEW [MonthlyCompanyCustomerOrderDetailsReport] AS 
SELECT O.order_id, O.customer_id, CC.name as 'customerName', D.name, PD.price * OD.quantity as dishQuantityCost, PD.price, OD.quantity, target_date, CONVERT(TIME,target_date) as 'Time', year(target_date) as 'year', month(target_date) as 'month' 
FROM Orders O 
INNER JOIN CompanyCustomers CC on O.customer_id = CC.customer_id 
INNER JOIN OrderDetails OD on O.order_id = OD.order_id 
INNER JOIN PlannedDishes PD on OD.planned_dish_id = PD.planned_dish_id


CREATE VIEW [WeeklyCompanyCustomerOrderDetailsReport] AS
SELECT O.order_id, O.customer_id, CC.name as 'customerName', D.name, PD.price * OD.quantity as dishQuantityCost, PD.price, OD.quantity, target_date, CONVERT(TIME,target_date) as 'Time', year(target_date) as 'year', datepart(ww, target_date) as 'week'
FROM Orders O
INNER JOIN CompanyCustomers CC on O.customer_id = CC.customer_id
INNER JOIN OrderDetails OD on O.order_id = OD.order_id
INNER JOIN PlannedDishes PD on OD.planned_dish_id = PD.planned_dish_id
Inner join Dishes D on D.dish_id= PD.dish_id


CREATE VIEW [MonthlyCompanyCustomerOrdersStatisticsView] AS
SELECT O.customer_id , C.name,
SUM(PD.price * OD.quantity) AS 'totalPricePaid',
year(target_date) as 'year', month(target_date) as 'month'
FROM Orders O
JOIN Companies C on O.customer_id = C.customer_id
INNER JOIN OrderDetails OD on O.order_id = OD.order_id
INNER JOIN PlannedDishes PD on OD.planned_dish_id = PD.planned_dish_id
GROUP BY O.customer_id , C.name, year(target_date),
month(target_date)


CREATE VIEW [WeeklyCompanyCustomerOrdersStatisticsView] AS
SELECT O.customer_id , C.name,
SUM(PD.price * OD.quantity) AS 'totalPricePaid',
year(target_date) as 'year',
datepart(ww, target_date) as 'week'
FROM Orders O
JOIN CompanyCustomers C on O.customer_id = C.customer_id
INNER JOIN OrderDetails OD on O.order_id = OD.order_id
INNER JOIN PlannedDishes PD on OD.planned_dish_id = PD.planned_dish_id
GROUP BY O.customer_id , C.name, year(target_date), datepart(ww, target_date)


CREATE VIEW [dbo].[AmountOfOrdersServedByEmployeesView]
AS
SELECT        dbo.Employees.firstname, dbo.Employees.lastname, dbo.Employees.email, YEAR(dbo.Orders.order_date) AS Year, MONTH(dbo.Orders.order_date) 
                         AS Month, COUNT(*) AS Amount
FROM            dbo.Employees INNER JOIN
                         dbo.Orders ON dbo.Employees.employee_id = dbo.Orders.employee_id WHERE        (dbo.Orders.target_date IS NOT NULL)
GROUP BY dbo.Employees.firstname, dbo.Employees.lastname, dbo.Employees.phone, dbo.Employees.email, YEAR(dbo.Orders.order_date), MONTH(dbo.Orders.order_date)
GO


CREATE VIEW [MonthlyPrivateCustomerOrderDetailsReport] AS 
SELECT O.order_id, O.customer_id, PC.firstname + ' ' + PC.lastname as 'customerName', PD.name, PD.price * OD.quantity as dishQuantityCost, PD.price, OD.quantity, target_date, CONVERT(TIME,target_date) as 'Time', year(target_date) as 'year', month(target_date) as 'month' 
FROM Orders O 
INNER JOIN PrivateCustomers PC on O.customer_id = PC.customer_id 
INNER JOIN OrderDetails OD on O.order_id = OD.order_id 
INNER JOIN PlannedDishes PD on OD.planned_dish_id = PD.planned_dish_id


CREATE VIEW [WeeklyPrivateCustomerOrderDetailsReport] AS
SELECT O.order_id, O.customer_id, PC.firstname + ' ' + PC.lastname as 'customerName', D.name, PD.price * OD.quantity as dishQuantityCost, PD.price, OD.quantity, target_date, CONVERT(TIME,target_date) as 'Time', year(target_date) as 'year', datepart(ww, target_date) as 'week'
FROM Orders O
INNER JOIN PrivateCustomers PC on O.customer_id = PC.customer_id
INNER JOIN OrderDetails OD on O.order_id = OD.order_id
INNER JOIN PlannedDishes PD on OD.planned_dish_id = PD.planned_dish_id
Inner join Dishes D on D.dish_id= PD.dish_id
GO


CREATE VIEW [MonthlyPrivateCustomerOrdersStatistics] AS 
SELECT O.customer_id , PC.firstname + ' ' + PC.lastname as 'customerName', SUM(price) AS 'totalPrice', year(target_date) as 'year', month(target_date) as 'month' 
FROM Orders O 
INNER JOIN PrivateCustomers PC on O.customer_id = PC.customer_id 
GROUP BY O.customer_id , PC.firstname + ' ' + PC.lastname, year(target_date), month(target_date)


CREATE VIEW [WeeklyPrivateCustomerOrdersStatisticsView] AS
SELECT O.customer_id , PC.firstname + ' ' + PC.lastname as 'customerName', SUM(PD.price * OD.quantity) AS 'totalPrice', year(target_date) as 'year',
datepart(ww, target_date) as 'week'
FROM Orders O
INNER JOIN OrderDetails OD on O.order_id = OD.order_id
INNER JOIN PlannedDishes PD on OD.planned_dish_id = PD.planned_dish_id
INNER JOIN PrivateCustomers PC on O.customer_id = PC.customer_id
GROUP BY O.customer_id , PC.firstname + ' ' + PC.lastname, year(target_date), datepart(ww, target_date)


CREATE VIEW [dbo].[DailyAmountOfCompanyCustomerOrdersView]
AS
SELECT Day, SUM(Amount) AS Amount
FROM     dbo.AmountOfCompanyCustomerOrdersView
GROUP BY Day
GO


CREATE VIEW [MonthlyOrderStatisticsReport ] AS 
SELECT ‘Private’ as TYPE, * FROM [MonthlyPrivateCustomerOrdersStatisticsView] 
UNION
 SELECT 'Company' as Type, * 
FROM [MonthlyCompanyCustomerOrdersStatisticsView]


CREATE VIEW [WeeklyOrderStatisticsReport ] AS 
SELECT ‘Private’ as TYPE, * FROM [WeeklyPrivateCustomerOrdersStatisticsView] 
UNION
 SELECT 'Company' as Type, * 
FROM [WeeklyCompanyCustomerOrdersStatisticsView]


CREATE VIEW [MonthlyOrderDetailsReport] AS 
SELECT ‘Private’ as TYPE, * FROM [MonthlyPrivateCustomerOrderDetailsReport] 
UNION
 SELECT 'Company' as Type, * 
FROM [MonthlyCompanyCustomerOrderDetailsReport]


CREATE VIEW [WeeklyOrderDetailsReport] AS 
SELECT ‘Private’ as TYPE, * FROM [WeeklyPrivateCustomerOrderDetailsReport] 
UNION
 SELECT 'Company' as Type, * 
FROM [WeeklyCompanyCustomerOrderDetailsReport]


CREATE VIEW [dbo].[AmountOfOrdersView]
AS
SELECT COUNT(*) AS Amount, YEAR(order_date) AS year, MONTH(order_date) AS Month, DATEPART(dw, order_date) AS Day, DATEPART(hh, order_date) AS Hour
FROM     dbo.Orders
GROUP BY YEAR(order_date), MONTH(order_date), DATEPART(dw, order_date), DATEPART(hh, order_date)
GO


CREATE VIEW [dbo].[DishesView]
AS
SELECT dbo.Dishes.name, dbo.Dishes.exclusive,  dbo.Categories.name as “Category”
FROM     dbo.Dishes INNER JOIN
                  dbo.Categories ON dbo.Dishes.category_id = dbo.Categories.category_id
GO


CREATE VIEW [dbo].[MenuView]
AS
SELECT dbo.Dishes.name, dbo.Dishes.exclusive, dbo.PlannedDishes.price, dbo.PlannedDishes.active_from, dbo.PlannedDishes.active_to,  dbo.Categories.name
FROM     dbo.Dishes INNER JOIN
                  dbo.PlannedDishes ON dbo.Dishes.dish_id = dbo.PlannedDishes.dish_id INNER JOIN
                  dbo.Categories ON dbo.Dishes.category_id = dbo.Categories.category_id
WHERE  (dbo.PlannedDishes.active_from <= GETDATE()) AND (GETDATE() <= ISNULL(dbo.PlannedDishes.active_to, GETDATE()))
GO


CREATE VIEW [dbo].[AmountOfPrivateReservationsView]
AS
SELECT COUNT(*) AS Amount, YEAR(start_time) AS Year, MONTH(start_time) AS Month, DATEPART(dw, start_time) AS Day, DATEPART(hh, start_time) AS Hour
FROM     dbo.PrivateReservations GROUP BY MONTH(start_time), YEAR(start_time), DATEPART(dw, start_time), DATEPART(hh, start_time)
GO


CREATE VIEW [dbo].[AmountOfCompanyReservationsView]
AS
SELECT COUNT(*) AS Amount, YEAR(start_time) AS Year, MONTH(start_time) AS Month, DATEPART(dw, start_time) AS Day, DATEPART(hh, start_time) AS Hour
FROM     dbo.CompanyReservations GROUP BY MONTH(start_time), YEAR(start_time), DATEPART(dw, start_time), DATEPART(hh, start_time)
GO


CREATE VIEW [dbo].[TablesView]
AS
SELECT seats, is_active
FROM dbo.Tables GO


CREATE VIEW [dbo].[CompanyReservationWithoutTables]
AS
SELECT    	c.name, r.start_time, r.end_time, d.people_count
FROM        	dbo.CompanyReservationTables t
inner join CompanyReservationDetails d on t.reservation_details_id = d.reservation_details_id
inner join CompanyReservations r on r.company_reservation_id = d.company_reservation_id
inner join CompanyCustomers c on c.customer_id = r.customer_id
WHERE    	(t.table_id  IS  NULL)


CREATE VIEW [dbo].[MonthlyTableReservationsAmount] AS
select 'CompanyReservation' as TYPE, T.table_id, year(CR.end_time) as 'year', month(CR.end_time) as 'month', count(CRT.reservation_details_id) as 'HowManyTimes' from Tables T
left outer join CompanyReservationTables CRT on T.table_id = CRT.table_id
inner join CompanyReservationDetails CRD on CRD.reservation_details_id = CRT.reservation_details_id
inner join CompanyReservations CR on CR.company_reservation_id = CRD.reservation_id
group by T.table_id, year(CR.end_time), month(CR.end_time)
union
select 'PrivateReservation' as TYPE, T.table_id, year(PR.end_time) as 'year', month(PR.end_time) as 'month', count(private_reservation_id) as 'HowManyTimes' from Tables T
left outer join PrivateReservations PR on T.table_id = PR.table_id
group by T.table_id, year(PR.end_time), month(PR.end_time)


CREATE VIEW [dbo].[WeeklyTableReservationsAmount] AS
select 'CompanyReservation' as TYPE, T.table_id, year(CR.end_time) as 'year', datepart(ww, CR.end_time) as 'week', count(CRT.reservation_details_id) as 'HowManyTimes' from Tables T
left outer join CompanyReservationTables CRT on T.table_id = CRT.table_id
inner join CompanyReservationDetails CRD on CRD.reservation_details_id = CRT.reservation_details_id
inner join CompanyReservations CR on CR.company_reservation_id = CRD.reservation_id
group by T.table_id, year(CR.end_time),datepart(ww, CR.end_time)
union
select 'PrivateReservation' as TYPE, T.table_id, year(PR.end_time) as 'year', datepart(ww, PR.end_time) as 'week', count(private_reservation_id) as 'HowManyTimes' from Tables T
left outer join PrivateReservations PR on T.table_id = PR.table_id
group by T.table_id, year(PR.end_time),datepart(ww, PR.end_time)


CREATE VIEW [dbo].[MonthlyDiscountPerCustomerAddedAmount] AS
select 'TemporaryDiscount' as TYPE, discount_id, discount as 'Discount', year(active_from) as 'Year', month(active_from) as 'Month', count(customer_id) as 'HowManyCustomers' from TemporaryDiscounts
group by discount_id, discount, year(active_from), month(active_from)
union
select 'PermanentDiscount' as TYPE, discount_id, discount as 'Discount', year(active_from) as 'Year', month(active_from) as 'Month', count(customer_id) as 'HowManyCustomers' from PermanentDiscounts
group by discount_id, discount, year(active_from), month(active_from)


CREATE VIEW [dbo].[WeeklyDiscountPerCustomerAddedAmount] AS
select 'TemporaryDiscount' as TYPE, discount_id, discount as 'Discount', year(active_from) as 'Year', datepart(ww, active_from) as 'Week', count(customer_id) as 'HowManyCustomers' from TemporaryDiscounts
group by discount_id, discount, year(active_from), datepart(ww, active_from)
union
select 'PermanentDiscount' as TYPE, discount_id, discount as 'Discount', year(active_from) as 'Year', datepart(ww, active_from) as 'Month', count(customer_id) as 'HowManyCustomers' from PermanentDiscounts
group by discount_id, discount, year(active_from), datepart(ww, active_from)


CREATE VIEW [dbo].[CurrentMenuView] AS
SELECT 
	d.name as [Nazwa dania],
	description as [Opis],
	price as [Cena],
	c.name as [Kategoria] 
FROM 
	PlannedDishes pd 
	inner join Dishes d on d.dish_id = pd.dish_id
	inner join Categories c on c.category_id = d.category_id
WHERE 
	active_from < GETDATE() and active_to IS NULL OR active_to > GETDATE();
GO


CREATE VIEW [dbo].[MenuLastChanges]
AS
SELECT DISTINCT d.name, pd.active_from, pd.active_to, pd.price from PlannedDishes pd
inner join Dishes d on d.dish_id = pd.dish_id
where DATEDIFF(day, active_from, getdate()) <= 14 or (DATEDIFF(day, active_to, getdate()) <= 14 and active_to IS NOT NULL)


CREATE view [dbo].[AllPrivateResevationsView] as
SELECT DISTINCT PR.ReservationID,
 	pr.time_from,
 	pr.time_to,
 	rs.status',
 	pc.Fristname + ' ' + pc.Lastname as 'assigned_to’,
 	pr.table_id from PrivateReservations pr
INNER JOIN ReservationStatusHistory rsh on pr.reservation_id = rsh.reservation_id
INNER JOIN ReservationsStatuses rs on rsh.status_id = rs.status_id
INNER JOIN PrivateCustomers pc on pr.customer_id = pc.customer_id


CREATE view [dbo].[CurrentPrivateResevationsView] as
SELECT *
FROM AllPrivateResevationsView
where time_to > GETDATE()


CREATE VIEW [dbo].[TodaysCompanyReservations] AS
SELECT 
	*
FROM 
	CompanyReservations cr
WHERE
	NULL not in 
	(
	select 
		crt.table_id
	from 
		CompanyReservationDetails crd
		left join CompanyReservationTables crt on crd.reservaton_details_id = crt.reservation_details_id
	where
		cr.company_reservation_id = crd.reservation_id
	)
	and (CONVERT(date, start_time) = CONVERT(date, GETDATE()))
GO


CREATE VIEW [dbo].[TodaysPrivateReservations] AS
SELECT 
	*
FROM 
	PrivateReservations
WHERE
	CONVERT (date, start_time) = CONVERT (date, GETDATE())
	and table_id is not null
GO
