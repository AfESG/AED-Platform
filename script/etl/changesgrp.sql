DROP VIEW aed2007.changesgrp;
CREATE VIEW aed2007.changesgrp AS

SELECT * FROM (

SELECT
  aed2007."Surveydata"."CCODE",
  aed2007."Surveydata"."CATEGORY",
  aed2007."ChangesTracker"."ReasonForChange",
  SUM(aed2007."Surveydata"."DEFINITE") AS SumOfDEFINITE,
  SUM(aed2007."Surveydata"."PROBABLE") AS SumOfPROBABLE,
  SUM(aed2007."Surveydata"."POSSIBLE") AS SumOfPOSSIBLE,
  SUM(aed2007."Surveydata"."SPECUL") AS SumOfSPECUL
FROM aed2007."Surveydata"
INNER JOIN aed2007."ChangesTracker"
  ON aed2007."Surveydata"."OBJECTID" = aed2007."ChangesTracker"."CurrentOID"
WHERE aed2007."ChangesTracker"."Merged" IS NULL
GROUP BY
  aed2007."Surveydata"."CCODE",
  aed2007."Surveydata"."CATEGORY",
  aed2007."ChangesTracker"."ReasonForChange"
HAVING
  (aed2007."Surveydata"."CATEGORY")='A'
  Or (aed2007."Surveydata"."CATEGORY")='D'
  Or (aed2007."Surveydata"."CATEGORY")='E'

UNION

SELECT
  aed2007."Surveydata"."CCODE",
  aed2007."Surveydata"."CATEGORY",
  aed2007."ChangesTracker"."ReasonForChange",
  CASE
    WHEN SUM(aed2007."Surveydata"."ESTIMATE")-1.96*SQRT(SUM(aed2007."Surveydata"."VARIANCE"))>0
    THEN SUM(aed2007."Surveydata"."ESTIMATE")-1.96*SQRT(SUM(aed2007."Surveydata"."VARIANCE"))
    ELSE CASE
          WHEN SUM(aed2007."Surveydata"."ACTUALSEEN")>0
          THEN SUM(aed2007."Surveydata"."ACTUALSEEN")
          ELSE 0
    END
  END
  AS SumOfDEFINITE,
  CASE
    WHEN SUM(aed2007."Surveydata"."ESTIMATE")<1.96*SQRT(SUM(aed2007."Surveydata"."VARIANCE"))
    THEN SUM(aed2007."Surveydata"."ESTIMATE"-aed2007."Surveydata"."ACTUALSEEN")
    ELSE 1.96*SQRT(SUM(aed2007."Surveydata"."VARIANCE"))
  END
  AS SumOfPROBABLE,
  1.96*SQRT(SUM(aed2007."Surveydata"."VARIANCE")) AS SumOfPOSSIBLE,
  SUM(aed2007."Surveydata"."SPECUL") AS SumOfSPECUL
FROM aed2007."Surveydata"
INNER JOIN aed2007."ChangesTracker"
  ON aed2007."Surveydata"."OBJECTID" = aed2007."ChangesTracker"."CurrentOID"
WHERE (((aed2007."ChangesTracker"."Merged") Is Null))
GROUP BY
  aed2007."Surveydata"."CCODE",
  aed2007."Surveydata"."CATEGORY",
  aed2007."ChangesTracker"."ReasonForChange"
HAVING aed2007."Surveydata"."CATEGORY"='B'

UNION

SELECT
  aed2007."Surveydata"."CCODE",
  aed2007."Surveydata"."CATEGORY",
  aed2007."ChangesTracker"."ReasonForChange",
  SUM(aed2007."Surveydata"."ACTUALSEEN") AS SumOfDEFINITE,
  SUM(aed2007."Surveydata"."ESTIMATE") AS SumOfPROBABLE,
  1.96*SQRT(SUM(aed2007."Surveydata"."VARIANCE")) AS SumOfPOSSIBLE,
  SUM(aed2007."Surveydata"."SPECUL") AS SumOfSPECUL
FROM aed2007."Surveydata"
INNER JOIN aed2007."ChangesTracker"
  ON aed2007."Surveydata"."OBJECTID" = aed2007."ChangesTracker"."CurrentOID"
WHERE
  aed2007."ChangesTracker"."Merged" Is Null
GROUP BY
  aed2007."Surveydata"."CCODE",
  aed2007."Surveydata"."CATEGORY",
  aed2007."ChangesTracker"."ReasonForChange"
HAVING aed2007."Surveydata"."CATEGORY"='C'

UNION

SELECT
  aed2007."Surveydata"."CCODE",
  aed2007."Surveydata"."CATEGORY",
  aed2007."ChangesTracker"."ReasonForChange",
  Avg(aed2007."Surveydata"."DEFINITE") AS SumOfDEFINITE,
  Avg(aed2007."Surveydata"."PROBABLE") AS SumOfPROBABLE,
  Avg(aed2007."Surveydata"."POSSIBLE") AS SumOfPOSSIBLE,
  Avg(aed2007."Surveydata"."SPECUL") AS SumOfSPECUL
FROM aed2007."Surveydata"
INNER JOIN aed2007."ChangesTracker"
  ON aed2007."Surveydata"."OBJECTID" = aed2007."ChangesTracker"."CurrentOID"
WHERE
  aed2007."ChangesTracker"."Merged"=1
GROUP BY
  aed2007."Surveydata"."CCODE",
  aed2007."Surveydata"."CATEGORY",
  aed2007."ChangesTracker"."ReasonForChange"
HAVING
  aed2007."Surveydata"."CATEGORY"='A' OR
  aed2007."Surveydata"."CATEGORY"='D' OR
  aed2007."Surveydata"."CATEGORY"='E'

UNION

SELECT
  aed2007."Surveydata"."CCODE",
  aed2007."Surveydata"."CATEGORY",
  aed2007."ChangesTracker"."ReasonForChange",
  CASE
    WHEN Avg(aed2007."Surveydata"."ESTIMATE")-1.96*SQRT(Avg(aed2007."Surveydata"."VARIANCE"))>0
    THEN Avg(aed2007."Surveydata"."ESTIMATE")-1.96*SQRT(Avg(aed2007."Surveydata"."VARIANCE"))
    ELSE CASE 
      WHEN Avg(aed2007."Surveydata"."ACTUALSEEN")>0
      THEN Avg(aed2007."Surveydata"."ACTUALSEEN")
      ELSE 0
    END
  END
  AS SumOfDEFINITE,
  CASE
    WHEN Avg(aed2007."Surveydata"."ESTIMATE")<1.96*SQRT(Avg(aed2007."Surveydata"."VARIANCE"))
    THEN Avg(aed2007."Surveydata"."ESTIMATE"-aed2007."Surveydata"."ACTUALSEEN")
    ELSE 1.96*SQRT(Avg(aed2007."Surveydata"."VARIANCE"))
  END
  AS SumOfPROBABLE,
  1.96*SQRT(Avg(aed2007."Surveydata"."VARIANCE")) AS SumOfPOSSIBLE,
  SUM(aed2007."Surveydata"."SPECUL") AS SumOfSPECUL
FROM aed2007."Surveydata"
INNER JOIN aed2007."ChangesTracker"
  ON aed2007."Surveydata"."OBJECTID" = aed2007."ChangesTracker"."CurrentOID"
WHERE
  aed2007."ChangesTracker"."Merged"=1
GROUP BY
  aed2007."Surveydata"."CCODE",
  aed2007."Surveydata"."CATEGORY",
  aed2007."ChangesTracker"."ReasonForChange"
HAVING
  aed2007."Surveydata"."CATEGORY"='B'

UNION

SELECT
  aed2007."Surveydata"."CCODE",
  aed2007."Surveydata"."CATEGORY",
  aed2007."ChangesTracker"."ReasonForChange",
  Avg(aed2007."Surveydata"."ACTUALSEEN") AS SumOfDEFINITE,
  Avg(aed2007."Surveydata"."ESTIMATE") AS SumOfPROBABLE,
  1.96*SQRT(Avg(aed2007."Surveydata"."VARIANCE")) AS SumOfPOSSIBLE,
  Avg(aed2007."Surveydata"."SPECUL") AS SumOfSPECUL
FROM aed2007."Surveydata"
INNER JOIN aed2007."ChangesTracker"
  ON aed2007."Surveydata"."OBJECTID" = aed2007."ChangesTracker"."CurrentOID"
WHERE
  aed2007."ChangesTracker"."Merged"=1
GROUP BY
  aed2007."Surveydata"."CCODE",
  aed2007."Surveydata"."CATEGORY",
  aed2007."ChangesTracker"."ReasonForChange"
HAVING
  aed2007."Surveydata"."CATEGORY"='C'

UNION

SELECT
  aed2007."PreviousSurveydata"."CCODE",
  aed2007."PreviousSurveydata"."CATEGORY",
  aed2007."ChangesTracker"."ReasonForChange",
  SUM(-1*"DEFINITE") AS SumOfDEFINITE,
  SUM(-1*"PROBABLE") AS SumOfPROBABLE,
  SUM(-1*"POSSIBLE") AS SumOfPOSSIBLE,
  SUM(-1*"SPECUL") AS SumOfSPECUL
FROM
  aed2007."PreviousSurveydata"
INNER JOIN aed2007."ChangesTracker"
  ON aed2007."PreviousSurveydata"."OBJECTID" = aed2007."ChangesTracker"."PreviousOID"
WHERE
  aed2007."ChangesTracker"."Split" Is Null
GROUP BY
  aed2007."PreviousSurveydata"."CCODE",
  aed2007."PreviousSurveydata"."CATEGORY",
  aed2007."ChangesTracker"."ReasonForChange"
HAVING
  aed2007."PreviousSurveydata"."CATEGORY"='A'
  OR aed2007."PreviousSurveydata"."CATEGORY"='D'
  OR aed2007."PreviousSurveydata"."CATEGORY"='E'

UNION

SELECT
  aed2007."PreviousSurveydata"."CCODE",
  aed2007."PreviousSurveydata"."CATEGORY",
  aed2007."ChangesTracker"."ReasonForChange",
  CASE
    WHEN SUM(aed2007."PreviousSurveydata"."ESTIMATE")-1.96*SQRT(SUM(aed2007."PreviousSurveydata"."VARIANCE"))>0
    THEN SUM(aed2007."PreviousSurveydata"."ESTIMATE")-1.96*SQRT(SUM(aed2007."PreviousSurveydata"."VARIANCE"))
    ELSE CASE 
      WHEN SUM(aed2007."PreviousSurveydata"."ACTUALSEEN")>0
      THEN SUM(aed2007."PreviousSurveydata"."ACTUALSEEN")
      ELSE 0
    END
  END * -1 AS SumOfDEFINITE,
  CASE
    WHEN SUM(aed2007."PreviousSurveydata"."ESTIMATE")<1.96*SQRT(SUM(aed2007."PreviousSurveydata"."VARIANCE"))
    THEN SUM(aed2007."PreviousSurveydata"."ESTIMATE"-"ACTUALSEEN")
    ELSE 1.96*SQRT(SUM(aed2007."PreviousSurveydata"."VARIANCE"))
  END * -1 AS SumOfPROBABLE,
  -1.96*SQRT(SUM(aed2007."PreviousSurveydata"."VARIANCE")) AS SumOfPOSSIBLE,
  SUM(-1*"SPECUL") AS SumOfSPECUL
FROM aed2007."PreviousSurveydata"
INNER JOIN aed2007."ChangesTracker"
  ON aed2007."PreviousSurveydata"."OBJECTID" = aed2007."ChangesTracker"."PreviousOID"
WHERE
  aed2007."ChangesTracker"."Split" Is Null
GROUP BY
  aed2007."PreviousSurveydata"."CCODE",
  aed2007."PreviousSurveydata"."CATEGORY",
  aed2007."ChangesTracker"."ReasonForChange"
HAVING
  aed2007."PreviousSurveydata"."CATEGORY"='B'

UNION

SELECT
  aed2007."PreviousSurveydata"."CCODE",
  aed2007."PreviousSurveydata"."CATEGORY",
  aed2007."ChangesTracker"."ReasonForChange",
  SUM(-"ACTUALSEEN") AS SumOfDEFINITE,
  SUM(-"ESTIMATE") AS SumOfPROBABLE,
  -1.96*SQRT(SUM(aed2007."PreviousSurveydata"."VARIANCE")) AS SumOfPOSSIBLE,
  SUM(-"SPECUL") AS SumofSPECUL
FROM aed2007."PreviousSurveydata"
INNER JOIN aed2007."ChangesTracker"
  ON aed2007."PreviousSurveydata"."OBJECTID" = aed2007."ChangesTracker"."PreviousOID"
WHERE 
  aed2007."ChangesTracker"."Split" Is Null
GROUP BY
  aed2007."PreviousSurveydata"."CCODE",
  aed2007."PreviousSurveydata"."CATEGORY",
  aed2007."ChangesTracker"."ReasonForChange"
HAVING
  aed2007."PreviousSurveydata"."CATEGORY"='C'

UNION

SELECT
  aed2007."PreviousSurveydata"."CCODE",
  aed2007."PreviousSurveydata"."CATEGORY",
  aed2007."ChangesTracker"."ReasonForChange",
  -Avg(aed2007."PreviousSurveydata"."DEFINITE") AS SumOfDEFINITE,
  -Avg(aed2007."PreviousSurveydata"."PROBABLE") AS SumOfPROBABLE,
  -Avg(aed2007."PreviousSurveydata"."POSSIBLE") AS SumOfPOSSIBLE,
  -Avg(aed2007."PreviousSurveydata"."SPECUL") AS SumOfSPECUL
FROM aed2007."PreviousSurveydata"
INNER JOIN aed2007."ChangesTracker"
  ON aed2007."PreviousSurveydata"."OBJECTID" = aed2007."ChangesTracker"."PreviousOID"
WHERE
  aed2007."ChangesTracker"."Split"=1
GROUP BY
  aed2007."PreviousSurveydata"."CCODE",
  aed2007."PreviousSurveydata"."CATEGORY",
  aed2007."ChangesTracker"."ReasonForChange"
HAVING
  aed2007."PreviousSurveydata"."CATEGORY"='A' OR
  aed2007."PreviousSurveydata"."CATEGORY"='D' OR
  aed2007."PreviousSurveydata"."CATEGORY"='E'

UNION

SELECT
  aed2007."PreviousSurveydata"."CCODE",
  aed2007."PreviousSurveydata"."CATEGORY",
  aed2007."ChangesTracker"."ReasonForChange",
  CASE
    WHEN Avg(aed2007."PreviousSurveydata"."ESTIMATE")-1.96*SQRT(Avg(aed2007."PreviousSurveydata"."VARIANCE"))>0
    THEN Avg(aed2007."PreviousSurveydata"."ESTIMATE")-1.96*SQRT(Avg(aed2007."PreviousSurveydata"."VARIANCE"))
    ELSE CASE
      WHEN Avg(aed2007."PreviousSurveydata"."ACTUALSEEN")>0
      THEN Avg(aed2007."PreviousSurveydata"."ACTUALSEEN")
      ELSE 0
    END
  END * -1 AS SumOfDEFINITE,
  CASE
    WHEN Avg(aed2007."PreviousSurveydata"."ESTIMATE")<1.96*SQRT(Avg(aed2007."PreviousSurveydata"."VARIANCE"))
    THEN Avg(aed2007."PreviousSurveydata"."ESTIMATE"-"ACTUALSEEN")
    ELSE 1.96*SQRT(Avg(aed2007."PreviousSurveydata"."VARIANCE"))
  END * -1 AS SumOfPROBABLE,
  -1.96*SQRT(Avg(aed2007."PreviousSurveydata"."VARIANCE")) AS SumOfPOSSIBLE,
  SUM(-"SPECUL") AS SumOfSPECUL
FROM
  aed2007."PreviousSurveydata"
INNER JOIN aed2007."ChangesTracker"
  ON aed2007."PreviousSurveydata"."OBJECTID" = aed2007."ChangesTracker"."PreviousOID"
WHERE
  aed2007."ChangesTracker"."Split"=1
GROUP BY
  aed2007."PreviousSurveydata"."CCODE",
  aed2007."PreviousSurveydata"."CATEGORY",
  aed2007."ChangesTracker"."ReasonForChange"
HAVING
  aed2007."PreviousSurveydata"."CATEGORY"='B'

UNION

SELECT
  aed2007."PreviousSurveydata"."CCODE",
  aed2007."PreviousSurveydata"."CATEGORY",
  aed2007."ChangesTracker"."ReasonForChange",
  Avg(-"ACTUALSEEN") AS SumOfDEFINITE,
  Avg(-"ESTIMATE") AS SumOfPROBABLE,
  -1.96*SQRT(Avg(aed2007."PreviousSurveydata"."VARIANCE")) AS SumOfPOSSIBLE,
  Avg(-"SPECUL") AS SumOfSPECUL
FROM aed2007."PreviousSurveydata"
INNER JOIN aed2007."ChangesTracker"
  ON aed2007."PreviousSurveydata"."OBJECTID" = aed2007."ChangesTracker"."PreviousOID"
WHERE
  aed2007."ChangesTracker"."Split"=1
GROUP BY
  aed2007."PreviousSurveydata"."CCODE",
  aed2007."PreviousSurveydata"."CATEGORY",
  aed2007."ChangesTracker"."ReasonForChange"
HAVING
  aed2007."PreviousSurveydata"."CATEGORY"='C'

) as a

ORDER BY "CCODE", "CATEGORY", "ReasonForChange";
