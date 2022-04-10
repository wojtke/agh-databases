CREATE PROCEDURE [dbo].[AddCategory]
 @CategoryName nvarchar(50)
AS
BEGIN
	BEGIN TRY
		INSERT INTO Categories(name) 
		VALUES (@CategoryName);
   	END TRY
	BEGIN CATCH
		DECLARE @errorMsg1 nvarchar(1024) = 'Error while inserting to Categories: '
		+ ERROR_MESSAGE();
		THROW 52000, @errorMsg1, 1;
	END CATCH
END;


CREATE PROCEDURE [dbo].[AddCompany]
 @CompanyName varchar(30),
 @NIP varchar(15),
 @Email varchar(50),
 @Phone varchar(15),
 @Street nvarchar(50),
 @CityID int
AS
BEGIN
 BEGIN TRY
   INSERT INTO Customers (phone, street, city_id) VALUES (@Phone, @Street, @CityID);
   DECLARE @CustomerID int;
   SELECT @CustomerID = SCOPE_IDENTITY();
   INSERT INTO CompanyCustomers(customer_id, name, nip) VALUES (@CustomerID, @CompanyName, @NIP);
 END TRY
 BEGIN CATCH
   DELETE FROM Customers WHERE customer_id = @CustomerID
   DELETE FROM CompanyCustomers WHERE customer_id = @CustomerID
   DECLARE @errorMsg nvarchar(1024) = 'Error while inserting Company: '
   + ERROR_MESSAGE();
   THROW 52000, @errorMsg, 1;
 END CATCH;
END;


CREATE PROCEDURE [dbo].[AddDish]
 @Name nvarchar(50),
 @Category int,
 @Description text,
 @IsSeafood bit
AS
BEGIN
	BEGIN TRY
		INSERT INTO Dishes(name, category_id, description, seafood) 
		VALUES (@Name, @Category, @Description, @IsSeafood);
    END TRY
	BEGIN CATCH
		DECLARE @errorMsg1 nvarchar(1024) = 'Error while inserting to Dishes: '
		+ ERROR_MESSAGE();
		THROW 52000, @errorMsg1, 1;
    END CATCH
END;


CREATE PROCEDURE [dbo].[AddPrivateCustomer]
 @FirstName nvarchar(50),
 @LastName nvarchar(50),
 @Email varchar(50),
 @Phone varchar(15),
 @Street nvarchar(50),
 @CityID int
AS
BEGIN
 BEGIN TRY
   INSERT INTO Customers (phone, street, city_id) VALUES (@Phone, @Street, @CityID);
   DECLARE @CustomerID int;
   SELECT @CustomerID = SCOPE_IDENTITY();
 
   INSERT INTO PrivateCustomers(customer_id, firstname, lastname, email) VALUES (@CustomerID, @FirstName, @LastName, @Email);
 END TRY
 BEGIN CATCH
   DELETE FROM Customers WHERE customer_id = @CustomerID
   DELETE FROM PrivateCustomers WHERE customer_id = @CustomerID
   DECLARE @errorMsg nvarchar(1024) = 'Error while inserting Private Customer: '
   + ERROR_MESSAGE();
   THROW 52000, @errorMsg, 1;
 END CATCH;
END;


CREATE PROCEDURE [dbo].[AddEmployee]
 @FirstName nvarchar(50),
 @LastName nvarchar(50),
 @Email varchar(50),
 @ReportsTo int
AS
BEGIN
	BEGIN TRY
		INSERT INTO Employees(firstname, lastname, email, reports_to) 
		VALUES (@FirstName, @LastName, @Email, @ReportsTo);
	END TRY
	BEGIN CATCH
		DECLARE @errorMsg1 nvarchar(1024) = 'Error while inserting to Employees: '
		+ ERROR_MESSAGE();
		THROW 52000, @errorMsg1, 1;
	END CATCH
END;


CREATE PROCEDURE [dbo].[CompanyReservationAccept]
 @ReservationID int
AS
BEGIN
	IF dbo.GetReservationStatus(@ReservationID, 1) > 1
	BEGIN
		DECLARE @errorMsg3 nvarchar(1024) = 'Cannot accept a reservation that is already accepted';
		THROW 52000, @errorMsg3, 1;
	END

	IF 0 = (
		SELECT 
			MIN(ISNULL(crt.table_id, 0))
		FROM 
			CompanyReservationDetails crd
			left join CompanyReservationTables crt on crd.reservation_details_id = crt.reservation_details_id
		WHERE crd.reservation_id = @ReservationID
	)
	BEGIN
		DECLARE @errorMsg2 nvarchar(1024) = 'Reservation has details with unassigned tables';
		THROW 52000, @errorMsg2, 1;
	END

	BEGIN TRY
		INSERT INTO ReservationStatusHistory(reservation_id, is_company, reservation_status_id) 
		VALUES (@ReservationID, 1, 2)
   	END TRY
	BEGIN CATCH
		DECLARE @errorMsg1 nvarchar(1024) = 'Error while inserting into ReservationStatusHistory'
		+ ERROR_MESSAGE();
		THROW 52000, @errorMsg1, 1;
	END CATCH
END;


CREATE PROCEDURE [dbo].[CompanyReservationAddDetails]
 @ReservationID int,
 @PeopleCount int
AS
BEGIN
	IF (SELECT TOP 1 reservation_status_id FROM ReservationStatusHistory 
	WHERE reservation_id=@ReservationID and is_company=1 ORDER BY datetime desc) > 1
	BEGIN
		DECLARE @errorMsg2 nvarchar(1024) = 'Cannot add details to reservation that is accepted';
		THROW 52000, @errorMsg2, 1;
	END

	BEGIN TRY
		INSERT INTO CompanyReservationDetails(reservation_id, people_count) 
		VALUES (@ReservationID, @PeopleCount);
   	END TRY
	BEGIN CATCH
		DECLARE @errorMsg1 nvarchar(1024) = 'Error while inserting to CompanyReservationDetails: '
		+ ERROR_MESSAGE();
		THROW 52000, @errorMsg1, 1;
	END CATCH
END;


CREATE PROCEDURE [dbo].[CompanyReservationAddEmployee]
 @ReservationDetailsID int,
 @EmployeeCustomerID int
AS
BEGIN
	BEGIN TRY
		INSERT INTO CompanyReservationEmployees(reservation_details_id, employee_customer_id) 
		VALUES (@ReservationDetailsID, @EmployeeCustomerID);
   	END TRY
	BEGIN CATCH
		DECLARE @errorMsg1 nvarchar(1024) = 'Error while inserting to CompanyReservationEmployees: '
		+ ERROR_MESSAGE();
		THROW 52000, @errorMsg1, 1;
	END CATCH
END;


CREATE PROCEDURE [dbo].[CompanyReservationAssignTable]
 @ReservationDetailsID int,
 @TableID int
AS
BEGIN
	DECLARE @ReservationID int = (SELECT reservation_id FROM CompanyReservationDetails WHERE reservation_details_id=@ReservationDetailsID)
	DECLARE @Start datetime = (SELECT start_time FROM CompanyReservations WHERE company_reservation_id=@ReservationID)
	DECLARE @End datetime = (SELECT end_time FROM CompanyReservations WHERE company_reservation_id=@ReservationID)
	DECLARE @People int = (SELECT people_count FROM CompanyReservationDetails WHERE reservation_details_id=@ReservationDetailsID)

	IF dbo.IsTableAvailable(@TableID, @Start, @End)=0
	BEGIN
		DECLARE @errorMsg2 nvarchar(1024) = 'The table is not available';
		THROW 52000, @errorMsg2, 1;
	END

	IF (SELECT seats FROM Tables WHERE table_id=@TableID)<@People
	BEGIN
		DECLARE @errorMsg3 nvarchar(1024) = 'The table does not have enough seats';
		THROW 52000, @errorMsg3, 1;
	END

	BEGIN TRY
		INSERT INTO CompanyReservationTables(reservation_details_id, table_id) 
		VALUES (@ReservationDetailsID, @TableID);
   	END TRY
	BEGIN CATCH
		DECLARE @errorMsg1 nvarchar(1024) = 'Error while inserting to CompanyReservationDetails: '
		+ ERROR_MESSAGE();
		THROW 52000, @errorMsg1, 1;
	END CATCH
END;


CREATE PROCEDURE [dbo].[CompanyReservationPlace]
 @CustomerID int,
 @Start datetime,
 @HowManyHours int
AS
BEGIN
	IF dbo.GetCustomerType(@CustomerID)!='company'
	BEGIN
		DECLARE @errorMsg3 nvarchar(1024) = 'Only company customer can make a company reservation';
		THROW 52000, @errorMsg3, 1;
	END

	BEGIN TRY
		DECLARE @End datetime = DATEADD(HOUR, @HowManyHours, @Start)

		INSERT INTO CompanyReservations(customer_id, start_time, end_time) 
		VALUES (@CustomerID, @Start, @End)

		DECLARE @ReservationID int = SCOPE_IDENTITY();
		INSERT INTO ReservationStatusHistory(reservation_id, is_company, reservation_status_id) 
		VALUES (@ReservationID, 1, 1)
   	END TRY
	BEGIN CATCH
		DECLARE @errorMsg1 nvarchar(1024) = 'Error while inserting to CompanyReservations: '
		+ ERROR_MESSAGE();
		THROW 52000, @errorMsg1, 1;
	END CATCH
END;


CREATE PROCEDURE [dbo].[GrantPermanentDiscount]
 @CustomerID int
AS
BEGIN
 IF dbo.CanCustomerGetPermanentDiscount(@CustomerID) = 1
 BEGIN
   BEGIN TRY
     DECLARE @DiscountValue real = (SELECT value FROM DiscountParams WHERE param_id='R1')/100.0
     DECLARE @ActiveFrom datetime = GETDATE();
	 DECLARE @DiscountID int = (SELECT max(discount_id) FROM DiscountParamHistory)
 
     INSERT INTO PermanentDiscounts(customer_id, discount_id, discount, active_from)
     VALUES (
		 @CustomerID, 
		 @DiscountID,
		 @DiscountValue, 
		 @ActiveFrom
	 );
   END TRY
   BEGIN CATCH
     DECLARE @errorMsg1 nvarchar(1024) = 'Error while inserting to PermanentDiscounts: '
     + ERROR_MESSAGE();
     THROW 52000, @errorMsg1, 1;
   END CATCH
 END
 ELSE
 BEGIN
   DECLARE @errorMsg2 nvarchar(1024) = CONCAT('Customer ', @CustomerID, ' is not eligible for Permanent Discount');
   THROW 52000, @errorMsg2, 1;
 END
END;


CREATE PROCEDURE [dbo].[GrantTemporaryDiscount]
 @CustomerID int
AS
BEGIN
 IF dbo.CanCustomerGetTemporaryDiscount(@CustomerID) = 1
 BEGIN
   BEGIN TRY
     DECLARE @DiscountValue real = (SELECT value FROM DiscountParams WHERE param_id='R2')/100.0
     DECLARE @DiscountPeriod int = (SELECT value FROM DiscountParams WHERE param_id='D1')
     DECLARE @ActiveFrom datetime = GETDATE();
     DECLARE @ActiveTo datetime = DATEADD(DAY, @DiscountPeriod, @ActiveFrom);
	 DECLARE @DiscountID int = (SELECT max(discount_id) FROM DiscountParamHistory)
 
     INSERT INTO TemporaryDiscounts(customer_id, discount_id, discount, active_from, active_to)
     VALUES (
		 @CustomerID, 
		 @DiscountID,
		 @DiscountValue, 
		 @ActiveFrom, 
		 @ActiveTo
	 );
   END TRY
   BEGIN CATCH
     DECLARE @errorMsg1 nvarchar(1024) = 'Error while inserting to TemporaryDiscounts: '
     + ERROR_MESSAGE();
     THROW 52000, @errorMsg1, 1;
   END CATCH
 END
 ELSE
 BEGIN
   DECLARE @errorMsg2 nvarchar(1024) = CONCAT('Customer ', @CustomerID, ' is not eligible for Temporary Discount');
   THROW 52000, @errorMsg2, 1;
 END
END;


CREATE PROCEDURE [dbo].[OrderAccept]
 @OrderID int,
 @EmployeeID int
AS
BEGIN
	IF (SELECT TOP 1 order_status_id FROM OrderStatusHistory WHERE order_id=@OrderID ORDER BY datetime desc) > 1
	BEGIN
		DECLARE @errorMsg1 nvarchar(1024) = 'Cannot accept an Order that is accepted';
		THROW 52000, @errorMsg1, 1;
	END

	BEGIN TRY
		UPDATE Orders SET employee_id = @EmployeeID WHERE order_id=@OrderID
		INSERT INTO OrderStatusHistory(order_id, order_status_id) 
		VALUES (@OrderID, 2);
   	END TRY
	BEGIN CATCH
		DECLARE @errorMsg2 nvarchar(1024) = 'Error while accepting Order: '
		+ ERROR_MESSAGE();
		THROW 52000, @errorMsg1, 1;
	END CATCH
END;


CREATE PROCEDURE [dbo].[OrderAddDetails]
 @OrderID int,
 @PlannedDishID int,
 @Quantity int
AS
BEGIN
	IF dbo.GetOrderStatus(@OrderID) > 1
	BEGIN
		DECLARE @errorMsg1 nvarchar(1024) = 'Cannot add details to an Order that is accepted';
		THROW 52000, @errorMsg1, 1;
	END

	DECLARE @OrderDate datetime =(SELECT order_date FROM Orders WHERE order_id=@OrderID);
	IF dbo.IsPlannedDishAvailable(@PlannedDishID, @OrderDate)=0
	BEGIN
		DECLARE @errorMsg2 nvarchar(1024) = 'Item not on the current menu';
		THROW 52000, @errorMsg2, 1;
	END

	IF dbo.isSeafood(@PlannedDishID)=1
	BEGIN
     DECLARE @OrderTargetDate datetime = (SELECT target_date FROM Orders WHERE order_id=@OrderID);

     IF DATEPART(WEEKDAY, @OrderTargetDate) <5 OR DATEPART(WEEKDAY, @OrderTargetDate) >7
     BEGIN
       DECLARE @errorMsg3 nvarchar(1024) = 'Seafood can only be ordered for a day between Thursday and Saturday';
       THROW 52000, @errorMsg3, 1;
     END;

	 DECLARE @MondayDate datetime = DATEADD(DAY, -DATEPART(WEEKDAY, @OrderTargetDate)+2, @OrderTargetDate);
     IF (SELECT order_date FROM Orders WHERE order_id=@OrderID)>@MondayDate
     BEGIN
       DECLARE @errorMsg4 nvarchar(1024) = 'Seafood can only be ordered before Monday preceding order date';
       THROW 52000, @errorMsg4, 1;
     END;
   END;

	BEGIN TRY
		INSERT INTO OrderDetails(order_id, planned_dish_id, quantity) 
		VALUES (@OrderID, @PlannedDishID, @Quantity);
   	END TRY
	BEGIN CATCH
		DECLARE @errorMsg5 nvarchar(1024) = 'Error while inserting to OrderDetails: '
		+ ERROR_MESSAGE();
		THROW 52000, @errorMsg5, 1;
	END CATCH
END;


CREATE PROCEDURE [dbo].[OrderFull]
 @CustomerID int,
 @TargetDate datetime,
 @Values OrderDetailsList READONLY,
 @OUT int OUTPUT
AS
BEGIN
	BEGIN TRY
	 DECLARE @OrderID int;
     EXEC dbo.OrderPlace @CustomerID, @TargetDate, @OrderID OUTPUT;

   	 DECLARE OrderCursor CURSOR FOR SELECT planned_dish_id, quantity FROM @Values
   	 OPEN OrderCursor
   	 DECLARE @PlannedDishID int, @Quantity int
   	 FETCH NEXT FROM OrderCursor INTO @PlannedDishID, @Quantity
   	 WHILE @@FETCH_STATUS=0
   	 BEGIN
   		 EXEC dbo.OrderAddDetails @OrderID, @PlannedDishID, @Quantity
   		 FETCH NEXT FROM OrderCursor INTO @PlannedDishID, @Quantity
   	 END
   	 CLOSE OrderCursor
   	 DEALLOCATE OrderCursor

	 SELECT @OUT = @OrderID
   	END TRY
	BEGIN CATCH
		DELETE FROM Orders WHERE order_id=@OrderID

		DECLARE @errorMsg1 nvarchar(1024) = 'Error while ordering: '
		+ ERROR_MESSAGE();
		THROW 52000, @errorMsg1, 1;
	END CATCH
END;


CREATE PROCEDURE [dbo].[OrderPlace]
 @CustomerID int,
 @TargetDate datetime
AS
BEGIN
	BEGIN TRY
		INSERT INTO Orders(customer_id, order_date, target_date) 
		VALUES (@CustomerID, GETDATE(), @TargetDate);
		DECLARE @OrderID int = SCOPE_IDENTITY();

		INSERT INTO OrderStatusHistory(order_id, order_status_id) 
		VALUES (@OrderID, 1);
   	END TRY
	BEGIN CATCH
		DECLARE @errorMsg1 nvarchar(1024) = 'Error while inserting to Orders: '
		+ ERROR_MESSAGE();
		THROW 52000, @errorMsg1, 1;
	END CATCH
END;


CREATE PROCEDURE [dbo].[PlanDish]
 @DishID int,
 @Price money,
 @Start datetime,
 @End datetime
AS
BEGIN
   BEGIN TRY
	   INSERT INTO PlannedDishes(dish_id, price, active_from,  active_to) 
	   VALUES (@DishID, @Price, @Start, @End);
   END TRY
   BEGIN CATCH
     DECLARE @errorMsg1 nvarchar(1024) = 'Error while inserting to PlannedDishes: '
     + ERROR_MESSAGE();
     THROW 52000, @errorMsg1, 1;
   END CATCH
END;


CREATE PROCEDURE [dbo].[PrivateReservationAccept]
 @ReservationID int,
 @TableID int
AS
BEGIN
	IF dbo.GetReservationStatus(@ReservationID, 0) > 1
	BEGIN
		DECLARE @errorMsg3 nvarchar(1024) = 'Cannot accept a reservation that is already accepted';
		THROW 52000, @errorMsg3, 1;
	END

	DECLARE @Start datetime = (SELECT start_time FROM PrivateReservations WHERE private_reservation_id=@ReservationID)
	DECLARE @End datetime = (SELECT end_time FROM PrivateReservations WHERE private_reservation_id=@ReservationID)

	IF dbo.IsTableAvailable(@TableID, @Start, @End)=0
	BEGIN
		DECLARE @errorMsg2 nvarchar(1024) = 'The table is not available';
		THROW 52000, @errorMsg2, 1;
	END

	BEGIN TRY
		UPDATE PrivateReservations SET table_id = @TableID WHERE private_reservation_id=@ReservationID;
		INSERT INTO ReservationStatusHistory(reservation_id, is_company, reservation_status_id) 
		VALUES (@ReservationID, 0, 2)
   	END TRY
	BEGIN CATCH
		DECLARE @errorMsg1 nvarchar(1024) = 'Error while updating PrivateReservations'
		+ ERROR_MESSAGE();
		THROW 52000, @errorMsg1, 1;
	END CATCH
END;


CREATE PROCEDURE [dbo].[PrivateReservationAndOrder]
 @CustomerID int,
 @Values OrderDetailsList READONLY,
 @TargetDate datetime,
 @PeopleCount int,
 @HowManyHours int,
 @OUT int OUTPUT
AS
BEGIN
	BEGIN TRY
	 DECLARE @OrderID int;
     EXEC dbo.OrderFull @CustomerId, @TargetDate, @Values, @OrderID OUTPUT;

	 DECLARE @ReservationID int;
	 EXEC PrivateReservationPlace @OrderID, @PeopleCount, @HowManyHours, @ReservationID OUTPUT;

	 SELECT @OUT = @OrderID
   	END TRY
	BEGIN CATCH
		DELETE FROM Orders WHERE order_id=@OrderID

		DECLARE @errorMsg1 nvarchar(1024) = 'Error while placing order with reservation: '
		+ ERROR_MESSAGE();
		THROW 52000, @errorMsg1, 1;
	END CATCH
END;


CREATE PROCEDURE [dbo].[PrivateReservationPlace]
 @OrderID int,
 @PeopleCount int,
 @HowManyHours int
AS
BEGIN
	DECLARE @CustomerID int = (SELECT customer_id FROM Orders WHERE order_id=@OrderID)

	IF dbo.GetCustomerType(@CustomerID)!='private'
	BEGIN
		DECLARE @errorMsg3 nvarchar(1024) = 'Only private customer can make a private reservation';
		THROW 52000, @errorMsg3, 1;
	END

	IF dbo.CanMakeReservation(@CustomerID, @OrderID)=0
	BEGIN
		DECLARE @errorMsg2 nvarchar(1024) = 'Cannot make reservation - requirements not met';
		THROW 52000, @errorMsg2, 1;
	END

	BEGIN TRY
		DECLARE @OrderTargetDate datetime = (SELECT target_date FROM Orders WHERE order_id=@OrderID)
		DECLARE @EndTime datetime = DATEADD(HOUR, @HowManyHours, @OrderTargetDate)

		INSERT INTO PrivateReservations(customer_id, order_id, people_count, start_time, end_time) 
		VALUES (@CustomerID, @OrderID, @PeopleCount, @OrderTargetDate, @EndTime)

		DECLARE @ReservationID int = SCOPE_IDENTITY();
		INSERT INTO ReservationStatusHistory(reservation_id, is_company, reservation_status_id) 
		VALUES (@ReservationID, 0, 1)

   	END TRY
	BEGIN CATCH
		DECLARE @errorMsg1 nvarchar(1024) = 'Error while inserting to PrivateReservations: '
		+ ERROR_MESSAGE();
		THROW 52000, @errorMsg1, 1;
	END CATCH
END;


CREATE PROCEDURE [dbo].[UpdateDiscountParam]
 @ParamID varchar(10),
 @Value int
AS
BEGIN
 BEGIN TRY
   UPDATE DiscountParamHistory SET active_to=GETDATE() WHERE (active_to IS NULL) AND param_id=@ParamID;
   UPDATE DiscountParams SET value=@Value WHERE param_id=@ParamID;
   INSERT INTO DiscountParamHistory(param_id, value, active_from, active_to) VALUES (@ParamID, @Value, GETDATE(), NULL);
 END TRY
 BEGIN CATCH

   DECLARE @errorMsg2 nvarchar(1024) = 'Error while inserting Discount Param: '
   + ERROR_MESSAGE();
   THROW 52000, @errorMsg2, 1;
 END CATCH
END;
