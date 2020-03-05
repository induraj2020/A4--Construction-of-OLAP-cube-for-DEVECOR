-----------------------------------------------------------------------------------------------------------------
--			******************			DECISIONAL DATABASE			***************************
-----------------------------------------------------------------------------------------------------------------
--								CONNECTING TO DECISIONAL DATABASE USER
-----------------------------------------------------------------------------------------------------------------

connect de_guy/de_guy;

-----------------------------------------------------------------------------------------------------------------
-- 								DELETING DECISIONAL TABLE IF EXISTS
-----------------------------------------------------------------------------------------------------------------

create or replace procedure delete_de_existing_table as
begin
for c1 in (select * from tab) loop
	execute immediate 'drop table '||c1.tname||' cascade constraints Purge';
end loop;
end;
/

-----------------------------------------------------------------------------------------------------------------
--								CREATING DECISIONAL DATABASE TABLES
-----------------------------------------------------------------------------------------------------------------
create or replace procedure create_place_dim as 
BEGIN 
EXECUTE IMMEDIATE 'create table place_dim ( 
			zipcode number not null, 
			department varchar(50),
			region varchar(50),
			country varchar(50),
			constraint place_pk primary key(zipcode))';
end;
/

create or replace procedure create_product_dim as
begin
EXECUTE IMMEDIATE 'create table product_dim (
			reference_id number not null,
			price number,
			typee varchar(50),
			constraint product_pk primary key(reference_id))';
end;
/

create or replace procedure create_timestamp_dim as
begin
EXECUTE IMMEDIATE 'create table timestampe_dim (
		timestampe timestamp(0),
		hours number,
		dayofweek varchar(50),
		dayofyear varchar(50),
		week varchar(50),
		months varchar(50),
		quarter varchar(50),
		semester number,
		years varchar(50),
		constraint timestampe_dim_pk primary key(timestampe))';
end;
/

create or replace procedure create_client_dim as
begin		
EXECUTE IMMEDIATE 'create table client_dim (
			client_id number,
			clientcode_id number,
			quantity number,
			Age number,
			Gender varchar(50),
			zipcode number,
			department_name varchar(50),
			region_name varchar(50),
			country_name varchar(50),
			constraint client_dim_pk primary key(client_id))';
end;
/

create or replace procedure create_purchase_fact as
begin
EXECUTE IMMEDIATE 'create table purchase_fact(
			quantity number,
			price number,
			zipcode_fk number,
			timestampe_fk timestamp(0),
			reference_fk number,
			client_id_fk number)';
END;
/

exec delete_de_existing_table;
exec create_place_dim;
exec create_product_dim;
exec create_timestamp_dim;
exec create_client_dim;
exec create_purchase_fact;

-----------------------------------------------------------------------------------------------------------------
--ALTERING Purchase Fact Table 
-----------------------------------------------------------------------------------------------------------------

create or replace procedure alter_fact1 as
begin
	execute immediate 'Alter table purchase_fact add constraint fk_zipcode foreign key(zipcode_fk) references place_dim(zipcode)';
end;
/

create or replace procedure alter_fact2 as
begin
	execute immediate 'Alter table purchase_fact add constraint fk_timestampe foreign key(timestampe_fk) references timestampe_dim(timestampe)';
end;
/

create or replace procedure alter_fact3 as 
begin
	execute immediate 'Alter table purchase_fact add constraint fk_reference foreign key (reference_fk) references product_dim(reference_id)';
end;
/

create or replace procedure alter_fact4 as 
begin 
	execute immediate 'alter table purchase_fact add constraint fk_client_id foreign key (client_id_fk) references client_dim(client_id)';
end;
/

exec alter_fact1;
exec alter_fact2;
exec alter_fact3;
exec alter_fact4;

-----------------------------------------------------------------------------------------------------------------
--INSERTING DATA'S INTO Purchase Fact Table 
-----------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE insert_place_dim as
BEGIN
execute immediate 'insert into place_dim(zipcode,department, region, country)
select distinct city.zipcode as zipcode,
		department.name as department,
		region.name as region,
		country.name as country
		from 
		op_guy.city
		inner join op_guy.department
		using(department_id)
		inner join op_guy.region
		using(region_id)
		inner join op_guy.country
		using(country_id)
		where not exists (select 1 from place_dim where 1=1 and place_dim.zipcode=city.zipcode)
		order by
		zipcode ASC';
end;
/

exec insert_place_dim

CREATE OR REPLACE PROCEDURE insert_product_dim as
BEGIN		
	execute immediate 'insert into product_dim
	select distinct product.reference_id,product.price,product.typee from op_guy.product 
	where not exists(select 1 from product_dim where 1=1 and product_dim.reference_id=product.reference_id)';
end;
/

exec insert_product_dim


create or replace procedure insert_timestampe_dim as
begin
insert into timestampe_dim
	select distinct(timestampe) as timestampe,
		extract (hour from timestampe) as hours,
		to_char(timestampe,'DY') as dayofweek,
		to_char(timestampe,'DDD') as dayofyear,
		to_char(timestampe,'IW') as week,
		to_char(timestampe,'MON') as months,
		to_char(timestampe,'Q') as quarter,
		(ceil(extract(month from timestampe)/6)) as semester,
		to_char(timestampe,'IYYY') as years from op_guy.purchase;
end;
/

exec insert_timestampe_dim

CREATE OR REPLACE PROCEDURE insert_client_dim as
BEGIN			
	execute immediate 'insert into client_dim
		select row_number() over(order by client.clientcode_id,quantity) client_id,
		client.clientcode_id,
		purchase.quantity,
		abs(trunc(months_between(sysdate,client.birthdate)/12)) age,
		client.gender,
		client.zipcode,
		department.name,
		region.name,
		country.name
		from op_guy.client
		inner join op_guy.purchase
		on client.clientcode_id=purchase.clientcode_id
		inner join op_guy.city
		on client.zipcode=city.zipcode
		inner join op_guy.department
		on city.department_id=department.department_id
		inner join op_guy.region
		on department.region_id=region.region_id
		inner join op_guy.country
		on region.country_id=country.country_id';	
end;
/
exec insert_client_dim;

CREATE OR REPLACE PROCEDURE insert_purchase_fact as
BEGIN
	execute immediate 'insert into purchase_fact
	select  distinct purchase.quantity,
			product.price,
			place_dim.zipcode,
			timestampe_dim.timestampe,
			product_dim.reference_id,
			client_dim.client_id
			from op_guy.purchase 
			inner join op_guy.product
			on purchase.reference_id=product.reference_id
			inner join de_guy.place_dim
			on purchase.zipcode=place_dim.zipcode
			inner join de_guy.timestampe_dim
			on purchase.timestampe=timestampe_dim.timestampe
			inner join de_guy.product_dim
			on purchase.reference_id=product_dim.reference_id
			inner join de_guy.client_dim
			on purchase.clientcode_id=client_dim.clientcode_id';
end;
/		

exec insert_purchase_fact;



create or replace trigger insert_new_facts 
after insert on de_guy.client_dim for each row
declare
PRAGMA AUTONOMOUS_TRANSACTION;
begin
execute immediate'truncate table purchase_fact';
insert into purchase_fact
select distinct purchase.quantity,
		product.price,
		place_dim.zipcode,
		timestampe_dim.timestampe,
		product_dim.reference_id,
		client_dim.clientcode_id
		from op_guy.purchase 
		inner join op_guy.product
		on purchase.reference_id=product.reference_id
		inner join de_guy.place_dim
		on purchase.zipcode=place_dim.zipcode
		inner join de_guy.timestampe_dim
		on purchase.timestampe=timestampe_dim.timestampe
		inner join de_guy.product_dim
		on purchase.reference_id=product_dim.reference_id
		inner join de_guy.client_dim
		on purchase.clientcode_id=client_dim.clientcode_id
		where timestampe_dim.timestampe between to_date('01-DEC-18','DD-MON-iYYY') and to_date('25-DEC-19','DD-MON-iYYY');		
commit;
end;
/




