CREATE ROLE Admin AUTHORIZATION dbo
GRANT all to Admin


CREATE ROLE Employee AUTHORIZATION dbo 
GRANT EXECUTE ON AddCompany to Employee 
GRANT EXECUTE ON AddPrivateCustomer to Employee 
GRANT EXECUTE ON CompanyReservationAccept to Employee 
GRANT EXECUTE ON CompanyReservationAssignTable to Employee 
GRANT EXECUTE ON CompanyReservationPlaceto Employee 
GRANT EXECUTE ON PrivateReservationPlace to Employee
GRANT EXECUTE ON OrderAcceptto Employee
GRANT EXECUTE ON AddCategory to Employee 
GRANT EXECUTE ON AddNewCity to Employee 
GRANT EXECUTE ON addNewCountry to Employee 
GRANT EXECUTE ON PlaceOrder to Employee 
GRANT EXECUTE ON ChangeOrderStatus to Employee


CREATE ROLE Manager AUTHORIZATION dbo 
GRANT EXECUTE ON AddCompany to Manager
GRANT EXECUTE ON AddPrivateCustomer to Manager
GRANT EXECUTE ON CompanyReservationAccept to Manager
GRANT EXECUTE ON CompanyReservationAssignTable to Manager
GRANT EXECUTE ON CompanyReservationPlace to Manager
GRANT EXECUTE ON PrivateReservationPlace to Manager
GRANT EXECUTE ON OrderAcceptto Manager
GRANT EXECUTE ON PrivateReservationWithOrder to Manager
GRANT EXECUTE ON PrivateReservationPlace to Manager
GRANT EXECUTE ON AddCategory to Manager
GRANT EXECUTE ON PlanDish to Manager
GRANT EXECUTE ON AddNewCity to Manager
GRANT EXECUTE ON addNewCountry to Manager
GRANT EXECUTE ON PlaceOrder to Manager
GRANT EXECUTE ON ChangeOrderStatus to Manager


CREATE ROLE CompanyCustomer AUTHORIZATION dbo
GRANT EXECUTE ON CompanyReservationPlace to CompanyCustomer 
GRANT EXECUTE ON CompanyReservationAddDetails to CompanyCustomer 
GRANT EXECUTE ON CompanyReservationAddEmployees to CompanyCustomer 
GRANT EXECUTE ON OrderFull to CompanyCustomer 

GRANT SELECT ON CurrentMenuView to CompanyCustomer 


CREATE ROLE PrivateCustomer AUTHORIZATION dbo
GRANT EXECUTE ON PrivateReservationAndOrder to PrivateCustomer 
GRANT EXECUTE ON OrderFull to PrivateCustomer 

GRANT SELECT ON CurrentMenuView to CompanyCustomer 
