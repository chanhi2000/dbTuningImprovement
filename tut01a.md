# D-01a:

## 설치

- #### Oracle XE 다운로드 / 설치
[http://www.oracle.com/technetwork/database/database-technologies/express-edition/downloads/index.html][0]
- #### Oracle SQL Developer 설치
[http://www.oracle.com/technetwork/developer-tools/sql-developer/downloads/index.html][1]
> 참고사이트 : [http://keep-cool.tistory.com/23][2]


## 접속

```sql
connect sys/oracle as sysdba
```
> `sys` 계정으로 로그인하는 명령어이며, 여기서 `oracle`은 데이터베이스를 설치할 때 설정해주었떤 비밀번호이다.

```sql
alter user hr identified by hr account unlock;
```
> `hr` 계정의 비밀번호를 `hr`로 설정하고, 잠겨있던 `hr`계정의 잠금을 해제하는 명령어이다.
>> `sys`계정으로 로그인해야만 위의 명령어를 사용할 수 있기 때문에 `sys`계정을 먼저 로그인한 것이다.

![0A][0A]
## 비밀본호 기억 못할 시
```sql
sqlplus /nolog
conn /as sysdba
```


## 상태확인 

```sql
select * from dba_users
```
> 시스템 내에 속해있는 모든 관련 유저 정보를 출력한다.
![0B][0B]

## `*.sql`파일 접근
- __경로__: `C:\oraclexe\app\oracle\product\11.2.0\server\rdbms\admin\scott.sql`
![0C][0C]
![0E][0E]


## 개념
- `DBMS`: Database Management System. (정합성 보장, 백업과 복구, 질의 처리 및 보안)
- `SQL` : 
- `DML` :	`insert`, `update`, `delete`
- `DCL` :	`revoke`, `grant`
- `DDL` :	`alter`, `create`
 
> 참조 : [설명링크01][3], [설명링크02][4]


## MISC
```sql 
	set linesize 200
	col table_name for a13
```


https://m.blog.naver.com/hsm119216/30094842888


[0]: http://www.oracle.com/technetwork/database/database-technologies/express-edition/downloads/index.html 
[1]: http://www.oracle.com/technetwork/developer-tools/sql-developer/downloads/index.html
[2]: http://keep-cool.tistory.com/23
[3]: http://yagi815.tistory.com/288
[4]: http://cafe.daum.net/oratun/k877/3


[0A]: imgs/[screenshot]01.png
[0B]: imgs/[screenshot]05.png
[0C]: imgs/[screenshot]06a.png
[0E]: imgs/[screenshot]06c.png
