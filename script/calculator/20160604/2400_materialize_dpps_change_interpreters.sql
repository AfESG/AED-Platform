delete from dpps_sums_continent_category;
insert into dpps_sums_continent_category
select * from i_dpps_sums_continent_category;

delete from dpps_sums_continent_category_reason;
insert into dpps_sums_continent_category_reason
select * from i_dpps_sums_continent_category_reason;

delete from dpps_sums_region_category;
insert into dpps_sums_region_category
select * from i_dpps_sums_region_category;

delete from dpps_sums_region_category_reason;
insert into dpps_sums_region_category_reason
select * from i_dpps_sums_region_category_reason;

delete from dpps_sums_country_category;
insert into dpps_sums_country_category
select * from i_dpps_sums_country_category;

delete from dpps_sums_country_category_reason;
insert into dpps_sums_country_category_reason
select * from i_dpps_sums_country_category_reason;
