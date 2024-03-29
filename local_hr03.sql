select /*+ INDEX(idx_col1) */ *
  from hr.empt_t;
  
/* 실습 01A */  
-- 임시테이블 생성
DROP TABLE emp_t;
CREATE TABLE emp_t AS (SELECT * FROM scott.emp);

-- 인덱스 생성 (생성될 ㄸㅐ 통계정보가 항상 생성)
CREATE INDEX EMP_T_IDX ON EMP_T(ENAME,SAL);
CREATE INDEX DEPTNO_IDX ON EMP_T(DEPTNO);
CREATE INDEX EMP_SALNAME_IDX ON EMP_T(SAL,ENAME);

EXEC DBMS_STATS.GATHER_TABLE_STATS('HR', 'EMP_T');

SELECT *
  FROM EMP_T
 WHERE DEPTNO=20;

-- INDEX FULL SCAN (소트제거) 유도
SELECT *
  FROM EMP_T
 WHERE SAL > 2000
ORDER BY ENAME;
-- `CREATE INDEX EMP_T_IDX ON EMP_T(ENAME,SAL)` 이 인덱스는 위의 쿼리에 적합하지 않다.

-- FULL SCAN 을 한번 하고 SORT을 하기때문에 낭비가 많다.
SELECT /*+ INDEX(EMP_T EMP_SALNAME_INDEX) */ 
        *
FROM EMP_T
WHERE ROWNUM <= 5 --상위 5건
ORDER BY ENAME;

-- 실행계획확인
-- SELECT * FROM TABLE( DBMS_XPLAN.DISPLAY_CURSOR( null, null, 'ALLSTATS LAST')  );

ALTER TABLE EMP_T MODIFY ENAME NOT NULL;
SELECT *
  FROM (SELECT /*+ INDEX(EMP_T EMP_T)*/*
        ROWID AS RID
          FROM EMP_T
         ORDER BY ENAME)
  ) A, EMP_T B;
  WHERE ROWNUM <= 5


-- 실습 1B: 아래 SQL을 확인하고 적절한 인덱스를 설계하시오
CREATE INDEX EMP_JOB_DEPTNO_IDX ON EMP_T(JOB, DEPTNO);
SELECT DEPTNO
 FROM EMP
WHERE JOB IN ('CLERK','SALARY')
ORDER BY JOB, DEPTNO;

SELECT JOB, SUBSTR(DEPTNO, 1, 1) + 100 DEPTNO
FROM EMP
WHERE JOB IN ('CLERK', 'SALARY')
GROUP BY JOB, DEPTNO;

SELECT JOB, DEPTNO, AVG(SAL)
FROM EMP
WHERE JOB IN ('CLERK', 'SALARY')
GROUP BY JOB, DEPTNO;

SELECT JOB, SUBSTR(DEPTNO, 1, 10), AVG(SAL)
FROM EMP
WHERE JOB IN ('CLERK', 'SALARY')
GROUP BY JOB, SUBSTR(DEPTNO, 1, 10);

 
-- 실습 1C:
-- 1. 테스트 테이블 생성
CREATE TABLE BIG_TABLE as SELECT * 
                          FROM dba_tables, 
                          (SELECT LEVEL 
                           FROM DUAL
                           connect by LEVEL <= 1000);
DROP TABLE BIG_TABLE;


SELECT *
  FROM BIG_TABLE
WHERE OWNER = 'SYSTEM'
  AND TABLESPACE_NAME = 'SYSTEM'
  AND TABLE_NAME LIKE 'REPCAT$%'
ORDER BY TABLE_NAME DESC;


-- trace file 구분을 위한 identifier 적용
ALTER SESSION SET tracefile_identifier ='hnj';

-- trace 생성파일 확인
SELECT r.value || '/' || LOWER(t.instance_name) || '_ora_'
      || ltrim(to_char(p.spid)) || '_hnj'||'.trc' trace_file
  FROM v$process p, v$session s, v$parameter r, v$instance t
 WHERE p.addr = s.paddr
   AND r.name = 'user_dump_dest'
   AND s.sid = (SELECT sid 
                  FROM v$mystat 
                 WHERE rownum = 1)

-- 세션에 trace 적용
ALTER SESSION SET EVENTS '10046 trace name context forever, level 12' ; -- level 12로 생성
ALTER SESSION SET STATISTICS_LEVEL = 'all';

SELECT /*+ hnj1 */ /*+ INDEX_DESC(A BIG_TABLE_IDX1)*/ *
  FROM BIG_TABLE A
 WHERE OWNER = 'SYSTEM'
   AND TABLESPACE_NAME = 'SYSTEM'
   AND TABLE_NAME LIKE 'REPCAT$%'
 ORDER BY TABLE_NAME;

-- 문제: 인덱스를 만들어 보자
CREATE INDEX BIG_TABLE_IDX1 ON BIG_TABLE(TABLE_NAME DESC);          -- FUNCTION-BASED INDEX
CREATE INDEX BIG_TABLE_IDX2 ON BIG_TABLE(OWNER, TABLESPACE_NAME, TABLE_NAME DESC);

SELECT * FROM TABLE(  DBMS_XPLAN.DISPLAY_CURSOR(null, null, 'ALLSTATS LAST')  ); 

WHERE _SQL_

-- 세션에 trace off
ALTER SESSION SET EVENTS '10046 trace name context forever, off';

CREATE INDEX SCOTT.DEPT_IDX1 ON SCOTT.DEPT(LOC);
SELECT /*+ LEADING(A B) USE_NL(B) NO_NLJ_BATCHING(B) */ A.DNAME, B.ENAME, B.SAL
  FROM SCOTT.DEPT A, SCOTT.EMP B
 WHERE A.DEPTNO = B.DEPTNO
  AND B.SAL > 200
   AND A.LOC = 'DALLAS';

SELECT /*+ FULL(A) FULL(B) USE_HASH(A B) */ A.DNAME, B.ENAME, B.SAL
  FROM SCOTT.DEPT A, SCOTT.EMP B
 WHERE A.DEPTNO = B.DEPTNO
  AND B.SAL > 200
   AND A.LOC = 'DALLAS';


create index scott.EMP_IDX1 ON SCOTT.EMP(DEPTNO, SAL);

SELECT /*+ */ A.DNAME, B.ENAME, B.SAL
  FROM SCOTT.DEPT A, SCOTT.EMP B
 WHERE A.DEPTNO = B.DEPTNO
  AND B.SAL > 200
   AND A.LOC = 'DALLAS';   


-- 실습 5:
DESC DBA_IND_COLUMNS;
DESC DBA_TABLES;
DESC DBA_INDEXES;

CREATE TABLE IND_COLUMNS AS 
SELECT TABLE_OWNER AS OWNER, TABLE_NAME, INDEX_NAME, COLUMN_NAME FROM DBA_IND_COLUMNS;
CREATE TABLE INDEXES AS 
SELECT OWNER, TABLE_NAME, INDEX_NAME FROM DBA_INDEXES;
CREATE TABLE TABLES AS 
SELECT OWNER, TABLE_NAME FROM DBA_TABLES;

DROP TABLE IND_COLUMNS;
DROP TABLE INDEXES;
DROP TABLE TABLES;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));

CREATE INDEX TABLES_IDX1 ON TABLES(TABLE_NAME);
CREATE INDEX INDEXES_IDX1 ON INDEXES(OWNER, TABLE_NAME);
CREATE INDEX IND_COLUMNS_IDX1 ON IND_COLUMNS(OWNER, TABLE_NAME, INDEX_NAME);


SELECT A.OWNER, A.TABLE_NAME, B.INDEX_NAME, C.COLUMN_NAME
  FROM TABLES A, INDEXES B, IND_COLUMNS C
WHERE A.TABLE_NAME = 'EMP'
  AND A.OWNER = B.OWNER
  AND A.TABLE_NAME = B.TABLE_NAME
  AND B.OWNER = C.OWNER
  AND B.TABLE_NAME = C.TABLE_NAME
  AND B.INDEX_NAME = C.INDEX_NAME
  AND A.OWNER = C.OWNER
  AND A.TABLE_NAME = C.TABLE_NAME
ORDER BY C.INDEX_NAME, C.COLUMN_NAME
;


SELECT *
  FROM INDEXES
 WHERE TABLE_NAME = 'EMP'