/*
  Nathan Nguyen
  CSC 352
  Assignment 7
  November 15th, 2021
*/

set serveroutput on;

-- 1
DROP table Dept_log;
CREATE TABLE      Dept_log(
   Updated_Date	DATE,
   Updated_By	Varchar2 (15),
   Action         Varchar2 (30)
);

CREATE TRIGGER Dept_Del
    BEFORE DELETE 
    ON departments

BEGIN
    INSERT INTO Dept_log
    VALUES (SYSDATE, 'user', 'DELETION MADE');

END;

    SAVEPOINT s1;
    
    DELETE departments where department_id = 150;
    DELETE departments where department_id > 249;
    
    SELECT * FROM Dept_log;

    ROLLBACK TO s1;

drop trigger dept_del;

-- 1 Output
/*
Savepoint created.


1 row deleted.


3 rows deleted.

>>Query Run In:Query Result 1

Rollback complete.

Query Result:
15-NOV-21	user	DELETION MADE
15-NOV-21	user	DELETION MADE
*/

-- 2
DROP table Dept_Del_log;
CREATE TABLE Dept_Del_log (
   Old_Deptno     number (4),
   OLD_Deptname   Varchar2 (30),
   OLD_MgrID      number (6),
   OLD_LocID      number (4),
   Updated_Date	  DATE,
   Updated_By	  Varchar2 (15),
   Action         Varchar2 (30)
);

CREATE TRIGGER Dept_Del_Row
    BEFORE DELETE 
    ON departments
    FOR EACH ROW

BEGIN
    INSERT INTO Dept_Del_log
    VALUES (:OLD.department_id, :OLD.department_name, :OLD.manager_id, :OLD.location_id, SYSDATE, 'user', 'DELETION MADE');

END;

    SAVEPOINT s1;
    
    DELETE departments where department_id = 150;
    DELETE departments where department_id > 249;
    
    SELECT * FROM Dept_Del_log;

    ROLLBACK TO s1;

drop trigger dept_del_row;

-- 2 OUTPUT
/*
Trigger DEPT_DEL_ROW compiled


Savepoint created.


1 row deleted.


3 rows deleted.

>>Query Run In:Query Result

Rollback complete.

Query Results:
150	Shareholder Services		1700	15-NOV-21	user	DELETION MADE
250	Retail Sales		1700	15-NOV-21	user	DELETION MADE
260	Recruiting		1700	15-NOV-21	user	DELETION MADE
270	Payroll		1700	15-NOV-21	user	DELETION MADE
*/

-- 3
DROP TABLE Dept_Access_log;
CREATE TABLE      Dept_Access_log(
   Deptno         number (4),
   OLD_Deptname   Varchar2 (30),
   NEW_Deptname   Varchar2 (30),
   OLD_MgrID      number (6),
   NEW_MgrID      number (6),
   OLD_LocID      number (4),
   NEW_LocID      number (4),
   Updated_Date	DATE,
   Updated_By	Varchar2 (15),
   Action         Varchar2 (30)
);

CREATE TRIGGER Change_Dept
    BEFORE INSERT OR DELETE OR UPDATE
    OF manager_id, location_id
    ON departments
    FOR EACH ROW

BEGIN
    --INSERT INTO Dept_Access_log
    --VALUES (:OLD.department_id, :OLD.department_name, :NEW.department_name, :OLD.manager_id, :NEW.manager_id, :OLD.location_id, :NEW.location_id, SYSDATE, 'user', 'CHANGE MADE');
    IF INSERTING THEN
	 INSERT INTO Dept_Access_log VALUES
          (:New.department_id, null, :NEW.department_name, null, :NEW.Manager_id,
           null, :NEW.location_id, Sysdate, user, 'Insert one new department');

      ELSIF DELETING THEN
	  INSERT INTO Dept_Access_log VALUES
          (:OLD.department_id, :OLD.department_name, null, :OLD.Manager_id,
           null, :OLD.location_id, null, Sysdate, user, 
           'Delete one department');

      ELSIF UPDATING('Manager_ID') THEN
	 INSERT INTO Dept_Access_log VALUES
         (:NEW.department_id, :OLD.department_name, :NEW.department_name, 
          :OLD.Manager_id, :NEW.Manager_id, :OLD.location_id, :NEW.location_id,
          Sysdate, user, 'manager is changed');

     ELSIF UPDATING('Location_ID') THEN
	 INSERT INTO Dept_Access_log VALUES
         (:NEW.department_id, :OLD.department_name, :NEW.department_name, 
          :OLD.Manager_id, :NEW.Manager_id, :OLD.location_id, :NEW.location_id,
          Sysdate, user, 'Location is changed');
      ELSE	
	 DBMS_OUTPUT.PUT_LINE('something goes wrong');
      END IF;
END;

    SAVEPOINT s1;
    
    Column OLD_Deptname format A10
    Column NEW_Deptname format A10

    Select * from departments;
    SELECT * from Dept_Access_log ;

    INSERT INTO departments VALUES (911, 'DeleteMe', 105, 1700);

    UPDATE departments set manager_id = 108   WHERE department_id = 911;
    UPDATE departments set location_id = 1400 WHERE department_id = 911;

    DELETE departments where department_id = '911';
    
    SELECT * FROM Dept_Access_log;

    ROLLBACK TO s1;

drop trigger Change_Dept;

-- 3 OUTPUT
/*
Savepoint created.

>>Query Run In:Query Result
>>Query Run In:Query Result 1

1 row inserted.


1 row updated.


1 row updated.


1 row deleted.


Rollback complete.

Query Result 1:
10	Administration	200	1700
20	Marketing	201	1800
30	Purchasing	114	1700
40	Human Resources	203	2400
50	Shipping	121	1500
60	IT	103	1400
70	Public Relations	204	2700
80	Sales	145	2500
90	Executive	100	1700
100	Finance	108	1700
110	Accounting	205	1700
120	Treasury		1700
130	Corporate Tax		1700
140	Control And Credit		1700
150	Shareholder Services		1700
160	Benefits		1700
170	Manufacturing		1700
180	Construction		1700
190	Contracting		1700
200	Operations		1700
210	IT Support		1700
220	NOC		1700
230	IT Helpdesk		1700
240	Government Sales		1700
250	Retail Sales		1700
260	Recruiting		1700
270	Payroll		1700

Query Result 2:
EMPTY

Query Result 3:
(null)  (null)      DeleteMe	(null)  105		(null)  1700	15-NOV-21	user	CHANGE MADE
911	    DeleteMe	DeleteMe	105	    108	    1700	1700	15-NOV-21	user	CHANGE MADE
911	    DeleteMe	DeleteMe	108	    108	    1700	1400	15-NOV-21	user	CHANGE MADE
911 	DeleteMe	(null)      108		(null)  1400	(null)  15-NOV-21	user	CHANGE MADE
*/

-- 4
/*
CREATE OR REPLACE PACKAGE Pkg_emp_Sal AS
    FUNCTION Emp_Sal ( emp_id IN employees.employee_id%type )
    RETURN number;
    
    FUNCTION Emp_Sal( emp_mail IN employees.email%type )
    RETURN number;
END;

CREATE OR REPLACE PACKAGE BODY Pkg_emp_Sal AS
    FUNCTION Emp_Sal( emp_id IN employees.employee_id%type )
    RETURN number IS empSalary employees.salary%type;
    BEGIN
        SELECT salary
        INTO empSalary
        FROM employees
        WHERE employee_id = emp_id;
        
        RETURN empSalary;
    END;
    
    FUNCTION Emp_Sal( emp_mail IN employees.email%type )
    RETURN number IS empSalary employees.salary%type;
    BEGIN
        SELECT salary
        INTO empSalary
        FROM employees
        WHERE email = emp_mail;
        
        RETURN empSalary;
    END;
    
END Pkg_emp_Sal;

BEGIN
    dbms_output.put_line('Salary: $' || Pkg_emp_Sal.Emp_Sal(100));
    dbms_output.put_line('Salary: $' || Pkg_emp_Sal.Emp_Sal('SKING'));
    
END;

drop package Pkg_emp_Sal;
*/
CREATE OR REPLACE PACKAGE Pkg_emp_Sal AUTHID DEFINER IS

   FUNCTION Emp_Sal 
     ( emp_id	employees.employee_id%TYPE)
       RETURN number ;

   FUNCTION Emp_Sal 
     ( emp_email  employees.email%TYPE)
       RETURN number ;
END Pkg_emp_Sal ;
/

CREATE OR REPLACE PACKAGE BODY Pkg_emp_Sal IS
   TYPE temp_rec IS RECORD(temp_count number, temp_name varchar2(30));
   
   FUNCTION Emp_Sal 
     ( emp_id	employees.employee_id%TYPE)
       RETURN number
      IS
       ret    number (9,2); 	
   BEGIN
    SELECT salary  into ret
    FROM   employees
    WHERE  employee_id = emp_id ;
    RETURN ret;
   END Emp_Sal ;

   FUNCTION Emp_Sal 
     ( emp_email	employees.email%TYPE)
       RETURN number
      IS
       ret    number (9,2); 	
   BEGIN
    SELECT salary  into ret
    FROM   employees
    WHERE  email = emp_email ;
    RETURN ret;
   END Emp_Sal ;

END Pkg_emp_Sal;
/
-- PL/SQL that invokes the functions in the package

DECLARE
    empid      employees.employee_id%TYPE := 100;  
    emp_email  varchar2 (25)  := 'SKING';
    sal       number (9,2); 	
 	
BEGIN
     DBMS_OUTPUT.PUT_LINE ('Call function via empid as parameter: ');
     sal :=  Pkg_emp_Sal.Emp_Sal ( empid ) ;
     DBMS_OUTPUT.PUT_LINE ('The salary of this emp_id ' || 
                empid || ' is: '|| To_char (sal, '$999,999') ||'.' );

     DBMS_OUTPUT.PUT_LINE (CHR(10)||'Call function with email as parameter:');
     sal := Pkg_emp_Sal.Emp_Sal ( emp_email) ;
     DBMS_OUTPUT.PUT_LINE ('The salary with email as ' || 
                emp_email || ' is: '|| To_char (sal, '$999,999') ||'.' );
                    
END;