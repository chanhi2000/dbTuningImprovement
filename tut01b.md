# D-01b

---

## 기본 Architecture
- 오라클은 데이터베이스와 이를 액세스하는 프로세스 사이에 메모리 캐시 영역(SGA)이 있다.

![0F][0F]

	- 디스크 I/O 에 비해 메모리 캐시 I/O 는 매우 빠르다.
	- 많은 프로세스가 동시에 데이터를 액세스 하기 때문에 사용자 데이터를 보호하는 Lock 과 공유 메모리 영역인 SGA 에 위치한 데이터 구조 액세스를 직렬화 하기 위한 Latch도 필요.
	- 오라클은 블록 단위로 I/O 하며, DBWR/CKPT 가 주기적으로 캐시-데이터파일 동기화 수행.
- `Database` : 디스크에 저장된 데이터 집합(Datafile, Redo Log File, Control File...)
- `Instance` : SGA + Process
- `Server Process` : 사용자 명령 처리
	- Dedicated Server Process : 클라이언트를 위한 전용 프로세스, 사용자에게 필요한 서비스 제공 (SQL 파싱, 최적화, 실행, 블록 읽기, 읽은 데이터 정렬, 네트워크 전송)
	- 스스로 처리하지 못하는 일을 만나면 OS, I/O 서브시스템, Background Process 등에 신호를 보내 대신 일을 처리하도록 요청
- `Background Process` : 뒤에서 역할 수행 

### 오라클 접속할 시 내부 처리 과정

![0G][0G]

리스너에 연결 요청 시 서버프로세스를 띄우고(Fork) 메모리(PGA)를 할당 한다.
 - 비용이 큰 작업 이므로 성능을 위해 Connection Pool 을 통해 __재사용__ 필수 

### Connection Pool

![0H][0H]

### RAC

![0I][0I]

- 하나의 데이터베이스를 엑세스 하는 다중 인스턴스로 구성
- 과거 공유 디스크 방식, 현재 공유 캐시 방식
- 글로벌 캐시 개념 : 로컬 캐시에 없는 데이터 블록을 원격 노드에서 전송 받음
- 다른 인스턴스의 Dirty 버퍼도 Interconnect 를 통해 주고 받으며 갱신 수행, OPS 는 디스크로 쓰기 작업 선행 필요 (Ping) 


## DB 버퍼 캐시
메모리 캐시 영역(SGA) 중 사용자 데이터가 거쳐 가는 부분

### 블록 단위 I/O
오라클에서 I/O는 블록(Block) 단위로 이뤄짐

- single block read / multi block read (`Full Scan`, `DBWR`)
- 하나 레코드의 하나 컬럼만 읽어도 속한 블록 전체를 읽음
- 블록 개수
	- SQL 성능을 좌우하는 가장 중요한 성능 지표
	- 옵티마이저의 판단에 가장 큰 영향을 미침 (`INDEX SCAN` / `FULL TABLE SCAN`)  

### 버퍼 캐시 구조
바둑판처럼 생긴 버퍼 캐시에서 읽고자 하는 블록을 어떻게 찾는가? (해시 테이블)
![0J][0J]

- 해시 테이블(해시 맵)은 SGA 내에서 가장 많이 사용되는 자료구조.
- 주소록과 유사 - 성씨가 같은 고객은 같은 페이지(해시 버킷)에 정렬 없이 관리
- 해시 버킷 내에서 스캔 방식 사용 (성능을 위해 각 버킷 내 엔트리 개수 일정 수준 유지 필요) 버퍼 캐시도 해시 테이블 구조로 관리 됨 - 해시 키 값 : DBA(Data Block Address)
	- 해시 함수에 DBA 입력해 리턴 받은 해시 값이 같은 블록들을 같은 해시 버킷에 연결 리스트(해시 체인)로 구조화
	- 필요한 블록 주소를 해시 버킷에서 스캔 후 있으면 읽고, 없으면 디스크에서 읽어 해시 체인에 연결 후 읽음

버퍼 헤더만 해시 체인에 연결 됨, 데이터 값은 포인터를 이용해 버퍼 블록을 찾아 얻게 됨

![0K][0K]

### 캐시 버퍼 체인
각 해시 체인은 Latch 에 의해 보호 됨

- DB 버퍼 캐시는 공유 메모리 영역에 존재 하므로 동시 액세스 가능 하며, 액세스 직렬화(Serialization) 메커니즘 필요 (*i.e*. Latch) 
- Latch 를 획득한 프로세스만 그 Latch 에 의해 보호되는 자료구조 진입 허용
- Cache Buffers Chains: 해시 체인에 버퍼 블록을 스캔/연결/해제 작업 보호, 하나의 Latch 가 여러 해시 체인을 동시 보호
- DB 버전 별 Latch 갯수

| DB버전 | Latch 갯수 |
| ------ | --------- |
| 9i | 241 개 |
| 10g | 394 개 |
| 11g |	496 개 |

- 해시 버킷, 블록 버퍼, 래치 갯수

| 구분 | 파라미터 | 책 | 실제(11g) |
| --- | -------- | -- | --------- |
| 해시 버킷 개수 | _db_block_hash_buckets	 | 2,097,152 | 8,388,608 |
| 래치 개수 | _db_block_hash_latches	| 65,536 | 262,144 |
| 래치 당 해시 버킷 수 | - | 32 | 32 |
| 블록 버퍼 개수 | _db_block_buffers | 836,684 | 3,084,990 |
| 해시 버킷 개수 / 블록 버퍼 개수 | - | 2.5 | 2.7 |

- 하나의 해시 체인에 하나의 버퍼만 달리는 것이 목표 임 - 해시 체인 스캔 비용 최소화
- 블록 버퍼 대비 해시 버킷 개수가 충분히 많아야 함 - 2.5배 ?

- 9i 부터 읽기 전용 작업 시 cache buffers chains Latch 를 Share 모드 획득 가능
	- SELECT (X) , 필요한 블록을 찾기 위한 해시 체인 스캔 (O)
- 버퍼 헤더에 Pin 설정 시 cache buffers chains Latch 사용
	- Share 모드 획득 후, 체인 구조 변경 혹은 버퍼 헤더에 Pin 설정 시 Exclusive 모드로 변

### 캐시 버퍼 LRU 체인
- LRU(Least Recently Used) 알고리즘

![0L][0L]

	- 사용 빈도 높은 블록들 위주로 버퍼 캐시가 구성 되도록 함
	- 모든 버퍼 블록 헤더를 LRU 체인에 연결
	- 사용 빈도 순으로 위치 이동
	- Free 버퍼 필요시 액세스 빈도가 낮은 블록을 우선 밀어냄 (자주 액세스 되는 블록이 캐시에 더 오래 남게 됨)
	- cache buffers lru chain Latch 로 보호
- 모든 버퍼 블록은 둘중 하나의 LRU 리스트에 속함
	- Dirty 리스트 : 캐시 내 변경 됨, 아직 디스크에 반영 안된 블록 관리 (LRUW 리스트)
		- 변경 시 리스트에서 잠시 나옴
	- LRU 리스트 : Dirty 리스트 외 나머지 블록 관리
		- 변경 시 Dirty 리스트로 이동
- 모든 버퍼 블록은 셋중 하나의 상태임
	- Free 버퍼 : 빈 상태 혹은 데이터 파일과 동기화 된 상태, 언제든 덮어 쓸 수 있음,
		- 변경 시 Dirty 버퍼 됨
	- Dirty 버퍼 : 변경 되어 데이터 파일과 동기화 필요 상태, 동기화 되면 Free 버퍼 됨
	- Pinned 버퍼 : 읽기/쓰기 작업 중인 버퍼 블록

### Redo
데이터/컨트롤 파일의 모든 변경 사항을 하나의 Redo 로그 엔트리로서 Redo 로그에 기록

| Redo 구분 | 속성 |
| --------- | ---- |
| Online | Redo 로그 버퍼에 버퍼링된 로그 엔트리를 기록하는 파일, 최소 두 개 구성, 라운드 로빈 로그 스위칭 발생 |
| Archived | Online Redo 로그 파일이 재사용 되기 전 다른 위치로의 백업본 |

> #### _Redo 목적_
>>	1. Database Recovery
>> 	2. Cache Recovery (Instance Recovery)
>> 	3. Fast Commit

- Media Fail 발생 시 데이터베이스 복구 위해 Archived Redo 로그 사용 인스턴스 비정상 종료 시 휘발성의 버퍼 캐시 데이터 복구 위해 Redo 로그 사용
	- 인스턴스 재기동 시 Online Redo 로그의 마지막 Checkpoint 이후 트랜잭션의 Roll Forward (버퍼 캐시에만 존재했던 변경 사항이 Commit 여부와 관계 없이 복구 됨)
	- Undo 데이터를 이용해 Commit 안된 트랜잭션을 Rollback (Transaction Recovery)
	- 데이터 파일에는 Commit 된 변경 사항만 존재
- Fast Commit 을 위해 Redo 로그 사용 메모리의 버퍼 블록이 아직 디스크에 기록되지 않았지만 Redo 로그를 믿고 빠르게 커밋 완료
	- 변경 사항은 Redo 로그에는 바로 기록하고, 버퍼 블록의 메모리-디스크 동기화는 나중에 일괄 수행
	- 버퍼 블록의 디스크에 기록은 Random 액세스(느림), Redo 로그 기록은 Append 액세스 (빠름)

> #### Delayed 블록 클린아웃
>> - 로우 Lock 이 버퍼 블록 내 레코드 속성으로 구현 되어 있어, Commit 시 바로 로우 Lock 해제 불가능
>> - Commit 시점에는 Undo 세그먼트 헤더의 트랜잭션 테이블에만 Commit 정보 기록, 블록 클린아웃(Commit 정보 기록, 로우 Lock 해제)은 나중에 수행

- Redo 레코드는 Redo 로그 버퍼 → Redo 로그 파일 기록 됨
1. 3초마다 DBWR 로부터 신호 받을 때 (DBWR 은 Dirty 버퍼를 데이터 파일에 기록하기 전 LGWR 에 신호 보냄)
	- Write Ahead Logging (DBWR 가 Dirty 블록을 디스크에 기록하기 전, LGWR 는 해당 Redo 엔트리를 모두 Redo 로그 파일에 기록 해야 한다.)
2. 로그 버퍼의 1/3이 차거나, Redo 레코드량이 1MB 넘을 때
3. 사용자 Commit/Rollback - Log Force at Commit (최소 Commit 시점에는 Redo 정보가 디스크에 저장 되어야 한다.) 

- Fast Commit 메커니즘

![0M][0M]

- 사용자 Commit
- LGWR 가 Commit 레코드 Redo 로그 버퍼 기록
- 트랜잭션 로그 엔트리와 함께 Redo 로그 파일 기록 (이후 복구 가능)
- 사용자 프로세스에 Success Code 리턴 

> #### `log file sync`
>> LGWR 프로세스가 로그 버퍼 내용을 Redo 로그 파일에 기록 하는 동안 서버 프로세스가 대기하는 현상

- Undo 세그먼트는 일반 세그먼트와 다르지 않다. (Extend 단위 확장, 버퍼 캐시 캐싱, 변경사항 Redo 로깅)
- 트랜잭션 별로 Undo 세그먼트가 할당 되고 변경 사항이 Undo 레코드 단위로 기록 됨 (복수 트랜잭션이 한 Undo 세그먼트 공유 가능)

| 구분 | 설명 |
| ---- | --- |
| Rollback | 8i 까지, Rollback 세그먼트 수동 관리 |
| Undo | 9i 부터, AUM(Automatic Undo Management) 도입 |

> #### AUM
>> - 1 Undo 세그먼트, 1 트랜잭션 목표로 자동 관리
>> - Undo 세그먼트 부족 시 가장 적게 사용되는 Undo 세그먼트 할당
>> - Undo 세그먼트 확장 불가 시 다른 Undo 세그먼트로 부터 Free Undo Space 회수 (Dynamic Extent Transfer)
>> - Undo Tablespace 내 Free Undo Space 가 소진 되면 에러 발생

### Undo 목적
- Transaction Rollback: 트랜잭션 Rollback 시 Undo 데이터 사용
- Transaction Recovery: Instance Recovery 시 Roll Forward 후 Commit 안된 트랜잭션 Rollback 시 Undo 데이터 사용
- Read Consistency: 읽기 일관성을 위해 Undo 데이터 사용 (다른 DB는 Lock 을 통해 읽기 일관성 구현) 

### Undo 세그먼트 트랜잭션 테이블 슬롯
Undo 세그먼트 중 첫 익스텐트, 첫 블록의 Undo 세그먼트 헤더에 트랜잭션 테이블 슬롯이 위치

![0N][0N]

- 트랜잭션 테이블 슬롯 기록 사항
	- 트랜잭션 ID: USN(Undo Segment Number)# + Slot# + Wrap#
	- 트랜잭션 상태 정보 (Transaction Status)
	- 커밋 SCN (트랜잭션이 커밋 된 경우)
	- Last UBA (Undo Block Address)
	- 기타
		- 트랜잭션 테이블 슬롯(Slot) 할당 및 Active 표시 후 트랜잭션 시작 가능 (대기 이벤트 : undo segment tx slot)
		- 트랜잭션의 변경사항은 Undo 블록에 Undo 레코드로서 순차적으로 하나씩 기록 됨 (Last UBA[Undo Block Address] 정보로 마지막 Undo 레코드 확인
			- Undo 레코드는 체인 형태로 연결 되며, Rollback 시 체인을 거슬러 올라가며 작업 수행
		- `v$transaction.{used_ublk, used_urec}`
			- 트랜잭션이 사용중인 Undo Block 수, Undo 레코드 수 확인 가능

DML 별 Undo 레코드 내용

![0O][0O]

| 구분 | Undo 레코드 내용 | `v$transaction.used_urec` 증가(TBL) | v$transaction.used_urec 증가(TBL+IDX) | 비고 |
| ---- | -------------- | ------------------------------------ | ---------------------------- | ---- | 
| INSERT | 추가된 레코드 ROWID | 1 | 2 | _ |
| UPDATE | 변경 | 컬럼 | Before Image | 1 | 3 | 인덱스는 DELETE/INSERT 처리 |
| DELETE | 전체 | 컬럼 | Before Image | 1 | 2 | _ |

- 커밋 된 순서대로 트랜잭션 슬롯 순차적 재사용
	- 커밋 안된 Active 상태의 Undo 블록 및 트랜잭션 슬롯은 재사용 안됨
	 - 커밋에 의해 트랜잭션 상태 정보 (committed), 그 시점의 커밋 SCN이 저장된 트랜잭션 슬롯이 재사용 됨 
- Undo Retention (undo_retention)
	- 완료된 트랜잭션의 Undo 데이터를 지정된 시간만큼 "가급적" 유지
	- 값을 기준으로 unexpired / expired 구분 되며 Undo Extent 필요시 expired 상태의 Extent 먼저 활용, 필요시 unexpired 상태의 Extent 도 활용
	- guarantee 옵션 : unexpired 상태의 Extent 활용 불가
		- `alter tablespace undotbs1 retention guarantee;`
	- Automatic Undo Retention Tuning
		- 시스템 상황에 따라 tuned_undo_retention 값 자동 계산 및 Undo Extent 관리
                     (undo_retention 최소값이 되며 "가급적" 지켜 짐) 



[0F]: https://www.ibm.com/developerworks/data/library/techarticle/dm-0401gupta/fig9.gif
[0G]: https://docs.oracle.com/cd/B28359_01/network.111/b28316/img/net81097.gif
[0H]: http://cfile8.uf.tistory.com/image/136E7D504F93100718AF59
[0I]: http://www.oracle.com/ocom/groups/public/%40otn/documents/digitalasset/112670.gif
[0J]: https://docs.oracle.com/database/121/CNCPT/img/GUID-5CE65D12-8850-421F-BAB6-5EC8DE0660B7-default.gif
[0K]: https://sites.google.com/site/embtdbo/_/rsrc/1263474372157/wait-event-documentation/oracle-latch-cache-buffers-chains/buffer_cache_steps_to_get_block.PNG
[0L]: https://talebzadehmich.files.wordpress.com/2012/03/mru-lru_oracle_pre_922.gif
[0M]: http://cfile24.uf.tistory.com/image/226EF23754F9FE311F02B4
[0N]: http://blog.itpub.net/attachment/201506/23/7728585_1435048415NuN8.jpg