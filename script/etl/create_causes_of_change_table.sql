CREATE TABLE public.cause_of_changes AS
  SELECT 
    "ChangeCODE" as code,
    "CauseofChange" as name,
    display_order
  FROM aed2007."CausesOfChange";
