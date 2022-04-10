CREATE TABLE [dbo].[Cities](
	[city_id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](50) NOT NULL,
	[country_id] [int] NOT NULL,
 CONSTRAINT [PK_Cities] PRIMARY KEY CLUSTERED 
(
	[city_id] ASC
)
CONSTRAINT [unique_name] UNIQUE NONCLUSTERED 
(
	[name] ASC
)
) 
GO

ALTER TABLE [dbo].[Cities]  WITH CHECK ADD  CONSTRAINT [FK_Cities_Countries] FOREIGN KEY([country_id])
REFERENCES [dbo].[Countries] ([country_id])
GO
ALTER TABLE [dbo].[Cities] CHECK CONSTRAINT [FK_Cities_Countries]
GO



CREATE TABLE [dbo].[CompanyCustomers](
	[customer_id] [int] NOT NULL,
	[name] [nvarchar](50) NOT NULL,
	[nip] [varchar](50) NOT NULL,
	[homepage] [varchar](50) NULL,
 CONSTRAINT [PK_CompanyCustomers] PRIMARY KEY CLUSTERED 
(
	[customer_id] ASC
)
CONSTRAINT [unique_nip] UNIQUE NONCLUSTERED 
(
	[nip] ASC
)
) 
GO

ALTER TABLE [dbo].[CompanyCustomers]  WITH CHECK ADD  CONSTRAINT [FK_CompanyCustomers_Customers] FOREIGN KEY([customer_id])
REFERENCES [dbo].[Customers] ([customer_id])
GO
ALTER TABLE [dbo].[CompanyCustomers] CHECK CONSTRAINT [FK_CompanyCustomers_Customers]
GO



CREATE TABLE [dbo].[CompanyReservationDetails](
	[reservaton_details_id] IDENTITY(1,1) [int] NOT NULL,
	[reservation_id] [int] NOT NULL,
	[people_count] [int] NOT NULL,
 CONSTRAINT [PK_CompanyReservationDetails] PRIMARY KEY CLUSTERED 
(
	[reservaton_details_id] ASC
)
)
GO

ALTER TABLE [dbo].[CompanyReservationDetails]  WITH CHECK ADD  CONSTRAINT [FK_CompanyReservationDetails_CompanyReservations] FOREIGN KEY([reservation_id])
REFERENCES [dbo].[CompanyReservations] ([company_reservation_id])
GO
ALTER TABLE [dbo].[CompanyReservationDetails] CHECK CONSTRAINT [FK_CompanyReservationDetails_CompanyReservations]
GO
ALTER TABLE [dbo].[CompanyReservationDetails]  WITH CHECK ADD  CONSTRAINT [FK_CompanyReservationDetails_CompanyReservationTables] FOREIGN KEY([reservaton_details_id])
REFERENCES [dbo].[CompanyReservationTables] ([reservation_details_id])
GO
ALTER TABLE [dbo].[CompanyReservationDetails] CHECK CONSTRAINT [FK_CompanyReservationDetails_CompanyReservationTables]
GO

ALTER TABLE [dbo].[CompanyReservationDetails]  WITH CHECK ADD CONSTRAINT [CK_positive] CHECK  ([people_count]>(1))
GO
ALTER TABLE [dbo].[CompanyReservationDetails] CHECK CONSTRAINT [CK_positive]
GO



CREATE TABLE [dbo].[CompanyReservationEmployees](
	[reservation_details_id] [int] NOT NULL,
	[employee_customer_id] [int] NOT NULL,
 CONSTRAINT [PK_CompanyReservationEmployees] PRIMARY KEY CLUSTERED 
(
	[reservation_details_id] ASC,
	[employee_customer_id] ASC
)
)
GO

ALTER TABLE [dbo].[CompanyReservationEmployees]  WITH CHECK ADD  CONSTRAINT [FK_CompanyReservationEmployees_CompanyReservationDetails] FOREIGN KEY([named_reservation_details_id])
REFERENCES [dbo].[CompanyReservationDetails] ([reservaton_details_id])
GO
ALTER TABLE [dbo].[CompanyReservationEmployees] CHECK CONSTRAINT [FK_CompanyReservationEmployees_CompanyReservationDetails]
GO
ALTER TABLE [dbo].[CompanyReservationEmployees]  WITH CHECK ADD  CONSTRAINT [FK_CompanyReservationEmployees_PrivateCustomers] FOREIGN KEY([employee_customer_id])
REFERENCES [dbo].[PrivateCustomers] ([customer_id])
GO
ALTER TABLE [dbo].[CompanyReservationEmployees] CHECK CONSTRAINT [FK_CompanyReservationEmployees_PrivateCustomers]
GO



CREATE TABLE [dbo].[CompanyReservations](
	[company_reservation_id] [int] IDENTITY(1,1) NOT NULL,
	[customer_id] [int] NOT NULL,
	[start_time] [datetime] NOT NULL,
	[end_time] [datetime] NOT NULL,
 CONSTRAINT [PK_CompanyReservations] PRIMARY KEY CLUSTERED 
(
	[company_reservation_id] ASC
)
) 
GO

ALTER TABLE [dbo].[CompanyReservations]  WITH CHECK ADD  CONSTRAINT [FK_CompanyReservations_CompanyCustomers] FOREIGN KEY([customer_id])
REFERENCES [dbo].[CompanyCustomers] ([customer_id])
GO
ALTER TABLE [dbo].[CompanyReservations] CHECK CONSTRAINT [FK_CompanyReservations_CompanyCustomers]
GO

--DATE CHRONOLOGICAL
ALTER TABLE [dbo].[CompanyReservations]  WITH CHECK ADD  CONSTRAINT [CK_chronological_date] CHECK  ([end_time]>[start_time])
GO
ALTER TABLE [dbo].[CompanyReservations] CHECK CONSTRAINT [CK_chronological_date]
GO



CREATE TABLE [dbo].[CompanyReservationTables](
	[reservation_details_id] [int] NOT NULL,
	[table_id] [int] NOT NULL,
 CONSTRAINT [PK_CompanyReservationTables] PRIMARY KEY CLUSTERED 
(
	[reservation_details_id] ASC
)
)
GO

ALTER TABLE [dbo].[CompanyReservationTables]  WITH CHECK ADD  CONSTRAINT [FK_CompanyReservationTables_Tables] FOREIGN KEY([table_id])
REFERENCES [dbo].[Tables] ([table_id])
GO
ALTER TABLE [dbo].[CompanyReservationTables] CHECK CONSTRAINT [FK_CompanyReservationTables_Tables]
GO



CREATE TABLE [dbo].[Countries](
	[country_id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Countries] PRIMARY KEY CLUSTERED 
(
	[country_id] ASC
),
 CONSTRAINT [unique_name] UNIQUE NONCLUSTERED 
(
	[name] ASC
)) 
GO



CREATE TABLE [dbo].[Customers](
	[customer_id] [int] IDENTITY(1,1) NOT NULL,
	[phone] [varchar](15) NOT NULL,
	[street] [nvarchar](50) NOT NULL,
	[city_id] [int] NOT NULL,
 CONSTRAINT [PK_Customers] PRIMARY KEY CLUSTERED 
(
	[customer_id] ASC
)
) 
GO

ALTER TABLE [dbo].[Customers]  WITH CHECK ADD  CONSTRAINT [FK_Customers_Cities] FOREIGN KEY([city_id])
REFERENCES [dbo].[Cities] ([city_id])
GO
ALTER TABLE [dbo].[Customers] CHECK CONSTRAINT [FK_Customers_Cities]
GO

--PHONE
ALTER TABLE [dbo].[Customers]  WITH CHECK ADD  CONSTRAINT [CK_phone] CHECK  ([phone] not like '%[^0-9]%')
GO
ALTER TABLE [dbo].[Customers] CHECK CONSTRAINT [CK_phone]
GO



CREATE TABLE [dbo].[DiscountParamHistory](
	[discount_id] [int] NOT NULL,
	[param_id] [nchar](10) NOT NULL,
	[value] [int] NOT NULL,
	[active_from] [datetime] NOT NULL DEFAULT GETDATE(),
	[active_to] [datetime] NULL,
 CONSTRAINT [PK_DiscountParamHistory] PRIMARY KEY CLUSTERED 
(
	[discount_id] ASC
)
) 
GO

ALTER TABLE [dbo].[DiscountParamHistory]  WITH CHECK ADD  CONSTRAINT [FK_DiscountParamHistory_DiscountParams] FOREIGN KEY([param_id])
REFERENCES [dbo].[DiscountParams] ([param_id])
GO
ALTER TABLE [dbo].[DiscountParamHistory] CHECK CONSTRAINT [FK_DiscountParamHistory_DiscountParams]
GO

--DATE CHRONOLOGICAL
ALTER TABLE [dbo].[DiscountParamHistory]  WITH CHECK ADD  CONSTRAINT [CK_chronological_date] CHECK  ([active_to]>[active_from])
GO
ALTER TABLE [dbo].[DiscountParamHistory] CHECK CONSTRAINT [CK_chronological_date]
GO



CREATE TABLE [dbo].[DiscountParams](
	[param_id] [varchar](10) NOT NULL,
	[value] [int] NOT NULL,
 CONSTRAINT [PK_DiscountParams] PRIMARY KEY CLUSTERED 
(
	[param_id] ASC
)
) 
GO

ALTER TABLE [dbo].[DiscountParamHistory]  WITH CHECK ADD CONSTRAINT [CK_positive] CHECK  ([value]>(0))
GO
ALTER TABLE [dbo].[DiscountParamHistory] CHECK CONSTRAINT [CK_positive]
GO



CREATE TABLE [dbo].[Dishes](
	[dish_id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](50) NOT NULL,
	[category_id] [int] NOT NULL,
	[description] [text] NULL,
	[seafood] [bit] NOT NULL,
 CONSTRAINT [PK_Dishes] PRIMARY KEY CLUSTERED 
(
	[dish_id] ASC
),
CONSTRAINT [unique_name] UNIQUE NONCLUSTERED 
(
	[name] ASC
)
)
GO

ALTER TABLE [dbo].[Dishes]  WITH CHECK ADD  CONSTRAINT [FK_Dishes_Categories] FOREIGN KEY([category_id])
REFERENCES [dbo].[Categories] ([category_id])
GO
ALTER TABLE [dbo].[Dishes] CHECK CONSTRAINT [FK_Dishes_Categories]
GO



CREATE TABLE [dbo].[Employees](
	[employee_id] [int] IDENTITY(1,1) NOT NULL,
	[reports_to] [int] NULL,
	[firstname] [nvarchar](50) NOT NULL,
	[lastname] [nvarchar](50) NOT NULL,
	[email] [varchar](50) NOT NULL,
 CONSTRAINT [PK_Employees] PRIMARY KEY CLUSTERED 
(
	[employee_id] ASC
),
CONSTRAINT [unique_email] UNIQUE NONCLUSTERED 
(
	[email] ASC
)
)
GO

ALTER TABLE [dbo].[Employees]  WITH CHECK ADD  CONSTRAINT [FK_Employees_Employees] FOREIGN KEY([reports_to])
REFERENCES [dbo].[Employees] ([employee_id])
GO
ALTER TABLE [dbo].[Employees] CHECK CONSTRAINT [FK_Employees_Employees]
GO
--EMAIL
ALTER TABLE [dbo].[Employees]  WITH CHECK ADD  CONSTRAINT [CK_email] CHECK  ([email] like '%@%[.]%')
GO
ALTER TABLE [dbo].[Employees] CHECK CONSTRAINT [CK_email]
GO



CREATE TABLE [dbo].[OrderDetails](
	[order_id] [int] NOT NULL,
	[planned_dish_id] [int] NOT NULL,
	[quantity] [int] NOT NULL,
 CONSTRAINT [PK_OrderDetails] PRIMARY KEY CLUSTERED 
(
	[order_id] ASC,
	[planned_dish_id] ASC
)
) 
GO

ALTER TABLE [dbo].[OrderDetails]  WITH CHECK ADD  CONSTRAINT [FK_OrderDetails_Orders] FOREIGN KEY([order_id])
REFERENCES [dbo].[Orders] ([order_id])
GO
ALTER TABLE [dbo].[OrderDetails] CHECK CONSTRAINT [FK_OrderDetails_Orders]
GO
ALTER TABLE [dbo].[OrderDetails]  WITH CHECK ADD  CONSTRAINT [FK_OrderDetails_PlannedDishes] FOREIGN KEY([planned_dish_id])
REFERENCES [dbo].[PlannedDishes] ([planned_dish_id])
GO
ALTER TABLE [dbo].[OrderDetails] CHECK CONSTRAINT [FK_OrderDetails_PlannedDishes]
GO

ALTER TABLE [dbo].[OrderDetails]  WITH CHECK ADD  CONSTRAINT [CK_positive] CHECK  ([quantity]>(0))
GO
ALTER TABLE [dbo].[OrderDetails] CHECK CONSTRAINT [CK_positive]
GO



CREATE TABLE [dbo].[Orders](
	[order_id] [int] IDENTITY(1,1) NOT NULL,
	[customer_id] [int] NOT NULL,
	[employee_id] [int] NULL,
	[order_date] [datetime] NOT NULL DEFAULT GETDATE(),
	[target_date] [datetime] NOT NULL,
	[paid_in_advance] [bit] NOT NULL,
 CONSTRAINT [PK_Orders] PRIMARY KEY CLUSTERED 
(
	[order_id] ASC
)
) 
GO

ALTER TABLE [dbo].[Orders]  WITH CHECK ADD  CONSTRAINT [FK_Orders_Customers] FOREIGN KEY([customer_id])
REFERENCES [dbo].[Customers] ([customer_id])
GO
ALTER TABLE [dbo].[Orders] CHECK CONSTRAINT [FK_Orders_Customers]
GO
ALTER TABLE [dbo].[Orders]  WITH CHECK ADD  CONSTRAINT [FK_Orders_Employees] FOREIGN KEY([employee_id])
REFERENCES [dbo].[Employees] ([employee_id])
GO
ALTER TABLE [dbo].[Orders] CHECK CONSTRAINT [FK_Orders_Employees]
GO
ALTER TABLE [dbo].[Orders]  WITH CHECK ADD  CONSTRAINT [FK_Orders_PrivateReservations] FOREIGN KEY([reservation_id])
REFERENCES [dbo].[PrivateReservations] ([reservation_id])
GO
ALTER TABLE [dbo].[Orders] CHECK CONSTRAINT [FK_Orders_PrivateReservations]
GO

--DATE CHRONOLOGICAL
ALTER TABLE [dbo].[Orders]  WITH CHECK ADD  CONSTRAINT [CK_chronological_date] CHECK  ([target_date]>[order_date])
GO
ALTER TABLE [dbo].[Orders] CHECK CONSTRAINT [CK_chronological_date]
GO



CREATE TABLE [dbo].[OrderStatuses](
	[order_status_id] [int] IDENTITY(1,1) NOT NULL,
	[order_status] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_OrderStatuses] PRIMARY KEY CLUSTERED 
(
	[order_status_id] ASC
),
CONSTRAINT [unique_status] UNIQUE NONCLUSTERED 
(
	[order_status] ASC
)
) 
GO



CREATE TABLE [dbo].[OrderStatusHistory](
	[order_id] [int] NOT NULL,
	[order_status_id] [int] NOT NULL,
	[datetime] [datetime] NOT NULL DEFAULT GETDATE(),
 CONSTRAINT [PK_OrderStatusHistory] PRIMARY KEY CLUSTERED 
(
	[order_id] ASC,
	[order_status_id] ASC
)) 
GO

ALTER TABLE [dbo].[OrderStatusHistory]  WITH CHECK ADD  CONSTRAINT [FK_OrderStatusHistory_Orders] FOREIGN KEY([order_id])
REFERENCES [dbo].[Orders] ([order_id])
GO
ALTER TABLE [dbo].[OrderStatusHistory] CHECK CONSTRAINT [FK_OrderStatusHistory_Orders]
GO
ALTER TABLE [dbo].[OrderStatusHistory]  WITH CHECK ADD  CONSTRAINT [FK_OrderStatusHistory_OrderStatuses] FOREIGN KEY([order_status_id])
REFERENCES [dbo].[OrderStatuses] ([order_status_id])
GO
ALTER TABLE [dbo].[OrderStatusHistory] CHECK CONSTRAINT [FK_OrderStatusHistory_OrderStatuses]
GO



CREATE TABLE [dbo].[PermanentDiscounts](
	[customer_id] [int] NOT NULL,
	[discount_id] [int] NOT NULL,
	[discount] [real] NOT NULL,
 CONSTRAINT [PK_PermanentDiscounts] PRIMARY KEY CLUSTERED 
(
	[customer_id] ASC
)) 
GO

ALTER TABLE [dbo].[PermanentDiscounts]  WITH CHECK ADD  CONSTRAINT [FK_PermanentDiscounts_DiscountParamHistory] FOREIGN KEY([discount_id])
REFERENCES [dbo].[DiscountParamHistory] ([discount_id])
GO
ALTER TABLE [dbo].[PermanentDiscounts] CHECK CONSTRAINT [FK_PermanentDiscounts_DiscountParamHistory]
GO

--REASONABLE DISCOUNT
ALTER TABLE [dbo].[PermanentDiscounts]  WITH CHECK ADD  CONSTRAINT [CK_reasonable_discount] CHECK  (discount between 0 and 1 )
GO
ALTER TABLE [dbo].[PermanentDiscounts] CHECK CONSTRAINT [CK_reasonable_discount]
GO



CREATE TABLE [dbo].[PlannedDishes](
	[planned_dish_id] [int] IDENTITY(1,1) NOT NULL,
	[dish_id] [int] NOT NULL,
	[price] [money] NOT NULL,
	[active_from] [datetime] NOT NULL DEFAULT GETDATE(),
	[active_to] [datetime] NULL,
 CONSTRAINT [PK_PlannedDishes] PRIMARY KEY CLUSTERED 
(
	[planned_dish_id] ASC
)) 
GO

ALTER TABLE [dbo].[PlannedDishes]  WITH CHECK ADD  CONSTRAINT [FK_PlannedDishes_Dishes] FOREIGN KEY([dish_id])
REFERENCES [dbo].[Dishes] ([dish_id])
GO
ALTER TABLE [dbo].[PlannedDishes] CHECK CONSTRAINT [FK_PlannedDishes_Dishes]
GO

--DATE CHRONOLOGICAL
ALTER TABLE [dbo].[PlannedDishes]  WITH CHECK ADD  CONSTRAINT [CK_chronological_date] CHECK  (([active_to]>[active_from]) or [active_to] is null)
GO
ALTER TABLE [dbo].[PlannedDishes] CHECK CONSTRAINT [CK_chronological_date]
GO

--POSITIVE VALUE
ALTER TABLE [dbo].[PlannedDishes]  WITH CHECK ADD  CONSTRAINT [CK_positive] CHECK  ([price]>0)
GO
ALTER TABLE [dbo].[PlannedDishes] CHECK CONSTRAINT [CK_positive]
GO



CREATE TABLE [dbo].[PrivateCustomers](
	[customer_id] [int] NOT NULL,
	[firstname] [nvarchar](50) NOT NULL,
	[lastname] [nvarchar](50) NOT NULL,
	[email] [varchar](50) NOT NULL,
 CONSTRAINT [PK_PrivateCustomers] PRIMARY KEY CLUSTERED 
(
	[customer_id] ASC
),
CONSTRAINT [unique_email] UNIQUE NONCLUSTERED 
(
	[email] ASC
)
) 
GO

ALTER TABLE [dbo].[PrivateCustomers]  WITH CHECK ADD  CONSTRAINT [FK_PrivateCustomers_Customers] FOREIGN KEY([customer_id])
REFERENCES [dbo].[Customers] ([customer_id])
GO
ALTER TABLE [dbo].[PrivateCustomers] CHECK CONSTRAINT [FK_PrivateCustomers_Customers]
GO
ALTER TABLE [dbo].[PrivateCustomers]  WITH CHECK ADD  CONSTRAINT [FK_PrivateCustomers_PermanentDiscounts] FOREIGN KEY([customer_id])
REFERENCES [dbo].[PermanentDiscounts] ([customer_id])
GO
ALTER TABLE [dbo].[PrivateCustomers] CHECK CONSTRAINT [FK_PrivateCustomers_PermanentDiscounts]
GO

--EMAIL
ALTER TABLE [dbo].[PrivateCustomers]  WITH CHECK ADD  CONSTRAINT [CK_email] CHECK  ([email] like '%@%[.]%')
GO
ALTER TABLE [dbo].[PrivateCustomers] CHECK CONSTRAINT [CK_email]
GO



CREATE TABLE [dbo].[PrivateReservations](
	[private_reservation_id] [int] NOT NULL,
	[customer_id] [int] NOT NULL,
	[order_id] [int] NOT NULL,
	[people_count] [int] NOT NULL,
	[start_time] [datetime] NOT NULL,
	[end_time] [datetime] NOT NULL,
	[table_id] [int] NULL,
 CONSTRAINT [PK_PrivateReservations] PRIMARY KEY CLUSTERED 
(
	[private_reservation_id] ASC
)
) 
GO

ALTER TABLE [dbo].[PrivateReservations]  WITH CHECK ADD  CONSTRAINT [FK_PrivateReservations_Orders] FOREIGN KEY([order_id])
REFERENCES [dbo].[Orders] ([order_id])
GO
ALTER TABLE [dbo].[PrivateReservations] CHECK CONSTRAINT [FK_PrivateReservations_Orders]
GO
ALTER TABLE [dbo].[PrivateReservations]  WITH CHECK ADD  CONSTRAINT [FK_PrivateReservations_PrivateCustomers] FOREIGN KEY([customer_id])
REFERENCES [dbo].[PrivateCustomers] ([customer_id])
GO
ALTER TABLE [dbo].[PrivateReservations] CHECK CONSTRAINT [FK_PrivateReservations_PrivateCustomers]
GO
ALTER TABLE [dbo].[PrivateReservations]  WITH CHECK ADD  CONSTRAINT [FK_PrivateReservations_Tables] FOREIGN KEY([table_id])
REFERENCES [dbo].[Tables] ([table_id])
GO
ALTER TABLE [dbo].[PrivateReservations] CHECK CONSTRAINT [FK_PrivateReservations_Tables]
GO

--DATE CHRONOLOGICAL
ALTER TABLE [dbo].[PrivateReservations]  WITH CHECK ADD  CONSTRAINT [CK_chronological_date] CHECK  ([end_time]>[start_time])
GO
ALTER TABLE [dbo].[PrivateReservations] CHECK CONSTRAINT [CK_chronological_date]
GO

--POSITIVE VALUE
ALTER TABLE [dbo].[PrivateReservations]  WITH CHECK ADD  CONSTRAINT [CK_positive] CHECK  ([people_count]>1)
GO
ALTER TABLE [dbo].[PrivateReservations] CHECK CONSTRAINT [CK_positive]
GO



CREATE TABLE [dbo].[ReservationParams](
	[param_id] [int] NOT NULL,
	[name] [varchar](20) NOT NULL,
	[value] [int] NOT NULL,
 CONSTRAINT [PK_ReservationParams] PRIMARY KEY CLUSTERED 
(
	[param_id] ASC
)
CONSTRAINT [unique_status] UNIQUE NONCLUSTERED 
(
	[name] ASC
)
) 
GO

--POSITIVE VALUE
ALTER TABLE [dbo].[ReservationParams]  WITH CHECK ADD  CONSTRAINT [CK_positive] CHECK  ([value]>0)
GO
ALTER TABLE [dbo].[ReservationParams] CHECK CONSTRAINT [CK_positive]
GO



CREATE TABLE [dbo].[ReservationsStatuses](
	[reservation_status_id] [int] NOT NULL,
	[status] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_ReservationsStatuses] PRIMARY KEY CLUSTERED 
(
	[reservation_status_id] ASC
),
CONSTRAINT [unique_status] UNIQUE NONCLUSTERED 
(
	[status] ASC
)
) 
GO



CREATE TABLE [dbo].[ReservationStatusHistory](
	[reservation_status_id] [int] NOT NULL,
	[reservation_id] [int] NOT NULL,
	[datetime] [datetime] NOT NULL DEFAULT GETDATE(),
 CONSTRAINT [PK_ReservationStatusHistory] PRIMARY KEY CLUSTERED 
(
	[reservation_status_id] ASC,
	[reservation_id] ASC
)
) 
GO

ALTER TABLE [dbo].[ReservationStatusHistory]  WITH CHECK ADD  CONSTRAINT [FK_ReservationStatusHistory_CompanyReservations1] FOREIGN KEY([reservation_id])
REFERENCES [dbo].[CompanyReservations] ([company_reservation_id])
GO
ALTER TABLE [dbo].[ReservationStatusHistory] CHECK CONSTRAINT [FK_ReservationStatusHistory_CompanyReservations1]
GO
ALTER TABLE [dbo].[ReservationStatusHistory]  WITH CHECK ADD  CONSTRAINT [FK_ReservationStatusHistory_PrivateReservations] FOREIGN KEY([reservation_id])
REFERENCES [dbo].[PrivateReservations] ([private_reservation_id])
GO
ALTER TABLE [dbo].[ReservationStatusHistory] CHECK CONSTRAINT [FK_ReservationStatusHistory_PrivateReservations]
GO
ALTER TABLE [dbo].[ReservationStatusHistory]  WITH CHECK ADD  CONSTRAINT [FK_ReservationStatusHistory_ReservationsStatuses] FOREIGN KEY([reservation_status_id])
REFERENCES [dbo].[ReservationsStatuses] ([reservation_status_id])
GO
ALTER TABLE [dbo].[ReservationStatusHistory] CHECK CONSTRAINT [FK_ReservationStatusHistory_ReservationsStatuses]
GO



CREATE TABLE [dbo].[Tables](
	[table_id] [int] NOT NULL,
	[seats] [int] NOT NULL,
	[is_active] [bit] NOT NULL,
 CONSTRAINT [PK_Tables] PRIMARY KEY CLUSTERED 
(
	[table_id] ASC
)
) 
GO

--POSITIVE VALUE
ALTER TABLE [dbo].[Tables]  WITH CHECK ADD  CONSTRAINT [CK_positive] CHECK  ([seats]>(0))
GO
ALTER TABLE [dbo].[Tables] CHECK CONSTRAINT [CK_positive]
GO



CREATE TABLE [dbo].[TemporaryDiscounts](
	[customer_id] [int] NOT NULL,
	[discount_id] [int] NOT NULL,
	[discount] [real] NOT NULL,
	[active_from] [datetime] NOT NULL,
	[active_to] [datetime] NOT NULL,
 CONSTRAINT [PK_TemporaryDiscounts] PRIMARY KEY CLUSTERED 
(
	[customer_id] ASC,
	[discount_id] ASC
)
) 
GO

ALTER TABLE [dbo].[TemporaryDiscounts]  WITH CHECK ADD  CONSTRAINT [FK_TemporaryDiscounts_DiscountParamHistory] FOREIGN KEY([discount_id])
REFERENCES [dbo].[DiscountParamHistory] ([discount_id])
GO
ALTER TABLE [dbo].[TemporaryDiscounts] CHECK CONSTRAINT [FK_TemporaryDiscounts_DiscountParamHistory]
GO
ALTER TABLE [dbo].[TemporaryDiscounts]  WITH CHECK ADD  CONSTRAINT [FK_TemporaryDiscounts_PrivateCustomers] FOREIGN KEY([customer_id])
REFERENCES [dbo].[PrivateCustomers] ([customer_id])
GO
ALTER TABLE [dbo].[TemporaryDiscounts] CHECK CONSTRAINT [FK_TemporaryDiscounts_PrivateCustomers]
GO

--REASONABLE DISCOUNT
ALTER TABLE [dbo].[TemporaryDiscounts]  WITH CHECK ADD  CONSTRAINT [CK_reasonable_discount] CHECK  (discount between 0 and 1 )
GO
ALTER TABLE [dbo].[TemporaryDiscounts] CHECK CONSTRAINT [CK_reasonable_discount]
GO

--DATE CHRONOLOGICAL
ALTER TABLE [dbo].[TemporaryDiscounts]  WITH CHECK ADD  CONSTRAINT [CK_chronological_date] CHECK  ([active_to]>[active_from])
GO
ALTER TABLE [dbo].[TemporaryDiscounts] CHECK CONSTRAINT [CK_chronological_date]
GO

