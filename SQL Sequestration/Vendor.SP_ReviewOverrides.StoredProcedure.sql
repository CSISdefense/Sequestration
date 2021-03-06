USE [DIIG]
GO
/****** Object:  StoredProcedure [Vendor].[SP_ReviewOverrides]    Script Date: 3/16/2017 12:26:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







-- =============================================
-- Author:		Greg Sanders
-- Create date: 2013-04-03
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [Vendor].[SP_ReviewOverrides]
	-- Add the parameters for the stored procedure here


AS
BEGIN
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

  select  'parentcontractor with overrideBgovid' as TableSource
,p.parentid

,p.overrideparentdunsnumber
,p.jointventure
,p.CSIScreateddate
,p.CSISmodifiedDate
,p.CSISmodifiedBy
from contractor.parentcontractor as p
where overrideparentdunsnumber=1
order by CSISmodifiedDate desc



select 'IgnoreBeforeYear from contractor.dunsnumber' as TableName
	,d.dunsnumber
	, d.ignorebeforeyear
	, dtpch.StandardizedTopContractor
	, dtpch.parentid
	, min(dtpch.fiscalyear) as MinOfFiscalYear
	, max(dtpch.fiscalyear) as MaxOfFiscalYear
	, d.CSISmodifieddate
	, d.CSISmodifiedBy
from contractor.dunsnumber as d
left outer join contractor.DunsnumberToParentContractorHistory as dtpch
	on right('000000000'+dtpch.dunsnumber,9)=right('000000000'+d.dunsnumber,9)

where ignorebeforeyear is not null
group by d.dunsnumber
	, d.ignorebeforeyear
		, d.CSISmodifieddate
	, d.CSISmodifiedBy
	, dtpch.StandardizedTopContractor
	, dtpch.parentid
order by d.dunsnumber, min(dtpch.fiscalyear)
----Change 7 to any other day value



/* TOO SLOW
select  'Contract.FPDS' as TableSource
,dptch.DUNSnumber
,dptch.Fiscal_Year
,dptch.obligatedamount
,dptch.Parentdunsnumber
,dptch.CSISmodifiedDate
from contract.fpds as dptch
where dptch.csismodifieddate>@startdate
order by dptch.CSISmodifiedDate desc
*/



END








GO
