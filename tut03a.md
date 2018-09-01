# D03-a:

## Hint

### 기본 사용예
```sql
SELECT /*+ INDEX(idx_col1) */ id, password, name
  FROM emp;

 SELECT /*+ ORDERED  INDEX(b idx_col1) */ id, password, name
  FROM emp a, depart b
```
> __주의__: 주석 표시 뒤에 `+` 기호가 있다


### INDEX Access Operation related HINT

| Hint | Description | Usage |
| ---- | ------- | ----- |
| `INDEX` |  `INDEX`를 순차적으로 스캔 | `INDEX(TABLE_name, INDEX_name)` |
| `INDEX_ASC` | `INDEX`를 내림차순으로 스캔. | _ | 
| `INDEX_DESC` | `INDEX`를 오름차순으로 스캔. | `INDEX_DESC(TABLE_name, INDEX_name)` |
| `INDEX_FFS` | `INDEX` FAST FULL SCAN | `INDEX_FFS(TABLE_name, INDEX_name)` |
| `PARALLEL_INDEX` | `INDEX` PARALLEL SCAN | `PARALLEL_INDEX(TABLE_name, INDEX_name)` |
| `NOPARALLEL_INDEX` | `INDEX` PARALLEL SCAN 제한 | `NOPARALLEL_INDEX(TABLE_name, INDEX_name)` |
| `AND_EQUALS` | 여러개의 `INDEX MARGE` 수행 | `AND_EQUALS(INDEX_name, INDEX_name)` |
| `FULL` | `FULL SCAN` 지정된 테이블에 대한 전체 스캔. | `FULL(TABLE_name)` |


### `JOIN` Access Operator related HINT

| HINT | Description | Usage |  
| ---- | ----------- | ----- |
| `USE_NL` | NESTED LOOP JOIN 옵티마이저가 NESTED LOOP JOIN을 사용하도록 한다. 먼저 특정 TABLE의 ROW에 액세스하고 그 값에 해당하는 다른 TABLE의 ROW를 찾는 작업을 해당범위까지 실행하는 조인. | `USE_NL(TABLE1, TABLE2)` |
| `USE_NL_WITH_INDEX` | INDEX를 사용해서 NESTED LOOP JOIN을 사용하도록 한다. |  `USE_NL_WITH_INDEX(TABLE  INDEX)` |
| `USE_MERGE` | SORT MERGE JOIN 옵티마이저가 SORT MERGE JOIN을 사용하도록 한다.  먼저 각각의 TABLE의 처리 범위를 스캔하여 SORT한 후, 서로 MERGE하면서 JOIN하는 방식. | `USE_MERGE(TABLE1, TABLE2)` |
| `USE_HASH` | HASH JOIN 옵티마이저가 HASH JOIN을 사용하도록 한다. | `USE_HASH(TABLE1, TABLE2)` |
| `HASH_AJ` | HASH ANTIJOIN | `HASH_AJ(TABLE1, TABLE2)` |
| `HASH_SJ` | HASH SEMIJOIN | `HASH_SJ(TABLE1, TABLE2)` |
| `NL_AJ` | NESTED LOOP ANTIJOIN | `NL_AJ(TABLE1, TABLE2)` |
| `NL_SJ` | NESTED LOOP SEMIJOIN | `NL_SJ(TABLE1, TABLE2)` |
| `MERGE_AJ` | SORT MERGE ANTIJOIN | `MERGE_AJ(TABLE1, TABLE2)` |
| `MERGE_SJ` | SORT MERGE SEMIJOIN | `MERGE_SJ(TABLE1, TABLE2)` |


### `JOIN`시 DRIVING 순서 결정 HINT

| HINT | Description | Usage | 
| `ORDERED` | FROM절에 명시된 테이블의 순서대로 DRIVING | _ |
| `LEADING` | 파라미터에 명시된 테이블의 순서대로 JOIN | `LEAING(TABLE_name1, TABLE_name2, ...)` |
| `DRIVING` | 해당 테이블을 먼저 DRIVING | `DRIVING(TABLE)` |


### Misc. HINT

| HINT | Description | Usage | 
| `APPEND` | `INSERT`시 DIRECT LOADING | _ |
| `PARALLEL` | `SELECT`, `INSERT`시 여러개의 프로세스로 수행 | `PARALLEL(TABLE, 개수)` |
| `CACHE` | 데이터를 메모리에 CACHING | _ |
| `NOCACHE` | 데이터를 메모리에 CACHING하지 않음 | _ |
| `PUSH_SUBQ` | SUBQUERY를 먼저 수행 | _ |
| `REWRITE` | QUERY REWRITE 수행 | _ |
| `NOREWIRTE` | QUERY REWRITE를 수행 못함 | _ |
| `USE_CONCAT` | IN절을 CONCATENATION ACCESS OPERATION으로 수행 | _ |
| `USE_EXPAND` | IN절을 CONCATENATION ACCESS OPERATION으로 수행못하게 함 | _ |
| `MERGE` | VIEW MERGING 수행 | _ |
| `NO_MERGE` | VIEW MERGING 수행못하게 함 | _ |
| `ALL_ROWS` | 가장 좋은 단위 처리량의 목표로 문 블록을 최적화하기 위해 cost-based 접근 방법을 선택합니다. (즉, 전체적인 최소의 자원 소비, 모든 레코드의 처리하는 시간의 최소화를 목적으로 최적화) | _ |
| `FIRST_ROWS` | 가장 좋은 응답 시간의 목표로 문 블록을 최적화하기 위해 cost-based 접근 방법을 선택합니다. (첫번째 레코드의 추출 시간을 최소화할 목적으로 최적화) | _ |
| `CHOOSE` | 최적자(optimizer)가 그 문에 의해 접근된 테이블을 위해 통계의 존재에 근거를 두는 SQL문을 위해 rule-based 접근 방법과 cost-based 접근 방법 사이에 선택하게 됩니다. | _ |
| `CLUSTER` | 지정된 테이블에 대한 클러스터 스캔. | _ |
| `HASH` | 지정된 테이블에 대한 해쉬 스캔. | _ |
| `ROWID` | 지정된 테이블에 대한 ROWID에 의한 테이블 스캔. | _ |
| `RULE` | explicitlly chooses rule-based optimization for a statement block. rule-base Optimizer를 사용 | _ | 

- 출처: [초록지붕의 앤][00]
- 정리표 엑샐: [http://wiki.gurubee.net/download/attachments/983183/HINT_Dictionray.xls?version=1][01]



[00]: http://annehouse.tistory.com/413
[01]: http://wiki.gurubee.net/download/attachments/983183/HINT_Dictionray.xls?version=1