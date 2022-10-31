/*
  Nathan Nguyen
  CSC 352
  Assignment 5
  November 1st, 2021
*/

set serveroutput on;

-- 1
DECLARE
    TYPE tab_column IS RECORD ( 
        col_name VARCHAR2(30), 
        data_type VARCHAR2(30), 
        data_length VARCHAR2(30) 
        );
    
    temp tab_column;
    
    CURSOR c IS
        SELECT  column_name, data_type, data_length
        FROM    user_tab_columns
        WHERE   table_name = 'EMPLOYEES';
        
BEGIN
    
    OPEN c;
    LOOP
        FETCH c INTO temp;
        EXIT WHEN c%NOTFOUND;
        dbms_output.put_line(temp.col_name || ' ' || temp.data_type || ' ' || temp.data_length);
    END LOOP;
    CLOSE c;
        
END;

-- 1 OUTPUT
/*
EMPLOYEE_ID NUMBER 22
FIRST_NAME VARCHAR2 20
LAST_NAME VARCHAR2 25
EMAIL VARCHAR2 25
PHONE_NUMBER VARCHAR2 20
HIRE_DATE DATE 7
JOB_ID VARCHAR2 10
SALARY NUMBER 22
COMMISSION_PCT NUMBER 22
MANAGER_ID NUMBER 22
DEPARTMENT_ID NUMBER 22


PL/SQL procedure successfully completed.
*/

-- 2
DECLARE
    TYPE Emp_Sal IS RECORD ( 
        emp_no employees.employee_id%type,
        full_name varchar2(46),
        sal employees.salary%type
        );
    
    temp Emp_Sal;
    
    CURSOR c IS
        SELECT  employee_id, first_name ||' '|| last_name, salary 
        FROM    employees
        WHERE   employee_id = 105;
        
BEGIN
    
    OPEN c;
    LOOP
        FETCH c INTO temp;
        EXIT WHEN c%NOTFOUND;
        dbms_output.put_line('ID-' || temp.emp_no || ' ' || temp.full_name || ' Salary: $' || temp.sal);
    END LOOP;
    CLOSE c;
        
END;

-- 2 OUTPUT
/*
ID-105 David Austin Salary: $4800


PL/SQL procedure successfully completed.
*/

-- 3
DECLARE
    TYPE Emp_Sal IS RECORD ( 
        emp_no employees.employee_id%type,
        full_name varchar2(46),
        sal employees.salary%type
        );
    
    TYPE Emp_Sal_NT IS TABLE OF Emp_Sal;
    
    LIST Emp_Sal_NT := Emp_Sal_NT();
    
    CURSOR c IS
        SELECT  employee_id, first_name ||' '|| last_name, salary 
        FROM    employees
        WHERE   department_id = 30;
        
BEGIN
    
    FOR record IN c
    LOOP
        LIST.EXTEND;
        LIST(LIST.LAST) := record;
    END LOOP;
    
    FOR x IN LIST.FIRST..LIST.LAST
    LOOP
        dbms_output.put_line('ID-' || LIST(x).emp_no ||' '|| LIST(x).full_name || ' Salary: $' || LIST(x).sal);
    END LOOP;
        
END;

-- 3 OUTPUT
/*
ID-114 Den Raphaely Salary: $11000
ID-115 Alexander Khoo Salary: $3100
ID-116 Shelli Baida Salary: $2900
ID-117 Sigal Tobias Salary: $2800
ID-118 Guy Himuro Salary: $2600
ID-119 Karen Colmenares Salary: $2500


PL/SQL procedure successfully completed.
*/

-- 4
DECLARE
    deptName departments.department_name%type;
    fullName varchar2(46);
    mngrID departments.manager_id%type;

    PROCEDURE dept_info( pdeptID IN departments.department_id%type, pdeptName OUT departments.department_name%type, pfullName OUT employees.first_name%type ) IS
    BEGIN
        SELECT department_name, manager_id
        INTO pdeptName, mngrID
        FROM departments
        WHERE department_id = pdeptID;
        
        SELECT first_name ||' '|| last_name
        INTO pfullName
        FROM employees
        WHERE department_id = pdeptID AND employee_id = mngrID;
    END;
    
BEGIN
    dept_info(10, deptName, fullName);
    dbms_output.put_line(deptName ||' '|| fullName);

END;

-- 4 OUTPUT
/*
Administration Jennifer Whalen


PL/SQL procedure successfully completed.
*/

-- 5
DECLARE
    deptName departments.department_name%type;
    fullName varchar2(46);
    mngrID departments.manager_id%type;
    
    CURSOR c IS
        SELECT department_ID, count(*)
        FROM employees
        GROUP BY department_ID
        HAVING count(*) >= 6;
    
    PROCEDURE dept_info( pdeptID IN departments.department_id%type, pdeptName OUT departments.department_name%type, pfullName OUT employees.first_name%type ) IS
    BEGIN
        SELECT department_name, manager_id
        INTO pdeptName, mngrID
        FROM departments
        WHERE department_id = pdeptID;
        
        SELECT first_name ||' '|| last_name
        INTO pfullName
        FROM employees
        WHERE department_id = pdeptID AND employee_id = mngrID;
    END;
        
BEGIN
    
    FOR record IN c
    LOOP
        dept_info(record.department_ID, deptName, fullName);
        dbms_output.put_line(deptName ||' '|| fullName);
        --dbms_output.put_line(record.department_ID);
    END LOOP;
    
END;

-- 5 OUTPUT
/*
Shipping Adam Fripp
Purchasing Den Raphaely
Finance Nancy Greenberg
Sales John Russell


PL/SQL procedure successfully completed.
*/