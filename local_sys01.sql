-- �ý���(dba) ���� ���� �ִ� ��� ���� ���� ������ ����Ѵ�.
select * from dba_users;

-- ���� `hr` Ȱ��ȭ && ��й�ȣ ����
alter user hr account unlock;
alter user hr identified by hr
alter user scott identified by scott
;
--- `hr`�������� dba ���� �ο�
grant dba to hr;

-- dictionary�� ����� ĳ�� ��� ������ (db_block_size) ��ȸ
select *
 from  v$parameter
 where name like '%block%';
