USE [DIIG]
GO
/****** Object:  StoredProcedure [Vendor].[sp_SummaryDUNSnumberRollups]    Script Date: 3/16/2017 12:26:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		Greg Sanders
-- Create date: 2013-03-13
-- Description:	Assign a parent ID to a dunsnumber for a range of years
-- =============================================
CREATE  PROCEDURE [Vendor].[sp_SummaryDUNSnumberRollups]
	-- Add the parameters for the stored procedure here


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	
	--Get a count of mismatches
	select dtpch.FiscalYear
	,count(dtpch.parentid) as DunsnumberLabeled
	,count(parent.ParentID) as ParentDunsnumberLabeled
	,sum(iif(dtpch.parentid=parent.parentid,1,0)) as ParentDUNSmatches
	,sum(iif(dtpch.parentid<>parent.parentid
		and (dunsparent.LastYear is null or dunsparent.LastYear < dtpch.FiscalYear) ,1,0)) as ParentDUNSmismatches
	,sum(iif(dtpch.parentid is null and parent.parentid is not null,1,0)) as ParentDUNSnewLabel
	,sum(iif(dtpch.parentid is null and parent.parentid is not null,dtpch.ObligatedAmount,0)) as ParentDUNSnewLabel
	,count(HQ.ParentID) as HeadquartersLabeled
	,sum(iif(dtpch.parentid=HQ.parentid,1,0)) as HQDUNSmatches
	,sum(iif(dtpch.parentid<>HQ.parentid
		and (dunsparent.LastYear is null or dunsparent.LastYear < dtpch.FiscalYear) ,1,0)) as HQDUNSmismatches
	,sum(iif(dtpch.parentid is null and HQ.parentid is not null,1,0)) as HQnewLabel
	,sum(iif(dtpch.parentid is null and HQ.parentid is not null,dtpch.ObligatedAmount,0)) as HQnewLabelDollars

	from contractor.DunsnumberToParentContractorHistory dtpch
	left outer join Contractor.Dunsnumber duns
	on duns.DUNSnumber=dtpch.DUNSnumber
	left outer join contractor.ParentContractor as dunsparent
	on dtpch.parentid=dunsparent.parentid
	left outer join Contractor.DunsnumberToParentContractorHistory parent
	on duns.ParentDunsnumber=parent.DUNSnumber and dtpch.FiscalYear = parent.FiscalYear
	left outer join Contractor.DunsnumberToParentContractorHistory HQ
	on duns.HeadquarterCode=HQ.DUNSnumber and dtpch.FiscalYear = HQ.FiscalYear
	where len(dtpch.dunsnumber)<=9
	group by dtpch.FiscalYear
	order by dtpch.FiscalYear


	----Examine mismatches between parentid from dunsnumber and from parentdunsnumber
	--select  
	--parent.ParentID as ParentDUNSnumberLabel
	--,duns.ParentDUNSnumber
	--,min(dtpch.fiscalyear) as MinOfFiscalYear
	--,max(dtpch.fiscalyear) as MaxOfFiscalYear

	--,dtpch.DUNSnumber 
	--,dtpch.StandardizedTopContractor
	--,dtpch.parentid as DUNSnumberLabel
	--,dunsparent.Subsidiary
	--,dunsparent.LastYear
	--,dunsparent.Owners
	--from contractor.DunsnumberToParentContractorHistory dtpch
	--left outer join Contractor.Dunsnumber duns
	--on duns.DUNSnumber=dtpch.DUNSnumber
	--left outer join contractor.ParentContractor as dunsparent
	--on dtpch.parentid=dunsparent.parentid
	--left outer join Contractor.DunsnumberToParentContractorHistory parent
	--on duns.ParentDunsnumber=parent.DUNSnumber
	--and dtpch.FiscalYear=parent.fiscalyear
	
	--where dtpch.parentid<>parent.parentid
	----Next eliminate dunsnumber that were acquired in years prior to acquisition
	--and (dunsparent.LastYear is null or dunsparent.LastYear < dtpch.FiscalYear) 
	----where dtpch.ParentID is not null 
	----	and parent.parentid is not null
	--group by dtpch.DUNSnumber 
	--,dtpch.parentid 
	--,duns.ParentDUNSnumber
	--,parent.ParentID
	--,dtpch.StandardizedTopContractor
	--	,dunsparent.Subsidiary
	--,dunsparent.LastYear
	--,dunsparent.Owners
	--order by parent.ParentID, ParentDUNSnumber, dunsnumber


--List dunsnumber rollup counts
select fiscalyear
,sum(iif(len(dtpch.dunsnumber)<=9 and dtpch.parentid is not null,1,0)) as AssignedDunsnumbers
,sum(iif(len(dtpch.dunsnumber)<=9,1,0)) as TotalDunsnumbers
,sum(iif(len(dtpch.dunsnumber)<=9 and dtpch.parentid is not null,dtpch.obligatedamount,0)) as DunsnumberObligated
,sum(iif(len(dtpch.dunsnumber)<=9,dtpch.obligatedamount,0)) as TotalObligated
,sum(iif(len(dtpch.dunsnumber)<=9 and dtpch.parentid is not null,dtpch.fed_funding_amount,0)) as fed_funding_amount
,sum(iif(len(dtpch.dunsnumber)<=9,dtpch.fed_funding_amount,0)) as Totalfed_funding_amount
from contractor.DunsnumberToParentContractorHistory as dtpch
group by fiscalyear




END




























GO
