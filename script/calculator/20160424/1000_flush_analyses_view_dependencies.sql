-- Destroys the dependencies on the 'analyses' table
-- so it can be modified

drop view if exists estimate_factors_analyses cascade;
drop view actual_diff_country cascade;
drop view actual_diff_region cascade;
drop view actual_diff_continent cascade;
