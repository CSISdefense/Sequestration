USE [DIIG]
GO
/****** Object:  StoredProcedure [Vendor].[sp_CreateParentIDstandardizedVendorName]    Script Date: 3/16/2017 12:26:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












-- =============================================
-- Author:		Greg Sanders
-- Create date: 2013-03-13
-- Description:	Assign a parent ID to all entries with a certain name for a range of years
-- =============================================
CREATE PROCEDURE [Vendor].[sp_CreateParentIDstandardizedVendorName]
	-- Add the parameters for the stored procedure here
	@standardizedVendorName varchar(255)
	,@parentid nvarchar(255)
	,@startyear int
	,@endyear int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	if @standardizedVendorName is null
		raiserror('The value for @standardizedVendorName shold not be null.',15,1)
	if @parentid is null
		set @parentid=@standardizedvendorname 
	if @startyear is null
		raiserror('The value for @startyear shold not be null. If assigning a single year, @startyear and @endyear should match.',15,1)
	if @endyear is null
		raiserror('The value for @endyear shold not be null. If assigning a single year, @startyear and @endyear should match.',15,1)
	if @endyear<@startyear
		raiserror('The value for @endyear must be greater than or equal to @startyear',15,1)
    -- Insert statements for procedure here
	
INSERT INTO [Contractor].[ParentContractor]
           ([ParentID]
           ,[Ticker]
           ,[ShortName]
           ,BloombergID
           ,[DIIGIndex]
           ,[LargeGreaterThan1B]
           ,[LargeGreaterThan3B]
           ,[PMC]
           ,[HRFprivatemilitary]
           ,[SIGIRprivemilitary]
           ,[SIGIRDuns]
           ,[Subsidiary]
           ,[MergerYear]
		   ,HooverID
		   ,LexisNexisID
           ,[RevenueInMillions]
           ,[RevenueYear]
           ,[RevenueSourceLink]
           ,[Replace]
           ,[JointVenture]
           ,[LastYear]
           ,[FirstYear]
           ,[SizeGuess]
           ,[NumberOfYears]
           ,[DACIM]
           ,[UnknownCompany]
           ,[FPDSannualRevenue]
           ,[Top100Federal]
           ,[AlwaysDisplay]
           ,[Owners]
           ,[MergerDate]
           ,[MergerURL]
           ,[FirstDate]
           ,[FirstURl]
           ,[SpunOffFrom]
           ,[Top6]
		   ,isInNeedOfInvestigation)
     VALUES
           (@parentid
           ,NULL --<Ticker, nvarchar(255),>
           ,NULL --<ShortName, nvarchar(255),>
           ,NULL --<BloombergID, nvarchar(255),>
           ,0 --<DIIGIndex, bit,>
           ,0--<LargeGreaterThan1B, bit,>
           ,0 --<LargeGreaterThan3B, bit,>
           ,0 --<PMC, bit,>
           ,0--<HRFprivatemilitary, bit,>
           ,0--<SIGIRprivemilitary, bit,>
           ,0--<SIGIRDuns, bit,>
           ,0--<Subsidiary, bit,>
           ,NULL --<MergerYear, int,>
		   ,NULL --<HooverID, nvarchar(255),>
		   ,NULL --<LexisNexisID, nvarchar(255),>
           ,NULL --<RevenueInMillions, decimal(19,4),>
           ,NULL --<RevenueYear, int,>
           ,NULL --<RevenueSourceLink, nvarchar(255),>
           ,NULL --<Replace, nvarchar(255),>
           ,0--<JointVenture, bit,>
           ,NULL --<LastYear, int,>
           ,NULL --<FirstYear, int,>
           ,0--<LargeGuess, bit,>
           ,NULL --<NumberOfYears, int,>
           ,0--<DACIM, bit,>
           ,0--<UnknownCompany, bit,>
           ,NULL --<FPDSannualRevenue, int,>
           ,0--<Top100Federal, bit,>
           ,0--<AlwaysDisplay, bit,>
           ,NULL --<Owners, nvarchar(255),>
           ,NULL --<MergerDate, datetime,>
           ,NULL --<MergerURL, nvarchar(255),>
           ,NULL --<FirstDate, datetime,>
           ,NULL --<FirstURl, nvarchar(255),>
           ,NULL --<SpunOffFrom, nvarchar(255),>
           ,0--<Top6, bit,>
		   ,1 -- isInNeedOfInvestigation)
		   )



	update contractor.DunsnumberToParentContractorHistory
	set parentid=@parentid
	,CSISmodifiedBy=system_user
	,csismodifieddate=getdate()
	where StandardizedTopContractor=@standardizedVendorName and
		fiscalyear>=@startyear and
		fiscalyear<=@endyear

--DECLARE	@return_value int

--EXEC	@return_value = vendor.[sp_AssignParentID]
--		@dunsnumber ,
--		@parentid ,
--		@startyear ,
--		@endyear 

END













GO
