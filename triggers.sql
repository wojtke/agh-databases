CREATE TRIGGER [dbo].[FullyDeleteCompanyReservationDetails]
ON [dbo].[CompanyReservationDetails]
INSTEAD OF DELETE
AS
BEGIN
	DECLARE @ReservationDetailsID int = (SELECT reservation_details_id FROM DELETED)

	DELETE FROM CompanyReservationEmployees WHERE reservation_details_id=@ReservationDetailsID
	DELETE FROM CompanyReservationTables WHERE reservation_details_id=@ReservationDetailsID
	DELETE FROM CompanyReservationDetails WHERE reservation_details_id =@ReservationDetailsID
END;


CREATE TRIGGER [dbo].[CheckCompanyReservationEmployeeAmount]
ON [dbo].[CompanyReservationEmployees]
AFTER INSERT
AS
BEGIN
 DECLARE @ReservationDetailsID int=(SELECT reservation_details_id FROM INSERTED);
 DECLARE @EmployeeCount int=(SELECT count(employee_customer_id) FROM CompanyReservationEmployees WHERE reservation_details_id=@ReservationDetailsID);
 DECLARE @PeopleCountInReservationDetails int=(SELECT people_count FROM CompanyReservationDetails WHERE reservation_details_id=@ReservationDetailsID);

 IF @EmployeeCount > @PeopleCountInReservationDetails
 BEGIN
   DECLARE @ErrorMsg nvarchar(100) = 'Cannot add more employees';
   RAISERROR(@ErrorMsg, 1, 1);
   ROLLBACK TRANSACTION
 END;
END;


CREATE TRIGGER [dbo].[CheckIfReservationCanBeModified]
ON [dbo].[CompanyReservationEmployees]
AFTER INSERT
AS
BEGIN
 DECLARE @ReservationDetailsID int=(SELECT reservation_details_id FROM INSERTED);

 	IF dbo.GetReservationStatus(
		(select reservation_id 
		from CompanyReservationDetails 
		where reservation_details_id=@ReservationDetailsID),
		1) > 1
	BEGIN
		   DECLARE @ErrorMsg nvarchar(100) = 'This reservation cannot be modified';
		   RAISERROR(@ErrorMsg, 1, 1);
		   ROLLBACK TRANSACTION
	END
END;


CREATE TRIGGER [dbo].[FullyDeleteCompanyReservation]
ON [dbo].[CompanyReservations]
INSTEAD OF DELETE
AS
BEGIN
	DECLARE @ReservationID int = (SELECT company_reservation_id FROM DELETED)

	DELETE FROM ReservationStatusHistory WHERE reservation_id=@ReservationID and is_company=1
	DELETE FROM CompanyReservationDetails WHERE reservation_id=@ReservationID
	DELETE FROM CompanyReservations WHERE company_reservation_id =@ReservationID
END;


CREATE TRIGGER [dbo].[FullyDeleteOrder]
ON [dbo].[Orders]
INSTEAD OF DELETE
AS
BEGIN
	DECLARE @OrderID int = (SELECT order_id FROM DELETED)

	DELETE FROM OrderDetails WHERE order_id = @OrderID
	DELETE FROM OrderStatusHistory WHERE order_id = @OrderID
	DELETE FROM PrivateReservations WHERE order_id = @OrderID
	DELETE FROM Orders WHERE order_id = @OrderID
END;


CREATE TRIGGER [dbo].[GrantDiscount]
ON [dbo].[Orders]
AFTER INSERT
AS
BEGIN
 DECLARE @CustomerID int=(SELECT customer_id FROM INSERTED);
 IF dbo.CanCustomerGetTemporaryDiscount(@CustomerID) = 1
 BEGIN
   EXEC GrantTemporaryDiscount @CustomerID
 END;
 IF dbo.CanCustomerGetPermanentDiscount(@CustomerID) = 1
 BEGIN
   EXEC GrantPermanentDiscount @CustomerID
 END;
END;


CREATE TRIGGER [dbo].[FullyDeletePrivateReservation]
ON [dbo].[PrivateReservations]
INSTEAD OF DELETE
AS
BEGIN
	DECLARE @ReservationID int = (SELECT private_reservation_id FROM DELETED)

	DELETE FROM ReservationStatusHistory WHERE reservation_id=@ReservationID and is_company=0
	DELETE FROM PrivateReservations WHERE private_reservation_id =@ReservationID
END;


CREATE TRIGGER [dbo].[CheckForReservationID]
ON [dbo].[ReservationStatusHistory]
AFTER INSERT
AS
BEGIN
	DECLARE @ReservationID int = (SELECT reservation_id from INSERTED)
	DECLARE @IsCompany int = (SELECT is_company from INSERTED)
 IF @IsCompany=1
 BEGIN
	IF NOT EXISTS (select * from CompanyReservations where company_reservation_id=@ReservationID)
	BEGIN
	    RAISERROR('Cannot find a corresponding reservation in CompanyReservations', 1, 1)
		ROLLBACK TRANSACTION
	END
 END
 IF @IsCompany=0
 BEGIN
	IF NOT EXISTS (select * from PrivateReservations where private_reservation_id=@ReservationID)
	BEGIN
	    RAISERROR('Cannot find a corresponding reservation in PrivateReservations', 1, 1)
		ROLLBACK TRANSACTION
	END
 END
END;
