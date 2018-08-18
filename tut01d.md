# D-01d:

---

## 인덱스 기본 원리
B*Tree 인덱스를 정상적으로 사용하려면 범위 스캔 시작지점을 찾기 위해 루트 블록부터 리프블록까지의 수직적 탐색 과정을 거쳐야 함

### 인덱스 사용이 불가능 하거나 범위 스캔이 불가능한 경우
 - 정상적인 인덱스 범위 스캔이 불가능한 경우(Index Full Scan은 가능)
	- 인덱스 컬럼을 조건절에서 가공: `where substr(업체명, 1, 2) = '대한'`
	- 부정형 비교: `where 직업 <> '학생'`
	- `is not null` 조건도 부정형 비교에 해당: `where 부서코드 is not null`
	> '부서코드'에 단일 컬럼 인덱스가 존재한다면 인덱스 전체 스캔을 통해 얻은 레코드는 모두 '`부서코드 is not null`' 조건을 만족.
 - 인덱스 사용이 불가능한 경우
	- `is null` 조건만으로 검색할 때: `where 연락처 is null`
	> 예외적으로 해당 컬럼이 `not null` 제약이 있을 경우 Table Full Scan을 피하기 위해 사용.
	- `is null` 조건을 사용하더라도 다른 인덱스 구성 컬럼에 `is null` 이외의 조건식이 하나라도 있으면 Index Range Scan 가능 (인덱스 선두 컬럼이 조건걸에 누락되지 않아야 한다) `emp_idx : job + deptno where job is null and deptno = 20`

### 인덱스 컬럼의 가공

| 인덱스 컬럼 가공 사례 | 튜닝 방안 |
| ------------------- | --------- |
| `substr(업체명, 1, 2) = '대한'` | `업체명 like '대한%'` | 
| `월급여 * 12 = 36000000` | `월급여 = 36000000 / 12` |
| `to_char(일시, 'yyyymmdd') = :dt` | `일시 >= to_date(:dt, 'yyyymmdd') and 일시 < to_date(:dt, 'yyyymmdd') + 1` | 
| `연령 || 직업 = '30공무원'` | `연령 = 30 and 직업 = '공무원'` |
| `회원번호 || 지점번호 = :str` | `회원번호 = substr(:str, 1, 2) and 지점번호 = substr(:str, 3, 4)` |
| `nvl(주문수량, 0) >= 100` | `주문수량 >= 100` |
| `nvl(주문수량, 0) < 100` | `create index 주문_x01 on 주문(nvl(주문수량, 0) );` |
`not null` 컬럼이면 `nvl`제거, 아니면 함수기반 인덱스(FBI) 생성 고려 


#### 튜닝사례1
일별지수업종별거래및시세_PK : 지수구분코드 + 지수업종코드 + 거래일자
일별지수업종별거래및시세_X01 : 거래일자
```sql
거래일자 between :startDd and :endDd
and 지수구분코드 || 지수업종코드 in ('1001', '2003');  => 거래일자 인데스 사용 혹은 Full Table Scan
=>
거래일자 between :startDd and :endDd
and (지수구분코드, 지수업종코드) in (('1', '001'), ('2', '003')); => PK 인덱스 사용
```

### 튜닝사례2
접수정보파일_PK : 수신번호
접수정보파일_X01 : 정정대상접수번호 + 금감원접수번호
```sql


decode(정정대상접수번호, lpad(' ', 14), 금감원접수번호, 정정대상접수번호) = :접수번호 => Full Table Scan
=>
정정대상접수번호 in (:접수번호, lpad(' ', 14))
and 금감원접수번호 = decode(정정대상접수번호, lpad(' ', 14), :접수번호, 금감원접수번호) 
=> 접수정보파일_X01 Index Range Scan
```


## 데이터타입 우선순위
 - 숫자형 > 문자형, 
 - 날짜형 > 문자형

### 예제1.
```sql
select * from EMP where empno||''=7900;
select *  from table(dbms_xplan.display);
```

### 예제2.
```sql
explain plan for
select * from EMP where empno=7900;
select *  from table(dbms_xplan.display);
```

### 예제3.
```sql
explain plan for
select * from EMP where empno='7900';
select *  from table(dbms_xplan.display);
```