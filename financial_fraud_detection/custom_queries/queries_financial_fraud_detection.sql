------------------ fraud detection rate on original dataset ---------------------------- 
------------------ 0.58
---------------------------------- with using CTE --------------------------------------
with is_fraud_tot as(
	select * from credit_card_transactions
	where is_fraud = 1),
all_rows as(
	select * from credit_card_transactions
	)
select count(*)::float /(select count(*)::float from all_rows) * 100 from is_fraud_tot 

------------------------------- 3 sigma method (3 x std_dev) -----------------------------
select *, 
case 
	when amt > 3 * stddev then 1
	when amt <= 3 * stddev then 0 
end as fraud_flag into final_cct
from cctxstd

----------------------- 5 x higher fraud density with the method 3 sigma --------------------------------
----------------------- 2.99 
select (sum(is_fraud)::float / (select (sum(fraud_flag)::float) from final_cct)) * 100.0 from final_cct
where fraud_flag = 1 and is_fraud = 1


------------------------------------------------ Interquartile range method ----------------------------------------
------------------ adding columns with 25th and 75th percentile, then substracing 25th from 75th -------------------
----------------------------------------------------- group by category --------------------------------------------

select category, avg(amt) as cat_amt_avg, 
percentile_cont(0.25) within group (order by amt) as cat_amt_perc_025, 
percentile_cont(0.75) within group (order by amt) as cat_amt_perc_075, 
percentile_cont(0.75) within group (order by amt) - percentile_cont(0.25) within group(order by amt) as cat_amt_IQR, 
stddev(amt) as cat_amt_stddev into IQR_category
from credit_card_transactions cct
group by category

------ Adding columns with 25th and 75th percentile, average, standard deviation---------------
-------------------------------------- and Z-score --------------------------------------------

select cct.*, amt_avg, amt_iqr, perc_025 as amt_perc_025, perc_075 as amt_perc_075, amt_stddev,
((cct.amt-amt_avg)/amt_stddev) as z_score 
into cct_z_score
from credit_card_transactions cct 
join IQR_table iqr on cct.merchant = iqr.merchant

------------------------------- Interquartile range method -----------------------------
------------- adding columns with flag when detecting fraud using IQR ------------------


select *,
case
	when amt > (amt_perc_075 + (1.5 * amt_iqr)) then 1
	when amt < (amt_perc_025 - (1.5 * amt_iqr)) then -1
	else 0
end as fraud_flag_iqr,
case 
	when z_score > 3 then 1
	when z_score < -3 then -1
	else 0
end as fraud_flag_std
into cct_flagged
from cct_z_score


--------------- confusion matrix for fraud detection by 3 sigma method ---------------
select count(*) as FN, 
(
	select count(*) from cct_flagged 
	where is_fraud = 1 and fraud_flag_std = 1
) as TP,
(
	select count(*) from cct_flagged 
	where is_fraud = 0 and (fraud_flag_std = 0 or fraud_flag_std = -1)
) as TN,
(
	select count(*) from cct_flagged 
	where is_fraud = 0 and fraud_flag_std = 1
) as FP
into conf_matrix_std
from cct_flagged
where is_fraud = 1 
and (fraud_flag_std = 0 or fraud_flag_std = -1)


----------------------------
--| tp = 5190  | fn = 2316 |
--|------------|-----------|
--| fp = 17140 | tn = 12726|
----------------------------

---- PPV = tp / (tp+fp)
---- PPV = 0.23


---- TPR = tp / (tp+fn)
-----TPR = 0.69