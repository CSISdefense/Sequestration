USE [DIIG]
GO
/****** Object:  StoredProcedure [Vendor].[SP_ReviewRecentUpdates]    Script Date: 3/16/2017 12:26:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







-- =============================================
-- Author:		Greg Sanders
-- Create date: 2013-04-03
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [Vendor].[SP_ReviewRecentUpdates]
	-- Add the parameters for the stored procedure here
	@StartDate datetime

AS
BEGIN
	set @startdate=isnull(@startdate,'2013-04-03 13:03:48.833')
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

  select  'parentcontractor' as TableSource
,p.parentid
,p.FPDSannualRevenue
,p.CSIScreateddate
,p.CSISmodifiedDate
,p.CSISmodifiedBy
from contractor.parentcontractor as p
where csismodifieddate>@startdate
order by CSISmodifiedDate desc





    select  'vendorname' as TableSource
,v.StandardizedVendorName
,v.parentid
,v.CSIScreateddate
,v.CSISmodifiedDate
,v.CSISmodifiedBy
from Vendor.VendorName as v
where csismodifieddate>@startdate
order by CSISmodifiedDate desc

select  'DunsnumberToParentContractorHistory' as TableSource
,dptch.DUNSnumber
,dptch.FiscalYear
,dptch.ParentID
,dptch.StandardizedTopContractor
,dptch.Parentdunsnumber
,dptch.CSISmodifiedBy
,dptch.CSISmodifiedDate
from contractor.DunsnumberToParentContractorHistory as dptch
where dptch.csismodifieddate>@startdate
order by dptch.CSISmodifiedDate desc


select  'DunsnumberToParentContractorHistory by Type' as TableSource
,count(dptch.DUNSnumber)
--,dptch.FiscalYear
--,dptch.ParentID
--,dptch.StandardizedTopContractor
--,dptch.Parentdunsnumber
,dptch.CSISmodifiedBy
,cast(dptch.CSISmodifiedDate as date)
from contractor.DunsnumberToParentContractorHistory as dptch
where dptch.csismodifieddate>@startdate
group by dptch.CSISmodifiedBy
,cast(dptch.CSISmodifiedDate as date)
order by count(dptch.DUNSnumber) desc


SELECT 'Altered Tables/Views/SPs', type_desc, s.name, s.modify_date
FROM sys.objects as s
where modify_date>@startdate
order by type_desc, modify_date desc
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
