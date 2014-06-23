select * from (
-- Elements for plan
select bi_operation.operationid,
        bi_plan.planid as planid,
        bi_plan.PLANNINGYEAR,
        null as ppgid,
        null as rfppgid,
        null as goalid,
        null as rfgoalid,
        null as objid,
        null as RFPROBLEMOBJECTIVEID,
        null as outputid,
        null as rfoutputid,
        bi_narrativereports.eltid,
        bi_narrativereports.planeltype,
        bi_narrativereports.usertxt,
        bi_narrativereports.createusr,
        bi_narrativereports.reportid,
        bi_narrativereports.report_type

from bi_operation
INNER JOIN BI_PLAN                ON   BI_OPERATION.OPERATIONID=BI_PLAN.OPERATIONID
inner join bi_narrativereports on bi_narrativereports.eltid = bi_plan.planid

union all

-- Elements for objective
select bi_operation.operationid,
        bi_plan.planid as planid,
        bi_plan.PLANNINGYEAR,
        null as ppgid,
        BI_PRJPOPULATIONGROUP.ORIGPOPGROUP_ID as rfppgid,
        null as goalid,
        bi_goal.rfgoalid as rfgoalid,
        bi_objective.objectiveid as objid,
        bi_objective.RFPROBLEMOBJECTIVEID as RFPROBLEMOBJECTIVEID,
        null as outputid,
        null as rfoutputid,
        bi_narrativereports.eltid,
        bi_narrativereports.planeltype,
        bi_narrativereports.usertxt,
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
inner join bi_narrativereports on bi_narrativereports.eltid = bi_objective.objectiveid

union all

-- Elements for goals
select bi_operation.operationid,
        bi_plan.planid as planid,
        bi_plan.PLANNINGYEAR,
        null as ppgid,
        BI_PRJPOPULATIONGROUP.ORIGPOPGROUP_ID as rfppgid,
        BI_GOAL.GOALID as goalid,
        BI_GOAL.RFGOALID as rfgoalid,
        null as objid,
        null as RFPROBLEMOBJECTIVEID,
        null as outputid,
        null as rfoutputid,
        bi_narrativereports.eltid,
        bi_narrativereports.planeltype,
        bi_narrativereports.usertxt,
        bi_narrativereports.createusr,
        bi_narrativereports.reportid,
        bi_narrativereports.report_type
from bi_operation
INNER JOIN BI_PLAN                ON   BI_OPERATION.OPERATIONID=BI_PLAN.OPERATIONID
INNER JOIN BI_PRJPOPULATIONGROUP  ON  BI_PLAN.PLANID=BI_PRJPOPULATIONGROUP.PLANID
INNER JOIN BI_GOAL                ON  BI_PRJPOPULATIONGROUP.POPULATIONGROUP_ID=BI_GOAL.POPULATIONGROUPID
INNER JOIN BI_RFGOALS             ON BI_GOAL.RFGOALID = BI_RFGOALS.ID
inner join bi_narrativereports on bi_narrativereports.eltid = BI_PRJPOPULATIONGROUP.populationgroup_id

union all

-- Elements for PPGs
select bi_operation.operationid,
        bi_plan.planid as planid,
        bi_plan.PLANNINGYEAR,
        BI_PRJPOPULATIONGROUP.populationgroup_id as ppgid,
        BI_PRJPOPULATIONGROUP.ORIGPOPGROUP_ID as rfppgid,
        null as goalid,
        null as rfgoalid,
        null as objid,
        null as RFPROBLEMOBJECTIVEID,
        null as outputid,
        null as rfoutputid,
        bi_narrativereports.eltid,
        bi_narrativereports.planeltype,
        bi_narrativereports.usertxt,
        bi_narrativereports.createusr,
        bi_narrativereports.reportid,
        bi_narrativereports.report_type
from bi_operation
INNER JOIN BI_PLAN                ON   BI_OPERATION.OPERATIONID=BI_PLAN.OPERATIONID
INNER JOIN BI_PRJPOPULATIONGROUP  ON  BI_PLAN.PLANID=BI_PRJPOPULATIONGROUP.PLANID
inner join bi_narrativereports on bi_narrativereports.eltid = BI_PRJPOPULATIONGROUP.populationgroup_id

union all

-- Elements for outputs
select bi_operation.operationid,
        bi_plan.planid as planid,
        bi_plan.PLANNINGYEAR,
        null as ppgid,
        BI_PRJPOPULATIONGROUP.ORIGPOPGROUP_ID as rfppgid,
        null as goalid,
        bi_goal.rfgoalid as rfgoalid,
        null as objid,
        bi_objective.RFPROBLEMOBJECTIVEID as RFPROBLEMOBJECTIVEID,
        null as outputid,
        BI_OUTPUTGRP.RFOUTPUTID as rfoutputid,
        bi_narrativereports.eltid,
        bi_narrativereports.planeltype,
        bi_narrativereports.usertxt,
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
inner join bi_narrativereports on bi_narrativereports.eltid = BI_OUTPUTGRP.outputid) t

WHERE PLANNINGYEAR >= 2012
