-- 3
set serveroutput on;

DECLARE
    loopCurrent NUMBER := 50;
    
    Exceed_Limit Exception;
    
BEGIN
    loop
        dbms_output.put_line('Counter : ' || loopCurrent);
        loopCurrent := loopCurrent + 3;
        if loopCurrent > 60 then
            raise Exceed_Limit;
        end if;
    end loop;
    exception
        when Exceed_Limit then
            dbms_output.put_line('Error: Counter greater than limit of 60');
END;

-- 4
DECLARE
    empID employees.employee_id%type;
    empSal employees.salary%type;
    
    cursor empCursor is 
        SELECT employee_id, salary
        FROM employees
        WHERE job_id = 'IT_PROG'
        ORDER BY salary DESC;
        
    Sal_too_low Exception;
    
BEGIN

    for record in empCursor
    loop
        if record.salary < 5000 then
            empID := record.employee_id;
            empSal := record.salary;
            
            raise Sal_too_low;
        end if;
    end loop;
    exception
        when Sal_too_low then
            dbms_output.put_line('Error: Salary ($' || empSal || ') too low for employee ID-' || empID);

END;

-- 5
DROP TABLE log_error; -- in case you have that table created, otherwise ignore it

CREATE TABLE log_error (
  Occur_date  DATE DEFAULT SYSDATE,
  Username    VARCHAR2 (15) DEFAULT USER,
  Err_code    NUMBER,
  Err_msg     VARCHAR2 (255));
  
DECLARE
    errorCode NUMBER;
    errorText varchar2(255);
    
BEGIN
    SAVEPOINT save1;
    
    DELETE FROM employees
    WHERE employee_id = 104;
    
    DELETE FROM employees
    WHERE employee_id = 123;
    
    ROLLBACK TO save1;
    
    exception
        when OTHERS then
            errorCode := SQLCODE;
            errorText := SQLERRM;
            INSERT INTO log_error 
            VALUES (SYSDATE, USER, errorCode, errorText);
    
END;

SELECT * from log_error;
