select * from (
-- Elements for plan
select bi_operation.operationid,
        bi_plan.planid AS planid,
        bi_plan.PLANNINGYEAR,
        null AS ppgid,
        null AS rfppgid,
        null AS goalid,
        null AS rfgoalid,
        null AS objid,
        null AS RFPROBLEMOBJECTIVEID,
        null AS outputid,
        null AS rfoutputid,
        bi_narrativereports.eltid,
        bi_narrativereports.planeltype,
        replace(bi_narrativereports.usertxt, chr(10), '\n'),
        bi_narrativereports.createusr,
        bi_narrativereports.reportid,
        bi_narrativereports.report_type

from bi_operation
INNER JOIN BI_PLAN                ON   BI_OPERATION.OPERATIONID=BI_PLAN.OPERATIONID
INNER JOIN bi_narrativereports on bi_narrativereports.eltid = bi_plan.planid

UNION ALL

-- Elements for objective
select bi_operation.operationid,
        bi_plan.planid AS planid,
        bi_plan.PLANNINGYEAR,
        null AS ppgid,
        BI_PRJPOPULATIONGROUP.ORIGPOPGROUP_ID AS rfppgid,
        null AS goalid,
        bi_goal.rfgoalid AS rfgoalid,
        bi_objective.objectiveid AS objid,
        bi_objective.RFPROBLEMOBJECTIVEID AS RFPROBLEMOBJECTIVEID,
        null AS outputid,
        null AS rfoutputid,
        bi_narrativereports.eltid,
        bi_narrativereports.planeltype,
        replace(bi_narrativereports.usertxt, chr(10), '\n'),
        bi_narrativereports.createusr,
        bi_narrativereports.reportid,
        bi_narrativereports.report_type

from bi_operation
INNER JOIN BI_PLAN                ON   BI_OPERATION.OPERATIONID=BI_PLAN.OPERATIONID
INNER JOIN BI_PRJPOPULATIONGROUP  ON  BI_PLAN.PLANID=BI_PRJPOPULATIONGROUP.PLANID
INNER JOIN BI_GOAL                ON  BI_PRJPOPULATIONGROUP.POPULATIONGROUP_ID=BI_GOAL.POPULATIONGROUPID
INNER JOIN BI_RFGOALS             ON BI_GOAL.RFGOALID = BI_RFGOALS.ID
INNER JOIN BI_RIGHTSGROUP         ON  BI_GOAL.GOALID=BI_RIGHTSGROUP.GOALID
INNER JOIN BI_RFRIGHTSGROUP       ON BI_RIGHTSGROUP.RFRIGHTSGROUPID = BI_RFRIGHTSGROUP.ID
INNER JOIN BI_OBJECTIVE           ON  BI_RIGHTSGROUP.RIGHTSGROUPID=BI_OBJECTIVE.RIGHTSGROUPID
INNER JOIN bi_narrativereports on bi_narrativereports.eltid = bi_objective.objectiveid

UNION ALL

-- Elements for problem
select bi_operation.operationid,
        bi_plan.planid AS planid,
        bi_plan.PLANNINGYEAR,
        null AS ppgid,
        BI_PRJPOPULATIONGROUP.ORIGPOPGROUP_ID AS rfppgid,
        null AS goalid,
        bi_goal.rfgoalid AS rfgoalid,
        bi_objective.problemid AS objid,
        bi_objective.RFPROBLEMOBJECTIVEID AS RFPROBLEMOBJECTIVEID,
        null AS outputid,
        null AS rfoutputid,
        bi_narrativereports.eltid,
        bi_narrativereports.planeltype,
        replace(bi_narrativereports.usertxt, chr(10), '\n'),
        bi_narrativereports.createusr,
        bi_narrativereports.reportid,
        bi_narrativereports.report_type
from bi_operation
INNER JOIN BI_PLAN                ON   BI_OPERATION.OPERATIONID=BI_PLAN.OPERATIONID
INNER JOIN BI_PRJPOPULATIONGROUP  ON  BI_PLAN.PLANID=BI_PRJPOPULATIONGROUP.PLANID
INNER JOIN BI_GOAL                ON  BI_PRJPOPULATIONGROUP.POPULATIONGROUP_ID=BI_GOAL.POPULATIONGROUPID
INNER JOIN BI_RFGOALS             ON BI_GOAL.RFGOALID = BI_RFGOALS.ID
INNER JOIN BI_RIGHTSGROUP         ON  BI_GOAL.GOALID=BI_RIGHTSGROUP.GOALID
INNER JOIN BI_RFRIGHTSGROUP       ON BI_RIGHTSGROUP.RFRIGHTSGROUPID = BI_RFRIGHTSGROUP.ID
INNER JOIN BI_OBJECTIVE           ON  BI_RIGHTSGROUP.RIGHTSGROUPID=BI_OBJECTIVE.RIGHTSGROUPID
INNER JOIN bi_narrativereports on bi_narrativereports.eltid = bi_objective.problemid

UNION ALL

-- Elements for goals
select bi_operation.operationid,
        bi_plan.planid AS planid,
        bi_plan.PLANNINGYEAR,
        null AS ppgid,
        BI_PRJPOPULATIONGROUP.ORIGPOPGROUP_ID AS rfppgid,
        BI_GOAL.GOALID AS goalid,
        BI_GOAL.RFGOALID AS rfgoalid,
        null AS objid,
        null AS RFPROBLEMOBJECTIVEID,
        null AS outputid,
        null AS rfoutputid,
        bi_narrativereports.eltid,
        bi_narrativereports.planeltype,
        replace(bi_narrativereports.usertxt, chr(10), '\n'),
        bi_narrativereports.createusr,
        bi_narrativereports.reportid,
        bi_narrativereports.report_type
from bi_operation
INNER JOIN BI_PLAN                ON   BI_OPERATION.OPERATIONID=BI_PLAN.OPERATIONID
INNER JOIN BI_PRJPOPULATIONGROUP  ON  BI_PLAN.PLANID=BI_PRJPOPULATIONGROUP.PLANID
INNER JOIN BI_GOAL                ON  BI_PRJPOPULATIONGROUP.POPULATIONGROUP_ID=BI_GOAL.POPULATIONGROUPID
INNER JOIN BI_RFGOALS             ON BI_GOAL.RFGOALID = BI_RFGOALS.ID
INNER JOIN bi_narrativereports on bi_narrativereports.eltid = bi_goal.goalid

UNION ALL

-- Elements for PPGs
select bi_operation.operationid,
        bi_plan.planid AS planid,
        bi_plan.PLANNINGYEAR,
        BI_PRJPOPULATIONGROUP.populationgroup_id AS ppgid,
        BI_PRJPOPULATIONGROUP.ORIGPOPGROUP_ID AS rfppgid,
        null AS goalid,
        null AS rfgoalid,
        null AS objid,
        null AS RFPROBLEMOBJECTIVEID,
        null AS outputid,
        null AS rfoutputid,
        bi_narrativereports.eltid,
        bi_narrativereports.planeltype,
        replace(bi_narrativereports.usertxt, chr(10), '\n'),
        bi_narrativereports.createusr,
        bi_narrativereports.reportid,
        bi_narrativereports.report_type
from bi_operation
INNER JOIN BI_PLAN                ON   BI_OPERATION.OPERATIONID=BI_PLAN.OPERATIONID
INNER JOIN BI_PRJPOPULATIONGROUP  ON  BI_PLAN.PLANID=BI_PRJPOPULATIONGROUP.PLANID
INNER JOIN bi_narrativereports on bi_narrativereports.eltid = BI_PRJPOPULATIONGROUP.populationgroup_id

UNION ALL

-- Elements for outputs
select bi_operation.operationid,
        bi_plan.planid AS planid,
        bi_plan.PLANNINGYEAR,
        null AS ppgid,
        BI_PRJPOPULATIONGROUP.ORIGPOPGROUP_ID AS rfppgid,
        null AS goalid,
        bi_goal.rfgoalid AS rfgoalid,
        null AS objid,
        bi_objective.RFPROBLEMOBJECTIVEID AS RFPROBLEMOBJECTIVEID,
        null AS outputid,
        BI_OUTPUTGRP.RFOUTPUTID AS rfoutputid,
        bi_narrativereports.eltid,
        bi_narrativereports.planeltype,
        replace(bi_narrativereports.usertxt, chr(10), '\n'),
        bi_narrativereports.createusr,
        bi_narrativereports.reportid,
        bi_narrativereports.report_type
from bi_operation
INNER JOIN BI_PLAN                ON   BI_OPERATION.OPERATIONID=BI_PLAN.OPERATIONID
INNER JOIN BI_PRJPOPULATIONGROUP  ON  BI_PLAN.PLANID=BI_PRJPOPULATIONGROUP.PLANID
INNER JOIN BI_GOAL                ON  BI_PRJPOPULATIONGROUP.POPULATIONGROUP_ID=BI_GOAL.POPULATIONGROUPID
INNER JOIN BI_RFGOALS             ON BI_GOAL.RFGOALID = BI_RFGOALS.ID
INNER JOIN BI_RIGHTSGROUP         ON  BI_GOAL.GOALID=BI_RIGHTSGROUP.GOALID
INNER JOIN BI_RFRIGHTSGROUP       ON BI_RIGHTSGROUP.RFRIGHTSGROUPID = BI_RFRIGHTSGROUP.ID
INNER JOIN BI_OBJECTIVE           ON  BI_RIGHTSGROUP.RIGHTSGROUPID=BI_OBJECTIVE.RIGHTSGROUPID
INNER JOIN BI_OUTPUTGRP          ON BI_OBJECTIVE.OBJECTIVEID=BI_OUTPUTGRP.OBJECTIVEID
INNER JOIN bi_narrativereports on bi_narrativereports.eltid = BI_OUTPUTGRP.outputid) t

WHERE PLANNINGYEAR >= 2012
