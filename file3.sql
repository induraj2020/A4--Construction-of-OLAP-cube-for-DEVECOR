------------------------------------------------------------------------------------------------------------------
--***************************				OPERATIONAL DATABASE		*******************
-----------------------------------------------------------------------------------------------------------------
--									CONNECTING TO OPERATIONAL DATABASE USER
-----------------------------------------------------------------------------------------------------------------

connect op_guy/op_guy;
set serveroutput on;

-----------------------------------------------------------------------------------------------------------------
-- 										DELETING OPERATION TABLES IF EXISTS
-----------------------------------------------------------------------------------------------------------------

create or replace procedure delete_existing_table as
begin
for c1 in (select * from tab) loop
	execute immediate 'drop table '||c1.tname||' cascade constraints Purge';
end loop;
end;
/

exec delete_existing_table; 
-----------------------------------------------------------------------------------------------------------------
--											Creating Tables
-----------------------------------------------------------------------------------------------------------------
create or replace procedure create_country_table as
begin 
	EXECUTE IMMEDIATE 'CREATE TABLE country (
										country_id number NOT NULL,
										name varchar(50),
										CONSTRAINT country_pk PRIMARY KEY(country_id))';
end;
/

create or replace procedure create_product_table as 
begin
	EXECUTE IMMEDIATE 'CREATE TABLE product (
										reference_id number NOT NULL,
										description varchar(50),
										price number,
										typee varchar(50),
										CONSTRAINT product_pk PRIMARY KEY(reference_id))';
end;
/

create or replace procedure create_region_table as 
begin
	EXECUTE IMMEDIATE 'CREATE TABLE region (
										region_id number NOT NULL,
										name varchar(50) NOT NULL,
										country_id number,
										CONSTRAINT id_pk PRIMARY KEY(region_id))';
end;
/

create or replace procedure create_department_table as
begin
	EXECUTE IMMEDIATE 'CREATE TABLE department(
										department_id number not null,
										name varchar(50),
										region_id number,
										constraint d_number_pk primary key(department_id))';
end;
/

create or replace procedure create_city_table as
begin
	EXECUTE IMMEDIATE 'CREATE TABLE city(
										zipcode number not null unique,
										city varchar(50) not null unique,
										department_id number,
										constraint zipcode_city_pk primary key(zipcode,city))';
end;
/

create or replace procedure create_client_table as
begin
	EXECUTE IMMEDIATE 'create table client(
										clientcode_id number not null,
										lastname varchar(50),
										firstname varchar(50),
										birthdate DATE,
										gender VARCHAR(50),
										zipcode number,
										cityname varchar(50),
										constraint clientcode_pk primary key(clientcode_id))';
end;
/

create or replace procedure create_purchase_table as
begin
	EXECUTE IMMEDIATE 'create table purchase(
										quantity number,
										timestampe timestamp(0),
										zipcode number,
										cityname varchar(50),
										clientcode_id number,
										reference_id number)';

end;
/

exec create_country_table;
exec create_product_table;
exec create_region_table;	
exec create_department_table;
exec create_city_table;
exec create_client_table;
exec create_purchase_table;

-----------------------------------------------------------------------------------------------------------------
-- 										POPULATING OPERATION TABLE DATA
-----------------------------------------------------------------------------------------------------------------
-- populating Country Table
-------------------------------------------------------------------------

create sequence seq_country;
create or replace procedure generate_country_data As
    c_name varchar(50);
begin
    for i in 1..20 loop
        case i
            when 1 then c_name:='Ethiopia';
            when 2 then c_name:='Brazil';
            when 3 then c_name:='Ivory_coast';
            when 4 then c_name:='Guinea';
            when 5 then c_name:='Vietnam';
            when 6 then c_name:='Sudan';
            when 7 then c_name:='Kenya';
            when 8 then c_name:='Germany';
            when 9 then c_name:='Algeria';
            when 10 then c_name:='SouthAfrica';
            when 11 then c_name:='Congo';
            when 12 then c_name:='Congo';
            when 13 then c_name:='Djoubouti';
            when 14 then c_name:='America';
            when 15 then c_name:='Canada';
            when 16 then c_name:='Ireland';
            when 17 then c_name:='China';
            when 18 then c_name:='Malasia';
            when 19 then c_name:='Srilanka';
            when 20 then c_name:='Bangaladesh';
        end case;
        insert into country values(seq_country.nextval,c_name);
    end loop;
end;
/

------------------------------------------------------------------------------
-- populating product table
------------------------------------------------------------------------------

create sequence seq_product;
create or replace procedure generate_product_data as 
begin
	insert into product 
	select seq_product.nextval,
			dbms_random.string('U',trunc(dbms_random.value(40,50))),
			round(trunc(dbms_random.value(10,10000),2)),
			dbms_random.string('U',trunc(dbms_random.value(4,5)))
	from dual 
	connect by level<=2000;
end;
/

------------------------------------------------------------------------------
-- populating Region table
------------------------------------------------------------------------------

create sequence seq_region;
create or replace procedure generate_data_region as 
begin
	insert into region
	select seq_region.nextval,
		'Region-'||to_char(round(dbms_random.value(1,20),0)),
		round(dbms_random.value(1,20),0) 
	from dual
	connect by level<= 2000;
end;
/
    
------------------------------------------------------------------------------
-- populating Department table
------------------------------------------------------------------------------
    
create sequence seq_department;
create or replace procedure generate_data_department as 
begin
insert into department
select seq_department.nextval,
		'department-'||to_char(round(dbms_random.value(1,200),0)),
		round(dbms_random.value(1,2000),0)
from dual
connect by level<=6000;
end;
/

------------------------------------------------------------------------------
-- populating CITY table
------------------------------------------------------------------------------

CREATE SEQUENCE seq_city
INCREMENT BY 1 
START WITH 600001;

create or replace procedure generate_city_data as 
begin 
insert into city
select seq_city.nextval,
		dbms_random.string('U',trunc(dbms_random.value(5,20))),
		round(dbms_random.value(1,6000),0)
from dual
connect by level <=6000;
end;
/

------------------------------------------------------------------------------
-- populating client table
------------------------------------------------------------------------------

CREATE SEQUENCE seq_client
INCREMENT BY 1 
START WITH 1000000;

create or replace procedure generate_client_data as
begin
insert into client 
select seq_client.nextval,
		dbms_random.string('U',trunc(dbms_random.value(5,20))),
		dbms_random.string('U',trunc(dbms_random.value(5,20))),
		TRUNC(SYSDATE - DBMS_RANDOM.value(1000,3000)),													
		decode(round(dbms_random.value), 0, 'F', 'M') rnd, 
		round(dbms_random.value(600001,606000),0),
		'city-'||to_char(round(dbms_random.value(1,400),0))
from dual
connect by level<=10000;
end;
/

------------------------------------------------------------------------------
-- populating purchase table
------------------------------------------------------------------------------

create or replace procedure generate_purchase_data as													
  l_hours_in_day NUMBER := 24;
  l_mins_in_day  NUMBER := 24*60;
  l_secs_in_day  NUMBER := 24*60*60;
begin
insert into purchase
select round(dbms_random.value(1,100),0),
(TRUNC(SYSDATE - DBMS_RANDOM.value(10,1000)) +(TRUNC(DBMS_RANDOM.value(0,1000))/l_mins_in_day)),
round(dbms_random.value(600001,606001),0),
'city-'||to_char(round(dbms_random.value(1,400),0)),
(round(dbms_random.value(1000000,1010000),0)),
(round(dbms_random.value(1,1999),0))
from dual
connect by level<=50000;
end;
/

exec generate_country_data;
exec generate_product_data;
exec generate_data_department;
exec generate_data_region
exec generate_city_data;
exec generate_client_data;
exec generate_purchase_data;


-----------------------------------------------------------------------------------------------------------------
-- 													ALTERING TABLE
-----------------------------------------------------------------------------------------------------------------
create or replace procedure alter_region as 
begin
	execute immediate 'Alter table region 
	add constraint country_fk foreign key(country_id) references country(country_id)';
end;
/

create or replace procedure alter_department as
begin
	execute immediate 'Alter table department
	add constraint region_fk foreign key(region_id) references region(region_id)';
end;
/

create or replace procedure alter_city as 
begin
	execute immediate 'alter table city
	add constraint department_fk foreign key(department_id) references department(department_id)';
end;
/

create or replace procedure alter_client as
begin
	execute immediate 'alter table client
	add constraint zipcode_fk foreign key(zipcode) references city(zipcode)';
end;
/

create or replace procedure delete_duplicate_zip as
begin
	execute immediate 'DELETE FROM purchase
	WHERE zipcode NOT IN (
		SELECT zipcode FROM city
	)';
end;
/

create or replace procedure delete_duplicate_city as
begin
	execute immediate 'DELETE FROM purchase
	WHERE cityname NOT IN (SELECT cityname FROM client)';
end;
/

create or replace procedure delete_duplicate_client as
begin
	execute immediate 'DELETE FROM purchase
	WHERE clientcode_id NOT IN (SELECT clientcode_id FROM client)';
end;
/

create or replace procedure delete_duplicate_purchase as
begin
	execute immediate 'DELETE FROM purchase
	WHERE reference_id NOT IN (SELECT reference_id FROM product)';
end;
/

create or replace procedure Alter_purchase1 as
begin
	execute immediate 'Alter table purchase
	add constraint zipcode_fk_1 foreign key(zipcode) references city(zipcode)';
end;
/

create or replace procedure Alter_purchase2 as
begin
	execute immediate 'Alter table purchase
	add constraint clientcode_fk_1 foreign key(clientcode_id) references client(clientcode_id)';
end;
/

create or replace procedure Alter_purchase3 as
begin
	execute immediate 'Alter table purchase
	add constraint reference_fk foreign key(reference_id) references product(reference_id)';
end;
/

exec alter_region;
exec alter_department;
exec alter_city;
exec alter_client;
exec delete_duplicate_zip;
exec delete_duplicate_city;
exec delete_duplicate_client;
exec delete_duplicate_purchase;
exec Alter_purchase1;
exec Alter_purchase2;
exec Alter_purchase3;

-----------------------------------------------------------------------------------------------------------------
--										GRANTING PERMISSIONS
-----------------------------------------------------------------------------------------------------------------

connect op_guy/op_guy;

grant select on client to de_guy; 
grant select on city to de_guy;
grant select on purchase to de_guy;
grant select on product to de_guy;
grant select on department to de_guy;
grant select on country to de_guy;
grant select on region to de_guy;
