WITH obj AS
(
  SELECT BI_OPERATION.OPERATIONID               AS OPERATIONID
       , BI_OPERATION.MSRPCODE                  AS OPERATION_CODE
       , BI_PLAN.PLANNAME
       , BI_PLAN.PLANNINGSTAGE
       , BI_PLAN.PLANNINGSTAGEDESC
       , BI_PLAN.PLANNINGYEAR
       , BI_PLAN.PLANID                         AS PLANID
       , BI_REGION.NAME subregion
       , BI_BUREAU.NAME bureau
       , BI_PRJPOPULATIONGROUP.ORIGPOPGROUP_ID  AS PPGID
       , POPULATIONGROUPNAME                      AS PPG
       , BI_PRJPOPULATIONGROUP.MSRPCODE         AS PPG_CODE
       , POPGROUPTYPE
       , POPGROUPTYPEID
       , BI_GOAL.GOALID, BI_GOAL.RFGOALID
       , BI_RIGHTSGROUP.RIGHTSGROUPID
       , BI_RIGHTSGROUP.RFRIGHTSGROUPID
       , BI_OBJECTIVE.OBJECTIVEID OBJID
       , BI_OBJECTIVE.RFPROBLEMOBJECTIVEID
       , BI_OBJECTIVE.EXTERNALLY_VISIBLE
       , BI_OUTPUTGRP.OUTPUTID
       , BI_OUTPUTGRP.RFOUTPUTID
       , BI_DETAILEDBUDGETELEMENTS.*
  FROM   BI_OPERATION
  INNER JOIN BI_PLAN                        ON   BI_OPERATION.OPERATIONID=BI_PLAN.OPERATIONID
  INNER JOIN BI_REGION                      ON  BI_REGION.REGIONID=BI_OPERATION.REGIONID
  INNER JOIN BI_BUREAU                      ON  BI_BUREAU.BUREAUID=BI_REGION.BUREAUID
  INNER JOIN BI_PRJPOPULATIONGROUP          ON  BI_PLAN.PLANID=BI_PRJPOPULATIONGROUP.PLANID
  INNER JOIN BI_GOAL                        ON  BI_PRJPOPULATIONGROUP.POPULATIONGROUP_ID=BI_GOAL.POPULATIONGROUPID
  INNER JOIN BI_RFGOALS             ON BI_GOAL.RFGOALID = BI_RFGOALS.ID
  INNER JOIN BI_RIGHTSGROUP                 ON  BI_GOAL.GOALID=BI_RIGHTSGROUP.GOALID
  INNER JOIN BI_RFRIGHTSGROUP       ON BI_RIGHTSGROUP.RFRIGHTSGROUPID = BI_RFRIGHTSGROUP.ID
  INNER JOIN BI_OBJECTIVE                   ON  BI_RIGHTSGROUP.RIGHTSGROUPID=BI_OBJECTIVE.RIGHTSGROUPID
  INNER JOIN BI_RFPROBLOBJ          ON BI_OBJECTIVE.RFPROBLEMOBJECTIVEID = BI_RFPROBLOBJ.ID
  LEFT OUTER JOIN
      (BI_BUDGETTYPE
        JOIN BI_DETAILEDBUDGETELEMENTS      ON  BI_BUDGETTYPE.ID=BI_DETAILEDBUDGETELEMENTS.BUDGETTYPE
        JOIN BI_OUTPUTGRP                   ON BI_OUTPUTGRP.OUTPUTID = BI_DETAILEDBUDGETELEMENTS.ELTID)
  ON  BI_OBJECTIVE.OBJECTIVEID=BI_OUTPUTGRP.OBJECTIVEID
  WHERE BI_PLAN.PLANNINGYEAR >= 2012
    AND BI_PLAN.PLANNINGSTAGE = 8
)

SELECT ROUND(SUM(usdcost), 0) AS AMOUNT, OPERATIONID, PLANID, PLANNINGYEAR, RFGOALID, RFPROBLEMOBJECTIVEID, RFOUTPUTID, PPGID, BUDGETTYPE, POPGROUPTYPEID, BUDGETCOMPONENT
FROM obj
GROUP BY OPERATIONID, PLANID, PLANNINGYEAR, RFGOALID, RFPROBLEMOBJECTIVEID, RFOUTPUTID, PPGID, BUDGETTYPE, BUDGETCOMPONENT, POPGROUPTYPEID

