-- CS4400: Introduction to Database Systems (Fall 2022)
-- Project Phase III: Stored Procedures SHELL [v2] Wednesday, November 30, 2022
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;

use restaurant_db;
-- -----------------------------------------------------------------------------
-- stored procedures and views
-- -----------------------------------------------------------------------------
/* Standard Procedure: If one or more of the necessary conditions for a procedure to
be executed is false, then simply have the procedure halt execution without changing
the database state. Do NOT display any error messages, etc. */
drop procedure if exists test_proc;
delimiter //
create procedure test_proc()
sp_main: begin
	SELECT username FROM employees;
end //
delimiter ;

-- [1] add_owner()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new owner.  A new owner must have a unique
username.  Also, the new owner is not allowed to be an employee. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_owner;
delimiter //
create procedure add_owner (in ip_username varchar(40), in ip_first_name varchar(100),
	in ip_last_name varchar(100), in ip_address varchar(500), in ip_birthdate date)
sp_main: begin
    -- ensure new owner has a unique username
    IF (ip_username is NULL or ip_first_name is NULL or ip_last_name is NULL or ip_address is NULL or ip_birthdate is NULL) THEN LEAVE sp_main; END IF;
    insert ignore into users values (ip_username, ip_first_name, ip_last_name, ip_address, ip_birthdate);
    insert ignore into restaurant_owners values (ip_username);
end //
delimiter ;

-- [2] add_employee()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new employee without any designated pilot or
worker roles.  A new employee must have a unique username unique tax identifier. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_employee;
delimiter //
create procedure add_employee (in ip_username varchar(40), in ip_first_name varchar(100),
	in ip_last_name varchar(100), in ip_address varchar(500), in ip_birthdate date,
    in ip_taxID varchar(40), in ip_hired date, in ip_employee_experience integer,
    in ip_salary integer)
sp_main: begin
    -- ensure new owner has a unique username
    -- ensure new employee has a unique tax identifier
    IF (ip_username is NULL or ip_first_name is NULL or ip_last_name is NULL or ip_address is NULL or ip_birthdate is NULL) THEN LEAVE sp_main; END IF;
	IF (ip_taxID is NULL or ip_hired is NULL or ip_employee_experience is NULL or ip_salary is NULL) THEN LEAVE sp_main; END IF;
	insert ignore into users values (ip_username, ip_first_name, ip_last_name, ip_address, ip_birthdate);
    insert ignore into employees values (ip_username, ip_taxID, ip_hired, ip_employee_experience, ip_salary);
end //
delimiter ;

-- [3] add_pilot_role()
-- -----------------------------------------------------------------------------
/* This stored procedure adds the pilot role to an existing employee.  The
employee/new pilot must have a unique license identifier. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_pilot_role;
delimiter //
create procedure add_pilot_role (in ip_username varchar(40), in ip_licenseID varchar(40),
	in ip_pilot_experience integer)
sp_main: begin
    -- ensure new employee exists
    -- ensure new pilot has a unique license identifier
    IF (ip_licenseID is NULL or ip_pilot_experience is NULL) THEN LEAVE sp_main; END IF;
    IF ip_username NOT IN (SELECT username from employees) THEN LEAVE sp_main; END IF;
    INSERT IGNORE INTO pilots VALUES (ip_username, ip_licenseID, ip_pilot_experience);
end //
delimiter ;

-- [4] add_worker_role()
-- -----------------------------------------------------------------------------
/* This stored procedure adds the worker role to an existing employee. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_worker_role;
delimiter //
create procedure add_worker_role (in ip_username varchar(40))
sp_main: begin
    -- ensure new employee exists
	IF ip_username NOT IN (SELECT username from employees) THEN LEAVE sp_main; END IF;
    INSERT IGNORE INTO workers VALUES (ip_username);
end //
delimiter ;

-- [5] add_ingredient()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new ingredient.  A new ingredient must have a
unique barcode. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_ingredient;
delimiter //
create procedure add_ingredient (in ip_barcode varchar(40), in ip_iname varchar(100),
	in ip_weight integer)
sp_main: begin
	-- ensure new ingredient doesn't already exist
    IF (ip_barcode is NULL or ip_iname is NULL or ip_weight is NULL) THEN LEAVE sp_main; END IF;
    INSERT IGNORE INTO ingredients VALUES (ip_barcode, ip_iname, ip_weight);
end //
delimiter ;

-- [6] add_drone()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new drone.  A new drone must be assigned 
to a valid delivery service and must have a unique tag.  Also, it must be flown
by a valid pilot initially (i.e., pilot works for the same service), but the pilot
can switch the drone to working as part of a swarm later. And the drone's starting
location will always be the delivery service's home base by default. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_drone;
delimiter //
create procedure add_drone (in ip_id varchar(40), in ip_tag integer, in ip_fuel integer,
	in ip_capacity integer, in ip_sales integer, in ip_flown_by varchar(40))
sp_main: begin
	-- ensure new drone doesn't already exist
    -- ensure that the delivery service exists
    -- ensure that a valid pilot will control the drone
    IF (ip_tag is NULL or ip_fuel is NULL or ip_capacity is NULL or ip_sales is NULL) THEN LEAVE sp_main; END IF;
    IF ip_id NOT IN (SELECT id from delivery_services) THEN LEAVE sp_main; END IF;
    IF ip_flown_by NOT IN (SELECT username from pilots) THEN LEAVE sp_main; END IF;
    IF ip_flown_by NOT IN (SELECT username from work_for where id = ip_id) THEN LEAVE sp_main; END IF;
    INSERT IGNORE INTO drones VALUES (ip_id, ip_tag, ip_fuel, ip_capacity, ip_sales, ip_flown_by, NULL, NULL, (SELECT home_base from delivery_services where ip_id = id));
end //
delimiter ;

-- [7] add_restaurant()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new restaurant.  A new restaurant must have a
unique (long) name and must exist at a valid location, and have a valid rating.
And a resturant is initially "independent" (i.e., no owner), but will be assigned
an owner later for funding purposes. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_restaurant;
delimiter //
create procedure add_restaurant (in ip_long_name varchar(40), in ip_rating integer,
	in ip_spent integer, in ip_location varchar(40))
sp_main: begin
	-- ensure new restaurant doesn't already exist
    -- ensure that the location is valid
    -- ensure that the rating is valid (i.e., between 1 and 5 inclusively)
    IF (ip_rating is NULL or ip_spent is NULL) THEN LEAVE sp_main; END IF;
    IF ip_location NOT IN (SELECT label FROM locations) THEN LEAVE sp_main; END IF;
	IF ip_rating NOT BETWEEN 1 AND 5 THEN LEAVE sp_main; END IF;
    INSERT IGNORE INTO restaurants VALUES (ip_long_name, ip_rating, ip_spent, ip_location, NULL);
end //
delimiter ;

-- [8] add_service()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new delivery service.  A new service must have
a unique identifier, along with a valid home base and manager. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_service;
delimiter //
create procedure add_service (in ip_id varchar(40), in ip_long_name varchar(100),
	in ip_home_base varchar(40), in ip_manager varchar(40))
sp_main: begin
	-- ensure new delivery service doesn't already exist
    -- ensure that the home base location is valid
    -- ensure that the manager is valid
    IF (ip_id is NULL or ip_long_name is NULL or ip_home_base is NULL or ip_manager is NULL) THEN LEAVE sp_main; END IF;
    IF ip_home_base NOT IN (SELECT label FROM locations) THEN LEAVE sp_main; END IF;
    IF ip_manager NOT IN (SELECT username FROM workers) THEN LEAVE sp_main; END IF;
    IF ip_manager IN (SELECT manager FROM delivery_services) THEN LEAVE sp_main; END IF;
    INSERT IGNORE INTO delivery_services VALUES (ip_id, ip_long_name, ip_home_base, ip_manager);
end //
delimiter ;

-- [9] add_location()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new location that becomes a new valid drone
destination.  A new location must have a unique combination of coordinates.  We
could allow for "aliased locations", but this might cause more confusion that
it's worth for our relatively simple system. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_location;
delimiter //
create procedure add_location (in ip_label varchar(40), in ip_x_coord integer,
	in ip_y_coord integer, in ip_space integer)
sp_main: begin
	-- ensure new location doesn't already exist
    -- ensure that the coordinate combination is distinct
    IF (ip_label is NULL or ip_x_coord is NULL or ip_y_coord is NULL or ip_space is NULL) THEN LEAVE sp_main; END IF;
    IF ip_x_coord IN (SELECT x_coord FROM locations WHERE ip_y_coord = y_coord) THEN LEAVE sp_main; END IF;
    INSERT IGNORE INTO locations VALUES (ip_label, ip_x_coord, ip_y_coord, ip_space);
end //
delimiter ;

-- [10] start_funding()
-- -----------------------------------------------------------------------------
/* This stored procedure opens a channel for a restaurant owner to provide funds
to a restaurant. If a different owner is already providing funds, then the current
owner is replaced with the new owner.  The owner and restaurant must be valid. */
-- -----------------------------------------------------------------------------
drop procedure if exists start_funding;
delimiter //
create procedure start_funding (in ip_owner varchar(40), in ip_long_name varchar(40))
sp_main: begin
	-- ensure the owner and restaurant are valid
    IF (ip_owner is NULL or ip_long_name is NULL) THEN LEAVE sp_main; END IF;
	IF ip_owner NOT IN (SELECT username FROM restaurant_owners) THEN LEAVE sp_main; END IF;
    IF ip_long_name NOT IN (SELECT long_name FROM restaurants) THEN LEAVE sp_main; END IF;
    UPDATE restaurants
    SET funded_by = ip_owner
    WHERE ip_long_name = long_name;
end //
delimiter ;

-- [11] hire_employee()
-- -----------------------------------------------------------------------------
/* This stored procedure hires an employee to work for a delivery service.
Employees can be combinations of workers and pilots. If an employee is actively
controlling drones or serving as manager for a different service, then they are
not eligible to be hired.  Otherwise, the hiring is permitted. */
-- -----------------------------------------------------------------------------
drop procedure if exists hire_employee;
delimiter //
create procedure hire_employee (in ip_username varchar(40), in ip_id varchar(40))
sp_main: begin
	-- ensure that the employee hasn't already been hired
    -- ensure that the employee and delivery service are valid
    IF (ip_username is NULL or ip_id is NULL) THEN LEAVE sp_main; END IF;
    IF ip_username NOT IN (SELECT username FROM employees) THEN LEAVE sp_main; END IF;
    IF ip_username IN (SELECT username FROM work_for where ip_id = id) THEN LEAVE sp_main; END IF;
    IF ip_id NOT IN (SELECT id FROM delivery_services) THEN LEAVE sp_main; END IF;
    -- ensure that the employee isn't a manager for another service
    IF ip_username IN (select manager FROM delivery_services) THEN LEAVE sp_main; END IF;
	-- ensure that the employee isn't actively controlling drones for another service
    IF ip_username IN (select flown_by FROM drones WHERE id <> ip_id) THEN LEAVE sp_main; END IF;
    INSERT IGNORE INTO work_for VALUES (ip_username, ip_id);
end //
delimiter ;

-- [12] fire_employee()
-- -----------------------------------------------------------------------------
/* This stored procedure fires an employee who is currently working for a delivery
service.  The only restrictions are that the employee must not be: [1] actively
controlling one or more drones; or, [2] serving as a manager for the service.
Otherwise, the firing is permitted. */
-- -----------------------------------------------------------------------------
drop procedure if exists fire_employee;
delimiter //
create procedure fire_employee (in ip_username varchar(40), in ip_id varchar(40))
sp_main: begin
	-- ensure that the employee is currently working for the service
    -- ensure that the employee isn't an active manager
	-- ensure that the employee isn't controlling any drones
    IF (ip_username is NULL or ip_id is NULL) THEN LEAVE sp_main; END IF;
    IF ip_username IN (select manager FROM delivery_services) THEN LEAVE sp_main; END IF;
    IF ip_username IN (SELECT flown_by FROM drones) THEN LEAVE sp_main; END IF;
    DELETE FROM work_for WHERE ip_username = username AND ip_id = id;    
end //
delimiter ;

-- [13] manage_service()
-- -----------------------------------------------------------------------------
/* This stored procedure appoints an employee who is currently hired by a delivery
service as the new manager for that service.  The only restrictions are that: [1]
the employee must not be working for any other delivery service; and, [2] the
employee can't be flying drones at the time.  Otherwise, the appointment to manager
is permitted.  The current manager is simply replaced.  And the employee must be
granted the worker role if they don't have it already. */
-- -----------------------------------------------------------------------------
drop procedure if exists manage_service;
delimiter //
create procedure manage_service (in ip_username varchar(40), in ip_id varchar(40))
sp_main: begin
	IF (ip_username is NULL or ip_id is NULL) THEN LEAVE sp_main; END IF;
	-- ensure that the employee is currently working for the service
    IF ip_username NOT IN (SELECT username from work_for WHERE ip_id = id) THEN LEAVE sp_main; END IF;
	-- ensure that the employee is not flying any drones
    IF ip_username IN (SELECT flown_by FROM drones) THEN LEAVE sp_main; END IF;
    -- ensure that the employee isn't working for any other services
    IF ip_username IN (SELECT username from work_for WHERE ip_id <> id) THEN LEAVE sp_main; END IF;
    -- add the worker role if necessary
    UPDATE delivery_services
    SET manager = ip_username
    WHERE id = ip_id;
    INSERT IGNORE INTO workers VALUES (ip_username);
end //
delimiter ;

-- [14] takeover_drone()
-- -----------------------------------------------------------------------------
/* This stored procedure allows a valid pilot to take control of a lead drone owned
by the same delivery service, whether it's a "lone drone" or the leader of a swarm.
The current controller of the drone is simply relieved of those duties. And this
should only be executed if a "leader drone" is selected. */
-- -----------------------------------------------------------------------------
drop procedure if exists takeover_drone;
delimiter //
create procedure takeover_drone (in ip_username varchar(40), in ip_id varchar(40),
	in ip_tag integer)
sp_main: begin
	IF (ip_username is NULL or ip_id is NULL or ip_tag is NULL) THEN LEAVE sp_main; END IF;
	-- ensure that the employee is currently working for the service
    IF ip_username NOT IN (SELECT username from work_for WHERE ip_id = id) THEN LEAVE sp_main; END IF;
	-- ensure that the selected drone is owned by the same service and is a leader and not follower
    IF ip_tag NOT IN (SELECT tag from drones where id = ip_id) THEN LEAVE sp_main; END IF;
    IF ip_tag NOT IN (SELECT swarm_tag from drones where id = swarm_id) THEN LEAVE sp_main; END IF;
	-- ensure that the employee isn't a manager
    IF ip_username IN (SELECT manager FROM delivery_services) THEN LEAVE sp_main; END IF;
    -- ensure that the employee is a valid pilot
    IF ip_username NOT IN (SELECT username FROM pilots) THEN LEAVE sp_main; END IF;
    UPDATE drones
    SET flown_by = ip_username
    WHERE tag = ip_tag AND id = ip_id;
end //
delimiter ;

-- [15] join_swarm()
-- -----------------------------------------------------------------------------
/* This stored procedure takes a drone that is currently being directly controlled
by a pilot and has it join a swarm (i.e., group of drones) led by a different
directly controlled drone. A drone that is joining a swarm connot be leading a
different swarm at this time.  Also, the drones must be at the same location, but
they can be controlled by different pilots. */
-- -----------------------------------------------------------------------------
drop procedure if exists join_swarm;
delimiter //
create procedure join_swarm (in ip_id varchar(40), in ip_tag integer,
	in ip_swarm_leader_tag integer)
sp_main: begin
	-- ensure that the swarm leader is a different drone
    IF ip_swarm_leader_tag = ip_tag THEN LEAVE sp_main; END IF;
    -- ensure that the drone joining the swarm is valid and owned by the service (review)
    IF (select count(*) from drones where id = ip_id and tag = ip_tag) <> 1 THEN LEAVE sp_main; END IF;
    -- ensure that the drone joining the swarm is not already leading a swarm
    IF (select count(*) from drones where id = ip_id and swarm_tag = ip_tag) <> 0 THEN LEAVE sp_main; END IF;
    -- ensure that the swarm leader drone is directly controlled
    IF (select count(*) from drones where id = ip_id and tag = ip_swarm_leader_tag and flown_by IS NOT NULL) <> 1 THEN LEAVE sp_main; END IF;
    -- ensure that the drones are at the same location
	IF (select hover from drones where id = ip_id and tag = ip_tag) <> (select hover from drones where id = ip_id and tag = ip_swarm_leader_tag) THEN LEAVE sp_main; END IF;
    
	UPDATE drones
	SET flown_by = NULL, swarm_id = ip_id, swarm_tag = ip_swarm_leader_tag
	where id = ip_id and tag = ip_tag;
end //
delimiter ;

-- [16] leave_swarm()
-- -----------------------------------------------------------------------------
/* This stored procedure takes a drone that is currently in a swarm and returns
it to being directly controlled by the same pilot who's controlling the swarm. */
-- -----------------------------------------------------------------------------
drop procedure if exists leave_swarm;
delimiter //
create procedure leave_swarm (in ip_id varchar(40), in ip_swarm_tag integer)
sp_main: begin
	-- ensure that the selected drone is owned by the service and flying in a swarm
	declare pilot varchar(40);
	declare swarmID varchar(40);
    declare swarmTag int;
	if (select count(*) from drones where id = ip_id and tag = ip_swarm_tag and swarm_tag IS NOT NULL and swarm_id IS NOT NULL) = 0 then leave sp_main; end if;
    select swarm_tag into swarmTag from drones where id = ip_id and tag = ip_swarm_tag;
    select swarm_id into swarmID from drones where id = ip_id and tag = ip_swarm_tag;
    select flown_by into pilot from drones where tag = swarmTag and id = swarmID;
    
	UPDATE drones
    SET flown_by = pilot, swarm_id = NULL, swarm_tag = NULL
    WHERE id = ip_id and tag = ip_swarm_tag;
end //
delimiter ;
delimiter ;

-- [17] load_drone()
-- -----------------------------------------------------------------------------
/* This stored procedure allows us to add some quantity of fixed-size packages of
a specific ingredient to a drone's payload so that we can sell them for some
specific price to other restaurants.  The drone can only be loaded if it's located
at its delivery service's home base, and the drone must have enough capacity to
carry the increased number of items.

The change/delta quantity value must be positive, and must be added to the quantity
of the ingredient already loaded onto the drone as applicable.  And if the ingredient
already exists on the drone, then the existing price must not be changed. */
-- -----------------------------------------------------------------------------
drop procedure if exists load_drone;
delimiter //
create procedure load_drone (in ip_id varchar(40), in ip_tag integer, in ip_barcode varchar(40),
	in ip_more_packages integer, in ip_price integer)
sp_main: begin
    declare q varchar(40);
	-- ensure that the drone being loaded is owned by the service
    IF (select id from delivery_services where id = ip_id) <> (select id from drones where id = ip_id and tag = ip_tag) THEN LEAVE sp_main; END IF;
	-- ensure that the ingredient is valid
    IF (select barcode from ingredients where barcode = ip_barcode) IS NULL THEN LEAVE sp_main; END IF;
    -- ensure that the drone is located at the service home base
	IF (select home_base from delivery_services where id = ip_id) <> (select hover from drones where id = ip_id and tag = ip_tag) THEN LEAVE sp_main; END IF;
	-- ensure that the quantity of new packages is greater than zero
    IF (ip_more_packages <= 0) THEN LEAVE sp_main; END IF;
	-- ensure that the drone has sufficient capacity to carry the new packages
    IF (select capacity from drones where id = ip_id and tag = ip_tag) < (select sum(quantity) from payload where id = ip_id and tag = ip_tag) + ip_more_packages THEN LEAVE sp_main; END IF;
    -- add more of the ingredient to the drone
    IF ip_barcode NOT IN (select barcode from payload where id = ip_id and tag = ip_tag) THEN INSERT into payload values (ip_id, ip_tag, ip_barcode, 0, ip_price); END IF;
    select quantity into q from payload where id = ip_id and tag = ip_tag and barcode = ip_barcode;
	UPDATE payload
	SET quantity = q + ip_more_packages
	where id = ip_id and tag = ip_tag and barcode = ip_barcode;
end //
delimiter ;

-- [18] refuel_drone()
-- -----------------------------------------------------------------------------
/* This stored procedure allows us to add more fuel to a drone. The drone can only
be refueled if it's located at the delivery service's home base. */
-- -----------------------------------------------------------------------------
drop procedure if exists refuel_drone;
delimiter //
create procedure refuel_drone (in ip_id varchar(40), in ip_tag integer, in ip_more_fuel integer)
sp_main: begin
	declare serviceLocation varchar(40);
    declare currentFuel int;
	-- ensure that the drone being switched is valid and owned by the service
    IF (select count(*) from drones where id = ip_id and tag = ip_tag) = 0 THEN LEAVE sp_main; END IF;
    -- ensure that the drone is located at the service home base
	select home_base into serviceLocation from delivery_services where id = ip_id;
    IF (select hover from drones where id = ip_id and tag = ip_tag) != serviceLocation THEN LEAVE sp_main; END IF;
    select fuel into currentFuel from drones where id = ip_id and tag = ip_tag;
    
    UPDATE drones
    SET fuel = currentFuel + ip_more_fuel
    WHERE id = ip_id and tag = ip_tag;
end //
delimiter ;

-- [19] fly_drone()
-- -----------------------------------------------------------------------------
/* This stored procedure allows us to move a single or swarm of drones to a new
location (i.e., destination). The main constraints on the drone(s) being able to
move to a new location are fuel and space.  A drone can only move to a destination
if it has enough fuel to reach the destination and still move from the destination
back to home base.  And a drone can only move to a destination if there's enough
space remaining at the destination.  For swarms, the flight directions will always
be given to the lead drone, but the swarm must always stay together. */
-- -----------------------------------------------------------------------------
drop function if exists fuel_required;
delimiter //
create function fuel_required (ip_departure varchar(40), ip_arrival varchar(40))
	returns integer reads sql data
begin
	if (ip_departure = ip_arrival) then return 0;
    else return (select 1 + truncate(sqrt(power(arrival.x_coord - departure.x_coord, 2) + power(arrival.y_coord - departure.y_coord, 2)), 0) as fuel
		from (select x_coord, y_coord from locations where label = ip_departure) as departure,
        (select x_coord, y_coord from locations where label = ip_arrival) as arrival);
	end if;
end //
delimiter ;

drop procedure if exists fly_drone;
delimiter //
create procedure fly_drone (in ip_id varchar(40), in ip_tag integer, in ip_destination varchar(40))
sp_main: begin
	-- ensure that the lead drone being flown is directly controlled and owned by the service
    -- ensure that the destination is a valid location
    -- ensure that the drone isn't already at the location
    -- ensure that the drone/swarm has enough fuel to reach the destination and (then) home base
    -- ensure that the drone/swarm has enough space at the destination for the flight
    declare currentLocation varchar(40);
    declare minimumFuel int;
    declare requiredFuel int;
    declare newRequiredFuel int;
    declare numDrones int;
    declare currentSpace int;
    
    IF (select count(*) from drones where id = ip_id and tag = ip_tag) = 0 THEN LEAVE sp_main; END IF;
    
    IF (select flown_by from drones where id = ip_id and tag = ip_tag) is NULL THEN LEAVE sp_main; END IF;
    
    IF (select count(*) from locations where label = ip_destination) = 0 THEN LEAVE sp_main; END IF;
    
    IF (select hover from drones where id = ip_id and tag = ip_tag) = ip_destination THEN LEAVE sp_main; END IF;
    
	select hover into currentLocation from drones where id = ip_id and tag = ip_tag;
	select min(fuel) into minimumFuel from drones where (swarm_id = ip_id and swarm_tag = ip_tag) or (id = ip_id and tag = ip_tag);
	SET requiredFuel = fuel_required(currentLocation, ip_destination);
	SET newRequiredFuel = requiredFuel + fuel_required(ip_destination, (select home_base from delivery_services where id = ip_id));
	IF (minimumFuel < newRequiredFuel) THEN LEAVE sp_main; END IF;

	select count(*) into numDrones from drones where (swarm_id = ip_id and swarm_tag = ip_tag) or (id = ip_id and tag = ip_tag);
	IF (select space from locations where label = ip_destination) < numDrones THEN LEAVE sp_main; END IF;
	select space into currentSpace from locations where label = ip_destination;

	UPDATE locations
	SET space = currentSpace - numDrones
	WHERE label = ip_destination;

	UPDATE drones
	SET hover = ip_destination, fuel = fuel - requiredFuel
	WHERE (swarm_id = ip_id and swarm_tag = ip_tag) or (id = ip_id and tag = ip_tag);
        
end //
delimiter ;

-- [20] purchase_ingredient()
-- -----------------------------------------------------------------------------
/* This stored procedure allows a restaurant to purchase ingredients from a drone
at its current location.  The drone must have the desired quantity of the ingredient
being purchased.  And the restaurant must have enough money to purchase the
ingredients.  If the transaction is otherwise valid, then the drone and restaurant
information must be changed appropriately.  Finally, we need to ensure that all
quantities in the payload table (post transaction) are greater than zero. */
-- -----------------------------------------------------------------------------
drop procedure if exists purchase_ingredient;
delimiter //
create procedure purchase_ingredient (in ip_long_name varchar(40), in ip_id varchar(40),
	in ip_tag integer, in ip_barcode varchar(40), in ip_quantity integer)
sp_main: begin
	declare loc varchar(40);
	declare q int;
	declare ingredientPrice int;
	declare moneySpent int;
	declare moneyMade int;

	-- ensure that the restaurant is valid
	IF (select count(*) from restaurants where long_name = ip_long_name) = 0 THEN LEAVE sp_main; END IF;
    
	-- ensure that the drone is valid and exists at the resturant's location
	IF (select count(*) from drones where id = ip_id and tag = ip_tag) = 0 THEN LEAVE sp_main; END IF;
	select location into loc from restaurants where long_name = ip_long_name;
	IF (select hover from drones where id = ip_id and tag = ip_tag) != loc THEN LEAVE sp_main; END IF;
    
	-- ensure that the drone has enough of the requested ingredient
	select quantity into q from payload where id = ip_id and tag = ip_tag and barcode = ip_barcode;
	IF q < ip_quantity THEN LEAVE sp_main; END IF;
    
	-- update the drone's payload
    UPDATE payload
    SET quantity = q - ip_quantity
    WHERE id = ip_id and tag = ip_tag and barcode = ip_barcode;
    
    -- update the monies spent and gained for the drone and restaurant
    select price into ingredientPrice from payload where id = ip_id and tag = ip_tag and barcode = ip_barcode;
    select spent into moneySpent from restaurants where long_name = ip_long_name;
    
    UPDATE restaurants
    SET spent = ip_quantity * ingredientPrice + moneySpent
    WHERE long_name = ip_long_name;
    
    select sales into moneyMade from drones where id = ip_id and tag = ip_tag;
    
    UPDATE drones
	SET sales = ip_quantity * ingredientPrice + moneyMade
    WHERE id = ip_id and tag = ip_tag;
    
    -- ensure all quantities in the payload table are greater than zero
	DELETE from payload where quantity < 1;
    
end //
delimiter ;

-- [21] remove_ingredient()
-- -----------------------------------------------------------------------------
/* This stored procedure removes an ingredient from the system.  The removal can
occur if, and only if, the ingredient is not being carried by any drones. */
-- -----------------------------------------------------------------------------
drop procedure if exists remove_ingredient;
delimiter //
create procedure remove_ingredient (in ip_barcode varchar(40))
sp_main: begin
	-- ensure that the ingredient exists
    IF (select count(*) from ingredients where barcode = ip_barcode) <> 1 THEN LEAVE sp_main; END IF;
    -- ensure that the ingredient is not being carried by any drones
    IF (select count(*) from payload where barcode = ip_barcode) <> 0 THEN LEAVE sp_main; END IF;
    
	DELETE from ingredients where barcode = ip_barcode;
end //
delimiter ;

-- [22] remove_drone()
-- -----------------------------------------------------------------------------
/* This stored procedure removes a drone from the system.  The removal can
occur if, and only if, the drone is not carrying any ingredients, and if it is
not leading a swarm. */
-- -----------------------------------------------------------------------------
drop procedure if exists remove_drone;
delimiter //
create procedure remove_drone (in ip_id varchar(40), in ip_tag integer)
sp_main: begin
	-- ensure that the drone exists
    IF (select count(*) from drones where ip_id = id and ip_tag = tag) <> 1 THEN LEAVE sp_main; END IF;
    -- ensure that the drone is not carrying any ingredients
    IF (select count(*) from payload where ip_id = id and ip_tag = tag) <> 0 THEN LEAVE sp_main; END IF;
	-- ensure that the drone is not leading a swarm
    IF (select count(*) from drones where ip_id = swarm_id and ip_tag = swarm_tag) <> 0 THEN LEAVE sp_main; END IF;

    DELETE from payload where id = ip_id and tag = ip_tag;
	DELETE from drones where id = ip_id and tag = ip_tag;
end //
delimiter ;

-- [23] remove_pilot_role()
-- -----------------------------------------------------------------------------
/* This stored procedure removes a pilot from the system.  The removal can
occur if, and only if, the pilot is not controlling any drones.  Also, if the
pilot also has a worker role, then the worker information must be maintained;
otherwise, the pilot's information must be completely removed from the system. */
-- -----------------------------------------------------------------------------
drop procedure if exists remove_pilot_role;
delimiter //
create procedure remove_pilot_role (in ip_username varchar(40))
sp_main: begin
	-- ensure that the pilot exists
    IF (ip_username NOT IN (select username from pilots)) THEN LEAVE sp_main; END IF;
    -- ensure that the pilot is not controlling any drones
    IF (ip_username IN (select flown_by from drones where flown_by = ip_username)) THEN LEAVE sp_main; END IF;
    -- remove all remaining information unless the pilot is also a worker
    IF (ip_username IN (select username from workers)) THEN DELETE from pilots where username = ip_username; LEAVE sp_main; END IF;

	DELETE from work_for where username = ip_username;
	DELETE from pilots where username = ip_username;
	DELETE from users where username = ip_username;
end //
delimiter ;

-- [24] display_owner_view()
-- -----------------------------------------------------------------------------
/* This view displays information in the system from the perspective of an owner.
For each owner, it includes the owner's information, along with the number of
restaurants for which they provide funds and the number of different places where
those restaurants are located.  It also includes the highest and lowest ratings
for each of those restaurants, as well as the total amount of debt based on the
monies spent purchasing ingredients by all of those restaurants. And if an owner
doesn't fund any restaurants then display zeros for the highs, lows and debt. */
-- -----------------------------------------------------------------------------
create or replace view display_owner_view as
select users.username, first_name, last_name, address, 
(select count(funded_by) from restaurants where funded_by = users.username) as restaurant_number, 
(select count(distinct location) from restaurants where funded_by = users.username) as location_number, 
if (users.username in (select funded_by from restaurants where users.username = funded_by), (select max(rating) from restaurants where users.username = funded_by), 0) as highest_rating,
if (users.username in (select funded_by from restaurants where users.username = funded_by), (select min(rating) from restaurants where users.username = funded_by), 0) as lowest_rating,
if (users.username in (select funded_by from restaurants where users.username = funded_by), (select sum(spent) from restaurants where users.username = funded_by), 0) as total_debt
from restaurant_owners left join users on restaurant_owners.username = users.username;


-- [25] display_employee_view()
-- -----------------------------------------------------------------------------
/* This view displays information in the system from the perspective of an employee.
For each employee, it includes the username, tax identifier, hiring date and
experience level, along with the license identifer and piloting experience (if
applicable), and a 'yes' or 'no' depending on the manager status of the employee. */
-- -----------------------------------------------------------------------------
create or replace view display_employee_view as
select employees.username, taxID, salary, hired, employees.experience, 
IFNULL(pilots.licenseID, 'n/a'), 
IFNULL(pilots.experience, 'n/a'),
if (employees.username in (select manager from delivery_services), 'yes', 'no') as manager_status
from employees left join pilots on employees.username = pilots.username;


-- [26] display_pilot_view()
-- -----------------------------------------------------------------------------
/* This view displays information in the system from the perspective of a pilot.
For each pilot, it includes the username, licenseID and piloting experience, along
with the number of drones that they are controlling. */
-- -----------------------------------------------------------------------------
create or replace view display_pilot_view as
select username, licenseID, experience, 
(select count(*) from drones where flown_by = username or 
swarm_id in (select id from drones where flown_by = username) and swarm_tag in (select tag from drones where flown_by = username)) as drone_number, 
(select count(distinct hover) from drones where flown_by = username) as location_number
from pilots; 


-- [27] display_location_view()
-- -----------------------------------------------------------------------------
/* This view displays information in the system from the perspective of a location.
For each location, it includes the label, x- and y- coordinates, along with the
number of restaurants, delivery services and drones at that location. */
-- -----------------------------------------------------------------------------
create or replace view display_location_view as
select label, x_coord, y_coord, 
(select count(long_name) from restaurants where label = location) as restaurant_number,
(select count(id) from delivery_services where label = home_base) as delivery_service_number,
(select count(hover) from drones where label = hover) as location_number
from locations;


-- [28] display_ingredient_view()
-- -----------------------------------------------------------------------------
/* This view displays information in the system from the perspective of the ingredients.
For each ingredient that is being carried by at least one drone, it includes a list of
the various locations where it can be purchased, along with the total number of packages
that can be purchased and the lowest and highest prices at which the ingredient is being
sold at that location. */
-- -----------------------------------------------------------------------------
create or replace view display_ingredient_view as
select iname, hover, sum(quantity), min(price), max(price)
from payload 
join ingredients on payload.barcode = ingredients.barcode 
join drones on payload.id = drones.id and payload.tag = drones.tag
group by iname, hover;

-- [29] display_service_view()
-- -----------------------------------------------------------------------------
/* This view displays information in the system from the perspective of a delivery
service.  It includes the identifier, name, home base location and manager for the
service, along with the total sales from the drones.  It must also include the number
of unique ingredients along with the total cost and weight of those ingredients being
carried by the drones. */
-- -----------------------------------------------------------------------------
create or replace view display_service_view as
select *, 
(select sum(sales) from drones where drones.id = delivery_services.id) as total_sales, 
(select count(distinct ingredients.barcode) from payload left join ingredients on payload.barcode = ingredients.barcode where payload.id = delivery_services.id) as ingredient_number,
(select sum(quantity * price) from payload  where payload.id = delivery_services.id) as total_cost, 
(select sum(quantity * weight) from payload left join ingredients on payload.barcode = ingredients.barcode where payload.id = delivery_services.id) as total_weight
from delivery_services;