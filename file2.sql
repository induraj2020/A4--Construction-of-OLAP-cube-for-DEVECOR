-----------------------------------------------------------------------------------------------------------------
--												CREATE USERS
-----------------------------------------------------------------------------------------------------------------
set linesize 600;
set serveroutput on;

create or replace procedure create_user as 
	userexist integer;
begin	
for c in 0..1 loop
	case c
	when 0 then
		select count(*) into userexist from dba_users where username='OP_GUY';
		if (userexist=0) then
			execute immediate 'create user op_guy identified by op_guy';
            execute immediate 'grant connect to op_guy';
            execute immediate 'grant resource to op_guy';
			execute immediate 'grant create view to op_guy';
			execute immediate 'grant create table to op_guy';
			execute immediate 'grant execute any procedure to op_guy';
            --execute immediate 'grant execute on procedure to operational_guy';
			dbms_output.put_line('user1 created');
		else
			dbms_output.put_line('user1 exists');
		end if;
	when 1 then 
		select count(*) into userexist from dba_users where username='DE_GUY';
		if (userexist=0) then
			execute immediate 'create user de_guy identified by de_guy';
            execute immediate 'grant connect to de_guy';
            execute immediate 'grant resource to de_guy';
			execute immediate 'grant create view to de_guy';
			execute immediate 'grant create table to de_guy';
			execute immediate 'grant execute any procedure to de_guy';
			dbms_output.put_line('user2 created');
		else 
			dbms_output.put_line('user2 exists');
		end if;
	end case;
end loop;
end;
/


exec create_user;