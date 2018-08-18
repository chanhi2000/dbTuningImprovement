-- dba���ο� ��ġ�� ��� ���̺� ���
select * from all_tables;

-- ���� ���� �� 'hr` ������ ���� �ִ� ��� ���̺� ���
select * from user_tables;

-- ��ü ����ڿ� ���� ������ �˻��� �� (GRANT �� ���� ������ ����)
select * from dba_users;

 
/**
  * ���� �����ȹ ���� set autotrace $PARAMETER
  * on explain : ��ȹ��
  * on statistics : ��踸
  * traceonly explain : ������ ����, ��ȹ�� 
  * traceonly statistics : ������ ����, ��踸
*/

set autotrace on explain;
select * from DEPARTMENTS;

-- ���� �����ȹȮ��
explain plan for
select * from DEPARTMENTS;
select * from table(DBMS_XPLAN.DISPLAY);

-- ���� �����ȹȮ��  
SELECT * 
  FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, NULL, 'ADVANCED LAST'));

-- ���� �����ȹȮ��
SELECT * 
  FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ADVANCED LAST'));

/** 
 * SQL ���� ��� ���� ��ȸ
 * ���ø�ũ: https://docs.oracle.com/cd/B19306_01/server.102/b14237/dynviews_2113.htm
 */
SELECT /* HNJ */ * from DEPARTMENTS;
SELECT SQL_ID, CHILD_NUMBER, SQL_TEXT
  FROM V$SQL
 WHERE SQL_TEXT LIKE '%HNJ%'
   AND SQL_TEXT NOT LIKE '%V$SQL%';

SELECT * 
  FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR('4as1hpqvptnrs', 0, 'ADVANCED LAST'));

SELECT * FROM V$SQLAREA;

show parameter block;

-- ROWID�� ����� ����Ÿ ����
SELECT *
  FROM user_objects;
  
select A.*, ROWID
  FROM DEPARTMENTS A;
  
/** 
  * Ȱ��01 : �ߺ������� ����
  */
-- ���� ���̺� Ȯ��
SELECT *
  FROM ALL_TABLES
 WHERE OWNER = 'SCOTT';

-- ���̺� ����1
CREATE TABLE HR.EMPT_T AS 
SELECT * 
  FROM SCOTT.EMP;

INSERT INTO EMPT_T
SELECT *
  FROM SCOTT.EMP;
-- ���� ����
COMMIT;
  
SELECT COUNT(*) FROM SCOTT.EMP;
SELECT COUNT(*) FROM HR.EMPT_T;

-- scott.emp ���̺� �ε��� �Ӽ� Ȯ��
SELECT *
  FROM ALL_INDEXES
  WHERE OWNER = 'SCOTT'
    AND TABLE_NAME = 'EMP'; 
    
SELECT *
  FROM ALL_IND_COLUMNS
 WHERE INDEX_OWNER = 'SCOTT'
   AND INDEX_NAME = 'PK_EMP';  


-- ���� �ε��� ���� (����: �̹� UNIQUE�ϱ� ������ �ߺ��� ����)


-- �ߺ������� Ȯ�� / ����
  select *
  -- DELETE
    from HR.EMPT_T
   where ROWID NOT IN (SELECT MAX(ROWID) FROM HR.EMPT_T GROUP BY EMPNO);

SELECT SQL_ID, CHILD_NUMBER, SQL_TEXT
  FROM V$SQL
 WHERE SQL_TEXT LIKE '%MAX(ROWID) FROM HR.EMPT_T%'
   AND SQL_TEXT NOT LIKE '%V$SQL%';

SELECT * 
  FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR('6r73uhg4xbd06', 0, 'ADVANCED LAST'));

-- �ε��� ����
CREATE UNIQUE INDEX HR.PK_EMPT_T ON HR.EMPT_T(EMPNO);

SELECT *
  FROM ALL_INDEXES
  WHERE OWNER = 'HR'
    AND TABLE_NAME = 'EMPT_T'; 
    
SELECT *
  FROM ALL_IND_COLUMNS
 WHERE INDEX_OWNER = 'SCOTT'
   AND INDEX_NAME = 'PK_EMP';  

-- Ȱ�� : Merge Into Ȱ��
ALTER TABLE EMPT_T ADD (DEPTNO_TMP VARCHAR2(10));
ALTER TABLE EMPT_T DROP COLUMN DEPTNO_TMP;

TRUNCATE TABLE EMPT_T;
INSERT INTO EMPT_T
SELECT * FROM SCOTT.EMP;
COMMIT;

-- ��¡ �۾�
MERGE INTO HR.EMPT_T
USING (SELECT ROWID AS RID
       FROM HR.EMPT_T
       WHERE ROWID NOT IN (SELECT MAX(ROWID)
                           FROM HR.EMPT_T
                           GROUP BY EMPNO)) B
ON (A.ROWID = B.RID)
WHEN MATCHED THEN 
UPDATE SET A.EMP_NO = 'X';

ROLLBACK;

SELECT * FROM ALL_IND_COLUMNS WHERE INDEX_OWNER = 'HR' AND TABLE_NAME = 'EMPT_T' ORDER BY COLUMN_POSITION;

SELECT /*+ INDEX_DESC(T EMPT_T_PK) */ * 
 FROM EMPT_T T 
 WHERE EMPNO = 7521;


-- ���� ó��
SELECT /*+ PARALLEL(T 4) INDEX_FFS(A EMPT_T_PK) */ * 
  FROM EMPT_T T;

-- CLUSTERING FACTOR
  create table t as 
  select * from all_objects 
  order by object_id;
  
-- cf = good
create index t_object_id_idx
on t(object_id);

-- cf = bad  
create index t_object_name_idx 
on t(object_name);

-- ������� ����
exec dbms_stats.gather_table_stats(user, 'T');

-- CLUSTERING FACTOR�� �������� ���� ��ġ
select i.index_name, t.blocks table_blocks, i.num_rows, i.clustering_factor
from   user_tables t, user_indexes i
where t.table_name = 'T'
and   i.table_name = t.table_name;



