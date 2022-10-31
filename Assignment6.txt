/*
  Nathan Nguyen
  CSC 352
  Assignment 6
  November 8th, 2021
*/

set serveroutput on;

-- 1a
DECLARE
    empID employees.employee_id%type;
    empBonus number;
    totalBonus number := 0;
    
    CURSOR c IS
        SELECT employee_id
        FROM employees
        WHERE department_id = 80;
    
    PROCEDURE Emp_Bonus( Emp_ID IN employees.employee_id%type, bonus OUT number ) IS
    empSalary employees.salary%type;
    empComm employees.commission_pct%type;
    
    BEGIN
        SELECT salary, commission_pct
        INTO empSalary, empComm
        FROM employees
        WHERE employee_id = Emp_ID;
        
        IF (empComm >= 0.25) THEN
            IF (empSalary >= 10000) THEN
                bonus := 1000;
            ELSIF (empSalary BETWEEN 7000 AND 9999) THEN
                bonus := 800;
            ELSIF (empSalary < 7000) THEN
                bonus := 600;
            END IF;
        ELSIF (empComm BETWEEN 0.15 AND 0.24) THEN
            IF (empSalary >= 10000) THEN
                bonus := 700;
            ELSIF (empSalary BETWEEN 7000 AND 9999) THEN
                bonus := 600;
            ELSIF (empSalary < 7000) THEN
                bonus := 500;
            END IF;
        ELSE
            bonus := 450;
        END IF;
    END;
        
BEGIN

    FOR record IN c
    LOOP
        Emp_Bonus(record.employee_id, empBonus);
        totalBonus := totalBonus + empBonus;
    END LOOP;
    
    dbms_output.put_line('Total Bonus: $' || totalBonus);
END;

-- 1a OUTPUT
/*
Total Bonus: $24900


PL/SQL procedure successfully completed.
*/

-- 1b
DECLARE
    empID employees.employee_id%type;
    empBonus number;
    totalBonus number := 0;
    
    CURSOR c IS
        SELECT employee_id
        FROM employees
        WHERE department_id = 80;
    
    FUNCTION F_Emp_Bonus( emp_id IN employees.employee_id%type )
    RETURN number IS bonus number;
    
    empSalary employees.salary%type;
    empComm employees.commission_pct%type;
    
    BEGIN
        SELECT salary, commission_pct
        INTO empSalary, empComm
        FROM employees
        WHERE employee_id = Emp_ID;
        
        IF (empComm >= 0.25) THEN
            IF (empSalary >= 10000) THEN
                bonus := 1000;
            ELSIF (empSalary BETWEEN 7000 AND 9999) THEN
                bonus := 800;
            ELSIF (empSalary < 7000) THEN
                bonus := 600;
            END IF;
        ELSIF (empComm BETWEEN 0.15 AND 0.24) THEN
            IF (empSalary >= 10000) THEN
                bonus := 700;
            ELSIF (empSalary BETWEEN 7000 AND 9999) THEN
                bonus := 600;
            ELSIF (empSalary < 7000) THEN
                bonus := 500;
            END IF;
        ELSE
            bonus := 450;
        END IF;
    RETURN bonus;
    END;
    
BEGIN

    FOR record IN c
    LOOP
        totalBonus := totalBonus + F_Emp_Bonus(record.employee_id);
    END LOOP;
    
    dbms_output.put_line('Total Bonus: $' || totalBonus);
END;

-- 1b OUTPUT
/*
Total Bonus: $24900


PL/SQL procedure successfully completed.
*/

-- 2
DECLARE
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

BEGIN
    dbms_output.put_line('Salary: $' || Emp_Sal(100));
    dbms_output.put_line('Salary: $' || Emp_Sal('SKING'));
END;

-- 2 OUTPUT
/*
Salary: $24000
Salary: $24000


PL/SQL procedure successfully completed.
*/

-- 3
DECLARE
    CURSOR c IS 
        SELECT employee_id
        FROM employees
        WHERE department_id = 60;

    TYPE Emp_Sal IS RECORD (
        Emp_ID employees.employee_id%type,
        Full_name varchar2(46),
        Sal employees.salary%type,
        Dept_id employees.department_id%type
        );
        
    empSalRecord Emp_Sal;
        
    FUNCTION Get_Emp_Sal( emp_id IN employees.employee_id%type )
    RETURN Emp_Sal IS Emp_Sal_Out Emp_Sal;
    BEGIN
        SELECT employee_id, first_name ||' '|| last_name, salary, department_id
        INTO Emp_Sal_Out
        FROM employees
        WHERE employee_id = emp_id;
        
        RETURN Emp_Sal_Out;
    END;
        
BEGIN
    FOR pointer IN c
    LOOP
        empSalRecord := Get_Emp_Sal(pointer.employee_id);
        dbms_output.put_line('ID-' || empSalRecord.Emp_ID ||' '|| empSalRecord.Full_name ||' ; Salary: $'|| empSalRecord.Sal ||' Dept-'|| empSalRecord.Dept_id);
    END LOOP;
END;

-- 3 OUTPUT
/*
ID-103 Alexander Hunold ; Salary: $9000 Dept-60
ID-104 Bruce Ernst ; Salary: $6000 Dept-60
ID-105 David Austin ; Salary: $4800 Dept-60
ID-106 Valli Pataballa ; Salary: $4800 Dept-60
ID-107 Diana Lorentz ; Salary: $4200 Dept-60


PL/SQL procedure successfully completed.
*/

-- 4
DECLARE
    TYPE emp_name IS RECORD (
        f_name varchar2(20),
        l_name varchar2(25)
    );
    
    emp1 emp_name;
    emp2 emp_name;
    emp3 emp_name;
    
    FUNCTION Emp_name_eq( r1 IN emp_name, r2 IN emp_name )
    RETURN BOOLEAN IS sameName BOOLEAN := FALSE;
    BEGIN
        IF ( (r1.f_name = r2.f_name) AND (r1.l_name = r2.l_name) ) THEN
            sameName := TRUE;
        END IF;
        
        RETURN sameName;
    END;

BEGIN
    SELECT first_name, last_name
    INTO emp1
    FROM employees
    WHERE employee_id = 202;
    
    SELECT first_name, last_name
    INTO emp2
    FROM employees
    WHERE employee_id = 202;
    
    emp3.f_name := 'Winston';
    emp3.l_name := 'Taylor';
    
    
    dbms_output.put_line('emp1 = emp2? ' || 
        CASE
            WHEN Emp_name_eq(emp1, emp2) THEN 'TRUE'
            ELSE 'FALSE'
        END
    );
    
    dbms_output.put_line('emp1 = emp3? ' || 
        CASE
            WHEN Emp_name_eq(emp1, emp3) THEN 'TRUE'
            ELSE 'FALSE'
        END
    );

END;

-- 4 OUTPUT
/*
emp1 = emp2? TRUE
emp1 = emp3? FALSE


PL/SQL procedure successfully completed.
*/