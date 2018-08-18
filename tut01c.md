# D-01c:

---

## Auto Trace

### 개요
SQL 수행 시 실제 일량 측정 및 튜닝하는데 유용한 정보들을 많이 포함하는 도구

### AutoTrace 옵션
아래와 같은 옵션에 따라 필요한 부분만 출력해 볼 수 있음
1. `set autotrace on` : SQL을 실행하고 그결과와 함께 실행 계획 및 실행통계를 출력
2. `set autotrace on explain` : SQL을 실행하고 그결과와 함께 실행 계획을 출력
3. `set autotrace on statistics` : SQL을 실행하고 그결과와 함께 실행통계를 출력
4. `set autotrace traceonly` : SQL을 실행하지만 그 결과는 출력하지 않고, 실행계획과 실행통계만을 출력
5. `set autotrace traceonly explain` : SQL을 실행하지않고 실행계획만을 출력
6. `set autotrace traceonly statistics` : SQL을 실행하지만 그 결과는 출력하지 않고, 실행통계만을 출력

>	1~3 수행 결과를 출력 해야 하므로 쿼리를 실제 수행
>	4,6 실행 통계를 보여줘야 하므로 쿼리를 실제 수행
>	5 번은 실행 계획만 출력하면 되므로 실제 수행하지 않음

### AutoTrace 필요권한
 - Autotrace 기능을 실행계획 확인 용도로 사용한다면 Plan_Table만 생성 되어 있으면 가능
 - 실행통계 까지 확인 하려면 `v_$sesstat`, `v_$statname`, `v_$mystat` 뷰에 대한 읽기 권한이 필요
 - `dba`, `select_catalog_role` 등의 롤을 부여받지 않은 사용자의 경우 별도의 권한 설정이 필요
- `plustrace` 롤을 생성하고 롤을 부여하는 것이 편리

```sql
SQL> @?/sqlplus/admin/plustrace.sql
SQL> grant plustrace to scott;
```

### `DBMS_XPLAN`
- `DBMS_XPLAN.DISPLAY`
- `DBMS_XPLAN.DISPLAY_CURSOR`

#### 예제1: 예상 실행계획 확인

```sql
explain plan for
select * 
  from EMP 
 where empno=7900;
select * 
  from table(dbms_xplan.display);
```

#### 예제2: 예상 실행계획 확인 (`sql_id`)

```sql
SELECT * 
  FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, NULL, 'BASIC'));
SELECT * 
  FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, NULL, 'ADVANCED'));
-- 필수확인
show parameter statistics_level;
select * 
  from v$parameter 
 where name like '%statistics_level%';
```

#### 예제3: 실제실행계획 확인

```sql
SET SERVEROUTPUT OFF;
alter session set statistics_level = 'ALL';
select /*+ GATHER_PLAN_STATISTICS *//* HNJ */ * from EMP where empno=7900;
-- sql_id 확인
SELECT SUBSTR(SQL_TEXT, 1, 30) SQL_TEXT, SQL_ID, CHILD_NUMBER
  FROM V$SQL
 WHERE SQL_TEXT LIKE '%HNJ%'
   AND SQL_TEXT NOT LIKE '%V$SQL%';

SELECT * 
  FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR('a1n5k59v630kb', 0, 'ALLSTATS LAST'));
```


### 참고
 - [SQL 실행계획][0a]

[0a]: http://blog.naver.com/PostView.nhn?blogId=sophie_yeom&logNo=220891529668
