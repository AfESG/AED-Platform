update survey_aerial_total_count_strata s
set stratum_area = (ST_Area(sg.geom::geography,true)/1000000)
from survey_geometries sg
where
sg.id = s.survey_geometry_id
and (s.stratum_area is null
  or s.stratum_area < 1)
;

update survey_aerial_sample_count_strata s
set stratum_area = (ST_Area(sg.geom::geography,true)/1000000)
from survey_geometries sg
where
sg.id = s.survey_geometry_id
and (s.stratum_area is null
  or s.stratum_area < 1)
;

update survey_ground_total_count_strata s
set stratum_area = (ST_Area(sg.geom::geography,true)/1000000)
from survey_geometries sg
where
sg.id = s.survey_geometry_id
and (s.stratum_area is null
  or s.stratum_area < 1)
;

update survey_ground_sample_count_strata s
set stratum_area = (ST_Area(sg.geom::geography,true)/1000000)
from survey_geometries sg
where
sg.id = s.survey_geometry_id
and (s.stratum_area is null
  or s.stratum_area < 1)
;

update survey_dung_count_line_transect_strata s
set stratum_area = (ST_Area(sg.geom::geography,true)/1000000)
from survey_geometries sg
where
sg.id = s.survey_geometry_id
and (s.stratum_area is null
  or s.stratum_area < 1)
;

update survey_faecal_dna_strata s
set stratum_area = (ST_Area(sg.geom::geography,true)/1000000)
from survey_geometries sg
where
sg.id = s.survey_geometry_id
and (s.stratum_area is null
  or s.stratum_area < 1)
;

update survey_others s
set stratum_area = (ST_Area(sg.geom::geography,true)/1000000)
from survey_geometries sg
where
sg.id = s.survey_geometry_id
and (s.stratum_area is null
  or s.stratum_area < 1)
;

update survey_individual_registrations s
set stratum_area = (ST_Area(sg.geom::geography,true)/1000000)
from survey_geometries sg
where
sg.id = s.survey_geometry_id
and (s.stratum_area is null
  or s.stratum_area < 1)
;
