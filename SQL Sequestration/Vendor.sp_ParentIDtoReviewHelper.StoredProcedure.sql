USE [DIIG]
GO
/****** Object:  StoredProcedure [Vendor].[sp_ParentIDtoReviewHelper]    Script Date: 3/16/2017 12:26:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		Greg Sanders
-- Create date: 2013-03-13
-- Description:	Assign a parent ID to a dunsnumber for a range of years
-- =============================================
CREATE  PROCEDURE [Vendor].[sp_ParentIDtoReviewHelper]
	-- Add the parameters for the stored procedure here
	
	@parentid varchar(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--declare @parentid varchar(100) Use this for testing
	if @parentid is null
		set @parentid = (select top 1 
			parentid
			from contractor.ParentContractor p
			where p.isInNeedOfInvestigation=1
			order by totalamount desc
		)

	declare @topISO3countrycode varchar(3)
	set @topISO3countrycode=(select top 1 
			p.topISO3countrycode
			from contractor.ParentContractor p
			where parentid=@parentid
	) 


	select top 1 
		'ParentID to investigation' as tablename
		,parentid
		,cc.name as Countryname
		,p.totalamount
	from contractor.ParentContractor p
	left outer join location.CountryCodes cc
		on p.topISO3countrycode=cc.[alpha-3]
	where parentid=@parentid

	if @topISO3countrycode<>'USA'
	begin
	select 'Other ParentIDs from the same country' as tablename
		,parentid
		,cc.name as Countryname
		,p.totalamount
	from contractor.ParentContractor p
	left outer join location.CountryCodes cc
		on p.topISO3countrycode=cc.[alpha-3]
	where p.topISO3countrycode = @topISO3countrycode
		and parentid<>@parentid
	order by parentid
	end

	select 'ParentIDs with the same first letter' as tablename
		,parentid
		,cc.name as Countryname
		,p.totalamount
	from contractor.ParentContractor p
	left outer join location.CountryCodes cc
		on p.topISO3countrycode=cc.[alpha-3]
	where left(p.parentid,1) = left(@parentid,1)
		and @parentid<>p.parentid
	order by parentid

	--Note, it'd be nice to add a parent duns lookup
	select 'Related Dunsnumbers by Dunsnumber' as Tablename
		,parentid
		,dunsnumber 
		,min(FiscalYear) as MinOfFiscalYear
		,max(FiscalYear) as MaxOFiscalYear
		,StandardizedTopContractor
		,cc.name as Countryname
		,sum(TotalAmount) as SumOfTotalAmount
	from contractor.dunsnumbertoparentcontractorhistory dtpchp
	left outer join location.CountryCodes cc
		on dtpchp.topISO3countrycode=cc.[alpha-3]
	where dunsnumber in (select dunsnumber 
		from Contractor.dunsnumbertoparentcontractorhistory dtpchp
		where @parentid=dtpchp.parentid
	)
	group by parentid
		,dunsnumber 
		,StandardizedTopContractor
		,cc.name 
	order by dunsnumber, min(FiscalYear)


	--Dunsnumber with related name
	select 'Related Dunsnumbers by name' as Tablename
		,parentid
		,dunsnumber 
		,min(FiscalYear) as MinOfFiscalYear
		,max(FiscalYear) as MaxOFiscalYear
		,StandardizedTopContractor
		,cc.name as Countryname
		,sum(TotalAmount) as SumOfTotalAmount
	from contractor.dunsnumbertoparentcontractorhistory dtpchp
	left outer join location.CountryCodes cc
		on dtpchp.topISO3countrycode=cc.[alpha-3]
	where dunsnumber in (
		select distinct dunsnumber
		where StandardizedTopContractor in (
			select distinct StandardizedTopContractor
			from contractor.DunsnumberToParentContractorHistory
			where dunsnumber in (
				select dunsnumber 
				from Contractor.dunsnumbertoparentcontractorhistory dtpchp
				where @parentid=dtpchp.parentid
			)
		)
	)
	and not dunsnumber in (select dunsnumber 
		from Contractor.dunsnumbertoparentcontractorhistory dtpchp
		where @parentid=dtpchp.parentid
	)
		group by
		parentid
		,dunsnumber 
		,FiscalYear
		,StandardizedTopContractor
		,cc.name 
	
	order by dunsnumber, min(FiscalYear)

	--Dunsnumber with same country
	if @topISO3countrycode<>'USA'
	begin
		select 'Dunsnumbers with same country' as Tablename
			,parentid
			,dunsnumber 
		,min(FiscalYear) as MinOfFiscalYear
		,max(FiscalYear) as MaxOFiscalYear
			,StandardizedTopContractor
			,cc.name as Countryname
			,sum(TotalAmount) as SumOfTotalAmount
		from contractor.dunsnumbertoparentcontractorhistory dtpchp
		left outer join location.CountryCodes cc
			on dtpchp.topISO3countrycode=cc.[alpha-3]
		where topISO3countrycode=@topISO3countrycode
		and not dunsnumber in (select dunsnumber 
			from Contractor.dunsnumbertoparentcontractorhistory dtpchp
			where @parentid=dtpchp.parentid)
		group by parentid
			,dunsnumber 
			,StandardizedTopContractor
			,cc.name 
		order by StandardizedTopContractor
		,dunsnumber
		, min(FiscalYear)
	end
	
--if(select p.ParentID
--from contractor.ParentContractor as p
--where p.ParentID=@parentid) is null 
--begin
--	if (select top 1 p.ParentID
--				from contractor.ParentContractor as p
--				where p.ParentID like '%'+@parentid+'%') is not null 
--	begin
		
--		select  p.ParentID
--				from contractor.ParentContractor as p
--				where p.ParentID like '%'+@parentid+'%'
--		select 'The value for @parentid is not found in contractor.parentcontractor. Did you mean one of the above?' as ErrorDescription
--		return -1
--	end
--	else
--	begin
--		raiserror('The value for @parentid is not found in contractor.parentcontractor.',15,1)
--	end
--end

--	select
--		'Contractor.ParentContractor' as SourceTable
--		,[ParentID]
--      ,[Ticker]
--      ,[ShortName]
--      ,[BloombergID]
--      ,[DIIGIndex]
--      ,[LargeGreaterThan1B]
--      ,[LargeGreaterThan3B]
--      ,[PMC]
--      ,[HRFprivatemilitary]
--      ,[SIGIRprivemilitary]
--      ,[SIGIRDuns]
--      ,[Subsidiary]
--      ,[MergerYear]
--	  ,[HooverID]
--	  ,[LexisNexisID]
--      ,[RevenueInMillions]
--      ,[RevenueYear]
--      ,[RevenueSourceLink]
--      ,[Replace]
--      ,[JointVenture]
--      ,[LastYear]
--      ,[FirstYear]
--      ,[SizeGuess]
--      ,[NumberOfYears]
--      ,[DACIM]
--      ,[UnknownCompany]
--      ,[FPDSannualRevenue]
--      ,[Top100Federal]
--      ,[AlwaysDisplay]
--      ,[Owners]
--      ,[MergerDate]
--      ,[MergerURL]
--      ,[FirstDate]
--      ,[FirstURl]
--      ,[SpunOffFrom]
--      ,[Top6]
--	from contractor.parentcontractor as P
--	where p.parentid like ('%'+@parentid+'%') or p.parentid =@parentid

--    -- Insert statements for procedure here


--	select
--	'Contractor.DunsnumberToParentContractorHistory' as SourceTable
--	,[DUNSnumber]
--      ,[FiscalYear]
--      ,[ParentID]
--	  ,[StandardizedTopContractor]
--	  ,[ObligatedAmount]
--	  ,d.fed_funding_amount
--	  ,d.TotalAmount
--      ,d.TopVendorNameTotalAmount
--      ,[Notes]
--      ,[TooHard]
--      ,[NotableSubdivision]
--      ,[SubdivisionName]
--      ,[Parentdunsnumber]
--	from contractor.DunsnumberToParentContractorHistory as D
--	where parentid like ('%'+@parentid+'%') or parentid =@parentid
--	order by FiscalYear

--	SELECT 'Contractor.ParentContractorNameHistory' as SourceTable
--	  ,[ParentID]
--      ,[FiscalYear]
--      ,[CSISname]
--      ,[LongName]
--      ,[SourceURL]
--      ,[StandardizedTopContractor]
--      ,[MaxOfTopContractorObligated]
--      ,[SumOfTopContractorObligated]
--      ,[CSISmodifiedDate]
--      ,[CSIScreateddate]
--      ,[CSISmodifiedBy]
--  FROM [DIIG].[Contractor].[ParentContractorNameHistory]
--  	where parentid like ('%'+@parentid+'%') or parentid =@parentid 
--		or csisname= @parentid or csisname like ('%'+@parentid+'%')
--order by FiscalYear

END






















GO
