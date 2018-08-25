-- ���ѿ��� ��� �� �� �ִ� ��� ���̺��� ���
select *
  from user_tables;

-- ���� ������� ���̺��� ���;
select * 
  from empt_t;

-- �ƹ��� ���� ���� ��������� ����/����
-- ����: �����ȹ�� �����ϴ� ��� ������ �Ժη� ������ �ȵȴ�.
exec DBMS_STATS.GATHER_TABLE_STATS('HR', 'EMPT_T');


-- ��ü������ �� �ڼ��� �˾ƺ���.
select TABLE_NAME, NUM_ROWS, BLOCKS, LAST_ANALYZED
  from user_tables;

-- ��������� �˼� �ִ� ������ ���̺��� ����.
-- �翬�� �� ���̺��� ��������� ������ �� �� �ִ�.
CREATE TABLE test
(
COL1 NUMBER,
COL2 VARCHAR2(10)
);

-- WITH�� �� ���� ��� ����Ÿ�� ��������� ���� �۾ƾ� ȿ�������� �� �� �ִ�.
-- Viewó�� �Ǿ� Temp Table Space�� ������ ���� �ϰ� �ȴ�.
WITH TMP AS 
(
SELECT EMPNO, ENAME, JOB FROM EMPT_T
)
SELECT * FROM TMP WHERE ENAME = 'SMITH'
 UNION ALL
SELECT * FROM TMP WHERE EMPNO = 7499;