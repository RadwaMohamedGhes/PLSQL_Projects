create or replace package body contract_pkg
is
function contract_payment(v_contract_id number)
return number
is 

v_con_startdate contracts.contract_startdate%type;
v_con_enddate contracts.contract_enddate%type;
v_total_fees contracts.contract_total_fees%type;
v_deposit_fees contracts.contract_deposit_fees%type;
v_pay_type contracts.contract_payment_type%type;
v_client_id clients.client_id%type;
v_con_years number(5);
v_payment number(10, 2);

begin
select contract_payment_type, contract_startdate, contract_enddate, contract_total_fees, contract_deposit_fees
into v_pay_type, v_con_startdate, v_con_enddate,  v_total_fees, v_deposit_fees
from contracts
where contract_id = v_contract_id;
if v_pay_type = 'ANNUAL' then
v_con_years := trunc(months_between( v_con_enddate, v_con_startdate) / 12);
v_payment := (v_total_fees - nvl(v_deposit_fees, 0)) / (v_con_years);
elsif v_pay_type = 'HALF_ANNUAL' then
v_con_years := trunc(months_between( v_con_enddate, v_con_startdate) / 12) * 2;
v_payment := (v_total_fees - nvl(v_deposit_fees, 0)) / (v_con_years);
elsif v_pay_type = 'QUARTER' then
v_con_years := trunc(months_between( v_con_enddate, v_con_startdate) / 12) * 4;
v_payment := (v_total_fees - nvl(v_deposit_fees, 0)) / (v_con_years);
else
v_con_years := trunc(months_between( v_con_enddate, v_con_startdate) / 12) * 12;
v_payment := (v_total_fees - nvl(v_deposit_fees, 0)) / (v_con_years);
end if;
return v_payment;
end;


procedure insert_installment_info (v_contract_id number)
is
    v_con_record contracts%rowtype; 
    v_payment number(10, 2);
    
begin
  
select *
into v_con_record
from contracts 
where contract_id = v_contract_id;
v_payment := contract_payment(v_con_record.contract_id);    
insert into installments_paid(contract_id, installment_date, installment_amount, paid)
values (v_con_record.contract_id, v_con_record.contract_startdate, v_payment, 0);
            
end;

end;