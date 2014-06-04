SELECT b1.PLANID
     , b1.PLANNINGYEAR   AS PLANNINGYEAR
     , b1.RFGOALID
     , b2.RFPROBLEMOBJECTIVEID
     , b1.RFOUTPUTID
     , b1.POPULATIONGROUPID
     , b1.BUDGET_TYPE
     , b1.BUDGETCOMPONENT
     , b1.OPERATIONID
     , ROUND(sum(expenses_usd), 0) AS AMOUNT
          FROM FOCUS_BI.BI_EXPENSES b1
          INNER JOIN FOCUS_BI.BI_OBJECTIVE b2
          ON b1.OBJECTIVEID = b2.OBJECTIVEID
          WHERE PLAN_TYPE = 'P-8'
          GROUP BY b1.PLANID
                 , b1.PLANNINGYEAR
                 , b1.RFGOALID
                 , b2.RFPROBLEMOBJECTIVEID
                 , b1.RFOUTPUTID
                 , b1.POPULATIONGROUPID
                 , b1.BUDGET_TYPE
                 , b1.BUDGETCOMPONENT
                 , b1.OPERATIONID
