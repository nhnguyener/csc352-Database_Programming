/*
  Nathan Nguyen
  CSC 352
  Assignment 2
  October 4th, 2021
*/

set serveroutput on;

-- 1
DECLARE
    CURSOR c IS
     	SELECT   last_name ||', ' || first_name Full_name, salary, 
                 department_ID
    	FROM     employees 
        WHERE	 salary < 2500  
    	ORDER BY salary DESC;

BEGIN
    DBMS_OUTPUT.put_line  
        (' No      Emp Full Name             Salary       Dept ID');    
    DBMS_OUTPUT.put_line  
        ('-----   ---------------------    --------     ---------');

    FOR record in c 
    LOOP
        DBMS_OUTPUT.put_line (rpad ( c%ROWCOUNT, 7) ||
          RPAD (record.Full_name, 25) || to_char (record.salary, '$99,999') 
                ||'        '|| record.department_ID);
    END LOOP;
END;

-- 2
DECLARE
    totalBonuses employees.salary%type := 0;

    CURSOR c IS
     	SELECT  salary, commission_pct
    	FROM    employees
        WHERE   department_ID = 80;
    
BEGIN
    FOR record IN c
    LOOP
        IF record.commission_pct >= 0.25 THEN
            IF record.salary >= 10000 THEN
                totalBonuses := totalBonuses + 1000;
            ELSIF record.salary BETWEEN 7000 AND 9999 THEN
                totalBonuses := totalBonuses + 800;
            ELSIF record.salary < 7000 THEN
                totalBonuses := totalBonuses + 600;
            END IF;
        ELSIF record.commission_pct BETWEEN 0.15 AND 0.24 THEN
            IF record.salary >= 10000 THEN
                totalBonuses := totalBonuses + 700;
            ELSIF record.salary BETWEEN 7000 AND 9999 THEN
                totalBonuses := totalBonuses + 600;
            ELSIF record.salary < 7000 THEN
                totalBonuses := totalBonuses + 500;
            END IF;
        ELSE
            totalBonuses := totalBonuses + 450;
        END IF;
    END LOOP;
    dbms_output.put_line(totalBonuses);
END;

-- 3
DECLARE
    CURSOR c ( ownerName varchar2, tableName varchar2 ) IS
        SELECT  column_name, data_type, data_length 
        FROM    all_tab_columns
        WHERE   owner = ownerName AND table_name = tableName;
    
    cRows c%rowtype;
    
BEGIN
    OPEN c(user, 'EMPLOYEES');
    dbms_output.put_line('[FOR TABLE EMPLOYEES]');
    LOOP
        FETCH c into cRows;
        EXIT WHEN c%notfound;
        dbms_output.put_line(cRows.column_name || ' ' || cRows.data_type || ' ' || cRows.data_length);
    END LOOP;
    CLOSE c;
    
    OPEN c(user, 'DEPARTMENTS');
    dbms_output.put_line('[FOR TABLE DEPARTMENTS]');
    LOOP
        FETCH c into cRows;
        EXIT WHEN c%notfound;
        dbms_output.put_line(cRows.column_name || ' ' || cRows.data_type || ' ' || cRows.data_length);
    END LOOP;
    CLOSE c;
END;

-- 4
DECLARE
    empID employees.employee_id%type;
    empLastName employees.last_name%type;
    salaryOld employees.salary%type;
    salaryNew employees.salary%type;
    
    CURSOR c IS
        SELECT  employee_id, last_name, salary
        FROM    employees
        WHERE   salary < 2450 AND commission_pct IS NULL
        FOR UPDATE;

BEGIN
    SAVEPOINT save1;
    OPEN c;
    LOOP
        FETCH c into empID, empLastName, salaryOld;
        IF c%found THEN
            salaryNew := salaryOld * 1.11;
            UPDATE  employees
            SET     salary = salaryNew;
            dbms_output.put_line('ID-' || empID || ' ' || empLastName || '. Old Salary: ' || salaryOld || ' New Salary: ' || salaryNew);
        ELSE
            EXIT;
        END IF;
    END LOOP;
    CLOSE c;
    ROLLBACK TO save1;
END;

-- 5
DECLARE
    deptid NUMBER := 30;

    TYPE EmpCurTyp IS REF CURSOR RETURN employees%ROWTYPE;
    c EmpCurTyp;
    c2 employees%ROWTYPE;
    
BEGIN
    OPEN c FOR
        SELECT      *
        FROM        employees
        WHERE       department_id = deptid
        ORDER BY    last_name;
    LOOP
        FETCH c into c2;
        EXIT WHEN c%notfound;
        dbms_output.put_line('ID-' || c2.employee_id || ' ' || c2.last_name || ', ' || c2.first_name);
    END LOOP;
    CLOSE c;
    
    OPEN c FOR
        SELECT      *  
        FROM        employees
        WHERE       commission_pct IS NULL AND salary > 15000
        ORDER BY    employee_id ;
    LOOP
        FETCH c into c2;
        EXIT WHEN c%notfound;
        dbms_output.put_line(c2.first_name || ' ' || c2.last_name || ', Salary: ' || to_char (c2.salary, '$99,999'));
    END LOOP;
    CLOSE c; 

END;