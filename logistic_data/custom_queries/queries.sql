with numered_rows as (
	select message_date, message_id, 
	geo_lat, geo_long, driven_dist, speed, 
	axle_load,
	row_number() over (partition by yr, day_of_year order by driven_dist desc) as point_for_day
	from all_filterd_wheels_diag_msg_data
)
select * into point_for_day_yr
from numered_rows
where point_for_day = 1


select * from wheels e 
order by message_date desc

-----------------------------------------------

with ranked_diag_msg as(
	select message_date, message_id, geo_lat, geo_long,
	row_number() over (partition by message_date, message_id order by message_id desc) 
	as rnumb
	from diag_msg
	),
distinct_diag_msg as(
	select * from ranked_diag_msg
	where rnumb = 1
),
filtered_wheels as(
	select * from wheels 
	where not (((wheels.driven_dist is null) or (wheels.driven_dist = 0)) or (wheels.speed is null))
)
select dd.message_date, dd.message_id, 
	dd.geo_lat,
	dd.geo_long,
	fe.speed, 
	fe.driven_dist,
	fe.axle_load,
	extract(year from dd.message_date) as yr,
	extract(quarter from dd.message_date) as qy,
	EXTRACT('doy' FROM dd.message_date) AS day_of_year
	into all_filterd_wheels_diag_msg_data
from distinct_diag_msg dd
join filtered_wheels fe on dd.message_date = fe.message_date 
and dd.message_id = fe.message_id

-----------------------------------------------

with bk as (
	select *, 
	case 
		when bin = '84.3' then log(6) / 6
		when bin = '79.5' then log(70) / 70
		when bin = '71.4' then log(206) / 206
		when bin = '66.4' then log(1355) / 1355
		when bin = '59.0' then log(13248) / 13248
	end
	as bin_value
	from inp_table_full
)
select bin, sum(bin_value) as cnt from bk
group by bin 
order by cnt asc

-----------------------------------------------

select device_id, "tempo_C/hour", "temperature_C", "pressure_kPa", vehicle_speed_kph,
longitude_geopoint, latitude_geopoint,
alert_type, metric_id, reading_time, heat_flux, bin,
	case 
		when bin = '84.3' then log(6) / 6
		when bin = '79.5' then log(70) / 70
		when bin = '71.4' then log(206) / 206
		when bin = '66.4' then log(1355) / 1355
		when bin = '59.0' then log(13248) / 13248
	end
	as bin_value into wheels_with_logh
from inp_table_full

-----------------------------------------------

with filtered_wheels as(
	select * from wheels 
	where not (((wheels.driven_dist is null) or (wheels.driven_dist = 0)) or (wheels.speed is null))
	)
select count(*) from filtered_wheels 

-----------------------------------------------

