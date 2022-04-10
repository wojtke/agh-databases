CREATE FUNCTION [dbo].[CanCustomerGetPermanentDiscount](@CustomerID int)
RETURNS bit --returns whether customer get permanent discount on current conditions
AS
BEGIN
 IF dbo.GetCustomerType(@CustomerID) != 'private'
 BEGIN
   RETURN 0;
 END
  IF EXISTS (select customer_id from PermanentDiscounts where customer_id=@CustomerID)
  BEGIN
   RETURN 0;
  END
 DECLARE @RequiredOrderCount int = dbo.GetDiscountParamValue('Z1', GETDATE());
 DECLARE @RequiredAmountPerOrder int = dbo.GetDiscountParamValue('K1', GETDATE());

 IF @RequiredOrderCount <= (
	 SELECT count(*)
	 FROM Orders
	 WHERE 
		customer_id = @CustomerID
		and dbo.GetOrderTotalAmount(order_id) >= @RequiredAmountPerOrder
 )
 BEGIN
   RETURN 1;
 END
 RETURN 0;
END;


CREATE FUNCTION [dbo].[CanCustomerGetTemporaryDiscount](@CustomerID int)
RETURNS bit --returns whether customer get temporary discount on current conditions
AS
BEGIN
 IF dbo.GetCustomerType(@CustomerID) != 'private'
  BEGIN
   RETURN 0;
 END
 DECLARE @RequiredTotalAmount int = dbo.GetDiscountParamValue('K2', GETDATE());
 DECLARE @EndOfLastTemporaryDiscount datetime = 
 ISNULL((SELECT active_to FROM TemporaryDiscounts WHERE customer_id=@CustomerID), '1999-01-01')
 IF @RequiredTotalAmount <= (
   SELECT SUM(dbo.GetOrderTotalAmount(order_id))
   FROM 
	Orders
   WHERE 
	customer_id = @CustomerID
	and order_date >= @EndOfLastTemporaryDiscount
 )
 BEGIN
   RETURN 1;
 END
 RETURN 0;
END;


CREATE FUNCTION [dbo].[CanMakeReservation] (@CustomerID int, @OrderID int)
RETURNS bit
AS
BEGIN
	IF dbo.GetCustomerType(@CustomerID) = 'company'
	BEGIN
		RETURN 1;
	END

	DECLARE @MinOrderCount int = 
	(SELECT value from ReservationParams where param_id='WK')

	DECLARE @CustomersOrderCount int = 
	(SELECT count(*) from Orders where customer_id=@CustomerID)

	DECLARE @MinOrderTotal int = 
	(SELECT value from ReservationParams where param_id='WZ')

	DECLARE @OrderTotal int = 
	dbo.GetOrderTotalAmount(@OrderID)

	IF( @MinOrderCount<=@CustomersOrderCount and @MinOrderTotal<=@OrderTotal)
	BEGIN
		RETURN 1;
	END
	RETURN 0;
END;


CREATE FUNCTION [dbo].[GetAvailableTable](@Start datetime, @End datetime, @People int)
RETURNS int 
AS
BEGIN
	RETURN (
		SELECT TOP 1 table_id 
		FROM Tables 
		WHERE dbo.IsTableAvailable(table_id, @Start, @End)=1
			and seats>=@People
		ORDER BY seats asc
		)
END;


CREATE FUNCTION [dbo].[GetCustomersDiscount](@CustomerID int, @Date datetime)
RETURNS real --returns customers discount value for a given date - the highest available is chosen
AS
BEGIN
 
 DECLARE @PermanentDiscount real =
 ISNULL(
 (SELECT 
	discount
 FROM
	PermanentDiscounts
 WHERE
	customer_id = @CustomerID
	and (active_from <= @Date)
 ),
 0)
 DECLARE @TemporaryDiscount real =
 ISNULL(
 (SELECT 
	discount
 FROM
	TemporaryDiscounts
 WHERE
	customer_id = @CustomerID
	and (active_from <= @Date)
	and (active_to is null or active_to >= @Date)
 ),
 0)
 IF (@TemporaryDiscount >= @PermanentDiscount)
 BEGIN
	RETURN @TemporaryDiscount;
 END
 RETURN @PermanentDiscount;
END;


CREATE FUNCTION [dbo].[GetCustomerType](@CustomerID int)
RETURNS varchar(10) 
AS
BEGIN
 IF @CustomerID in (
	SELECT customer_id
	FROM PrivateCustomers
	)
 BEGIN
	RETURN 'private';
 END
  IF @CustomerID in (
	SELECT customer_id
	FROM CompanyCustomers
	)
 BEGIN
	RETURN 'company';
 END
 RETURN NULL;
END;


CREATE FUNCTION [dbo].[GetDiscountParamValue] (@ParamID varchar(10), @Date datetime NULL)
RETURNS int
AS
BEGIN
 IF(@Date is NULL)
 BEGIN
	SET @Date = GETDATE()
 END

 RETURN (
   SELECT Value
   FROM DiscountParamHistory
   WHERE param_id = @ParamID
     AND (active_to IS NULL OR active_to >= @Date)
	 AND (active_from <= @Date)
 )
END;


CREATE FUNCTION [dbo].[GetOrderStatus](@OrderID int)
RETURNS int 
AS
BEGIN
	RETURN (SELECT TOP 1 order_status_id FROM OrderStatusHistory 
	WHERE order_id=@OrderID ORDER BY datetime desc)
END;


CREATE FUNCTION [dbo].[GetOrderTotalAmount] (@OrderID int)
RETURNS money
AS
BEGIN
 RETURN (
   SELECT 
	SUM(od.quantity * pd.price * 
	(1-dbo.GetCustomersDiscount(o.customer_id, o.order_date)) 
	) AS TotalAmount
   FROM 
	   Orders o
	   INNER JOIN OrderDetails od ON o.order_id = od.order_id
	   INNER JOIN PlannedDishes pd ON pd.planned_dish_id = od.planned_dish_id
   WHERE o.order_id = @OrderID
 )
END;


CREATE FUNCTION [dbo].[GetReservationStatus](@ReservationID int, @IsCompany bit)
RETURNS int 
AS
BEGIN
	RETURN (SELECT TOP 1 reservation_status_id FROM ReservationStatusHistory 
	WHERE reservation_id=@ReservationID and is_company=@IsCompany ORDER BY datetime desc)
END;


CREATE FUNCTION [dbo].[IsMenuFresh] (@Date datetime)
RETURNS bit
AS
BEGIN
 DECLARE @ItemsOlderThan14Days int = (
	 SELECT count(dish_id)
	 FROM PlannedDishes
	 WHERE 
		(active_to>@Date or active_to is NULL)
		and DATEDIFF(DAY, @Date, active_from) >= 14
		and active_from<GETDATE()
 )
 DECLARE @MenuLength int = (
	 SELECT count(*)
	FROM PlannedDishes
	WHERE active_from < @Date and (active_to IS NULL OR active_to > @Date)
 )
 IF @MenuLength >= 2*@ItemsOlderThan14Days
 BEGIN
	RETURN 1
 END
 RETURN 0
END;


CREATE FUNCTION [dbo].[IsPlannedDishAvailable] (@PlannedDishID int, @Date datetime)
RETURNS bit
AS
BEGIN
	IF @PlannedDishID in (
		SELECT planned_dish_id
		FROM PlannedDishes
		WHERE active_from < @Date and (active_to IS NULL OR active_to > @Date)
	)
	BEGIN
		RETURN 1
	END
	RETURN 0
END;


CREATE FUNCTION [dbo].[IsSeafood] (@PlannedDishID int)
RETURNS bit
AS
BEGIN
	IF 'Seafood' = (SELECT c.name
	FROM 
		Dishes d
		inner join PlannedDishes pd on pd.dish_id=d.dish_id
		inner join Categories c on d.category_id = c.category_id
	WHERE planned_dish_id=@PlannedDishID)

	BEGIN
		RETURN 1;
	END
	RETURN 0;

END;


CREATE FUNCTION [dbo].[IsTableAvailable] (@TableID int, @Start datetime, @End datetime)
RETURNS bit
AS
BEGIN
 IF 0 = ISNULL((
	  SELECT is_active
	  FROM Tables
	  WHERE table_id = @TableID),
	  0)
  BEGIN
	RETURN 0;
  END
 DECLARE @HasPrivateReservation bit =
 ISNULL((SELECT 
	table_id
 FROM PrivateReservations
 WHERE 
	table_id=@TableID 
	and start_time between @Start and @End
	and end_time between @Start and @End
	and @Start between start_time and end_time),0)

 DECLARE @HasCompanyReservation bit =
 ISNULL((SELECT 
	table_id
 FROM
	CompanyReservationTables crt
	inner join CompanyReservationDetails crd on crd.reservation_details_id = crt.reservation_details_id
	inner join CompanyReservations cr on cr.company_reservation_id = crd.reservation_id
 WHERE 
	table_id=@TableID 
	and start_time between @Start and @End
	and end_time between @Start and @End
	and @Start between start_time and end_time),0)

	IF(@HasPrivateReservation=0 and @HasCompanyReservation=0)
	BEGIN
		RETURN 1;
	END
	RETURN 0;
END;
