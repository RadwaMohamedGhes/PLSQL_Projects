declare
cursor pk_cursor
is
select distinct uc.table_name, uc.column_name
from user_cons_columns uc
join user_constraints u
on u.constraint_name = uc.constraint_name
join user_tab_columns ut
on uc.column_name = ut.column_name
where upper(data_type) = upper('number')
and upper(uc.constraint_name) like upper('%_PK')
and u.table_name in (SELECT table_name
from user_cons_columns
where upper(constraint_name) like upper('%_PK')
group by table_name
having count(column_name) = 1);
v_count number(4);
a_max_id employees.employee_id%type;

begin
for v_record in pk_cursor loop
select count(*)
into v_count
from user_sequences
where upper(sequence_name) = upper(v_record.table_name||'_SEQ');
--- drop sequences that exist in the schema 
if v_count > 0 then
execute immediate 'drop sequence '||v_record.table_name||'_SEQ';
end if;
--- create sequence over the primary key for each table
execute immediate 'select max( '||v_record.column_name||' ) + 1 from '||v_record.table_name into a_max_id;
execute immediate 'create sequence '||v_record.table_name||'_SEQ start with '||a_max_id||' increment by 1';
--- create trigger for each table
execute immediate 'create or replace trigger '||v_record.table_name||'_TRG'||' before insert on '||v_record.table_name||' for each row begin '||':new.'||v_record.column_name||' := '||v_record.table_name||'_SEQ.nextval; end;';
end loop;
end;

