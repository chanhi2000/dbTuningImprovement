# D-02a:

RBO (Rule-Based Optimizer)
CBO (Cost-based Optimizer)


https://use-the-index-luke.com/
http://studybyyourself.com/seminar/sql/course/?lang=en

https://docs.oracle.com/cd/B10501_01/server.920/a96533/optimops.htm
https://oracle-base.com/articles/misc/cost-based-optimizer-and-database-statistics


https://www.siue.edu/~dbock/cmis565/module12-indexes.htm
http://www.dba-oracle.com/art_9i_indexing.htm
http://www.remote-dba.net/t_op_sql_btree_indexes.htm
https://www.morganslibrary.org/reference/indexes.html
https://dev.to/databasestar/a-guide-to-indexes-in-oracle
https://www.1keydata.com/sql/sql-index.html
https://www.tutorialspoint.com/sql/sql-indexes.htm
https://d2.naver.com/helloworld/1155
https://www.geeksforgeeks.org/sql-indexes/


https://en.wikipedia.org/wiki/Data_warehouse

http://www.dba-oracle.com/t_reverse_key_indexes_dml_insert.htm
http://wiki.gurubee.net/pages/viewpage.action?pageId=26741180
https://richardfoote.wordpress.com/2008/01/14/introduction-to-reverse-key-indexes-part-i/
http://wiki.gurubee.net/pages/viewpage.action?pageId=26741180

https://logicalread.com/oracle-11-g-function-based-indexes-mc02/#.W4C0s84zaUk
https://oracle-base.com/articles/8i/function-based-indexes
https://medium.com/@complete_it_pro/what-is-a-function-based-index-in-oracle-and-why-should-i-create-one-6e19e6912a55
https://www.akadia.com/services/ora_function_based_index_2.html

https://oracle-base.com/articles/9i/index-skip-scanning
http://dba-oracle.com/t_oracle_index_skip_scan_tips.htm
http://www.orafaq.com/tuningguide/index%20skip%20scan.html
https://stackoverflow.com/questions/19059444/index-range-scan-vs-index-skip-scan-vs-index-fast-full-scan

partition table 종류
http://12bme.tistory.com/290
http://energ.tistory.com/entry/Oracle-Partition-table-%EC%A2%85%EB%A5%98
http://www.dbguide.net/db.db?cmd=view&boardUid=13828&boardConfigUid=9&boardIdx=73&boardStep=1
http://support.dbworks.co.kr/index.php?document_srl=2751&mid=ora_tb

index organized table
https://oracle-base.com/articles/8i/index-organized-tables
https://docs.oracle.com/cd/B28359_01/server.111/b28310/tables012.htm#ADMIN01506
https://m.blog.naver.com/PostView.nhn?blogId=whdahek&logNo=220796458477&proxyReferer=https%3A%2F%2Fwww.google.co.kr%2F\

Random Access
http://www.gurubee.net/lecture/2230
http://www.gurubee.net/lecture/2235
http://sorasora.tistory.com/60
http://blog.naver.com/PostView.nhn?blogId=bb_&logNo=220902149310&redirect=Dlog&widgetTypeCall=true

Selectivity
https://jdm.kr/blog/169
http://www.dbguide.net/dbqna.db?cmd=view&boardConfigUid=30&boardUid=145437
http://wiki.gurubee.net/pages/viewpage.action?pageId=1507544
http://ojc.asia/bbs/board.php?bo_table=LecOrccleTun&wr_id=85

Transitivity
http://docs.openlinksw.com/virtuoso/transitivityinsql/
http://www.dba-oracle.com/t_sql_tuning_transitive_closure.htm
https://stackoverflow.com/questions/18100621/how-to-find-matching-pairs-with-transitivity-of-equality-in-ms-sql
https://medium.com/@mauridb/transitive-closure-clustering-with-sql-server-uda-and-json-dade18953fd2

View
https://oracle-base.com/articles/misc/materialized-views


DBMS_XPLAN
 - DISPLY
 - DISPLAY_CURSOR
 - V$SESSION
 - V$SQL_PLAN
 - V$SQL
 - V$SQL_PLAN_STATISTICS_ALL

10046 Trace
 - parsing: 
 - execute: sql을 실제 수행하는 구간 (DML only)
 - fetch: sql을 통해 나온 값을 사용자에게 반환하는 구간

ADVANCED ALLSTATS LAST


실행계획 종류
 - BY INDEX ROWID 
 - FULL SCAN
 - BY USER ROWID: 
 - SAMPLE
