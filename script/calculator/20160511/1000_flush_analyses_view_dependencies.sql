-- Destroys the dependencies on the 'analyses' table
-- so it can be modified

drop view if exists estimate_factors_analyses cascade;
drop view if exists actual_diff_country cascade;
drop view if exists actual_diff_region cascade;
drop view if exists actual_diff_continent cascade;
drop view if exists new_strata cascade;
drop view if exists replaced_strata cascade;
