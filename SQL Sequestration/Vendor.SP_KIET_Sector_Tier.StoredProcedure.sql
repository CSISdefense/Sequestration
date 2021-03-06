USE [DIIG]
GO
/****** Object:  StoredProcedure [Vendor].[SP_KIET_Sector_Tier]    Script Date: 3/16/2017 12:26:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [Vendor].[SP_KIET_Sector_Tier]
	-- Add the parameters for the stored procedure here
	--<@Param1, sysname, @p1> <Datatype_For_Param1, , int> = <Default_Value_For_Param1, , 0>, 
	--<@Param2, sysname, @p2> <Datatype_For_Param2, , int> = <Default_Value_For_Param2, , 0>
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT [fiscal_year]
      ,[ContractingCustomer]
      --,[FundingCustomer]
	  ,pscplatformportfolio
	  ,cpcplatformportfolio
      ,isnull([PlatformPortfolio],'Unlabeled') as PlatformPortfolio
      ,sum([obligatedamount]) as SumOfObligatedAmount
      ,sum([numberofactions]) as SumOfNumberOfActions
	   ,sum(obligated2012dollars) as SumOfObligated2012dollars
  FROM [DIIG].[ProductOrServiceCode].[HistoryBucketClaimantProgramFunder]
  where 'Defense' in ([ContractingCustomer])--,[FundingCustomer])
	group by [fiscal_year]
      ,[ContractingCustomer]
      ,[FundingCustomer]
      ,[PlatformPortfolio]
 ,pscplatformportfolio
	  ,cpcplatformportfolio

	SELECT [fiscal_year]
      ,[Size]
      ,[ContractingCustomer]
      --,[FundingCustomer]
      ,isnull([PlatformPortfolio],'Unlabeled') as PlatformPortfolio
      ,sum([obligatedamount]) as SumOfObligatedAmount
      ,sum([numberofactions]) as SumOfNumberOfActions
	  ,sum(obligated2012dollars) as SumOfObligated2012dollars
  FROM [DIIG].[ProductOrServiceCode].[VendorSizeHistoryBucketPlatformPortfolioFunder]
  where 'Defense' in ([ContractingCustomer])--,[FundingCustomer])
	group by [fiscal_year]
		,size
      ,[ContractingCustomer]
      --,[FundingCustomer]
      ,[PlatformPortfolio]


	 

 SELECT [fiscal_year]
      ,[Query_Run_Date]
      ,[ContractingComponent]
	  ,platformportfolio
	  ,case
		when [CompetitionClassification] in (
			'No Competition (Only One Source Exception)'
			,'No Competition (Only One Source Exception; Overrode blank Fair Opportunity)'
			)
		then 'No Competition (Only One Source Exception)'
		when left([ClassifyNumberOfOffers],9)='Unlabeled' or
			[CompetitionClassification] in (
			'No Competition (Unlabeled Exception)'
			,'No Competition (Unlabeled Exception; Overrode blank Fair Opportunity)'
			)
		then 'Unlabeled'
		when [ClassifyNumberOfOffers] in (
			'No competition'
			,'No competition; Overrode blank Fair Opportunity)'
			)
		then 'No Competition'
		else [ClassifyNumberOfOffers]
		end as SummaryCompetition
      ,[ClassifyNumberOfOffers]
	  	   ,sum([SumOfobligatedAmount]) as SumOfObligatedAmount
      ,sum([SumOfobligatedAmount]) as SumOfNumberOfActions
	   ,sum([sumobligated2012dollars]) as SumOfObligated2012dollars
  FROM [DIIG].[ProductOrServiceCode].[CompetitionHistoryPlatformPortfolioFunderClassification] comp
    where 'Defense' in ([ContractingComponent])--,[FundingCustomer])
	group by 
		[fiscal_year]
      ,[Query_Run_Date]
      ,[ContractingComponent]
      ,[FundingComponent]
      ,[CompetitionClassification]
      ,[ClassifyNumberOfOffers]
	  ,platformportfolio
	,case
		when [CompetitionClassification] in (
			'No Competition (Only One Source Exception)'
			,'No Competition (Only One Source Exception; Overrode blank Fair Opportunity)'
			)
		then 'No Competition (Only One Source Exception)'
		when left([ClassifyNumberOfOffers],9)='Unlabeled' or
			[CompetitionClassification] in (
			'No Competition (Unlabeled Exception)'
			,'No Competition (Unlabeled Exception; Overrode blank Fair Opportunity)'
			)
		then 'Unlabeled'
		when [ClassifyNumberOfOffers] in (
			'No competition'
			,'No competition; Overrode blank Fair Opportunity)'
			)
		then 'No Competition'
		else [ClassifyNumberOfOffers]
		end

END

GO
