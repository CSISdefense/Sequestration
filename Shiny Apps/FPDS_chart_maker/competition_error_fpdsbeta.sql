select f.numberofoffersreceived
,statutoryexceptiontofairopportunity
,extentcompeted
,count(*) as tcount
,sum(obligatedamount) as  obligatedamount

from ErrorLogging.FPDSbetaViolatesConstraint f
where Fiscal_Year=2018
group by f.numberofoffersreceived
,statutoryexceptiontofairopportunity
,extentcompeted