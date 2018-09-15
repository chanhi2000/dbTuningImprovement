CREATE TABLE EMP1 AS 
    SELECT * FROM SCOTT.EMP,
        (SELECT LEVEL NO FROM DUAL CONNECT BY LEVEL <= 1000)
;

CREATE TABLE EMP2 AS 
    SELECT * FROM SCOTT.EMP;

ALTER TABLE EMP1 ADD CONSTRAINT EMP1_PK PRIMARY KEY (NO, EMPNO);
ALTER TABLE EMP2 ADD CONSTRAINT EMP2_PK PRIMARY KEY (EMPNO);

EXEC DBMS_STATS.GATHER_TABLE_STATS(USER, 'EMP1');
EXEC DBMS_STATS.GATHER_TABLE_STATS(USER, 'EMP2');


