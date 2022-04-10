CREATE NONCLUSTERED INDEX OrdersCustomerIDIndex ON Orders(customer_id);
CREATE NONCLUSTERED INDEX OrdersDatesIDIndex ON Orders(order_date, target_date);

CREATE NONCLUSTERED INDEX PrivateReservationsCustomerIDIndex ON PrivateReservations(customer_id);
CREATE NONCLUSTERED INDEX PrivateReservationsOrderIDIndex ON PrivateReservations(order_id);
CREATE NONCLUSTERED INDEX PrivateReservationsDatesIDIndex ON PrivateReservations(starts_at, ends_at);

CREATE NONCLUSTERED INDEX CompanyReservationsCompanyIDIndex] ON CompanyReservations(customer_id); 
CREATE NONCLUSTERED INDEX CompanyReservationsDatesIDIndex ON CompanyReservations(starts_at, ends_at);

CREATE UNIQUE NONCLUSTERED INDEX CompanyNIPIndex ON CompanyCustomers(nip);

CREATE UNIQUE NONCLUSTERED INDEX CategoriesIndex ON Categories(CategoryName);

CREATE NONCLUSTERED INDEX PlannedDishesDatesIDIndex ON PlannedDishes(active_from, active_to);
CREATE NONCLUSTERED INDEX PlannedDishDishIDIndex ON PlannedDishes(dish_id);

CREATE UNIQUE NONCLUSTERED INDEX PermanentDiscountsDateIndex ON PermanentDiscounts(active_from);

CREATE UNIQUE NONCLUSTERED INDEX TemporaryDiscountsDateIndex ON TemporaryDiscounts(active_from, active_to);
CREATE UNIQUE NONCLUSTERED INDEX TemporaryDiscountsCustomersIndex ON TemporaryDiscounts(customer_id);

CREATE UNIQUE NONCLUSTERED INDEX DiscountParamHistoryParamIDIndex ON DiscountParamHistorys(param_id);
CREATE UNIQUE NONCLUSTERED INDEX DiscountParamHistoryDateIndex ON DiscountParamHistorys(active_from, active_to);
