USE [DIIG]
GO
/****** Object:  StoredProcedure [Vendor].[sp_InvestigateDunsnumber]    Script Date: 3/16/2017 12:26:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











-- =============================================
-- Author:		Greg Sanders
-- Create date: 2013-03-13
-- Description:	Assign a parent ID to a dunsnumber for a range of years
-- =============================================
CREATE PROCEDURE [Vendor].[sp_InvestigateDunsnumber]
	-- Add the parameters for the stored procedure here
	@dunsnumber varchar(13)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	if @dunsnumber is null
		raiserror('The value for @dunsnumber shold not be null.',15,1)
	
    -- Insert statements for procedure here
	select
	d.[DUNSnumber]
      ,d.[FiscalYear]
      ,d.[ParentID]
	  ,d.[StandardizedTopContractor]
	  ,d.VendorNameParentID
	  ,d.[ObligatedAmount]
	  ,d.fed_funding_amount
	  ,d.TotalAmount
      ,d.[Notes]
      ,d.[TooHard]
      ,d.[NotableSubdivision]
      ,d.[SubdivisionName]
      ,d.[Parentdunsnumber]
	  ,d.ParentDunsnumberParentID
	  ,d.HeadquarterCode
	  ,d.HeadquarterCodeParentID
	  ,d.CAGE
	  ,d.TopCountryName
	  ,d.topISO3countrytotalamount
	from Vendor.DunsnumberAlternateParentID as D
	where d.dunsnumber=@dunsnumber or  d.dunsnumber=right('000000000'+left(@dunsnumber,9),9)
	order by D.FiscalYear
	

	    -- Grab based on ParentDunsnumber
	select
	'ParentDunsnumber Match'
	,d.[Parentdunsnumber]
	,pduns.ParentID as ParentDunsnumberParentID
	,d.[DUNSnumber]
      ,d.[FiscalYear]
      ,d.[ParentID]
	  ,d.[StandardizedTopContractor]
	  ,vn.parentid as VendorNameParentID
	  ,d.[ObligatedAmount]
	  ,d.fed_funding_amount
	  ,d.TotalAmount
      ,d.[Notes]
      ,d.[TooHard]
      ,d.[NotableSubdivision]
      ,d.[SubdivisionName]
	  ,d.HeadquarterCode
	  ,hq.ParentID as HeadquarterCodeParentID
	  ,d.CAGE
	  ,l.name as TopCountryName
	  ,d.topISO3countrytotalamount
	from contractor.DunsnumberToParentContractorHistory as D
	left outer join Location.CountryCodes l
	on l.[alpha-3]=d.topISO3countrycode
	left outer join contractor.DunsnumberToParentContractorHistory as PDuns
	on PDuns.DUNSnumber=d.Parentdunsnumber and pduns.FiscalYear = d.FiscalYear
	left outer join contractor.DunsnumberToParentContractorHistory as HQ
	on HQ.DUNSnumber=d.HeadquarterCode and HQ.FiscalYear = d.FiscalYear
	left outer join Vendor.vendorname as VN
	on d.StandardizedTopContractor=vn.vendorname
	where d.Parentdunsnumber=@dunsnumber or  d.Parentdunsnumber=right('000000000'+left(@dunsnumber,9),9)
	order by D.FiscalYear
	

	    -- Grab based on ParentDunsnumber
	select
	'HeadquarterCode Match'
	,d.HeadquarterCode
	  ,hq.ParentID as HeadquarterCodeParentID
	,d.[DUNSnumber]
      ,d.[FiscalYear]
      ,d.[ParentID]
	  ,d.[StandardizedTopContractor]
	  ,vn.parentid as VendorNameParentID
	  ,d.[ObligatedAmount]
	  ,d.fed_funding_amount
	  ,d.TotalAmount
      ,d.[Notes]
      ,d.[TooHard]
      ,d.[NotableSubdivision]
      ,d.[SubdivisionName]
	  	,d.[Parentdunsnumber]
	,pduns.ParentID as ParentDunsnumberParentID
	  ,d.CAGE
	  ,l.name as TopCountryName
	  ,d.topISO3countrytotalamount
	from contractor.DunsnumberToParentContractorHistory as D
	left outer join Location.CountryCodes l
	on l.[alpha-3]=d.topISO3countrycode
	left outer join contractor.DunsnumberToParentContractorHistory as PDuns
	on PDuns.DUNSnumber=d.Parentdunsnumber and pduns.FiscalYear = d.FiscalYear
	left outer join contractor.DunsnumberToParentContractorHistory as HQ
	on HQ.DUNSnumber=d.HeadquarterCode and HQ.FiscalYear = d.FiscalYear
		left outer join vendor.vendorname as VN
	on d.StandardizedTopContractor=vn.vendorname
	where d.HeadquarterCode=@dunsnumber or  d.HeadquarterCode=right('000000000'+left(@dunsnumber,9),9)
	order by D.FiscalYear

END












GO
